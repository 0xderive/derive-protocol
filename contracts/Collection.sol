//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./aux/Catalogue.sol";
import "./aux/Artwork.sol";
import "./aux/Meta.sol";
import "./aux/Hooks.sol";




interface ICollection {

    struct Edition {
        uint id;
        string name;
        string creator;
        string license;
        bool released;
        bool finalised;
        uint price;
        uint supply;
        address recipient;
        address meta_address;
        address artwork_address;
        uint[] items;
    }

    struct EditionInput {
        string name;
        string creator;
        string license;
        bool released;
        bool finalised;
        uint price;
        uint supply;
        address recipient;
        address meta_address;
        address artwork_address;
        ICatalogue.ItemInput[] items;
    }

    function init(address for_, string memory id_, address cat_, address art_, address meta_) external;
    function setCatalogueAddress(address meta_) external;
    function getCatalogueAddress() external view returns(address);
    function setArtworkAddress(address meta_) external;
    function getArtworkAddress() external view returns(address);
    function setMetaAddress(address meta_) external;
    function getMetaAddress() external view returns(address);

    function createEdition() external;
    function getEdition(uint edition_id_) external view returns(Edition memory);
    function addItems() external;
    function removeItem() external;
    function finalize() external;
    function release() external;

}




contract Collection is ERC1155, ERC1155Supply, AccessControl {

    bool _init = false;

    ICatalogue private _cat;
    IArtwork private _art;
    IMeta private _meta;
    IHooks private _hooks;

    uint private _edition_ids;
    mapping(uint => ICollection.Edition) private _editions;

    string private _coll_id = '';

    /// @dev MANAGER_ROLE allow addresses to use the label contract
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);
    }

    function init(address for_, string memory id_, address cat_, address art_, address meta_) public {

        require(!_init, 'Cannot init twice');

        _coll_id = id_;

        _cat = ICatalogue(cat_);
        _cat.init();
        _cat.grantRole(keccak256("DEFAULT_ADMIN_ROLE"), for_);
        _cat.grantRole(keccak256("MANAGER_ROLE"), for_);

        _art = IArtwork(art_);
        _meta = IMeta(meta_);

        _grantRole(DEFAULT_ADMIN_ROLE, for_);
        _grantRole(MANAGER_ROLE, for_);

        _init = true;


    }

    function getId() public view returns(string memory){
        return _coll_id;
    }

    function setCatalogueAddress(address cat_) public onlyRole(MANAGER_ROLE){
        _cat = ICatalogue(cat_);
    }

    function getCatalogueAddress() public view returns(address){
      return address(_cat);
    }

    function setArtworkAddress(address art_) public onlyRole(MANAGER_ROLE){
        _art = IArtwork(art_);
    }

    function getArtworkAddress() public view returns(address){
      return address(_art);
    }


    function setMetaAddress(address meta_) public onlyRole(MANAGER_ROLE){
      _meta = IMeta(meta_);
    }

    function getMetaAddress() public view returns(address){
      return address(_meta);
    }

    function setHooksAddress(address hooks_) public onlyRole(MANAGER_ROLE){
      _hooks = IHooks(hooks_);
    }

    function getHooksAddress() public view returns(address){
      return address(_hooks);
    }





    ////////////////////////////////////////////////////
    /// RELEASES
    ////////////////////////////////////////////////////

    function createEdition(
      ICollection.EditionInput memory edition_
    )
    public onlyRole(MANAGER_ROLE) {

        uint[] memory items_;
        uint item_id_;
        for(uint256 i = 0; i < edition_.items.length; i++) {
            item_id_ = _cat.createItem(edition_.items[i]);
        }

        _edition_ids++;
        _editions[_edition_ids] = ICollection.Edition(
            _edition_ids,
            edition_.name,
            edition_.creator,
            edition_.license,
            edition_.released,
            edition_.finalised,
            edition_.price,
            edition_.supply,
            edition_.recipient,
            edition_.meta_address,
            edition_.artwork_address,
            items_
        );

    }

    function setEditionName(
      uint edition_id_,
      string memory name_
    )
    public onlyRole(MANAGER_ROLE) {
      _hooks.beforeSetEditionName(edition_id_, msg.sender);
      // require(canSetEditionName(edition_id_, name_, msg.sender));
      _editions[edition_id_].name = name_;
    }

    function getEdition(
      uint edition_id_
    )
    public view returns(ICollection.Edition memory) {
      return _editions[edition_id_];
    }

    function isFinalised(
      uint edition_id_
    ) public view returns(bool){
        return _editions[edition_id_].finalised;
    }

    function isReleased(
      uint edition_id_
    ) public view returns(bool){
        return _editions[edition_id_].released;
    }


    function mint(
      uint edition_id_
    )
    public payable {

      // require(canMint(msg.sender, edition_id_), 'INVALID_ADDRESS');
      // require(_editions[edition_id_].released, "INVALID_RELEASE");
      // require(msg.value ==  _editions[edition_id_].price, "INVALID_PRICE");
      // require((getAvailable(edition_id_) > 0), "NOT_AVAILABLE");

      (bool sent, bytes memory data) =  _editions[edition_id_].recipient.call{value: msg.value}("");
      require(sent, "Failed to send Ether");

      _mintFor(msg.sender, edition_id_);
      // _last_mint[msg.sender][edition_id_] = block.timestamp;

    }


    function _mintFor(
      address for_,
      uint edition_id_
    ) private {
      _mint(for_, edition_id_, 1, "");
    }


    // Overrides
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    internal
    virtual
    override (ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
    public
    view
    override(ERC1155, AccessControl)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


}
