//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ICatalogue.sol";

/**
@title Polly - on-chain catalogue for digital assets
*/

contract Catalogue is AccessControl {

    using Counters for Counters.Counter;

    bool _didInit = false;

    /// @dev item id incrementer
    Counters.Counter private _ids;
    Counters.Counter private _coll_ids;

    /// @dev MANAGER_ROLE allow addresses to add items to the catalogue
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @dev Item mappings
    mapping(uint => ICatalogue.Item) private _items; /// @dev item_id => ICatalogue.item struct
    mapping(uint => mapping(uint => ICatalogue.Source)) private _sources; /// @dev item_id => ICatalogue.Source struct
    mapping(uint => Counters.Counter) private _sources_count; /// @dev item_id => number of sources for item
    mapping(uint => mapping(string => string)) private _meta; /// @dev item_id => (key => value)

    /// @dev collection mappings
    mapping(uint => ICatalogue.Collection) private _colls;
    mapping(uint => mapping(uint => uint)) private _coll_tracks;
    mapping(uint => Counters.Counter) private _coll_items_count;

    /// @dev Maps like item_id => role => address => granted; 
    mapping(uint => mapping(string => mapping(address => bool))) private _item_roles; /// @dev item_id => (role => (address => granted))

    // EVENTS
    event itemCreated(uint indexed _id, address indexed _by);
    event sourceAdded(uint indexed _id, ICatalogue.Source indexed _source);
    event metaUpdated(string indexed _key, string indexed value);
    event metaDeleted(string indexed _key, string indexed value);

    // Constructor
    constructor(){
      _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
      _setupRole(MANAGER_ROLE, msg.sender);
    }

    /**
    *****
    ITEMS
    *****
    */

    /**
    @dev internal function to create new item for a given address
     */
    function _createItemFor(ICatalogue.Item memory item_, address for_) private returns(uint){
      
      _ids.increment();
      uint item_id_ = _ids.current();

      _items[item_id_] = item_;
      _grantAllItemRoles(for_, item_id_);

      emit itemCreated(item_id_, for_);
      return item_id_;

    }


    /**
    @dev Creates a item entry in _items from the ICatalogue.Item Item struct passed in
    via item_. Sets the current sender as admin of the item.
    */
    function createItem(ICatalogue.Item memory item_) public returns(uint){
      return _createItemFor(item_, msg.sender);
    }

    /**
    @dev Creates a item entry in _items from the ICatalogue.Item Item struct passed in
    via item_ and adds sources and meta to it. Sets the current sender as admin of the item.
    */
    function createItemWithSourcesAndMeta(ICatalogue.Item memory item_, string[] memory sources_, ICatalogue.Meta[] memory meta_) public onlyRole(MANAGER_ROLE) returns(uint) {

      uint item_id_ = _createItemFor(item_, msg.sender);

      for (uint256 i = 0; i < sources_.length; i++) {
        _addSource(item_id_, ICatalogue.Source(msg.sender, sources_[i]));
      }

      for (uint256 i = 0; i < meta_.length; i++) {
        _updateMeta(item_id_, meta_[i].key, meta_[i].value);
      }

      return item_id_;

    }
    
    /// @dev check if an item exists
    function itemExists(uint item_id_) public view returns(bool){
      return (item_id_ > 0 && item_id_ <= _ids.current());
    }

    /// @dev retrieves a given item based on item_id_
    function getItem(uint item_id_) public view returns (ICatalogue.Item memory) {
      require(itemExists(item_id_), "Invalid item");
      return _items[item_id_];
    }

    /// @dev retrieves a set of items based on item_ids_ array of uints
    function getItems(uint[] memory item_ids_) public view returns (ICatalogue.Item[] memory) {
      
      ICatalogue.Item[] memory items_;
      for (uint i = 0; i < item_ids_.length; i++) {
        items_[i] = getItem(item_ids_[i]);
      }
      return items_;
      
    }


    /// @dev helper function that produces a JSON object for a given item
    function getItemJSON(uint item_id_) public view returns(string memory){

      ICatalogue.Item memory item_ = getItem(item_id_);
      ICatalogue.Source memory source_;
      uint source_count_ = getSourceCount(item_id_);
      string memory source_string_;
      uint i = 1;
      while(i <= source_count_) {
        source_ = getSource(item_id_, i);
        source_string_ = string(abi.encodePacked(source_string_, '"', source_.source,'"', (i < source_count_ ? ',' : '')));
        i++;
      }

      return string(abi.encodePacked('{', '"name":"', item_.name, '", "creator": "',item_.creator,'", "checksum": "',item_.checksum,'", "sources": [',source_string_,']}'));

    }


    /**
    ***********
    COLLECTIONS
    ***********
    */

    function createCollection(ICatalogue.Collection memory coll_, ICatalogue.ItemInput[] memory items_) public onlyRole(MANAGER_ROLE) returns(uint) {
      
      _coll_ids.increment();
      uint coll_id_ = _coll_ids.current();
      uint work_id_;
      
      for (uint i = 0; i < items_.length; i++) {
        
        work_id_ = createItem(ICatalogue.Item(
          items_[i].title,
          items_[i].artist,
          items_[i].checksum
        ));
        
        addSource(work_id_, items_[i].source);
        _coll_tracks[coll_id_][i+1] = work_id_;
        _coll_items_count[coll_id_].increment();

      }

      _colls[coll_id_] = coll_;

      return coll_id_;

    }

    function getCollection(uint coll_id_) public view returns(ICatalogue.Collection memory){
      return _colls[coll_id_];
    }

    function getTotalCollections() public view returns(uint){
      return _coll_ids.current();
    }

    function getItemCount(uint coll_id_) public view returns(uint){
      return _coll_items_count[coll_id_].current();
    }


    /**
    **********
    ITEM ROLES
    **********
    */
    
    function _grantAllItemRoles(address to_, uint item_id_) private {
      grantItemRole(to_, item_id_, 'add_sources');
      grantItemRole(to_, item_id_, 'update_meta');
    }

    function grantItemRole(address check_, uint item_id_, string memory role_) public {
      _item_roles[item_id_][role_][check_] = true;
    }

    function revokeItemRole(address check_, uint item_id_, string memory role_) public {
      delete(_item_roles[item_id_][role_][check_]);
    }

    function hasItemRole(address check_, uint item_id_, string memory role_) public view returns(bool){
      return _item_roles[item_id_][role_][check_];
    }


    /**
    *******
    SOURCES
    *******
    */


    function getSourceCount(uint item_id_) public view returns(uint){
      return _sources_count[item_id_].current();
    }

    function getSource(uint item_id_, uint source_no_) public view returns(ICatalogue.Source memory){
      return _sources[item_id_][source_no_];
    }


    function _addSource(uint item_id_, ICatalogue.Source memory source_) private {
      _sources_count[item_id_].increment();
      _sources[item_id_][_sources_count[item_id_].current()] = source_;
      emit sourceAdded(item_id_, source_);
    }

    function addSource(uint item_id_, string memory source_) public {
      require(itemExists(item_id_), "Invalid item");
      require(hasItemRole(msg.sender, item_id_, 'add_sources'), "Missing item role");
      _addSource(item_id_, ICatalogue.Source(msg.sender, source_));
    }

    function addSources(uint item_id_, string[] memory sources_) public {
      require(itemExists(item_id_), "Invalid item");
      require(hasItemRole(msg.sender, item_id_, 'add_sources'), "Missing item role");
      for (uint256 i = 0; i < sources_.length; i++) {
        _addSource(item_id_, ICatalogue.Source(msg.sender, sources_[i]));
      }
    }


    /**
    ****
    META
    ****
    */

    /// @dev private function to update meta for item_id_
    function _updateMeta(uint item_id_, string memory key_, string memory value_) private {
      _meta[item_id_][key_] = value_;
      emit metaUpdated(key_, value_);
    }

    /// @dev update meta for item_id_
    function updateMeta(uint item_id_, ICatalogue.Meta[] memory meta_) public {
      require(itemExists(item_id_), "Invalid item");
      require(hasItemRole(msg.sender, item_id_, 'update_meta'), "Missing item role");

      for(uint256 i = 0; i < meta_.length; i++) {
        _updateMeta(item_id_, meta_[i].key, meta_[i].value);
      }

    }

    /// @dev get meta for item_id_
    function getMeta(uint item_id_, string memory key_) public view returns(string memory) {
      require(itemExists(item_id_), "Invalid item");
      return _meta[item_id_][key_];
    }

    /// @dev private _delete meta for item_id_
    function _deleteMeta(uint item_id_, string memory key_) private {
      string memory value_ = _meta[item_id_][key_];
      delete(_meta[item_id_][key_]);
      emit metaDeleted(key_, value_);
    }

    /// @dev delete meta for item_id_
    function deleteMeta(uint item_id_, string[] memory keys_) public {
      require(itemExists(item_id_), "Invalid item");
      require(hasItemRole(msg.sender, item_id_, 'update_meta'), "Missing item role");
      for (uint256 i = 0; i < keys_.length; i++) {
        _deleteMeta(item_id_, keys_[i]);
      }
    }


    /**
    ********
    MANAGERS
    ********
    */

    /// @dev grant manager role
    function addManager(address add_) public onlyRole(DEFAULT_ADMIN_ROLE){
      grantRole(MANAGER_ROLE, add_);
    }

    function removeManager(address remove_) public onlyRole(DEFAULT_ADMIN_ROLE){
      revokeRole(MANAGER_ROLE, remove_);
    }

    function isManager(address check_) public view returns(bool){
      return hasRole(MANAGER_ROLE, check_);
    }


}
