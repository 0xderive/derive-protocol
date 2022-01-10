//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IArtwork {

    function getArtwork(uint edition_id_, bool base64_) external view returns(string memory);
    
}