### 👋 Welcome Flow Developer!

### 🔨 Run your setup Switchboard Transaction!

The account receiving royalties must have a FungibleTokenSwitchboard Vault.
This vault allows you to manage the receipt of royalties in several FT types.

#### To run your transactions, open a new terminal and call the following command:

`flow transactions send --signer=${signer-account} cadence/transactions/${transaction-name}.cdc`

#### If your transaction contains arguments, add them in the order in which they are present in your script:

For example:

transaction/test.cdc
transaction(address: Address, id: UInt64)...

Your command will then be:
`flow transactions send --signer=${signer-account} transaction/test.cdc 'f8d6e0586b0a20c7' '1'`

#### Scaffold Switchboard default transactions:

In our mint transaction, we specify that the account exampleNFT-deployer receives the royalties.
If you want to add another account as the recipient of the royalties, run this transaction with that account as the signatory.

##### Setup Switchboard Account:
`flow transactions send --signer=exampleNFT-deployer cadence/transactions/royalty-receiver/setupSwitchboardAccount.cdc`