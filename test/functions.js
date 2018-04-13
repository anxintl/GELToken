// Jun 12 2017
var ethPriceUSD = 380.39;

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Super Owner");
addAccount(eth.accounts[2], "Account #2 - KYCed");
addAccount(eth.accounts[3], "Account #3 - KYCed");
addAccount(eth.accounts[4], "Account #4");
addAccount(eth.accounts[5], "Account #5");
addAccount(eth.accounts[6], "Account #6");
addAccount(eth.accounts[7], "Account #7");
addAccount(eth.accounts[8], "Account #8");
addAccount(eth.accounts[9], "Account #9");
addAccount(eth.accounts[10], "Account #10");
addAccount(eth.accounts[11], "Account #11");
addAccount(eth.accounts[12], "Account #12 - Unlocked");
addAccount(eth.accounts[13], "Account #13 - 3M Locked");
addAccount(eth.accounts[14], "Account #14 - 24M Locked");
addAccount(eth.accounts[15], "Account #15 - Owner");
addAccount("0x0000000000000000000000000000000000000000", "Burn Account");


var minerAccount = eth.accounts[0];
var tokenOwnerAccount = eth.accounts[1];
var account2 = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var account6 = eth.accounts[6];
var account7 = eth.accounts[7];
var account8 = eth.accounts[8];
var account9 = eth.accounts[9];
var account10 = eth.accounts[10];
var account11 = eth.accounts[11];
var contributorAccountUnLocked = eth.accounts[12];
var contributorAccountLocked3M = eth.accounts[13];
var contributorAccountLocked24M = eth.accounts[14];
var ownerAccount = eth.accounts[15];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
    for (var i = 0; i < eth.accounts.length; i++) {
        personal.unlockAccount(eth.accounts[i], password, 100000);
    }
}

function addAccount(account, accountName) {
    accounts.push(account);
    accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;
var lockedTokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi, lockedTokenAbi) {
    tokenContractAddress = address;
    tokenContractAbi = tokenAbi;
    lockedTokenContractAbi = lockedTokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
    var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = token == null ? 18 : token.decimals();
    var lockedTokenContract = token == null || lockedTokenContractAbi == null ? null : web3.eth.contract(lockedTokenContractAbi).at(token.lockedTokens());
    var i = 0;
    var totalTokenBalanceUnlocked = new BigNumber(0);
    var totalTokenBalance3M = new BigNumber(0);
    var totalTokenBalance24M = new BigNumber(0);
    var totalTokenBalance = new BigNumber(0);
    console.log("RESULT:  # Account                                             EtherBalanceChange                 Unlocked Token                      Locked 3M                      Locked 24M                          Total Name");
    console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ------------------------------ ------------------------------ ---------------------------");
    accounts.forEach(function (e) {
        i++;
        var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
        var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
        var tokenBalanceUnlocked = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
        var tokenBalance3M = lockedTokenContract == null ? new BigNumber(0) : lockedTokenContract.balanceOfLocked3M(e).shift(-decimals);
        var tokenBalance24M = lockedTokenContract == null ? new BigNumber(0) : lockedTokenContract.balanceOfLocked24M(e).shift(-decimals);
        var tokenBalance = tokenBalanceUnlocked.add(tokenBalance3M).add(tokenBalance24M);
        totalTokenBalanceUnlocked = totalTokenBalanceUnlocked.add(tokenBalanceUnlocked);
        totalTokenBalance3M = totalTokenBalance3M.add(tokenBalance3M);
        totalTokenBalance24M = totalTokenBalance24M.add(tokenBalance24M);
        totalTokenBalance = totalTokenBalance.add(tokenBalance);
        console.log("RESULT: " + pad2(i) + " " + e + " " + pad(etherBalance) + " " + padToken(tokenBalanceUnlocked, decimals) + " " + padToken(tokenBalance3M, decimals) + " " +
            padToken(tokenBalance24M, decimals) + " " +
            padToken(tokenBalance, decimals) + " " + accountNames[e]);
    });
    console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ------------------------------ ------------------------------ ------------------------------ ---------------------------");
    console.log("RESULT:                                                                           " + padToken(totalTokenBalanceUnlocked, decimals) + " " +
        padToken(totalTokenBalance3M, decimals) + " " +
        padToken(totalTokenBalance24M, decimals) + " " +
        padToken(totalTokenBalance, decimals) + " Total Token Balances *");
    console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ------------------------------ ------------------------------ ------------------------------ ------------------------------ ---------------------------");
    console.log("RESULT: * Note that the sum of all the locked tokens is represented in the unlocked balance at the token contract address, and this will be double counted in the grand total balance above");
    console.log("RESULT: ");
}

