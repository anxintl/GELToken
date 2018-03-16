#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`
ERC20INTERFACESOL=`grep ^ERC20INTERFACESOL= settings.txt | sed "s/^.*=//"`
ERC20INTERFACETEMPSOL=`grep ^ERC20INTERFACETEMPSOL= settings.txt | sed "s/^.*=//"`
ERC20TOKENSOL=`grep ^ERC20TOKENSOL= settings.txt | sed "s/^.*=//"`
ERC20TOKENTEMPSOL=`grep ^ERC20TOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
OWNEDSOL=`grep ^OWNEDSOL= settings.txt | sed "s/^.*=//"`
OWNEDTEMPSOL=`grep ^OWNEDTEMPSOL= settings.txt | sed "s/^.*=//"`
SAFEMATHSOL=`grep ^SAFEMATHSOL= settings.txt | sed "s/^.*=//"`
SAFEMATHTEMPSOL=`grep ^SAFEMATHTEMPSOL= settings.txt | sed "s/^.*=//"`
LOCKEDTOKENSSOL=`grep ^LOCKEDTOKENSSOL= settings.txt | sed "s/^.*=//"`
LOCKEDTOKENSTEMPSOL=`grep ^LOCKEDTOKENSTEMPSOL= settings.txt | sed "s/^.*=//"`
TOKENCONFIGSOL=`grep ^TOKENCONFIGSOL= settings.txt | sed "s/^.*=//"`
TOKENCONFIGTEMPSOL=`grep ^TOKENCONFIGTEMPSOL= settings.txt | sed "s/^.*=//"`
TOKENSOL=`grep ^TOKENSOL= settings.txt | sed "s/^.*=//"`
TOKENTEMPSOL=`grep ^TOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
TOKENJS=`grep ^TOKENJS= settings.txt | sed "s/^.*=//"`
DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`

#OSX
CURRENTTIMES=`date -r $CURRENTTIME -u`

#GNU
#CURRENTTIMES=`date --date="@$CURRENTTIME" -u`

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+70" | bc`
fi
#OSX
STARTTIME_S=`date -r $STARTTIME -u`
#GNU
#STARTTIME_S=`date --date="@$STARTTIME" -u`
ENDTIME=`echo "$CURRENTTIME+60*3" | bc`
#OSX
ENDTIME_S=`date -r $ENDTIME -u`
#ENDTIME_S=`date --date="@$ENDTIME" -u`

printf "MODE                  = '$MODE'\n"
printf "GETHATTACHPOINT       = '$GETHATTACHPOINT'\n"
printf "PASSWORD              = '$PASSWORD'\n"
printf "ERC20INTERFACESOL     = '$ERC20INTERFACESOL'\n"
printf "ERC20INTERFACETEMPSOL = '$ERC20INTERFACETEMPSOL'\n"
printf "ERC20TOKENSOL         = '$ERC20TOKENSOL'\n"
printf "ERC20TOKENTEMPSOL     = '$ERC20TOKENTEMPSOL'\n"
printf "OWNEDSOL              = '$OWNEDSOL'\n"
printf "OWNEDTEMPSOL          = '$OWNEDTEMPSOL'\n"
printf "SAFEMATHSOL           = '$SAFEMATHSOL'\n"
printf "SAFEMATHTEMPSOL       = '$SAFEMATHTEMPSOL'\n"
printf "LOCKEDTOKENSSOL       = '$LOCKEDTOKENSSOL'\n"
printf "LOCKEDTOKENSTEMPSOL   = '$LOCKEDTOKENSTEMPSOL'\n"
printf "TOKENCONFIGSOL        = '$TOKENCONFIGSOL'\n"
printf "TOKENCONFIGTEMPSOL    = '$TOKENCONFIGTEMPSOL'\n"
printf "TOKENSOL              = '$TOKENSOL'\n"
printf "TOKENTEMPSOL          = '$TOKENTEMPSOL'\n"
printf "TOKENJS               = '$TOKENJS'\n"
printf "DEPLOYMENTDATA        = '$DEPLOYMENTDATA'\n"
printf "INCLUDEJS             = '$INCLUDEJS'\n"
printf "TEST1OUTPUT           = '$TEST1OUTPUT'\n"
printf "TEST1RESULTS          = '$TEST1RESULTS'\n"
printf "CURRENTTIME           = '$CURRENTTIME' '$CURRENTTIMES'\n"
printf "STARTTIME             = '$STARTTIME' '$STARTTIME_S'\n"
printf "ENDTIME               = '$ENDTIME' '$ENDTIME_S'\n"

