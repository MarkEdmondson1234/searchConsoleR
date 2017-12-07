.onLoad <- function(libname, pkgname) {
  
  op <- options()
  op.searchConsoleR <- list(
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


.onAttach <- function(libname, pkgname){
  
  ## override any existing setting
  options(googleAuthR.batch_endpoint = 'https://www.googleapis.com/batch/webmasters/v3',
          googleAuthR.httr_oauth_cache = 'sc.oauth')
  
  suppressMessages(googleAuthR::gar_attach_auto_auth("https://www.googleapis.com/auth/webmasters", 
                                    environment_var = "SC_AUTH_FILE"))
  
  invisible()
  
}

