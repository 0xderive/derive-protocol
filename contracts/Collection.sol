//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./ICollection.sol";
import "./storage/ICatalogue.sol";
import "./storage/IArtwork.sol";
import "./storage/IMeta.sol";

contract Collection is ERC1155, ERC1155Supply, AccessControl {

    bool _init = false;

    ICatalogue private _cat;
    IArtwork private _art;
    IMeta private _meta;

    uint private _edition_ids;
    mapping(uint => ICollection.Edition) private _editions;

    string private _coll_id = 'hello';

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
        _cat.init(for_);
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

    function setCatalogue(address cat_) public onlyRole(MANAGER_ROLE){
        _cat = ICatalogue(cat_);
    }

    function setArtwork(address art_) public onlyRole(MANAGER_ROLE){
        _art = IArtwork(art_);
    }
    function setMeta(address meta_) public onlyRole(MANAGER_ROLE){
        _meta = IMeta(meta_);
    }



    ////////////////////////////////////////////////////
    /// RELEASES
    ////////////////////////////////////////////////////

    function createEdition(ICollection.EditionInput memory edition_) public onlyRole(MANAGER_ROLE) {

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

    function setEditionName(uint id_, string memory name_) public onlyRole(MANAGER_ROLE) {
        require(!isFinalised(id_), 'Edition is finalised');
        _editions[id_].name = name_;
    }


    function isFinalised(uint id_) public returns(bool){
        return _editions[id_].finalised;
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