# Make copy of SOL file and modify start and end times ---
`cp $ERC20INTERFACESOL $ERC20INTERFACETEMPSOL`
`cp $ERC20TOKENSOL $ERC20TOKENTEMPSOL`
`cp $OWNEDSOL $OWNEDTEMPSOL`
`cp $SAFEMATHSOL $SAFEMATHTEMPSOL`
`cp $LOCKEDTOKENSSOL $LOCKEDTOKENSTEMPSOL`
`cp $TOKENCONFIGSOL $TOKENCONFIGTEMPSOL`
`cp $TOKENSOL $TOKENTEMPSOL`

# --- Modify dates ---
# START_DATE = +1m
`perl -pi -e "s/START_DATE = 1510070400;/START_DATE = $STARTTIME; \/\/ $STARTTIME_S/" $TOKENCONFIGTEMPSOL`
`perl -pi -e "s/LOCKED_6M_DATE = 1525104000;/LOCKED_6M_DATE \= START_DATE \+ 3 minutes;/" $TOKENCONFIGTEMPSOL`
`perl -pi -e "s/LOCKED_24M_DATE = 1541001600;/LOCKED_24M_DATE \= START_DATE \+ 4 minutes;/" $TOKENCONFIGTEMPSOL`

# --- Un-internal safeMaths ---
#`perl -pi -e "s/internal/constant/" $TOKENTEMPSOL`

DIFFS=`diff $TOKENCONFIGSOL $TOKENCONFIGTEMPSOL`
echo "--- Differences ---"
echo "$DIFFS"

echo "var tokenOutput=`solc --optimize --combined-json abi,bin,interface $TOKENTEMPSOL`;" > $TOKENJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | grep -v '^undefined$' | tee $TEST1OUTPUT
loadScript("$TOKENJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(tokenOutput.contracts["$TOKENTEMPSOL:GELToken"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$TOKENTEMPSOL:GELToken"].bin;
var lockedTokensAbi = JSON.parse(tokenOutput.contracts["$LOCKEDTOKENSTEMPSOL:LockedTokens"].abi);

console.log("DATA: tokenABI=" + JSON.stringify(tokenAbi));
console.log("DATA: lockedTokensAbi=" + JSON.stringify(lockedTokensAbi));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

var skipKycContract = "$MODE" == "dev" ? true : false;
var skipSafeMath = "$MODE" == "dev" ? true : false;

