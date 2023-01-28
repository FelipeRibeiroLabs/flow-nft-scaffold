### 👋 Welcome Flow Developer!

### 🔨 Run your scripts!

#### To run your scripts, open a new terminal and call the following command:

`flow scripts execute cadence/scripts/${script-name}.cdc`

#### If your script contains arguments, add them in the order in which they are present in your script:

For example:

scripts/test.cdc
pub fun main(address: Address, id: UInt64)...

Your command will then be:
`flow scripts run scripts/test.cdc 'f8d6e0586b0a20c7' '1'`

#### Scaffold default Scripts:

##### Total Supply:
`flow scripts execute cadence/scripts/exampleNFT/totalSupply.cdc`

##### Get NFT Metadata:
`flow scripts execute cadence/scripts/exampleNFT/getNftMetadata.cdc '${NFT-OWNER-ADDRESS}' '${NFT-ID}'`

###### Get Collection IDS:
 `flow scripts execute cadence/scripts/exampleNFT/getNftMetadata.cdc '${NFT-OWNER-ADDRESS}' '/public/exampleNFTCollection'`