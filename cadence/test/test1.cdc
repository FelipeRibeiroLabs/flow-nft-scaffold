import Test

// let blockchain = Test.newEmulatorBlockchain()
pub var blockchain = Test.newEmulatorBlockchain()
pub var accounts: {String: Test.Account} = {}

pub fun setup() {

    // Setup accounts for the smart contract.
    let nft = blockchain.createAccount()
    let metadataViews = blockchain.createAccount()
    let fungibleToken = blockchain.createAccount()
    let nonFungibleToken = blockchain.createAccount()
    let userAccount1 = blockchain.createAccount()


    accounts = {
        "FungibleToken": fungibleToken,
        "NonFungibleToken": nonFungibleToken,
        "MetadataViews": metadataViews,
        "ExampleNFT": nft,
        "userAccount1": userAccount1
    }

    // ---------------------------------------
    // Deploy the smart contracts.
    // ---------------------------------------
    deploySmartContract(blockchain, "FungibleToken", accounts["FungibleToken"]!, "./contracts/nft-standards/FungibleToken.cdc")
    deploySmartContract(blockchain, "NonFungibleToken", accounts["NonFungibleToken"]!, "./contracts/nft-standards/NonFungibleToken.cdc")

    // Let the CLI know how the above addresses are mapped to the contracts.
    blockchain.useConfiguration(Test.Configuration({
        "./FungibleToken.cdc":accounts["FungibleToken"]!.address,
        "./NonFungibleToken.cdc":accounts["NonFungibleToken"]!.address
    }))

    deploySmartContract(blockchain, "MetadataViews", accounts["MetadataViews"]!, "./contracts/nft-standards/MetadataViews.cdc")

    blockchain.useConfiguration(Test.Configuration({
        "../nft-standards/FungibleToken.cdc":accounts["FungibleToken"]!.address,
        "../nft-standards/NonFungibleToken.cdc":accounts["NonFungibleToken"]!.address,
        "../nft-standards/MetadataViews.cdc":accounts["MetadataViews"]!.address
    }))

    deploySmartContract(blockchain, "ExampleNFT", accounts["ExampleNFT"]!, "./contracts/exampleNFT-deployer/ExampleNFT.cdc")
}

// ---------------------------------------
// HELPER FUNCTIONS
// ---------------------------------------

/// Helper function to deploy required smart contracts.
pub fun deploySmartContract(_ blockchain: Test.Blockchain, _ contractName: String, _ account: Test.Account, _ filePath: String) {
    let contractCode = Test.readFile(filePath)
    let err = blockchain.deployContract(
        name: contractName,
        code: contractCode,
        account: account,
        arguments: [],
    )
    if err != nil {
        panic(err!.message)
    }
}

// ---------------------------------------
/// Helper function to execute a transaction.
// ---------------------------------------
pub fun txExecutor(_ txCode: String, _ signers: [Test.Account], _ arguments: [AnyStruct], _ expectedError: String?): Bool {
    let tx = Test.Transaction(
        code: txCode,
        authorizers: [signers[0].address],
        signers: signers,
        arguments: arguments,
    )
    let txResult = blockchain.executeTransaction(tx)
    if let err = txResult.error {
        if let expectedErrorMessage = expectedError {
            let panicErrMessage = err.message.slice(from: 73, upTo: 73 + expectedErrorMessage.length)
            let assertionErrMessage = err.message.slice(from: 84, upTo: 84 + expectedErrorMessage.length)
            let preConditionErrMessage = err.message.slice(from: 88, upTo: 88 + expectedErrorMessage.length)
            let hasEmittedCorrectMessage = panicErrMessage == expectedErrorMessage ? true : (assertionErrMessage == expectedErrorMessage ? true : preConditionErrMessage == expectedErrorMessage)
            let failureMessage = "Expecting - "
                .concat(expectedErrorMessage)
                .concat("\n")
                .concat("But received - ")
                .concat(err.message)
            assert(hasEmittedCorrectMessage, message: failureMessage)
            return true
        }
        panic(err.message)
    } else {
        if let expectedErrorMessage = expectedError {
            panic("Expecting error - ".concat(expectedErrorMessage).concat(". While no error triggered"))
        }
    }
    return txResult.status == Test.ResultStatus.succeeded
}

