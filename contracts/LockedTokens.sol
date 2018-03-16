pragma solidity ^0.4.11;

// ----------------------------------------------------------------------------
// GEL contract locked tokens
//
//
// Enjoy. (c) ANX International and BokkyPooBah / Bok Consulting Pty Ltd 2017.
// The MIT Licence.
// ----------------------------------------------------------------------------

import "./ERC20Interface.sol";
import "./SafeMath.sol";
import "./GELTokenConfig.sol";


// ----------------------------------------------------------------------------
// Contract that holds the locked token information
// ----------------------------------------------------------------------------
contract LockedTokens is GELTokenConfig {
    using SafeMath for uint;

    // ------------------------------------------------------------------------
    // Current totalSupply of locked tokens
    // ------------------------------------------------------------------------
    uint public totalSupplyLocked6M;
    uint public totalSupplyLocked24M;

    // ------------------------------------------------------------------------
    // Locked tokens mapping
    // ------------------------------------------------------------------------
    mapping (address => uint) public balancesLocked6M;
    mapping (address => uint) public balancesLocked24M;

    // ------------------------------------------------------------------------
    // Address of GEL token contract
    // ------------------------------------------------------------------------
    ERC20Interface public tokenContract;
    address public tokenContractAddress;


    // ------------------------------------------------------------------------
    // Constructor - called by token contract
    // ------------------------------------------------------------------------
    function LockedTokens(address _tokenContract) {
        tokenContract = ERC20Interface(_tokenContract);
        tokenContractAddress = _tokenContract;

        // any locked token balances known in advance of contract deployment can be added here
        // add6M(0xaBBa43E7594E3B76afB157989e93c6621497FD4b, 2000000 * DECIMALSFACTOR);
        // add8M(0xAddA9B762A00FF12711113bfDc36958B73d7F915, 2000000 * DECIMALSFACTOR);
        // add12M(0xAddA9B762A00FF12711113bfDc36958B73d7F915, 2000000 * DECIMALSFACTOR);

    }

    // ------------------------------------------------------------------------
    // Modifier to mark that a function can only be executed by the token contract
    // ------------------------------------------------------------------------
    modifier onlyTokenContract {
        require(msg.sender == tokenContractAddress);
        _;
    }

    // ------------------------------------------------------------------------
    // Add to 6m locked balances and totalSupply
    // ------------------------------------------------------------------------
    function add6M(address account, uint value) onlyTokenContract {
        balancesLocked6M[account] = balancesLocked6M[account].add(value);
        totalSupplyLocked6M = totalSupplyLocked6M.add(value);
    }

    // ------------------------------------------------------------------------
    // Add to 24m locked balances and totalSupply
    // ------------------------------------------------------------------------
    function add24M(address account, uint value) onlyTokenContract {
        balancesLocked24M[account] = balancesLocked24M[account].add(value);
        totalSupplyLocked24M = totalSupplyLocked24M.add(value);
    }

    // ------------------------------------------------------------------------
    // 6m locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked6M(address account) constant returns (uint balance) {
        return balancesLocked6M[account];
    }


    // ------------------------------------------------------------------------
    // 24m locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked24M(address account) constant returns (uint balance) {
        return balancesLocked24M[account];
    }


    // ------------------------------------------------------------------------
    // locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked(address account) constant returns (uint balance) {
        return balancesLocked6M[account].add(balancesLocked24M[account]);
    }


    // ------------------------------------------------------------------------
    // locked total supply
    // ------------------------------------------------------------------------
    function totalSupplyLocked() constant returns (uint) {
        return totalSupplyLocked6M + totalSupplyLocked24M;
    }

    // ------------------------------------------------------------------------
    // An account can unlock their 6m locked tokens 6m after token launch date
    // ------------------------------------------------------------------------
    function unlock6M() {
        require(now >= LOCKED_6M_DATE);
        uint amount = balancesLocked6M[msg.sender];
        require(amount > 0);
        balancesLocked6M[msg.sender] = 0;
        totalSupplyLocked6M = totalSupplyLocked6M.sub(amount);
        require(tokenContract.transfer(msg.sender, amount));
    }


    // ------------------------------------------------------------------------
    // An account can unlock their 8m locked tokens 8m after token launch date
    // ------------------------------------------------------------------------
    function unlock24M() {
        require(now >= LOCKED_24M_DATE);
        uint amount = balancesLocked24M[msg.sender];
        require(amount > 0);
        balancesLocked24M[msg.sender] = 0;
        totalSupplyLocked24M = totalSupplyLocked24M.sub(amount);
        require(tokenContract.transfer(msg.sender, amount));
    }

}