//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./../Collection.sol";

interface IHooks {

  function beforeCreateEdition(
    ICollection.EditionInput memory edition_,
    address sender
  ) external;

  function beforeSetEditionName(
    uint edition_id_,
    address sender
  ) external;

}

contract Hooks {

  function beforeSetEditionName(
    uint edition_id_,
    string memory name_,
    address sender_
  ) public {

    ICollection coll_ = ICollection(msg.sender);
    ICollection.Edition memory edition_ = coll_.getEdition(edition_id_);

  }

}
