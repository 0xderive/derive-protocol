//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./proxy/Label.sol";
import "./resolver/Collection.sol";

interface IOwnable {
    function transferOwnership(address newOwner) external;
}

contract Main {


    mapping(string => address) private _proxies;
    address private _coll;

    constructor() {
        _coll = address(new Collection());
    }


    /**
    @notice Creates a label proxy and sets the owner to calling address
    @param id_ a string identification for the label
    */
    function createLabel(
        string memory id_
    ) public {
        
        require(!labelExists(id_), 'Label with that id already exists');

        Label p_ = new Label(_coll);
        address pa_ = address(p_);
        IOwnable(pa_).transferOwnership(msg.sender);
        _proxies[id_] = pa_;

    }


    /**
    @notice Get the proxy address for label with id_
    @param id_ a string identification for the label
    @return address of the proxy;
    */
    function getLabelProxy(
        string memory id_
    ) public view returns(address){
        require(labelExists(id_), 'Label does not exist');
        return _proxies[id_];
    }

    /**
    @notice Determine wether a label proxy exists or not
    @param id_ a string identification for the label
    @return true if exists, false if not
    */
    function labelExists(
        string memory id_
    ) public view returns(bool){
        return !(_proxies[id_] == address(0));
    }


}