function pad2(s) {
    var o = s.toFixed(0);
    while (o.length < 2) {
        o = " " + o;
    }
    return o;
}

function pad(s) {
    var o = s.toFixed(18);
    while (o.length < 27) {
        o = " " + o;
    }
    return o;
}

function padToken(s, decimals) {
    var o = s.toFixed(decimals);
    var l = parseInt(decimals) + 12;
    while (o.length < l) {
        o = " " + o;
    }
    return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
    var tx = eth.getTransaction(txId);
    var txReceipt = eth.getTransactionReceipt(txId);
    var gasPrice = tx.gasPrice;
    var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
    var gasCostUSD = gasCostETH.mul(ethPriceUSD);
    console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH +
        " costUSD=" + gasCostUSD + " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + gasPrice + " block=" +
        txReceipt.blockNumber + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
    var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
    if (etherBalance == expectedBalance) {
        console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
    } else {
        console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
    }
}

function gasEqualsGasUsed(tx) {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
        console.log("RESULT: FAIL " + msg);
        return 0;
    } else {
        console.log("RESULT: PASS " + msg);
        return 1;
    }
}

function passIfGasEqualsGasUsed(tx, msg) {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
        console.log("RESULT: PASS " + msg);
        return 1;
    } else {
        console.log("RESULT: FAIL " + msg);
        return 0;
    }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
    if (contractAddress == null) {
        console.log("RESULT: FAIL " + msg);
        return 0;
    } else {
        var gas = eth.getTransaction(tx).gas;
        var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
        if (gas == gasUsed) {
            console.log("RESULT: FAIL " + msg);
            return 0;
        } else {
            console.log("RESULT: PASS " + msg);
            return 1;
        }
    }
}


// -----------------------------------------------------------------------------
// Token Contract details
// -----------------------------------------------------------------------------
function printTokenContractStaticDetails() {
    if (tokenContractAddress != null && tokenContractAbi != null) {
        var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
        var decimals = contract.decimals();
        console.log("RESULT: token.symbol=" + contract.symbol());
        console.log("RESULT: token.name=" + contract.name());
        console.log("RESULT: token.decimals=" + decimals);
        console.log("RESULT: token.DECIMALSFACTOR=" + contract.DECIMALSFACTOR());
        var startDate = contract.START_DATE();
        console.log("RESULT: token.START_DATE=" + startDate + " " + new Date(startDate * 1000).toUTCString() +
            " / " + new Date(startDate * 1000).toGMTString());
        var locked3MDate = contract.LOCKED_3M_DATE();
        console.log("RESULT: token.LOCKED_3M_DATE=" + locked3MDate + " " + new Date(locked3MDate * 1000).toUTCString() +
            " / " + new Date(locked3MDate * 1000).toGMTString());
        var locked24MDate = contract.LOCKED_24M_DATE();
        console.log("RESULT: token.LOCKED_24M_DATE=" + locked24MDate + " " + new Date(locked24MDate * 1000).toUTCString() +
            " / " + new Date(locked24MDate * 1000).toGMTString());
    }
}

var dynamicDetailsFromBlock = 0;

