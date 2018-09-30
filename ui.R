library(leaflet)
library(shiny)

fileData <- "./data/Kyoto_Restaurant_Info.csv"
df <- read.csv(fileData)

## get unique list of station names
df$Station <- gsub("^ *","",df$Station)
idStation <- unique(df$Station)
idStation <- idStation[order(idStation)]

## tidy price columns
df$DinnerPrice <- gsub("\\D+"," ",df$DinnerPrice)
df$DinnerPrice <- gsub("^ *","",df$DinnerPrice)

df$PriceLow <- substring(df$DinnerPrice,1,5)
df$PriceLow <- as.numeric(gsub(" *","",df$PriceLow))

df$PriceHigh <- substring(df$DinnerPrice,6,10)
df$PriceHigh <- as.numeric(gsub(" *","",df$PriceHigh))
df$PriceHigh[is.na(df$PriceHigh)] <- df$PriceLow[is.na(df$PriceHigh)] 


## add colours for markers
df$Colour <- "blue"
df$Colour[df$TotalRating>3.5] = "red"
df$Colour[df$TotalRating>4] = "yellow"


shinyUI(fluidPage(
  
  # Application title
  titlePanel("Kyoto Restaurants : Closest Restaurants in your Price Range"),
  helpText("Data sourced from Kaggle : https://www.kaggle.com/koki25ando/tabelog-restaurant-review-dataset"),
  
  # Sidebar 
  sidebarLayout(
    sidebarPanel(
        selectInput("station", "Nearest Station:", 
            choices=idStation),
        helpText("Select your nearest station"),
        hr(),
        helpText(" "),
        hr(),
        sliderInput("slider1", "Max Price", 2000, 5000, 4000),
        helpText("Select your maximum price"),
        hr()
    ),
    
    
    # Show a plot of the generated distribution
    mainPanel(
        leafletOutput("mymap"),
        hr(),
        textOutput("message1")
    )
  )
))




