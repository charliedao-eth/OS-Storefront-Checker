# Source functions ----
source("shared_nft/global.R")

# Example Wallet ----

address = "0xabf107de3e01c7c257e64e0a18d60a733aad395d"

# put your API key here!
api_key = readLines("shared_nft/moralis_api.txt")

# Get the NFTs ----

nfts <- get_nfts(address, api_key)

# Parse the Storefront ---- 

parsed <- parse_storefront(nfts$owned_nfts)
