pragma solidity ^0.4.15;

// ----------------------------------------------------------------------------
// GEL 'GEL Network Token' contract - ERC20 Token Interface implementation
//
//
// Enjoy. (c) ANX International and BokkyPooBah / Bok Consulting Pty Ltd 2017.
// The MIT Licence.
// ----------------------------------------------------------------------------

import "./ERC20Interface.sol";
import "./Owned.sol";
import "./SafeMath.sol";
import "./GELNetworkTokenConfig.sol";
import "./LockedTokens.sol";


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals
// ----------------------------------------------------------------------------
contract ERC20Token is ERC20Interface, Owned {
    using SafeMath for uint;

    // ------------------------------------------------------------------------
    // symbol(), name() and decimals()
    // ------------------------------------------------------------------------
    string public symbol;
    string public name;
    uint8 public decimals;

    // ------------------------------------------------------------------------
    // Balances for each account
    // ------------------------------------------------------------------------
    mapping(address => uint) balances;

    // ------------------------------------------------------------------------
    // Owner of account approves the transfer of an amount to another account
    // ------------------------------------------------------------------------
    mapping(address => mapping (address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function ERC20Token(
        string _symbol, 
        string _name, 
        uint8 _decimals, 
        uint _totalSupply
    ) Owned() {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[owner] = _totalSupply;
    }


    // ------------------------------------------------------------------------
    // Get the account balance of another account with address _owner
    // ------------------------------------------------------------------------
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from owner's account to another account
    // ------------------------------------------------------------------------
    function transfer(address _to, uint _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount             // User has balance
            && _amount > 0                              // Non-zero transfer
            && balances[_to] + _amount > balances[_to]  // Overflow check
        ) {
            balances[msg.sender] = balances[msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }


    // ------------------------------------------------------------------------
    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount. If this function is called again it overwrites the
    // current allowance with _value.
    // ------------------------------------------------------------------------
    function approve(
        address _spender,
        uint _amount
    ) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }


    // ------------------------------------------------------------------------
    // Spender of tokens transfer an amount of tokens from the token owner's
    // balance to another account. The owner of the tokens must already
    // have approve(...)-d this transfer
    // ------------------------------------------------------------------------
    function transferFrom(
        address _from,
        address _to,
        uint _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount                  // From a/c has balance
            && allowed[_from][msg.sender] >= _amount    // Transfer approved
            && _amount > 0                              // Non-zero transfer
            && balances[_to] + _amount > balances[_to]  // Overflow check
        ) {
            balances[_from] = balances[_from].sub(_amount);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(
        address _owner, 
        address _spender
    ) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}


// ----------------------------------------------------------------------------
// token smart contract
// ----------------------------------------------------------------------------
contract GELToken is ERC20Token, GELTokenConfig {

    // ------------------------------------------------------------------------
    // Have the token balance allocations been finalised?
    // ------------------------------------------------------------------------
    bool public finalised = false;

    // ------------------------------------------------------------------------
    // Locked Tokens - holds the 6m and 8m locked tokens information
    // ------------------------------------------------------------------------
    LockedTokens public lockedTokens;

    // ------------------------------------------------------------------------
    // participant's accounts need to be KYC verified before
    // the participant can move their tokens
    // ------------------------------------------------------------------------
    mapping(address => bool) public kycRequired;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function HazzaNetworkToken()
        ERC20Token(SYMBOL, NAME, DECIMALS, 0)
    {
        lockedTokens = new LockedTokens(this);
        require(address(lockedTokens) != 0x0);
    }

    // ------------------------------------------------------------------------
    // Hazza Network to finalise the population of balances - adding the locked tokens to
    // this contract and the total supply
    // ------------------------------------------------------------------------
    function finalise() onlyOwner {

        // Can only finalise once
        require(!finalised);

        // Allocate locked and premined tokens
        balances[address(lockedTokens)] = balances[address(lockedTokens)].
            add(lockedTokens.totalSupplyLocked());

        totalSupply = totalSupply.add(lockedTokens.totalSupplyLocked());

        finalised = true;
    }


    // ------------------------------------------------------------------------
    // Hazza Network to add token balance before the contract is finalized
    // ------------------------------------------------------------------------
    function addTokenBalance(address participant, uint balance, bool kycRequiredFlag) onlyOwner {
        require(!finalised);
        require(now < START_DATE);
        require(balance > 0);
        balances[participant] = balances[participant].add(balance);
        totalSupply = totalSupply.add(balance);
        kycRequired[participant] = kycRequiredFlag;
        Transfer(0x0, participant, balance);
        TokenUnlockedCreated(participant,balance,kycRequiredFlag);
    }
    event TokenUnlockedCreated(address indexed participant, uint balance, bool kycRequiredFlag);

    // ------------------------------------------------------------------------
    // GEL to add locked token balance before the contract is finalized
    // ------------------------------------------------------------------------
    function addTokenBalance6MLocked(address participant, uint balance) onlyOwner {
        require(!finalised);
        require(now < START_DATE);
        require(balance > 0);
        lockedTokens.add6M(participant,balance);
        TokenLocked6MCreated(participant,balance);
    }
    event TokenLocked6MCreated(address indexed participant, uint balance);

    // ------------------------------------------------------------------------
    // GEL to add locked token balance before the contract is finalized
    // ------------------------------------------------------------------------
    function addTokenBalance24MLocked(address participant, uint balance) onlyOwner {
        require(!finalised);
        require(now < START_DATE);
        require(balance > 0);
        lockedTokens.add24M(participant,balance);
        TokenLocked24MCreated(participant,balance);
    }
    event TokenLocked24MCreated(address indexed participant, uint balance);

    // ------------------------------------------------------------------------
    // Transfer the balance from owner's account to another account, with KYC
    // ------------------------------------------------------------------------
    function transfer(address _to, uint _amount) returns (bool success) {
        // Cannot transfer before crowdsale ends
        require(finalised);
        require(now > START_DATE);
        // Cannot transfer if KYC verification is required
        require(!kycRequired[msg.sender]);
        // Standard transfer
        return super.transfer(_to, _amount);
    }


    // ------------------------------------------------------------------------
    // Spender of tokens transfer an amount of tokens from the token owner's
    // balance to another account, with KYC verification check for the
    // participant's first transfer
    // ------------------------------------------------------------------------
    function transferFrom(address _from, address _to, uint _amount) 
        returns (bool success)
    {
        // Cannot transfer before crowdsale ends
        require(finalised);
        require(now > START_DATE);
        // Cannot transfer if KYC verification is required
        require(!kycRequired[_from]);
        // Standard transferFrom
        return super.transferFrom(_from, _to, _amount);
    }


    // ------------------------------------------------------------------------
    // GEL to KYC verify the participant's account
    // ------------------------------------------------------------------------
    function kycVerify(address participant) onlyOwner {
        kycRequired[participant] = false;
        KycVerified(participant);
    }
    event KycVerified(address indexed participant);


    // ------------------------------------------------------------------------
    // Any account can burn _from's tokens as long as the _from account has 
    // approved the _amount to be burnt using
    //   approve(0x0, _amount)
    // ------------------------------------------------------------------------
    function burnFrom(
        address _from,
        uint _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount                  // From a/c has balance
            && allowed[_from][0x0] >= _amount           // Transfer approved
            && _amount > 0                              // Non-zero transfer
            && balances[0x0] + _amount > balances[0x0]  // Overflow check
        ) {
            balances[_from] = balances[_from].sub(_amount);
            allowed[_from][0x0] = allowed[_from][0x0].sub(_amount);
            balances[0x0] = balances[0x0].add(_amount);
            totalSupply = totalSupply.sub(_amount);
            Transfer(_from, 0x0, _amount);
            return true;
        } else {
            return false;
        }
    }


    // ------------------------------------------------------------------------
    // 6m locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked6M(address account) constant returns (uint balance) {
        return lockedTokens.balanceOfLocked6M(account);
    }


    // ------------------------------------------------------------------------
    // 24m locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked24M(address account) constant returns (uint balance) {
        return lockedTokens.balanceOfLocked24M(account);
    }


    // ------------------------------------------------------------------------
    // locked balances for an account
    // ------------------------------------------------------------------------
    function balanceOfLocked(address account) constant returns (uint balance) {
        return lockedTokens.balanceOfLocked(account);
    }


    // ------------------------------------------------------------------------
    // 6m locked total supply
    // ------------------------------------------------------------------------
    function totalSupplyLocked6M() constant returns (uint) {
        if (finalised) {
            return lockedTokens.totalSupplyLocked6M();
        } else {
            return 0;
        }
    }


    // ------------------------------------------------------------------------
    // 24m locked total supply
    // ------------------------------------------------------------------------
    function totalSupplyLocked24M() constant returns (uint) {
        if (finalised) {
            return lockedTokens.totalSupplyLocked24M();
        } else {
            return 0;
        }
    }


    // ------------------------------------------------------------------------
    // locked total supply
    // ------------------------------------------------------------------------
    function totalSupplyLocked() constant returns (uint) {
        if (finalised) {
            return lockedTokens.totalSupplyLocked();
        } else {
            return 0;
        }
    }


    // ------------------------------------------------------------------------
    // Unlocked total supply
    // ------------------------------------------------------------------------
    function totalSupplyUnlocked() constant returns (uint) {
        if (finalised && totalSupply >= lockedTokens.totalSupplyLocked()) {
            return totalSupply.sub(lockedTokens.totalSupplyLocked());
        } else {
            return 0;
        }
    }


    // ------------------------------------------------------------------------
    // Hazza Network can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint amount)
      onlyOwner returns (bool success) 
    {
        return ERC20Interface(tokenAddress).transfer(owner, amount);
    }
}