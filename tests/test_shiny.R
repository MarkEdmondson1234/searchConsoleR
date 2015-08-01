library(shiny)
source('~/dev/R/SearchConsoleR/R/scr_auth.R')

# The object can be passed to runApp()
app <- shinyApp(
  ui = fluidPage(
    numericInput("n", "n", 1),
    plotOutput("plot"),
    shiny::dataTableOutput("websites"),
    textOutput("url_pars"),
    textOutput("queryText")
  ),
  server = function(input, output, session) {
    output$plot <- renderPlot( plot(head(cars, input$n)) )
    
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
      
      scr_auth(shiny=session)
    })
    
    output$websites <- renderDataTable({
  
      web()
      
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
