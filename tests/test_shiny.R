library(shiny)
library(magrittr)
source('~/dev/R/SearchConsoleR/R/scr_auth.R')
source('~/dev/R/SearchConsoleR/R/getData.R')
source('~/dev/R/SearchConsoleR/R/http_requests.R')

# The object can be passed to runApp()
app <- shinyApp(
  ui = fluidPage(
    shiny::dataTableOutput("websites"),
    textOutput("url_pars"),
    textOutput("queryText"),
    textOutput("summary")
  ),
  server = function(input, output, session) {
    
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

    web <- reactive({
      
      s <- scr_auth(shiny=session)
      
      s
    })
    
    output$websites <- renderDataTable({
  
      w <- web()
      
      message(str(w))
      message(str(w$access_token))
      
      ww <- .state$websites
      
      message(str(ww))
      
      www <- list_websites()
      
      message(str(www))
      
      www
      
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
