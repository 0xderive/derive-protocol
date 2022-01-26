//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./../utils/base64.sol";

import "./../Collection.sol";
import "./../Aux.sol";
import "./../Catalogue.sol";
import "./AuxArtwork.sol";



interface IAuxMeta {

  function getMeta(uint edition_id_, bool base64_) external view returns(string memory);

}


////////////////////////////////////
//                                //
//            META v1             //
//                                //
////////////////////////////////////


/// @title Default edition metadata - v1
/// @notice Generates metadata for editions
/// @dev Uses collection and artwork contract to produce metadata including json encoded meta
contract AuxMeta is Aux {

  string private constant AUX_NAME = 'meta';
  bool private constant AUX_CLONE = true;

  string[] private _hooks = ['getURI'];

  constructor(){
    registerHooks(_hooks);
  }


  function getAuxName() public pure returns(string memory){
    return 'meta v1';
  }

  function getURI(
    string memory uri_,
    uint edition_id_
  )
  public view returns(string memory) {

    ICollection coll_ = ICollection(msg.sender);
    ICatalogue cat_ = ICatalogue(coll_.getCatalogueAddress());
    ICollection.Edition memory edition_ = coll_.getEdition(edition_id_);

    string memory items_json_ = "{";
    for (uint256 i = 0; i < edition_.items.length; i++) {
      items_json_ = string(abi.encodePacked(items_json_, cat_.getItemJSON(edition_.items[i]), (i < edition_.items.length ? ',' : '}')));
      i++;
    }

    uri_ = string(abi.encodePacked(
      '{',
        '"name": "', edition_.name,'",',
        '"items": ', items_json_,''
      '}'
    ));

    return Base64.encode(bytes(uri_));

  }

}