## Run via shiny::runApp("./tests/shiny_test", port=4624)
library(searchConsoleR)
library(shiny)
library(DT)

source('global.R')

shinyServer(function(input, output, session) {

  message("New Shiny Session - ", Sys.time())
  
  ## Get auth code
  access_token  <- googleAuthR::reactiveAccessToken(session)
  
  ## Make a button to link to Google auth screen
  ## If auth_code is returned then don't show login button
  output$loginButton <- googleAuthR::renderLogin(session, access_token())
  
  output$token_websites <- renderTable({
    if(!is.null(access_token())){
      googleAuthR::with_shiny(list_websites,
                              shiny_access_token = access_token())
    }
  })
  
  website_df <- reactive({
    if(!is.null(access_token())){
      googleAuthR::with_shiny(list_websites,
                              shiny_access_token = access_token())         
    }
    
  })
  
  
  
  observe({
    
    www <- website_df()
    urls <- www[www$permissionLevel != "siteUnverifiedUser",'siteUrl']
    
    updateSelectInput(session,
                      "website_select",
                      choices = urls)
    
  })
  
  sa_trend_data <- eventReactive(input$submit, {
    www <- input$website_select
    dates <- input$date_range
    # dims <- input$dims
    type <- input$type
    dim_filter <- input$filter_dim
    dim_op <- input$filter_op
    dim_ex <- input$filter_ex
    
    
    if(!is.null(access_token())){
      
      if(all(dim_filter != "none", !is.null(dim_ex))){
        dfe <- paste0(dim_filter,dim_op,dim_ex)
      } else {
        dfe = NULL
      }
      
      sa <- googleAuthR::with_shiny(search_analytics,
                                    shiny_access_token = access_token(),
                                    siteURL = www, 
                                    startDate = dates[1], 
                                    endDate = dates[2],
                                    dimensions = c('date'),
                                    searchType = type,
                                    dimensionFilterExp = dfe)
    }
    
    
  })
  
  sa_breakdown_data <- reactive({
    www <- input$website_select
    dates <- input$date_range
    dims <- input$dims
    type <- input$type
    dim_filter <- input$filter_dim
    dim_op <- input$filter_op
    dim_ex <- input$filter_ex
    
    
    if(!is.null(access_token()) && !is.null(dims)){
      
      if(all(dim_filter != "none", !is.null(dim_ex))){
        dfe <- paste0(dim_filter,dim_op,dim_ex)
      } else {
        dfe = NULL
      }
      
      sa <- googleAuthR::with_shiny(search_analytics,
                                    shiny_access_token = access_token(),
                                    siteURL = www, 
                                    startDate = dates[1], 
                                    endDate = dates[2],
                                    dimensions = dims,
                                    searchType = type,
                                    dimensionFilterExp = dfe, 
                                    prettyNames = FALSE)
    }
    
    
  })
  
  output$sa_breakdown <- DT::renderDataTable({
    
    sa_breakdown_data()
    
  }, selection = 'single')
  
  breakdown_trend <- reactive({
    
    www <- input$website_select
    breakdown_df <- sa_breakdown_data()
    selected_row <- input$sa_breakdown_rows_selected
    dims <- input$dims
    dates <- input$date_range
    type <- input$type
    
    data_row <- breakdown_df[selected_row,]
    
    
    if(!is.null(access_token()) && !is.null(selected_row)){
      
      data_dims <- data_row[,dims]
      ## construct the filter
      dfe <- paste(dims, "==", data_dims)
      message(dfe)
      sa <- googleAuthR::with_shiny(search_analytics,
                                    shiny_access_token = access_token(),
                                    siteURL = www, 
                                    startDate = dates[1], 
                                    endDate = dates[2],
                                    dimensions = c('date'),
                                    searchType = type,
                                    dimensionFilterExp = dfe)      
    }
    
  })
  
  output$breakdown_plot <- renderPlot({
    
    breakdown_trend <- breakdown_trend()
    metrics <- input$metrics
    
    if(!is.null(breakdown_trend)){
      plot(breakdown_trend$date, breakdown_trend[,metrics], type = "l",
           xlab = "date", ylab = metrics)         
    }
    
    
    
  })
  
  output$plot_analytics <- renderPlot({
    
    sadata <- sa_trend_data()
    metrics <- input$metrics
    
    if(!is.null(access_token())){
      plot(sadata$date, sadata[,metrics], type = "l",
           xlab = "date", ylab = metrics)     
    }
    
    
  })
  
  output$websites <- DT::renderDataTable({
    
    website_df()
    
  }, selection = 'single')
  
  selected_www <- reactive({
    
    www <- website_df()
    selected_row <- input$websites_rows_selected
    
    if(!is.null(selected_row)){
      www <- www[selected_row,] 
      
      if(www[selected_row, 'permissionLevel'] %in% c('siteUnverifiedUser')){
        
        www$siteUrl <- paste(www$siteUrl, "- No Access")
        
      }
      
      www
    }
    
  })
  
  output$selected_url <- renderText({
    
    www <- input$website_select
    
    if(!is.null(access_token())){
      s <- www  
    } else {
      s <- "Authenticate to see data."
    }
    
    s
    
  })
  
  output$crawl_errors <- renderPlot({
    
    www <- input$website_select
    errors <- input$errors
    platform <- input$platform
    
    if(!is.null(access_token())){
      
      ce <- 
        # try(
        googleAuthR::with_shiny(crawl_errors, 
                                shiny_access_token = access_token(),
                                siteURL = www, 
                                category = errors, 
                                platform = platform)
      # )
      
      if(!is.error(ce)){
        plot(ce$timecount, ce$count, type="l")                 
      }
    }
    
  })
  
  crawl_error_df <- reactive({
    www <- input$website_select
    errors <- input$errors
    platform <- input$platform
    
    if(!is.null(access_token())){
      
      error_df <- googleAuthR::with_shiny(list_crawl_error_samples,
                                          shiny_access_token = access_token(),
                                          siteURL = www, 
                                          category = errors, 
                                          platform = platform)
        
      error_df$last_crawled <- as.Date(error_df$last_crawled)
      error_df$first_detected <- as.Date(error_df$first_detected)
      
      error_df

    }
    
  })
  
  output$crawl_error_samples <- DT::renderDataTable({
    
    if(!is.null(crawl_error_df())) crawl_error_df()
    
  }, selection = 'single')
  
  sample_error_url <- reactive({
    crawl_error_df <- crawl_error_df()
    errors <- input$errors
    platform <- input$platform
    sample_detail <- input$crawl_error_samples_rows_selected
    
    if(!is.null(sample_detail)){
      
      crawl_error_df <- crawl_error_df[sample_detail,] 
      
    }      
    
    crawl_error_df$pageUrl
    
  })
  
  sample_error_url_details <- reactive({
    www <- input$website_select
    sample_error_url <- sample_error_url()
    errors <- input$errors
    platform <- input$platform      
    
    if(!is.null(access_token()))
    {
      df_err <- googleAuthR::with_shiny(error_sample_url,
                                        shiny_access_token = access_token(),
                                        siteURL = www, 
                                        pageURL = sample_error_url, 
                                        category = errors, 
                                        platform = platform)   
    }
    
  })
  
  output$error_detail <- DT::renderDataTable({
    
    sample_error_url_details()
    
  }, selection ='single')
  
  
}
)

# runApp(app, port=4624)