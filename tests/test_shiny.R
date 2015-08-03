library(shiny)
library(DT)
library(magrittr)
library(searchConsoleR)

# The object can be passed to runApp()
app <- shinyApp(
  
  ui = fluidPage(
    h3("Search Console Websites"),
    DT::dataTableOutput("websites"),
    textOutput("selected_url"),
    h3("Crawl Errors"),
    selectInput("errors", 
                "Error Type",
                choices = c("Not Found" = "notFound",
                            "Soft 404" = "soft404",
                            "Auth Permissions" = "authPermissions",
                            "Many To One Redirect" = "manyToOneRedirect",
                            "Not Followed" = "notFollowed",
                            "Roboted" = "roboted",
                            "Server Error" = "serverError")),
    selectInput("platform",
                "Googlebot User Agent",
                choices = c("Web" = "web",
                            "SmartPhone" = "smartphoneOnly",
                            "Mobile" = "mobile")
                            ),
    plotOutput("crawl_errors"),
    h3("URL parameters"),
    textOutput("queryText"),
    h3("shiny session data"),
    textOutput("summary")
  ),
  server = function(input, output, session) {
    
    auth <- reactive({

      a <- scr_auth(shiny_session = session)
      
      a
      
    })
    
    website_df <- reactive({
      a <- auth()
      www <- list_websites()
    })
    
    output$websites <- DT::renderDataTable({
      
      website_df()
      
    }, selection = 'single')
    
    selected_www <- reactive({
      a <- auth()
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
      
      www <- selected_www()
      
      if(!is.null(www)){
        s <- www$siteUrl     
      } else {
        s <- "Select a website in table above."
      }
      
      s
        
    })
    
    output$crawl_errors <- renderPlot({
      
      www <- selected_www()
      errors <- input$errors
      platform <- input$platform
      
      if(!is.null(www)){
 
        ce <- try(crawl_errors(www$siteUrl, category = errors, platform = platform))
        
        if(!is.error(ce)){
          plot(ce$timecount, ce$count, type="l")                 
        }
      }
      
    })

    # Print out clientData, which is a reactiveValues object.
    # This object is list-like, but it is not a list.
    output$summary <- renderText({
      # Find the names of all the keys in clientData
      cnames <- names(session$clientData)
      
      # Apply a function to all keys, to get corresponding values
      allvalues <- lapply(cnames, function(name) {
        item <- session$clientData[[name]]
        if (is.list(item)) {
          list_to_string(item, name)
        } else {
          paste(name, item, sep=" = ")
        }
      })
      paste(allvalues, collapse = "\n")
    })
    
    pars <- reactive({parseQueryString(session$clientData$url_search)})
    
    # Parse the GET query string
    output$queryText <- renderText({
      
      query <- pars()
      # Return a string with key-value pairs
      paste(names(query), query, sep = "=", collapse=", ")
    })


  }
)

list_to_string <- function(obj, listname) {
  if (is.null(names(obj))) {
    paste(listname, "[[", seq_along(obj), "]] = ", obj,
          sep = "", collapse = "\n")
  } else {
    paste(listname, "$", names(obj), " = ", obj,
          sep = "", collapse = "\n")
  }
}

is.error <- function(test_me){
  inherits(test_me, "try-error")
}

runApp(app, port=4624)