///////////////////
/// Script Helpers
///////////////////
pub fun scriptExecutor(_ path: String, _ arguments: [AnyStruct]): AnyStruct? {
    let scriptCode = Test.readFile(path)

    let scriptResult = blockchain.executeScript(scriptCode, arguments)
    var failureMessage = ""
    if let failureError = scriptResult.error {
        failureMessage = "Failed to execute the script because -:  ".concat(failureError.message)
    }
    assert(scriptResult.status == Test.ResultStatus.succeeded, message: failureMessage)
    return scriptResult.returnValue
}

// ---------------------------------------
// Function that sets up the account for the ExampleNFT Collection.
// ---------------------------------------
pub fun executeSetupExampleNFTAccount(_ whom: Test.Account) {
     blockchain.useConfiguration(Test.Configuration({
        "./contracts/nft-standards/NonFungibleToken.cdc": accounts["NonFungibleToken"]!.address,
        "./contracts/exampleNFT-deployer/ExampleNFT.cdc": accounts["ExampleNFT"]!.address,
        "./contracts/nft-standards/MetadataViews.cdc": accounts["MetadataViews"]!.address
    }))
    let txCode = Test.readFile("./setup_example_nft_account.cdc")
    assert(
        txExecutor(txCode, [whom], [], nil),
        message: "Failed to setup account for ExampleNFT"
    )
}

// ---------------------------------------
// Function that mint Example NFTs
// ---------------------------------------
pub fun executeMintNFTTx(
    _ signer: Test.Account,
    _ recipient: Address,
    _ name: String,
    _ description: String,
    _ thumbnail: String,
    _ cuts: [UFix64],
    _ royaltyDescriptions: [String],
    _ royaltyBeneficiaries: [Address],
    _ expectedError: String?
) {
    blockchain.useConfiguration(Test.Configuration({
        "./contracts/nft-standards/NonFungibleToken.cdc": accounts["NonFungibleToken"]!.address,
        "./contracts/exampleNFT-deployer/ExampleNFT.cdc": accounts["ExampleNFT"]!.address,
        "./contracts/nft-standards/MetadataViews.cdc": accounts["MetadataViews"]!.address,
        "./contracts/nft-standards/FungibleToken.cdc": accounts["FungibleToken"]!.address
    }))
    let txCode = Test.readFile("./mint_nft.cdc")
    assert(
        txExecutor(txCode, [signer], [recipient, name, description, thumbnail, cuts, royaltyDescriptions, royaltyBeneficiaries], expectedError),
        message: "Failed mint NFT for given receipient"
    )
}


// ---------------------------------------
//Script to get the length of the collection
// ---------------------------------------
pub fun getNFTLengthInsideAccount(_ target: Address): Int64 {
    blockchain.useConfiguration(Test.Configuration({
        "./contracts/nft-standards/NonFungibleToken.cdc": accounts["NonFungibleToken"]!.address,
        "./contracts/exampleNFT-deployer/ExampleNFT.cdc": accounts["ExampleNFT"]!.address
    }))
    let scriptResult = scriptExecutor("./get_collection_ids_length.cdc", [target])
    return scriptResult! as! Int64
}

// ---------------------------------------
// Test function -> This function will be called by the test framework
// ---------------------------------------
pub fun testGetExampleNftInsideAccount() {

    // GET ACCOUNTS
    let userAccount1 = accounts["userAccount1"]!
    let exampleMinter = accounts["ExampleNFT"]!

    // SETUP ACCOUNT 1 FOR EXAMPLE NFT
    // ASSERT THAT ACCOUNT 1 DOES NOT HAVE ANY NFT
    executeSetupExampleNFTAccount(userAccount1)
    assert(getNFTLengthInsideAccount(userAccount1.address) == 0, message: "Not equal")

    // MINT NFT TO ACCOUNT 1
    // ASSERT THAT ACCOUNT 1 HAS 1 NFT
    executeMintNFTTx(exampleMinter, userAccount1.address, "Test NFT", "This is a test NFT", "https://test.com", [], [], [], nil)
    assert(getNFTLengthInsideAccount(userAccount1.address) == 1, message: "Not equal")
}

//Comand to run the test
// flow test cadence/test/test1.cdc

