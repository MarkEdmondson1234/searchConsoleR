library(shiny)
library(DT)
library(searchConsoleR)
source('global.R')

shinyServer(function(input, output, session) {
  
  cdata <- session$clientData
  
  shiny_google_token_session_scope <- NULL
  
  ## Make a button to link to Google auth screen
  ## If auth_code is returned then don't show login button
  output$loginButton <- renderUI({
    if(is.null(isolate(auth()))) {
      actionLink("loginButton",
                 label = a("Authorize App",
                           href = shinygaGetTokenURL(getShinyURL(session))))
    } else {
      return()
    }
  })
  
  ## Get auth code from return URL
  access_token  <- reactive({
    ## gets all the parameters in the URL. The auth code should be one of them.
    pars <- parseQueryString(session$clientData$url_search)
    
    if(length(pars$code) > 0) {
      ## extract the authorization code
      get_google_token_shiny(session) 
    } else {
      NULL
    }
  })
  

  auth <- reactive({
    
    token <- access_token()
    
    if(!is.null(token)){
      a <- scr_auth(token = token, shiny_session=session)      
    }
    
  })
  
  # Values from cdata returned as text
  output$clientdataText <- renderText({
    cnames <- names(cdata)
    
    allvalues <- lapply(cnames, function(name) {
      paste(name, cdata[[name]], sep=" = ")
    })
    paste(allvalues, collapse = "\n")
  })
  
  output$token_websites <- renderTable({
    if(!is.null(auth())){
      Authentication$public_fields$website
    }
  })
  
  website_df <- reactive({
    if(!is.null(auth())){
      www <- list_websites(session)           
    }
    
  })
  

  
  observe({
    
    www <- website_df()
    urls <- www[www$permissionLevel != "siteUnverifiedUser",'siteUrl']
    
    updateSelectInput(session,
                      "website_select",
                      choices = urls)
    
  })
  
  sa_trend_data <- reactive({
    www <- input$website_select
    dates <- input$date_range
    # dims <- input$dims
    type <- input$type
    dim_filter <- input$filter_dim
    dim_op <- input$filter_op
    dim_ex <- input$filter_ex
    
    
    if(!is.null(auth())){
      
      if(all(dim_filter != "none", !is.null(dim_ex))){
        dfe <- paste0(dim_filter,dim_op,dim_ex)
      } else {
        dfe = NULL
      }
      
      sa <- search_analytics(www, dates[1], dates[2],
                             dimensions = c('date'),
                             searchType = type,
                             dimensionFilterExp = dfe,
                             session = session)
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
    
    
    if(!is.null(auth()) && !is.null(dims)){
      
      if(all(dim_filter != "none", !is.null(dim_ex))){
        dfe <- paste0(dim_filter,dim_op,dim_ex)
      } else {
        dfe = NULL
      }
      
      sa <- search_analytics(www, dates[1], dates[2],
                             dimensions = dims,
                             searchType = type,
                             dimensionFilterExp = dfe, prettyNames = FALSE,
                             session = session)
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
    
    
    if(!is.null(auth()) && !is.null(selected_row)){
      
      data_dims <- data_row[,dims]
      ## construct the filter
      dfe <- paste(dims, "==", data_dims)
      message(dfe)
      sa <- search_analytics(www, dates[1], dates[2],
                             dimensions = c('date'),
                             searchType = type,
                             dimensionFilterExp = dfe,
                             session = session)      
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
    
    if(!is.null(auth())){
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
    
    if(!is.null(auth())){
      s <- www  
    } else {
      s <- "Select a website in table above."
    }
    
    s
    
  })
  
  output$crawl_errors <- renderPlot({
    
    www <- input$website_select
    errors <- input$errors
    platform <- input$platform
    
    if(!is.null(auth())){
      
      ce <- try(
        crawl_errors(www, 
                     category = errors, 
                     platform = platform, 
                     session = session)
      )
      
      if(!is.error(ce)){
        plot(ce$timecount, ce$count, type="l")                 
      }
    }
    
  })
  
  crawl_error_df <- reactive({
    www <- input$website_select
    errors <- input$errors
    platform <- input$platform
    
    if(!is.null(auth())){
      
      error_df <- try(list_crawl_error_samples(www, 
                                               category = errors, 
                                               platform = platform,
                                               session = session))
      if(!is.error(error_df)){
        
        error_df$last_crawled <- as.Date(error_df$last_crawled)
        error_df$first_detected <- as.Date(error_df$first_detected)
        
        error_df
      }
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
    
    if(!is.null(auth()))
    {
      df_err <- error_sample_url(www, 
                                 sample_error_url, 
                                 category = errors, 
                                 platform = platform,
                                 session = session)     
    }
    
  })
  
  output$error_detail <- DT::renderDataTable({
    
    sample_error_url_details()
    
  }, selection ='single')
  
  
}
)

# runApp(app, port=4624)