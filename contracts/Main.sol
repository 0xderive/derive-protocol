//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./Collection.sol";
import "./Catalogue.sol";
import "./Aux.sol";

interface IOwnable {
    function transferOwnership(address newOwner) external;
}

contract Main {

    struct Proxy {
        address coll;
        address cat;
        address aux_handler;
    }

    mapping(string => Proxy) private _proxies;
    mapping(address => string) private _proxy_ids;
    address private _coll;
    address private _cat;
    address private _aux_handler;

    constructor() {

        _coll = address(new Collection());
        _cat = address(new Catalogue());
        _aux_handler = address(new AuxHandler());

    }

    /**
    ************
    ** LABELS **
    ************
    */

    /// @notice Creates a collection proxy and sets the owner to calling address
    /// @param id_ a string identification for the collection

    function createCollection(
        string memory id_,
        address[] memory aux_
    ) public {

        require(!collectionExists(id_), 'Collection with that id already exists');

        Proxy memory proxy_ = Proxy(
            Clones.clone(_coll),
            Clones.clone(_cat),
            Clones.clone(_aux_handler)
        );

        ICollection(proxy_.coll).init(msg.sender, id_, proxy_.cat, proxy_.aux_handler, aux_);

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
