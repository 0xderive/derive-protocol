//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/access/IAccessControl.sol";

interface ICatalogue is IAccessControl {

  struct Source {
    address provider;
    string source;
  }

  struct Item {
    string name;
    string creator;
    string checksum;
  }

  struct ItemInput {
    string name;
    string creator;
    string checksum;
    string[] sources;
  }

  struct Meta {
    string key;
    string value;
  }

  function init(address for_) external;

  // Items
  function getItem(uint item_id_) external view returns(Item memory);
  function getItems(uint[] memory item_ids_) external view returns(Item[] memory);
  function createItem(ItemInput memory item_) external returns(uint);
  function getItemJSON(uint item_id_) external view returns(string memory);

  // Sources
  function getSourceCount(uint item_id_) external view returns(uint);
  function getSource(uint item_id_, uint source_no_) external view returns(Source memory);
  function addSource(uint item_id_, string memory source) external;
  function addSources(uint item_id_, string[] memory source) external;

}
