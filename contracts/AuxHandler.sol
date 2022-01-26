//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Aux.sol";
import "hardhat/console.sol";

interface IAuxHandler is IAccessControl {
  function init() external;
  function addAux(address aux_address_) external;
  function removeAux(address remove_) external;
  function setAuxAddress(uint index_, address address_) external;
  function getAuxForHook(string memory name_) external view returns(IAux[] memory);

}


contract AuxHandler is AccessControl {


  bool _didInit = false;

  IAux[] private _aux;
  mapping(address => uint) private _aux_index;

  /// @dev MANAGER_ROLE allow addresses to use the label contract
  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");


  /// @dev Inits contract for a given address
  function init() public {

    require(!_didInit, 'Cannot init twice');

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(MANAGER_ROLE, msg.sender);

    _didInit = true;

  }


  function addAux(address aux_address_) public onlyRole(MANAGER_ROLE) {
    _aux.push(IAux(aux_address_));
    _aux_index[aux_address_] = (_aux.length -1);
  }

  function removeAux(address remove_) public onlyRole(MANAGER_ROLE) {

    IAux[] memory new_aux_;
    uint aux_index_ = _aux_index[remove_];
    uint ii;
    for(uint256 i = 0; i < _aux.length; i++) {
      if(aux_index_ != i){
        new_aux_[ii] = _aux[i];
      }
    }
    _aux = new_aux_;
    delete _aux_index[remove_];

  }

  function setAuxAddress(uint index_, address address_) public onlyRole(MANAGER_ROLE) {
    delete _aux_index[address(_aux[index_])];
    _aux[index_] = IAux(address_);
    _aux_index[address_] = index_;
  }

  function getAuxForHook(string memory name_) public view returns(IAux[] memory){

    uint ii = 0;
    IAux[100] memory aux_temp_;
    for(uint256 i = 0; i < _aux.length; i++){
      if(_aux[i].hasHook(name_)){
        aux_temp_[ii] = _aux[i];
        ii++;
      }
    }

    IAux[] memory aux_ = new IAux[](ii);
    for(uint256 iii = 0; iii < aux_.length; iii++) {
      aux_[iii] = aux_temp_[iii];
    }

    return aux_;

  }

}
