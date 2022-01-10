//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./Label.sol";
import "./ILabel.sol";
import "./storage/Catalogue.sol";
import "./storage/Artwork.sol";
import "./storage/Meta.sol";
import "hardhat/console.sol";

interface IOwnable {
    function transferOwnership(address newOwner) external;
}

contract Main {

    struct Proxy {
        address label;
        address cat;
        address art;
        address meta;
    }

    mapping(string => Proxy) private _proxies;
    mapping(address => string) private _proxy_ids;
    address private _label;
    address private _cat;
    address private _art;
    address private _meta;

    constructor() {

        _label = address(new Label());
        _cat = address(new Catalogue());
        _art = address(new Artwork());
        _meta = address(new Meta());        
        ILabel(_label).init(_cat, _art, _meta);

    }

    /**
    ************
    ** LABELS **
    ************
    */

    /// @notice Creates a label proxy and sets the owner to calling address
    /// @param id_ a string identification for the label
    
    function createLabel(
        string memory id_
    ) public {
        
        require(!labelExists(id_), 'Label with that id already exists');

        Proxy memory proxy_ = Proxy(
            Clones.clone(_label),
            Clones.clone(_cat),
            Clones.clone(_art),
            Clones.clone(_meta)
        );

        address[] memory catmans_;
        ILabel(proxy_.label).init(proxy_.cat, proxy_.art, proxy_.meta);

        _proxies[id_] = proxy_;

    }

    /// @notice Get the proxy address for label with id_
    /// @param id_ a string identification for the label
    /// @return address of the proxy;
    
    function getLabelProxy(
        string memory id_
    ) public view returns(Proxy memory){
        require(labelExists(id_), 'Label does not exist');
        return _proxies[id_];
    }

    
    /// @notice Determine wether a label proxy exists or not
    /// @param id_ a string identification for the label
    /// @return true if exists, false if not

    function labelExists(
        string memory id_
    ) public view returns(bool){
        return !(_proxies[id_].label == address(0));
    }


    // transferLabelOwnership(address)


}
