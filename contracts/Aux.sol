//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface IAux {

  struct AuxResult{
    string name;
    address location;
  }

  function getAuxName() external view returns(string memory);

  // Filter functions
  function getURI(string memory uri_, uint edition_id_) external view returns(string memory);
  function getArtwork(string memory artwork_, uint edition_id_) external returns(string memory);

  function setMaxSupply(uint edition_id_, uint supply_) external;
  function getMaxSupply(uint edition_id_) external view returns(uint);

  function setPrice(uint edition_id_, uint price_) external;
  function getPrice(uint edition_id_) external view returns(uint);

  function setRecipient(uint edition_id_, address recipient_) external;
  function getRecipient(uint edition_id_) external view returns(address);

  function isReleased(uint edition_id_) external view returns(bool);
  function isFinalized(uint edition_id_) external view returns(bool);

  function registerHooks(string[] memory hooks_) external;
  function getHooks() external returns(string[] memory);
  function hasHook(string memory hook_) external view returns(bool);

}


abstract contract Aux {

  string[] private _hooks;
  mapping(string => bool) private _hook_names;

  function registerHooks(string[] memory hooks_) public {
    _hooks = hooks_;
    for (uint256 i = 0; i < hooks_.length; i++) {
      _hook_names[hooks_[i]] = true;
    }
  }

  function getHooks() public view returns(string[] memory){
    return _hooks;
  }

  function hasHook(string memory hook_) public view returns(bool){
    return _hook_names[hook_];
  }


}
