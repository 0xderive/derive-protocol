//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./../utils/base64.sol";
import "./../Aux.sol";

interface IAuxArtwork is IAux {

  function getArtwork(uint edition_id_, bool base64_) external view returns(string memory);
  function setArtwork(uint edition_id_, string memory artwork_) external;

}


////////////////////////////////////
//                                //
//           ARTWORK v1           //
//                                //
////////////////////////////////////



/**
@dev Default artwork contract for editions
*/

contract AuxArtwork is Ownable, Aux {

  /// @dev artwork mapping. (edition id => artwork string)
  mapping(uint => string) private _artworks;

  /// @dev Get the artwork string for a given release
  /// @param edition_id_ The id of the edition in the main contract
  /// @param base64_ Boolean determining wether to base64 encode the output string
  /// @return String containing the artwork url
  function getArtwork(
    uint edition_id_,
    bool base64_
  )
  public view returns (string memory) {
    string memory artwork_ = _artworks[edition_id_];
    if(base64_)
      artwork_ = Base64.encode(bytes(artwork_));
    return artwork_;
  }

  /// @dev Allows the caller to set the artwork string for a given edition. Only settable once.
  /// @param edition_id_ the edition to update
  /// @param artwork_ A string with the artwork
  function setArtwork(
    uint edition_id_,
    string memory artwork_
  )
  public onlyOwner {
    require(bytes(_artworks[edition_id_]).length < 1, 'Artwork already set');
    _artworks[edition_id_] = artwork_;
  }

}
