//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";


contract Artwork is Ownable {

    mapping(uint => string) private _artworks;
    
    function getArtwork(uint coll_id_, bool base64_) public view returns (string memory) {
    
      string memory artwork_ = _artworks[coll_id_];

      return artwork_;

    }

    function setArtwork(uint coll_id_, string memory artwork_) public returns (string memory){
      require(bytes(_artworks[coll_id_]).length < 1, 'Artwork already set');
      
    }

}
