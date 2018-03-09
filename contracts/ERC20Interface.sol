pragma solidity ^0.4.15;

// ----------------------------------------------------------------------------
// GEL 'GEL Token' contract - ERC20 Token Interface
//
//
// Enjoy. (c) ANX International and BokkyPooBah / Bok Consulting Pty Ltd 2017.
// The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
// ----------------------------------------------------------------------------
contract ERC20Interface {
    uint public totalSupply;
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) 
        returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant 
        returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, 
        uint _value);
}