library(shiny)
library(magrittr)
library(searchConsoleR)

# The object can be passed to runApp()
app <- shinyApp(
  
  ui = fluidPage(
    h3("Search Console Websites"),
    DT::dataTableOutput("websites"),
    textOutput("selected_url"),
    h3("Crawl Errors - Not Found"),
    plotOutput("crawl_errors"),
    h3("URL parameters"),
    textOutput("queryText"),
    h3("shiny session data"),
    textOutput("summary")
  ),
  server = function(input, output, session) {
    
    auth <- reactive({
      
      a <- scr_auth(shiny_session = session)
      
    })
    
    output$websites <- DT::renderDataTable({
      
      a <- auth()
      
      www <- list_websites()
      
      DT::datatable(www, selection = 'single')
      
    })
    
    selected_www <- reactive({
      a <- auth()
      www <- list_websites()
      selected_row <- input$websites_rows_selected
      
      ## pick the last click
      selected_row <- selected_row[length(selected_row)]
      
      www <- www[selected_row,]    
      
    })
    
    output$selected_url <- renderText({
      www <- selected_www()
      
      www$siteUrl
      
    })
    
    output$crawl_errors <- renderPlot({
      
      www <- selected_www()
      
      if(!is.null(www)){
        
        ce <- crawl_errors(www[,'siteUrl'], category = "notFound", platform = "web")
        
        plot(ce$timecount, ce$count, type="l")        
        
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

runApp(app, port=4624)
