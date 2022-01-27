

library(shiny)

# Define server logic 
shinyServer(function(input, output) {

  # Get the NFTs ----
  
  nft <- eventReactive(input$begin, {
    withProgress(expr = {
   get_nfts(address = input$address, api_key = readLines("moralis_api.txt"))
    }, min = 0, max = 1, value = 0, message = "Pulling Data from Moralis")
    
  })
  
  # Parse the Storefront ---- 
  
  parsed <- reactive({ 
    parse_storefront(nft()$owned_nfts)
  })
  
  # Summary Table
  output$summary <- DT::renderDataTable({
    get_dt(parsed()$summary, full = FALSE)
  })

  # OpenSea 
  output$opensea <- DT::renderDataTable(expr = {
    temp = parsed()$opensea[, c("storefront_true_name", "url")]
    colnames(temp) <- c("Parsed Name", "OpenSea URL")
    get_dt(temp)
  })
})