function printTokenContractDynamicDetails() {
    if (tokenContractAddress != null && tokenContractAbi != null && lockedTokenContractAbi != null) {
        var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
        var lockedTokenContract = eth.contract(lockedTokenContractAbi).at(contract.lockedTokens());
        var decimals = contract.decimals();
        console.log("RESULT: token.finalised=" + contract.finalised());
        console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
        console.log("RESULT: token.totalSupplyLocked(3M/24M)=" + contract.totalSupplyLocked3M().shift(-decimals) + " / " + contract.totalSupplyLocked24M().shift(-decimals));
        console.log("RESULT: token.totalSupplyLocked=" + contract.totalSupplyLocked().shift(-decimals));
        console.log("RESULT: token.totalSupplyUnlocked=" + contract.totalSupplyUnlocked().shift(-decimals));
        console.log("RESULT: lockedToken.totalSupplyLocked3M=" + lockedTokenContract.totalSupplyLocked3M().shift(-decimals));
        console.log("RESULT: lockedToken.totalSupplyLocked24M=" + lockedTokenContract.totalSupplyLocked24M().shift(-decimals));
        console.log("RESULT: lockedToken.totalSupplyLocked=" + lockedTokenContract.totalSupplyLocked().shift(-decimals));
        console.log("RESULT: token.superOwner=" + contract.superOwner());
        console.log("RESULT: token.newSuperOwner=" + contract.newSuperOwner());

        var latestBlock = eth.blockNumber;
        var i;


        var ownerAddedEvent = contract.OwnerAdded({}, {
            fromBlock: dynamicDetailsFromBlock,
            toBlock: latestBlock
        });
        i = 0;
        ownerAddedEvent.watch(function (error, result) {
            console.log("RESULT: OwnerAdded Event " + i++ + ": address=" + result.args._owner + " " + result.blockNumber);
        });
        ownerAddedEvent.stopWatching();

        var ownerRemovedEvent = contract.OwnerRemoved({}, {
            fromBlock: dynamicDetailsFromBlock,
            toBlock: latestBlock
        });
        i = 0;
        ownerRemovedEvent.watch(function (error, result) {
            console.log("RESULT: OwnerRemoved Event " + i++ + ": address=" + result.args._owner + " " + result.blockNumber);
        });
        ownerRemovedEvent.stopWatching();


        var ownershipTransferredEvent = contract.OwnershipTransferred({}, {
            fromBlock: dynamicDetailsFromBlock,
            toBlock: latestBlock
        });
        i = 0;
        ownershipTransferredEvent.watch(function (error, result) {
            console.log("RESULT: OwnershipTransferred Event " + i++ + ": from=" + result.args._from + " to=" + result.args._to + " " +
                result.blockNumber);
        });
        ownershipTransferredEvent.stopWatching();

        var tokenUnlockedCreatedEvent = contract.TokenUnlockedCreated({}, {
            fromBlock: dynamicDetailsFromBlock,
            toBlock: latestBlock
        });
        i = 0;
        tokenUnlockedCreatedEvent.watch(function (error, result) {
            console.log("RESULT: TokenUnlockedCreated Event " + i++ + ": participant=" + result.args.participant +
                " balance=" + result.args.balance.shift(-decimals) +
                " kycRequired=" + result.args.kycRequiredFlag +
                " block=" + result.blockNumber);
        });
        tokenUnlockedCreatedEvent.stopWatching();

        var tokenLocked3MCreatedEvent = contract.TokenLocked3MCreated({}, {
            fromBlock: dynamicDetailsFromBlock,
            toBlock: latestBlock
        });
        i = 0;
        tokenLocked3MCreatedEvent.watch(function (error, result) {
            console.log("RESULT: TokenUnlockedCreated Event " + i++ + ": participant=" + result.args.participant +
                " balance=" + result.args.balance.shift(-decimals) +
                " block=" + result.blockNumber);
        });
        tokenLocked3MCreatedEvent.stopWatching();


        var tokenLocked24MCreatedEvent = contract.TokenLocked24MCreated({}, {
            fromBlock: dynamicDetailsFromBlock,
            toBlock: latestBlock
        });
        i = 0;
        tokenLocked24MCreatedEvent.watch(function (error, result) {
            console.log("RESULT: TokenUnlockedCreated Event " + i++ + ": participant=" + result.args.participant +
                " balance=" + result.args.balance.shift(-decimals) +
                " block=" + result.blockNumber);
        });
        tokenLocked24MCreatedEvent.stopWatching();


        var kycVerifiedEvent = contract.KycVerified({}, {fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock});
        i = 0;
        kycVerifiedEvent.watch(function (error, result) {
            console.log("RESULT: KycVerified Event " + i++ + ": participant=" + result.args.participant + " block=" + result.blockNumber);
        });
        kycVerifiedEvent.stopWatching();

        var approvalEvent = contract.Approval({}, {fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock});
        i = 0;
        approvalEvent.watch(function (error, result) {
            console.log("RESULT: Approval Event " + i++ + ": owner=" + result.args._owner + " spender=" + result.args._spender + " " +
                result.args._value.shift(-decimals) + " block=" + result.blockNumber);
        });
        approvalEvent.stopWatching();

        var transferEvent = contract.Transfer({}, {fromBlock: dynamicDetailsFromBlock, toBlock: latestBlock});
        i = 0;
        transferEvent.watch(function (error, result) {
            console.log("RESULT: Transfer Event " + i++ + ": from=" + result.args._from + " to=" + result.args._to +
                " value=" + result.args._value.shift(-decimals) + " block=" + result.blockNumber);
        });
        transferEvent.stopWatching();
        dynamicDetailsFromBlock = latestBlock + 1;
    }
}
