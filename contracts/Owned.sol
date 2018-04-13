pragma solidity ^0.4.21;

// ----------------------------------------------------------------------------
// GEL contract ownership
//
//
// Enjoy. (c) ANX International and BokkyPooBah / Bok Consulting Pty Ltd 2017.
// The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {

    // ------------------------------------------------------------------------
    // Current super owner, and proposed new super owner
    // ------------------------------------------------------------------------
    address public superOwner;
    address public newSuperOwner;

    // ------------------------------------------------------------------------
    // Mapping of the owners
    // ------------------------------------------------------------------------
    mapping(address => bool) public owners;

    // ------------------------------------------------------------------------
    // Constructor - assign creator as the super owner
    // ------------------------------------------------------------------------
    function Owned() public {
        superOwner = msg.sender;
    }


    // ------------------------------------------------------------------------
    // Modifier to mark that a function can only be executed by the super owner
    // ------------------------------------------------------------------------
    modifier onlySuperOwner {
        require(msg.sender == superOwner);
        _;
    }


    // ------------------------------------------------------------------------
    // Modifier to mark that a function can only be executed by owners
    // ------------------------------------------------------------------------
    modifier onlyOwner {
        require(owners[msg.sender] == true);
        _;
    }


    // ------------------------------------------------------------------------
    // Super owner can initiate transfer of contract to a new super owner
    // ------------------------------------------------------------------------
    function transferOwnership(address _newSuperOwner) public onlySuperOwner {
        newSuperOwner = _newSuperOwner;
    }


    // ------------------------------------------------------------------------
    // Super Owner can add owners
    // ------------------------------------------------------------------------
    function addOwner(address _newOwner) public onlySuperOwner {
        owners[_newOwner] = true;
        emit OwnerAdded(_newOwner);
    }

    event OwnerAdded(address indexed _owner);


    // ------------------------------------------------------------------------
    // Super Owner can remove owners
    // ------------------------------------------------------------------------
    function removeOwner(address _removeOwner) public onlySuperOwner {
        owners[_removeOwner] = false;
        emit OwnerRemoved(_removeOwner);
    }

    event OwnerRemoved(address indexed _owner);


    // ------------------------------------------------------------------------
    // Check if address is an owner
    // ------------------------------------------------------------------------
    function isOwner(address _owner) public view returns (bool success) {
        return owners[_owner];
    }


    // ------------------------------------------------------------------------
    // New owner has to accept transfer of contract
    // ------------------------------------------------------------------------
    function acceptOwnership() public {
        require(msg.sender == newSuperOwner);
        superOwner = newSuperOwner;
        emit OwnershipTransferred(superOwner, newSuperOwner);
    }

    event OwnershipTransferred(address indexed _from, address indexed _to);
}