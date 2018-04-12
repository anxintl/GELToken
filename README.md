# GEL Token Contract

Website: [http://XXX/](http://XXX/)

<br />

<hr />

# Table of contents

* [Requirements](#requirements)
* [Operations On The Contract](#operations-on-the-contract)
  * [Anytime](#anytime)
  * [Before Start Date and Before Finalised](#before-start-date-and-before-finalised)
  * [Before Start Date Or Finalised](#before-start-date-or-finalised)
  * [After Finalised and After Start Date](#after-finalised-and-after-start-date)
  * [After 3 months and 24 months](#after-3-months-and-24-months)
* [Testing](#testing)
* [Deployment Checklist](#deployment-checklist)

<br />

<hr />

# Requirements

* Token Identifier
  * symbol `GEL`
  * name `GEL Token`
  * decimals `18`

* Total Suppy of Tokens
  * The total supply of tokens will be determined by the number of tokens sold by the end of the sale.
  * The total supply of 3 month locked tokens is: TBC
  * The total supply of 24 month locked tokens is: TBC

* Off Chain Public Sale of Tokens
  * The tokens sale will be conducted off-chain
  * On completion of the sale, the contract owner will make multiple calls to add 3, and 24 month locked balances, and unlocked balances
  * After reconciliation, the token contract will be finalized and no further tokens can be allocated.

*  KYC on Contributions Over 1,000 USD
    * Token sale will conduct KYC on all participants that contribute over 1,000 USD. Typically, all token balances will be activated at the time of finalisation, however, GEL has the ability to deploy balances that remain "locked" until the participants has completed their KYC process.

* `finalise()` The Token Balances
  * GEL calls `finalise()` to close the allocation of balances to the contract. 
  * The `finalise()` function will allocate the 3 and 24 month locked tokens
  
<br />

<hr />

# Operations On The Contract

Following are the functions that can be called at the different phases of the contract lifecycle

## Anytime

* Owner can call `kycVerify(...)` to verify participants.

## Before Start Date and Before Finalised

* Owner can call `addTokenBalance(...)` to add participant balances, and flag if KYC is required
* Owner can call `addTokenBalance[3|24]MLocked(...)` to add locked participant balances, assumes no KYC is required

## Before Start Date Or Finalised

* Owner can call `finalise()` to prevent the allocation of any more balances.

## After Finalised and After Start Date

* Owner calls `kycVerify(...)` to verify participants.
* Participant can call the normal `transfer(...)`, `approve(...)` and `transferFrom(...)` to transfer tokens

## After 3 months and 24 months

* Participants with locked tokens can call the `lockedTokens.unlock3M()` and `lockedTokens.unlock24M()` to unlock their tokens
  * Find the address of the LockedTokens contract from the lockedTokens variable in the token contract
  * Watch the LockedTokens address using the LockedTokens Application Binary Interface
  * Execute `unlock3M()` after 3 months has passed or `unlock24M()` after 24 months has passed, to unlock the tokens

<br />

<hr />

# Testing

See [test](test) for details.

<br />

<hr />

# Deployment Checklist

* Check START_DATE
* Check Solidity [release history](https://github.com/ethereum/solidity/releases) for potential bugs 
* Deploy contract to Mainnet
* Verify the source code on EtherScan.io
  * Verify the main GEL Token contract
  * Verify the LockedToken contract

<br />

<br />

# Credits

Thanks to the excellent work from BokkyPoohBah on the OAX project which was used as the template for this contract.

(c) ANX International 2017. The MIT Licence.
<br />
Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.


