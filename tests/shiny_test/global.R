## Run via shiny::runApp("./tests/shiny_test", port=4624)

is.error <- function(test_me){
  inherits(test_me, "try-error")
}