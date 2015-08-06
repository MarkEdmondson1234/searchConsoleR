library(shiny)
library(DT)
library(magrittr)
library(searchConsoleR)

is.error <- function(test_me){
  inherits(test_me, "try-error")
}

# runApp(app, port=4624)
