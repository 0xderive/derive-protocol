//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./storage/ICatalogue.sol";

interface ILabel {
    
    struct Release {
        uint coll_id;
        bool released;
        uint price;
        uint supply;
        address meta_address;
        address artwork_address;
    }

    struct ReleaseInput {
        bool released;
        uint price;
        uint supply;
        address recipient_address;
        address meta_address;
        address artwork_address;
        ICatalogue.Collection collection;
        ICatalogue.ItemInput[] items;
    }

    function init(address cat_, address art_, address meta_) external;
    function setCatalogue(address meta_) external;
    function setArtwork(address meta_) external;
    function setMeta(address meta_) external;


}