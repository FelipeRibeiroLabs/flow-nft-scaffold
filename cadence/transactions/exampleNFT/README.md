### 👋 Welcome Flow Developer!

### 🔨 Run your setup Example NFT Transactions!

In this folder you will find the necessary transactions for:

- Create your account setup configuration;
- Mint exampleNFTs;

The mintNFT.cdc transaction receives recipient (Address) as an argument. To work correctly, run the setupAccount.cdc transaction with recipient as the signer to initialise an ExampleNFT Collection in your account.

The transaction mintNFT.cdc also receives royaltyBeneficiaries ([Address]) as an argument. 
Make sure you run the setupSwitchboardAccount.cdc transaction with the addresses to be passed as signers in this argument. Otherwise your transaction will fail.

#### To run your transactions, open a new terminal and call the following command:

`flow transactions send --signer=${signer-account} cadence/transactions/${transaction-name}.cdc`

#### If your transaction contains arguments, add them in the order in which they are present in your script:

For example:

transaction/test.cdc
transaction(address: Address, id: UInt64)...

Your command will then be:
`flow transactions send --signer=${signer-account} transaction/test.cdc 'f8d6e0586b0a20c7' '1'`

#### Scaffold Example NFT default transactions:

Make sure you run the setupSwitchboardAccount.cdc transaction before running the following transactions!

In our mint transaction, we specify that the account emulator-account receives the exampleNFT.
As a result, we first need to initialize your account to contain an exampleNFT collection

##### Setup ExampleNFT Account:
`flow transactions send --signer=emulator-account cadence/transactions/exampleNFT/setupAccount.cdc`

##### Mint ExampleNFT Account:
Inside your flow.json file copy the address of the exampleNFT-deployer account
Replace ${exampleNFT-deployer-ADDRESS}, the last argument on the follow command, with the copied address

`flow transactions send --signer=exampleNFT-deployer cadence/transactions/exampleNFT/mintNFT.cdc 'f8d6e0586b0a20c7' 'ExampleNFT' 'Example NFT' 'https://developers.flow.com/build/_assets/flow-docs-logo-dark-ICQTJU4A.png' '[0.1]' '["Creator Royalty"]' '[ '${exampleNFT-deployer-ADDRESS}' ]'`