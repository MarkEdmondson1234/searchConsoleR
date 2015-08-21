## Run via shiny::runApp("./tests/shiny_test", port=4624)
options("googleAuthR.scopes.selected" = getOption("searchConsoleR.scope") )
options("googleAuthR.client_id" = getOption("searchConsoleR.client_id"))
options("googleAuthR.client_secret" = getOption("searchConsoleR.client_secret"))
options("googleAuthR.webapp.client_id" = getOption("searchConsoleR.webapp.client_id"))
options("googleAuthR.webapp.client_secret" = getOption("searchConsoleR.webapp.client_secret"))


is.error <- function(test_me){
  inherits(test_me, "try-error")
}