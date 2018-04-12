pragma solidity ^0.4.21;

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
    uint public totalSupplyLocked3M;
    uint public totalSupplyLocked24M;

    // ------------------------------------------------------------------------
    // Locked tokens mapping
    // ------------------------------------------------------------------------
    mapping(address => uint) public balancesLocked3M;
    mapping(address => uint) public balancesLocked24M;

    // ------------------------------------------------------------------------
    // Address of GEL token contract
    // ------------------------------------------------------------------------
    ERC20Interface public tokenContract;
    address public tokenContractAddress;


    // ------------------------------------------------------------------------
    // Constructor - called by token contract
    // ------------------------------------------------------------------------
    function LockedTokens(address _tokenContract) public {
        tokenContract = ERC20Interface(_tokenContract);
        tokenContractAddress = _tokenContract;

        // any locked token balances known in advance of contract deployment can be added here
        // add3M(0xaBBa43E7594E3B76afB157989e93c6621497FD4b, 2000000 * DECIMALSFACTOR);
        // add24M(0xAddA9B762A00FF12711113bfDc36958B73d7F915, 2000000 * DECIMALSFACTOR);

    }

    // ------------------------------------------------------------------------
    // Modifier to mark that a function can only be executed by the token contract
    // ------------------------------------------------------------------------
    modifier onlyTokenContract {
        require(msg.sender == tokenContractAddress);
        _;
    }

    // ------------------------------------------------------------------------
    // Add to 3m locked balances and totalSupply
    // ------------------------------------------------------------------------
    function add3M(address account, uint value) public onlyTokenContract {
        balancesLocked3M[account] = balancesLocked3M[account].add(value);
        totalSupplyLocked3M = totalSupplyLocked3M.add(value);
    }

    // ------------------------------------------------------------------------
    // Add to 24m locked balances and totalSupply
    // ------------------------------------------------------------------------
    function add24M(address account, uint value) public onlyTokenContract {
        balancesLocked24M[account] = balancesLocked24M[account].add(value);
        totalSupplyLocked24M = totalSupplyLocked24M.add(value);
    }

    // ------------------------------------------------------------------------
    // 3m locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked3M(address account) public constant returns (uint balance) {
        return balancesLocked3M[account];
    }


    // ------------------------------------------------------------------------
    // 24m locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked24M(address account) public constant returns (uint balance) {
        return balancesLocked24M[account];
    }


    // ------------------------------------------------------------------------
    // locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked(address account) public constant returns (uint balance) {
        return balancesLocked3M[account].add(balancesLocked24M[account]);
    }


    // ------------------------------------------------------------------------
    // locked total supply
    // ------------------------------------------------------------------------
    function totalSupplyLocked() public constant returns (uint) {
        return totalSupplyLocked3M + totalSupplyLocked24M;
    }

    // ------------------------------------------------------------------------
    // An account can unlock their 3m locked tokens 3m after token launch date
    // ------------------------------------------------------------------------
    function unlock3M() public {
        require(now >= LOCKED_3M_DATE);
        uint amount = balancesLocked3M[msg.sender];
        require(amount > 0);
        balancesLocked3M[msg.sender] = 0;
        totalSupplyLocked3M = totalSupplyLocked3M.sub(amount);
        require(tokenContract.transfer(msg.sender, amount));
    }


    // ------------------------------------------------------------------------
    // An account can unlock their 8m locked tokens 8m after token launch date
    // ------------------------------------------------------------------------
    function unlock24M() public {
        require(now >= LOCKED_24M_DATE);
        uint amount = balancesLocked24M[msg.sender];
        require(amount > 0);
        balancesLocked24M[msg.sender] = 0;
        totalSupplyLocked24M = totalSupplyLocked24M.sub(amount);
        require(tokenContract.transfer(msg.sender, amount));
    }

}