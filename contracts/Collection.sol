//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./Catalogue.sol";
import "./Aux.sol";
import "./AuxHandler.sol";

import "hardhat/console.sol";

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

    function init(address for_, string memory id_, address cat_, address aux_handler_, address[] memory aux_) external;
    function setCatalogueAddress(address meta_) external;
    function getCatalogueAddress() external view returns(address);

    function createEdition() external;
    function getEdition(uint edition_id_) external view returns(Edition memory);
    function addItems() external;
    function removeItem() external;
    function finalize() external;
    function release() external;


    function addAux(address aux_) external;

}


contract Collection is ERC1155, ERC1155Supply, AccessControl {

    bool _init = false;

    ICatalogue private _cat;
    IAuxHandler private _aux_handler;

    mapping(string => address) private _hooks;

    uint private _edition_ids;
    mapping(uint => ICollection.Edition) private _editions;

    string private _coll_id = '';

    /// @dev MANAGER_ROLE allow addresses to use the label contract
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor() ERC1155("") {
        // _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _grantRole(MANAGER_ROLE, msg.sender);
    }

    function init(address for_, string memory id_, address cat_, address aux_handler_, address[] memory aux_) public {

        require(!_init, 'Cannot init twice');

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);

        _coll_id = id_;

        _cat = ICatalogue(cat_);
        _cat.init();
        _cat.grantRole(keccak256("DEFAULT_ADMIN_ROLE"), for_);
        _cat.grantRole(keccak256("MANAGER_ROLE"), for_);

        _aux_handler = IAuxHandler(aux_handler_);
        _aux_handler.init();
        _aux_handler.grantRole(keccak256("DEFAULT_ADMIN_ROLE"), for_);
        _aux_handler.grantRole(keccak256("MANAGER_ROLE"), for_);

        _grantRole(DEFAULT_ADMIN_ROLE, for_);
        _grantRole(MANAGER_ROLE, for_);

        for(uint256 i = 0; i < aux_.length; i++) {
          _aux_handler.addAux(aux_[i]);
        }

        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _revokeRole(MANAGER_ROLE, msg.sender);


        _init = true;


    }

    function getId() public view returns(string memory){
        return _coll_id;
    }

    ////////////////////////////////////////////////////
    /// EDITIONS
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


    function uri(uint edition_id_) public view override returns(string memory uri_){

      IAux[] memory hooks_ = _aux_handler.getAuxForHook('getURI');
      for(uint256 i = 0; i < hooks_.length; i++) {
        uri_ = hooks_[i].getURI(uri_, edition_id_);
      }

      return uri_;

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
