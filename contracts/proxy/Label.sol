//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Label is Proxy, Ownable {

    address private _main;

    constructor(address main_){
        _main = main_;
    }

    function _implementation() internal view override returns(address){
        return _main;
    }

    function setMain(address main_) public onlyOwner {
        _main = main_;
    }

}