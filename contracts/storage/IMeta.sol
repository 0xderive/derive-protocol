//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IMeta {

  function getMeta(uint edition_id_, bool base64_) external view returns(string memory);

}
