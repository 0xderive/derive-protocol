//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./ILabel.sol";
import "./storage/ICatalogue.sol";
import "./storage/IArtwork.sol";
import "./storage/IMeta.sol";

contract Label is ERC1155, ERC1155Supply, Ownable {

    bool _init = false;

    ICatalogue private _cat;
    IArtwork private _art;
    IMeta private _meta;

    uint private _release_ids;
    mapping(uint => ILabel.Release) private _releases;

    constructor() ERC1155("") {
    }

    mapping(uint => string) private id_;

    function init(address cat_, address art_, address meta_) public {
        
        require(!_init, 'Cannot init twice');
        
        _cat = ICatalogue(cat_);
        _art = IArtwork(art_);
        _meta = IMeta(meta_);
        
        _init = true;

    }

    function setCatalogue(address cat_) public onlyOwner(){
        _cat = ICatalogue(cat_);
    }

    function setArtwork(address art_) public onlyOwner(){
        _art = IArtwork(art_);
    }
    function setMeta(address meta_) public onlyOwner(){
        _meta = IMeta(meta_);
    }


    function createRelease(ILabel.ReleaseInput memory release_) public {

        uint coll_id_ = _cat.createCollection(release_.collection, release_.items);

        _release_ids++;
        _releases[_release_ids] = ILabel.Release(
            coll_id_,
            release_.released,
            release_.price,
            release_.supply,
            release_.meta_address,
            release_.artwork_address
        );

    }


    // Overrides
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual override (ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

}