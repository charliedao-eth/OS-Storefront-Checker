
library(shiny)

# Define UI 
shinyUI(fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  div(class = 'main-app',
      br(),
      div(class = "button-bar",
          fluidRow(
            column(2, ""),
            column(8,
                   div(class = "address-input",
                       textInput(inputId = "address", 
                                 label = "Paste an Ethereum Address",
                                 value = "0xabf107de3e01c7c257e64e0a18d60a733aad395d",
                                 width = "100%")
                   )),
            column(2, 
                   div(class = "center-button",br(),
                       actionButton(inputId = "begin",
                                    label = "Launch"))
            )
          )
      ),
      div(class = "summary-table",
          h4("Summary of Address's NFT Portfolio"),
          DT::dataTableOutput("summary")
          ), hr(),
      div(class = "Opensea-table",
          h4("OpenSea Shared Storefront NFTs"),
          DT::dataTableOutput("opensea")),
      div()
  ),
  
  # Enter Mainnet Address 
  
  #  
  
  # Return Table
  
  # Signature ----
  hr(),
  div(class = "footer", 
      HTML("Not financial advice, this is for entertainment and informational
      purposes only. <br> 
           If you like applications like these, requests & donations 
           can be made to the creator charliemarketplace.eth on 
           Mainnet, Polygon, Arbitrum, Fantom, or Avalanche.<br> If you'd like to 
           join CharlieDAO and learn/share/collaborate on your writings, 
           applications, and analyses, DM <a href = \"https://twitter.com/charliedao_eth\">
           charliedao_eth</a> on twitter! <br>
           ")
  )
  
))
