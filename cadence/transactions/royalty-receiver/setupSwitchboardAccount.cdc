
import "FungibleTokenSwitchboard"
import FungibleToken from 0xee82856bf20e2aa6

transaction {
    prepare(account: AuthAccount) {
        let switchboard = account.borrow<&FungibleTokenSwitchboard.Switchboard>(
            from: FungibleTokenSwitchboard.StoragePath
        )

        if switchboard == nil {
            account.save(
                <- FungibleTokenSwitchboard.createSwitchboard(),
                to: FungibleTokenSwitchboard.StoragePath
            )

            account.link<&FungibleTokenSwitchboard.Switchboard{FungibleToken.Receiver}>(
                FungibleTokenSwitchboard.ReceiverPublicPath,
                target: FungibleTokenSwitchboard.StoragePath
            )
            account.link<&FungibleTokenSwitchboard.Switchboard{FungibleTokenSwitchboard.SwitchboardPublic}>(
                FungibleTokenSwitchboard.PublicPath,
                target: FungibleTokenSwitchboard.StoragePath
            )
        }
    }
}

//flow transactions send --signer=exampleNFT-deployer cadence/transactions/royalty-receiver/setupSwitchboardAccount.cdc