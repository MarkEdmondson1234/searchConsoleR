library(shiny)
library(DT)
library(searchConsoleR)

is.error <- function(test_me){
  inherits(test_me, "try-error")
}

# shiny::runApp("./tests/shiny_test", port=4624)
