library(httr)
library(jsonlite)
library(dplyr)
library(DT)

nfts <- function(){ 
  readRDS("../template.rds")
}

# Get Owned NFTs by an Address ----

fill_null <- function(result_){ 
  nullvector <- is.null(result_) 
  result_[ unlist(nullvector)] <- NA
  return(result_)
}

# Get a set of 500 ---- 

get_nft <- function(address, api_key, offset = 0){ 
  request <- httr::GET( 
    url = paste0("http://deep-index.moralis.io/api/v2/",
                 address,
                 "/nft?chain=eth&format=decimal&offset=", offset),
    httr::add_headers(
      `accept` = "application/json", 
      `X-API-Key` = api_key
    )
  )
  
  the_json <- httr::content(request)
  
  the_json$result <- lapply(the_json$result, FUN = function(x){
    lapply(x, fill_null)
  })
  result <- bind_rows(lapply(the_json$result, list2DF))  
  return(result)
}

# Get all of them ----
get_nfts <- function(address, api_key){
  
  request <- httr::GET( 
    url = paste0("http://deep-index.moralis.io/api/v2/",
                 address,
                 "/nft?chain=eth&format=decimal"),
    httr::add_headers(
      `accept` = "application/json", 
      `X-API-Key` = api_key
    )
  )
  
  the_json <- httr::content(request)
  
  the_json$result <- lapply(the_json$result, FUN = function(x){
    lapply(x, fill_null)
  })
  result <- bind_rows(lapply(the_json$result, list2DF))  
  
  num_nfts <- the_json$total 
  
  owned_nfts_tbl <- result  
  
  if(num_nfts > 500){
    runs = ceiling(num_nfts/500)
    
    for(i in 2:runs){
     result <- get_nft(address, api_key, offset = (i-1)*500)
      owned_nfts_tbl <- rbind(owned_nfts_tbl, result)
      }
  }
  
  
  return(list(owned_nfts = owned_nfts_tbl, num_nfts = num_nfts))
  }

# Identify which are OpenSea Storefront ---- 

# To parse ugly metadata in OpenSea Shared Storefront items 
parse_metadata <- function(metastring){ 
  target = strsplit(metastring, ",")[[1]][1]
  partial_clean = gsub(pattern = "[[:punct:]]","",target)
  # remove 'name' prefix and ONLY the prefix from dirty metadata 
  clean = sub("name","",partial_clean)
  return(clean)
  }

parse_storefront <- function(owned_nfts){ 

  blank_index = which(owned_nfts$name == "" | is.na(owned_nfts$name))
 
  # replace error name with token address 
  owned_nfts$name[blank_index] <- owned_nfts$token_address[blank_index] 
  
nft_summary <- data.frame(
  "NFTs Owned" = nrow(owned_nfts),
  "Unique NFTs Owned" = length(unique(owned_nfts$name)),
  "ERC1155s Owned" = sum(owned_nfts$contract_type == "ERC1155"),
  "ERC721s Owned" = sum(owned_nfts$contract_type == "ERC721"),
  "Shared Storefront NFTs Owned" = sum(owned_nfts$name == "OpenSea Shared Storefront"),
  row.names = NULL, 
  check.names = FALSE
)

os <- owned_nfts[owned_nfts$name == "OpenSea Shared Storefront", ]

blank_metadata <- which(is.na(os$metadata))

# pray that 'name' doesn't appear in a token address LOL
os$metadata[blank_metadata] <- os$token_address[blank_metadata]

os$storefront_true_name <- unlist ( lapply(os$metadata, parse_metadata) )

imageurl_name_index <- grepl("imageurl ipfs", os$storefront_true_name)

os$storefront_true_name[imageurl_name_index] <- os$token_address[imageurl_name_index]

os$url <- paste0("<a href = https://opensea.io/assets/",
                 os$token_address,"/",os$token_id,
                 "> ",
                 os[ ,"storefront_true_name"],
                 "</a>")

return(
  list(summary = nft_summary, opensea = os)
)    
  
}

# Get Data Table

get_dt <- function(x, full = TRUE){
  # Makes a nice table for presentation. Must be rendered in HTML.
  
  if(full == TRUE){ 
  DT::datatable(x, escape = FALSE,
                rownames = FALSE,
                options = list(dom = 'tlp',
                               columnDefs = list(list(className = 'dt-center',
                                                      targets = "_all")))
  )
  } else { 
    DT::datatable(x, escape = FALSE,
                  rownames = FALSE,
                  options = list(dom = 't',
                                 columnDefs = list(list(className = 'dt-center',
                                                        targets = "_all")))
    )
    }
}


