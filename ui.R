# ui.R created 7/17

library(shiny)
library(tidyverse)

ui <- fluidPage(
  titlePanel(title = "Spotify Listening Activity", windowTitle = "Spotify Data Analysis"),
  tabsetPanel(type = "tabs",
              tabPanel("File Upload", 
                       fileInput("streamingHistory", "Upload 'StreamingHistory.json' files:", 
                                 multiple = TRUE, accept = c(".json")),
                       
                       fileInput("yourLibrary", "Upload 'YourLibrary.json' file",
                                 multiple = FALSE, accept = c(".json"))
                       ),
              tabPanel("Streaming History",
                       uiOutput("DateRange"),
                       plotOutput("StreamPlot1")),
              tabPanel("Your Library"),
              tabPanel("Read Me Page",
                       h6())
              )
  )