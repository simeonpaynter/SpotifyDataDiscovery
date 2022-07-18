# ui.R created 7/17

library(shiny)
library(tidyverse)

ui <- fluidPage(
  titlePanel(title = "Spotify Listening Activity", windowTitle = "Spotify Data Analysis"),
  tabsetPanel(type = "tabs",
              
              # Tab 1:
              tabPanel("File Upload", 
                       br(),
                       h5("After downloading your Spotify data, you will have access to the following files. Please upload them."),
                       br(),
                       fileInput("streamingHistory", "'StreamingHistory.json' file(s):", 
                                 multiple = TRUE, accept = c(".json")),
                       
                       fileInput("yourLibrary", "'YourLibrary.json' file:",
                                 multiple = FALSE, accept = c(".json"))
                       ),
              
              # Tab 2:
              tabPanel("Streaming History",
                       uiOutput("DateRange"),
                       textOutput("TotalListeningTime"),
                       textOutput("AvgListeningTime"),
                       textOutput("NumSongs"),
                       plotOutput("TopArtists"),
                       plotOutput("TopSongs")),
              
              # Tab 3:
              tabPanel("Your Library"),
              
              # Tab 4:
              tabPanel("Read Me",
                       h5("Request 1 year of Spotfiy data by following the steps on this page:"), 
                       a("Spotify - Data rights and privacy settings", href = "https://support.spotify.com/us/article/data-rights-and-privacy-settings/"))
              )
  )