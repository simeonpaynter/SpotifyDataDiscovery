# server.R created 7/17

library(shiny)
library(tidyverse)

server <- function(input, output){
  
  # Tab 2: Streaming History Data
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
  
  output$DateRange <- renderUI({
      minDate <- min(streamingHistory()$endTime_ymd)
      maxDate <- max(streamingHistory()$endTime_ymd)
      
      dateRangeInput("dateRange", "Date Listened To:", start = minDate, end = maxDate, format = "mm/dd/yyyy")
  })
  
  history_filtered <- reactive({
      req(input$dateRange)
      streamingHistory() %>%
        filter(endTime >= input$dateRange[1] & endTime <= input$dateRange[2]) %>%
        return()
  })
  
  output$TotalListeningTime <- renderText({
      total_time <- history_filtered() %>%
        summarise(mins = round(sum(msPlayed)/3600000))
      
      return(paste("Total Listening Time:", sum(total_time$mins), "Hours"))
  })
  
  output$AvgListeningTime <- renderText({
      avg_time <- history_filtered() %>%
        group_by(endTime_ymd) %>%
        summarise(mins = round(sum(msPlayed)/60000)) %>%
        ungroup()
      
      return(paste("Avg. Daily Listening Time:", round(mean(avg_time$mins)), "Minutes"))
  })
  
  output$NumSongs <- renderText({
      n_songs <- history_filtered() %>%
        unique() %>%
        nrow()
      return(paste("# of Unique Songs Played:", n_songs))
  })
  
  top_artists <- reactive({
    history_filtered() %>%
      group_by(artistName) %>%
      summarise(n = n(), min = round(sum(msPlayed)/60000)) %>%
      ungroup() %>%
      arrange(desc(min)) %>%
      head(10)
  })
  
  output$TopArtists <- renderPlot({
    top_artists() %>%  
      ggplot(aes(x = reorder(artistName, +min), y = min)) + 
      geom_col(fill="#1ed760") +
      coord_flip() +
      labs(title = "Top Artists",
           y= "Minutes Played",
           x = "Song") +
      theme_classic() +
      scale_y_continuous(expand = c(0, 0), limits = c(0, NA), breaks = seq.int(0, 10000, 60))
  })
  
  top_songs <- reactive({
      history_filtered() %>%
      group_by(trackName, artistName) %>%
      summarise(n = n(), min = round(sum(msPlayed)/60000)) %>%
      ungroup() %>%
      arrange(desc(min)) %>%
      head(10)
  })
  
  output$TopSongs <- renderPlot({
      top_songs() %>%  
        ggplot(aes(x = reorder(trackName, +min), y = min)) + 
        geom_col(fill="#1ed760") +
        coord_flip() +
        labs(title = "Top Songs",
             y= "Minutes Played",
             x = "Song") +
        theme_classic() +
        scale_y_continuous(expand = c(0, 0), limits = c(0, NA), breaks = seq.int(0, 10000, 60))
  })
}

