.onLoad <- function(libname, pkgname) {
  
  op <- options()
  op.searchConsoleR <- list(
    ## httr_oauth_cache can be a path, but I'm only really thinking about and
    ## supporting the simpler TRUE/FALSE usage, i.e. assuming that .httr-oauth
    ## will live in current working directory if it exists at all
    ## this is main reason for creating this searchConsoleR-specific variant
    searchConsoleR.client_id = "858905045851-3beqpmsufml9d7v5d1pr74m9lnbueak2.apps.googleusercontent.com",
    searchConsoleR.client_secret = "bnmF6C-ScpSR68knbGrHBQrS",
    searchConsoleR.webapp.client_id = "858905045851-iuv6uhh34fqmkvh4rq31l7bpolskdo7h.apps.googleusercontent.com",
    searchConsoleR.webapp.client_secret = "rFTWVq6oMu5ZgYd9e3sYu2tm",
    searchConsoleR.scope = "https://www.googleapis.com/auth/webmasters",
    searchConsoleR.valid.categories = c('authPermissions', 
                                        'manyToOneRedirect',
                                        'notFollowed',
                                        'notFound',
                                        'other',
                                        'roboted',
                                        'serverError',
                                        'soft404'),
    
    searchConsoleR.valid.platforms = c('mobile',
                                       'smartphoneOnly',
                                       'web')
  )
  toset <- !(names(op.searchConsoleR) %in% names(op))
  if(any(toset)) options(op.searchConsoleR[toset])
  
  invisible()
  
}