// -----------------------------------------------------------------------------
var testMessage = "Test 1.1 Deploy Token Contract";
console.log("RESULT: " + testMessage);
var tokenContract = web3.eth.contract(tokenAbi);
console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new(tokenOwnerAccount, {from: tokenOwnerAccount, data: tokenBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, token.symbol() + " '" + token.name() + "' *");
        addAccount(token.lockedTokens(), "Locked Tokens");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi, lockedTokensAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printTxData("tokenAddress=" + tokenAddress, tokenTx);
printBalances();
failIfGasEqualsGasUsed(tokenTx, testMessage);
printTokenContractStaticDetails();
printTokenContractDynamicDetails();
console.log("RESULT: ");
console.log(JSON.stringify(token));


// -----------------------------------------------------------------------------
var testMessage = "Test 1.2 tokens created";
console.log("RESULT: " + testMessage);
var tx1_2_1 = token.addTokenBalance(contributorAccountUnLocked, "10000000000000000000000000",true, {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_2 = token.addTokenBalance(account2, "10000000000000000000000000",true, {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_3 = token.addTokenBalance(account3, "200000000000000000000000000",true, {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_4 = token.addTokenBalance(account4, "3000000000000000000000000000",true, {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_5 = token.addTokenBalance(account5, "40000000000000000000000000000",true, {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_6 = token.addTokenBalance6MLocked(contributorAccountLocked6M, "2000000000000000000000000", {from: tokenOwnerAccount, gas: 4000000});
var tx1_2_7 = token.addTokenBalance24MLocked(contributorAccountLocked24M, "300000000000000000000000", {from: tokenOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx1_2_1", tx1_2_1);
printTxData("tx1_2_2", tx1_2_2);
printTxData("tx1_2_3", tx1_2_3);
printTxData("tx1_2_4", tx1_2_4);
printTxData("tx1_2_5", tx1_2_5);
printTxData("tx1_2_6", tx1_2_6);
printTxData("tx1_2_7", tx1_2_7);

printBalances();

failIfGasEqualsGasUsed(tx1_2_1, testMessage + " - contributorAccountUnLocked");
failIfGasEqualsGasUsed(tx1_2_2, testMessage + " - account2");
failIfGasEqualsGasUsed(tx1_2_3, testMessage + " - account3");
failIfGasEqualsGasUsed(tx1_2_4, testMessage + " - account4");
failIfGasEqualsGasUsed(tx1_2_5, testMessage + " - account5");
failIfGasEqualsGasUsed(tx1_2_6, testMessage + " - contributorAccountLocked6M");
failIfGasEqualsGasUsed(tx1_2_7, testMessage + " - contributorAccountLocked24M");

printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for token activation date start
// -----------------------------------------------------------------------------
var startDateTime = token.START_DATE();
var startDateTimeDate = new Date(startDateTime * 1000);
console.log("RESULT: Waiting until start date at " + startDateTime + " " + startDateTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startDateTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + startDateTime + " " + startDateTimeDate +
  " currentDate=" + new Date());

// -----------------------------------------------------------------------------
var testMessage = "Test 2.1 Cannot Move Tokens Without Finalisation And KYC Verification";
console.log("RESULT: " + testMessage);
var tx2_1_1 = token.transfer(account5, "1000000000000", {from: account2, gas: 100000});
var tx2_1_2 = token.transfer(account6, "200000000000000", {from: account4, gas: 100000});
var tx2_1_3 = token.approve(account7,  "30000000000000000", {from: account3, gas: 100000});
var tx2_1_4 = token.approve(account8,  "4000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx2_1_5 = token.transferFrom(account3, account7, "30000000000000000", {from: account7, gas: 100000});
var tx2_1_6 = token.transferFrom(account4, account8, "4000000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx2_1_1", tx2_1_1);
printTxData("tx2_1_2", tx2_1_2);
printTxData("tx2_1_3", tx2_1_3);
printTxData("tx2_1_4", tx2_1_4);
printTxData("tx2_1_5", tx2_1_5);
printTxData("tx2_1_6", tx2_1_6);
printBalances();
passIfGasEqualsGasUsed(tx2_1_1, testMessage + " - transfer 0.000001 HAZ ac2 -> ac5. CHECK no movement");
passIfGasEqualsGasUsed(tx2_1_2, testMessage + " - transfer 0.0002 HAZ ac4 -> ac6. CHECK no movement");
failIfGasEqualsGasUsed(tx2_1_3, testMessage + " - approve 0.03 HAZ ac3 -> ac7");
failIfGasEqualsGasUsed(tx2_1_4, testMessage + " - approve 4 HAZ ac4 -> ac8");
passIfGasEqualsGasUsed(tx2_1_5, testMessage + " - transferFrom 0.03 HAZ ac3 -> ac5. CHECK no movement");
passIfGasEqualsGasUsed(tx2_1_6, testMessage + " - transferFrom 4 HAZ ac4 -> ac6. CHECK no movement");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 3.1 Finalise";
console.log("RESULT: " + testMessage);
var tx3_1 = token.finalise({from: tokenOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx3_1", tx3_1);
printBalances();
failIfGasEqualsGasUsed(tx3_1, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 4.1 KYC Verify";
console.log("RESULT: " + testMessage);
var tx4_1_1 = token.kycVerify(account2, {from: tokenOwnerAccount, gas: 4000000});
var tx4_1_2 = token.kycVerify(account3, {from: tokenOwnerAccount, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx4_1_1", tx4_1_1);
printTxData("tx4_1_2", tx4_1_2);
printBalances();
failIfGasEqualsGasUsed(tx4_1_1, testMessage + " - account2");
failIfGasEqualsGasUsed(tx4_1_2, testMessage + " - account3");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 5.1 Move Tokens After Finalising";
console.log("RESULT: " + testMessage);
console.log("RESULT: kyc(account3)=" + token.kycRequired(account3));
console.log("RESULT: kyc(account4)=" + token.kycRequired(account4));
var tx5_1_1 = token.transfer(account5, "1000000000000", {from: account2, gas: 100000});
var tx5_1_2 = token.transfer(account6, "200000000000000", {from: account4, gas: 100000});
var tx5_1_3 = token.approve(account7, "30000000000000000", {from: account3, gas: 100000});
var tx5_1_4 = token.approve(account8, "4000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx5_1_5 = token.transferFrom(account3, account7, "30000000000000000", {from: account7, gas: 100000});
var tx5_1_6 = token.transferFrom(account4, account8, "4000000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx5_1_1", tx5_1_1);
printTxData("tx5_1_2", tx5_1_2);
printTxData("tx5_1_3", tx5_1_3);
printTxData("tx5_1_4", tx5_1_4);
printTxData("tx5_1_5", tx5_1_5);
printTxData("tx5_1_6", tx5_1_6);
printBalances();
failIfGasEqualsGasUsed(tx5_1_1, testMessage + " - transfer 0.000001 HAZ ac2 -> ac5. CHECK for movement");
passIfGasEqualsGasUsed(tx5_1_2, testMessage + " - transfer 0.0002 HAZ ac4 -> ac5. CHECK no movement");
failIfGasEqualsGasUsed(tx5_1_3, testMessage + " - approve 0.03 HAZ ac3 -> ac5");
failIfGasEqualsGasUsed(tx5_1_4, testMessage + " - approve 4 HAZ ac4 -> ac5");
failIfGasEqualsGasUsed(tx5_1_5, testMessage + " - transferFrom 0.03 HAZ ac3 -> ac5. CHECK for movement");
passIfGasEqualsGasUsed(tx5_1_6, testMessage + " - transferFrom 4 HAZ ac4 -> ac6. CHECK no movement");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for 6M unlocked date
// -----------------------------------------------------------------------------
var locked6MDateTime = token.LOCKED_6M_DATE();
var locked6MDateTimeDate = new Date(locked6MDateTime * 1000);
console.log("RESULT: Waiting until locked 6M date at " + locked6MDateTime + " " + locked6MDateTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= locked6MDateTimeDate.getTime()) {
}
console.log("RESULT: Waited until locked 6M date at " + locked6MDateTime + " " + locked6MDateTimeDate +
  " currentDate=" + new Date());


var lockedTokens = eth.contract(lockedTokensAbi).at(token.lockedTokens());


// -----------------------------------------------------------------------------
var testMessage = "Test 6.1 Unlock 6M Locked Token";
console.log("RESULT: " + testMessage);
var tx6_1_1 = lockedTokens.unlock6M({from: contributorAccountLocked6M, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx6_1_1", tx6_1_1);
printBalances();
failIfGasEqualsGasUsed(tx6_1_1, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for 24M unlocked date
// -----------------------------------------------------------------------------
var locked24MDateTime = token.LOCKED_24M_DATE();
var locked24MDateTimeDate = new Date(locked24MDateTime * 1000);
console.log("RESULT: Waiting until locked 24M date at " + locked24MDateTime + " " + locked24MDateTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= locked24MDateTimeDate.getTime()) {
}
console.log("RESULT: Waited until locked 24M date at " + locked24MDateTime + " " + locked24MDateTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var testMessage = "Test 7.1 Successfully Unlock 24M Locked Token";
console.log("RESULT: " + testMessage);
var tx7_1_1 = lockedTokens.unlock24M({from: contributorAccountLocked24M, gas: 4000000});
while (txpool.status.pending > 0) {
}
printTxData("tx7_1_1", tx7_1_1);
printBalances();
failIfGasEqualsGasUsed(tx7_1_1, testMessage);
printTokenContractDynamicDetails();
console.log("RESULT: ");

// -----------------------------------------------------------------------------
var testMessage = "Test 8.1 Burn Tokens";
console.log("RESULT: " + testMessage);
var tx8_1_1 = token.burnFrom(account5, "100000000000000", {from: account2, gas: 100000});
var tx8_1_2 = token.transfer("0x0",    "1000000000000", {from: account5, gas: 100000});
var tx8_1_3 = token.approve("0x0",     "3000000000000000000", {from: account3, gas: 100000});
var tx8_1_4 = token.approve("0x0",     "400000000000000000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx8_1_5 = token.burnFrom(account3, "3000000000000000000", {from: account3, gas: 100000});
var tx8_1_6 = token.burnFrom(account4, "400000000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx8_1_1", tx8_1_1);
printTxData("tx8_1_2", tx8_1_2);
printTxData("tx8_1_3", tx8_1_3);
printTxData("tx8_1_4", tx8_1_4);
printTxData("tx8_1_5", tx8_1_5);
printTxData("tx8_1_6", tx8_1_6);
printBalances();
failIfGasEqualsGasUsed(tx8_1_1, testMessage + " - burn 0.0001 HAZ ac2. CHECK no movement");
passIfGasEqualsGasUsed(tx8_1_2, testMessage + " - burn 0.000001 HAZ ac5. CHECK no movement");
failIfGasEqualsGasUsed(tx8_1_3, testMessage + " - approve burn 3 HAZ ac3");
failIfGasEqualsGasUsed(tx8_1_4, testMessage + " - approve burn 400 HAZ ac4");
failIfGasEqualsGasUsed(tx8_1_5, testMessage + " - burn 3 HAZ ac3 from ac3. CHECK for movement");
failIfGasEqualsGasUsed(tx8_1_6, testMessage + " - burn 400 HAZ ac4 from ac8. CHECK for movement");
printTokenContractDynamicDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var testMessage = "Test 9.1 Change Ownership";
console.log("RESULT: " + testMessage);
var tx9_1_1 = token.transferOwnership(minerAccount, {from: tokenOwnerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
var tx9_1_2 = token.acceptOwnership({from: minerAccount, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("tx9_1_1", tx10_1_1);
printTxData("tx9_1_2", tx10_1_2);
printBalances();
failIfGasEqualsGasUsed(tx9_1_1, testMessage + " - Change owner");
failIfGasEqualsGasUsed(tx9_1_2, testMessage + " - Accept ownership");
printTokenContractDynamicDetails();
console.log("RESULT: ");

exit;


// TODO: Update test for this
if (!skipSafeMath && false) {
  // -----------------------------------------------------------------------------
  // Notes: 
  // = To simulate failure, comment out the throw lines in safeAdd() and safeSub()
  //
  var testMessage = "Test 2.0 Safe Maths";
  console.log("RESULT: " + testMessage);
  console.log(JSON.stringify(token));
  var result = token.safeAdd("1", "2");
  if (result == 3) {
    console.log("RESULT: PASS safeAdd(1, 2) = 3");
  } else {
    console.log("RESULT: FAIL safeAdd(1, 2) <> 3");
  }

  var minusOneInt = "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
  result = token.safeAdd(minusOneInt, "124");
  if (result == 0) {
    console.log("RESULT: PASS safeAdd(" + minusOneInt + ", 124) = 0. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeAdd(" + minusOneInt + ", 124) = 123. Result=" + result);
  }

  result = token.safeAdd("124", minusOneInt);
  if (result == 0) {
    console.log("RESULT: PASS safeAdd(124, " + minusOneInt + ") = 0. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeAdd(124, " + minusOneInt + ") = 123. Result=" + result);
  }

    result = token.safeSub("124", 1);
  if (result == 123) {
    console.log("RESULT: PASS safeSub(124, 1) = 123. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeSub(124, 1) <> 123. Result=" + result);
  }

    result = token.safeSub("122", minusOneInt);
  if (result == 0) {
    console.log("RESULT: PASS safeSub(122, " + minusOneInt + ") = 0. Result=" + result);
  } else {
    console.log("RESULT: FAIL safeSub(122, " + minusOneInt + ") = 123. Result=" + result);
  }

}

EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
