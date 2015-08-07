library(shiny)
library(DT)
library(searchConsoleR)

is.error <- function(test_me){
  inherits(test_me, "try-error")
}

Authentication$set("public", "token", NULL, overwrite=TRUE)
Authentication$set("public", "websites", NULL, overwrite=TRUE)
# shiny::runApp("./tests/shiny_test", port=4624)
