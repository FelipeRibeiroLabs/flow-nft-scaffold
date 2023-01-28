import NonFungibleToken from "./contracts/nft-standards/NonFungibleToken.cdc"
import ExampleNFT from "./contracts/exampleNFT-deployer/ExampleNFT.cdc"

/// Script to get NFT IDs in an account's collection
///
pub fun main(address: Address): Int64 {
    let account = getAccount(address)

    let collectionRef = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection at specified path")

    return Int64((collectionRef.getIDs()).length)
}