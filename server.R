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


# Define server logic 
shinyServer(function(input, output,session) {
   
    data <- reactive({
        x <- subset(df, Station==input$station & PriceHigh < input$slider1)
    })
    
    output$mymap <- renderLeaflet({
        dfRest <- data()
        nMsg <- paste("Restaurants in your price range : ",NROW(dfRest),sep="")
        
        output$message1 <- renderText({
            nMsg
        })
        
        dfRest <- dfRest %>%
            leaflet() %>%
            addTiles()%>%
            addMarkers(
                lng = ~Long,
                lat = ~Lat,
                popup=dfRest$Name) %>%
            addCircleMarkers(color = dfRest$Colour) %>%
            addLegend(labels=c("Rating 3.0-3.5",
                "Rating 3.5-4.0","Rating 4.0-4.5"), 
                colors = c("blue", "red","yellow"), title = input$station)
    })
  
})

