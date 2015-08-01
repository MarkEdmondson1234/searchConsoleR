.onLoad <- function(libname, pkgname) {
  
  op <- options()
  op.SearchConsoleR <- list(
    ## httr_oauth_cache can be a path, but I'm only really thinking about and
    ## supporting the simpler TRUE/FALSE usage, i.e. assuming that .httr-oauth
    ## will live in current working directory if it exists at all
    ## this is main reason for creating this SearchConsoleR-specific variant
    SearchConsoleR.httr_oauth_cache = TRUE,
    SearchConsoleR.client_id = "858905045851-3beqpmsufml9d7v5d1pr74m9lnbueak2.apps.googleusercontent.com",
    SearchConsoleR.client_secret = "bnmF6C-ScpSR68knbGrHBQrS",
    SearchConsoleR.webapp.client_id = "858905045851-iuv6uhh34fqmkvh4rq31l7bpolskdo7h.apps.googleusercontent.com",
    SearchConsoleR.webapp.client_secret = "rFTWVq6oMu5ZgYd9e3sYu2tm",
    SearchConsoleR.scope = "https://www.googleapis.com/auth/webmasters",
    SearchConsoleR.securitycode = paste0(sample(c(1:9, LETTERS, letters), 20, replace = T), collapse='')
  )
  toset <- !(names(op.SearchConsoleR) %in% names(op))
  if(any(toset)) options(op.SearchConsoleR[toset])
  
  invisible()
  
}