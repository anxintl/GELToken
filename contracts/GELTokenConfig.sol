pragma solidity ^0.4.21;

// ----------------------------------------------------------------------------
// GEL'GEL Token' contract configuration
//
//
// Enjoy. (c) ANX International and BokkyPooBah / Bok Consulting Pty Ltd 2017.
// The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// GEL crowdsale token smart contract - configuration parameters
// ----------------------------------------------------------------------------
contract GELTokenConfig {

    // ------------------------------------------------------------------------
    // Token symbol(), name() and decimals()
    // ------------------------------------------------------------------------
    string public constant SYMBOL = "GEL";
    string public constant NAME = "GEL Token";
    uint8 public constant DECIMALS = 18;


    // ------------------------------------------------------------------------
    // Decimal factor for multiplications from GEL unit to GEL natural unit
    // ------------------------------------------------------------------------
    uint public constant DECIMALSFACTOR = 10 ** uint(DECIMALS);

    // ------------------------------------------------------------------------
    // Token activation start date
    // Do not use the `now` function here
    // Start - Nov 8 0000 HKT; Nov 7 1600 GMT
    // ------------------------------------------------------------------------
    uint public constant START_DATE = 1510070400;

    // ------------------------------------------------------------------------
    // dates for locked tokens
    // Do not use the `now` function here. Will specify exact epoch for each
    // TODO: 3M  1/5/2018 0000 HKT; 30/4/2018 1600 GMT
    // TODO: 24M 1/11/2018 0000 HKT; 31/10/2018 1600 GMT
    // ------------------------------------------------------------------------
    uint public constant LOCKED_3M_DATE = 1525104000;
    uint public constant LOCKED_24M_DATE = 1541001600;

}