# server.R created 7/17

library(shiny)
library(tidyverse)

server <- function(input, output){
  
  # Streaming History Data
  streamingHistory <- reactive({
    files <- req(input$streamingHistory)
    
    stream <- c()
    
    for(i in 1:length(files[, 1])){
      temp_df <- jsonlite::fromJSON(
        files[[i, 'datapath']]
      )
      stream <- rbind(stream, temp_df)
    }
    
    # transform data
    history <- stream
    history$endTime_ymd <- as.Date(history$endTime)
    history$endTime_ymd_hm <- lubridate::ymd_hm(history$endTime)
    history$wday = lubridate::wday(history$endTime_ymd, label = TRUE)
    
    return(history)
  })
  
  # Streaming History
  output$DateRange <- renderUI({
    minDate <- min(streamingHistory()$endTime_ymd)
    maxDate <- max(streamingHistory()$endTime_ymd)
    
    dateRangeInput("dateRange", "Date Listened To:", start = minDate, end = maxDate, format = "mm/dd/yyyy")
  })
  
  top_songs <- reactive({
    streamingHistory() %>%
    group_by(trackName, artistName) %>%
    summarise(n = n()) %>%
    filter(n > 50) %>%
    arrange(desc(n))
  })
  
  output$StreamPlot1 <- renderPlot({
    top_songs() %>%  
      ggplot(aes(x = reorder(trackName, +n), y = n)) + 
      geom_col(fill="#1ed760") +
      coord_flip() +
      labs(y= "# of Plays",
           x = "Song") +
      theme_classic() +
      scale_y_continuous(expand = c(0, 0), limits = c(0, NA), breaks = seq.int(0, 100, 10))
  })
}