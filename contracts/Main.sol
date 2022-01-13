//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./Collection.sol";
import "./ICollection.sol";
import "./storage/Catalogue.sol";
import "./storage/Artwork.sol";
import "./storage/Meta.sol";
import "hardhat/console.sol";

interface IOwnable {
    function transferOwnership(address newOwner) external;
}

contract Main {

    struct Proxy {
        address coll;
        address cat;
        address art;
        address meta;
    }

    mapping(string => Proxy) private _proxies;
    mapping(address => string) private _proxy_ids;
    address private _coll;
    address private _cat;
    address private _art;
    address private _meta;

    constructor() {

        _coll = address(new Collection());
        _cat = address(new Catalogue());
        _art = address(new Artwork());
        _meta = address(new Meta());        
        // ICollection(_coll).init('__base', _cat, _art, _meta);

    }

    /**
    ************
    ** LABELS **
    ************
    */

    /// @notice Creates a collection proxy and sets the owner to calling address
    /// @param id_ a string identification for the collection
    
    function createCollection(
        string memory id_
    ) public {
        
        require(!collectionExists(id_), 'Collection with that id already exists');

        Proxy memory proxy_ = Proxy(
            Clones.clone(_coll),
            Clones.clone(_cat),
            Clones.clone(_art),
            Clones.clone(_meta)
        );

        ICollection(proxy_.coll).init(msg.sender, id_, proxy_.cat, proxy_.art, proxy_.meta);

        _proxies[id_] = proxy_;

    }

    /// @notice Get the proxy address for collection with id_
    /// @param id_ a string identification for the collection
    /// @return address of the proxy;
    
    function getCollectionProxy(
        string memory id_
    ) public view returns(Proxy memory){
        require(collectionExists(id_), 'Collection does not exist');
        return _proxies[id_];
    }

    
    /// @notice Determine wether a collection proxy exists or not
    /// @param id_ a string identification for the collection
    /// @return true if exists, false if not

    function collectionExists(
        string memory id_
    ) public view returns(bool){
        return !(_proxies[id_].coll == address(0));
    }


    // transferCollectionOwnership(address)


}
