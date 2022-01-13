//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./storage/ICatalogue.sol";

interface ICollection {
    
    struct Edition {
        uint id;
        string name;
        string creator;
        string license;
        bool released;
        bool finalised;
        uint price;
        uint supply;
        address recipient;
        address meta_address;
        address artwork_address;
        uint[] items;
    }

    struct EditionInput {
        string name;
        string creator;
        string license;
        bool released;
        bool finalised;
        uint price;
        uint supply;
        address recipient;
        address meta_address;
        address artwork_address;
        ICatalogue.ItemInput[] items;
    }

    function init(address for_, string memory id_, address cat_, address art_, address meta_) external;
    function setCatalogue(address meta_) external;
    function setArtwork(address meta_) external;
    function setMeta(address meta_) external;

    function createEdition() external;
    function addItems() external;
    function removeItem() external;
    function finalize() external;
    function release() external;


}