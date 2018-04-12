# GEL Token - Testing

<br />

<hr />

# Table of contents

* [Requirements](#requirements)
* [Executing The Tests](#executing-the-tests)
* [The Tests](#the-tests)
* [Notes](#notes)

<br />

<hr />

# Requirements

* The tests works on Linux, a few commented lines need to be uncommented in 01_test1.sh for OSX. May work in Windows with Cygwin
* Geth/v1.8.2-stable/darwin-amd64/go1.10
* Solc 0.4.21+commit.dfe3193c.Darwin.appleclang

<br />

<hr />

# Executing The Tests

* Run `geth` in dev mode

      ./00_runGeth.sh

* Run the test in [01_test1.sh](01_test1.sh)

      ./01_test1.sh

* See  [test1results.txt](test1results.txt) for the results and [test1output.txt](test1output.txt) for the full output.

<br />

<hr />

# The Tests

* Test 1 Before The Token is Activated
  * Test 1.1 Deploy Token Contract
  * Test 1.2 Add Locked and unlocked balances
* Test 2 Cannot Move Tokens Without Finalising
  * `transfer(...)`, `approve(...)` and `transferFrom(...)`
* Test 3 Finalising
* Test 4 KYC Verify
* Test 5 Move Tokens After Finalising
* Test 6 Unlock Tokens 1
  * Test 6.1 Unlock 3M Locked Token
  * Test 6.2 Unsuccessfully Unlock 24M Locked Token
* Test 7 Unlock Tokens 2
  * Test 7.1 Successfully Unlock 24M Locked Token
* Test 8 Burn Tokens
* Test 9 Change Ownership

## Todo
* Execute un-permissioned functions
* Safe maths
* Other edge cases

<br />

<hr />

# Notes

* The tests were conducted using bash shell scripts running Geth/v1.8.2-stable/darwin-amd64/go1.10 JavaScript commands
* The smart contracts were compiled using Solidity 0.4.21+commit.dfe3193c.Darwin.appleclang
* The test script can be found in [01_test1.sh](01_test1.sh)
* The test results can be found in [test1results.txt](test1results.txt) with details in [test1output.txt](test1output.txt)
* The test can be run on Linux and may run on OSX, and Windows with Cygwin
* The [genesis.json](genesis.json) allocates ethers to the test accounts, and specifies a high block gas limit to accommodate many transactions in the same block
* The [00_runGeth.sh](00_runGeth.sh) scripts starts `geth` with the parameter `--targetgaslimit 994712388` to keep the high block gas limit
* The reasons for using the test environment as listed above, instead of truffles/testrpc are:
  * The test are conducted using the actual blockchain client software as is running on Mainnet and not just a mock environment like testrpc
  * It is easy to change parameters like dates, addresses or blocknumbers using the Unix search/replace tools
  * There have been issues in the part with version incompatibility between testrpc and solidity, i.e., version mismatches 
  * The intermediate and key results are all saved to later viewing