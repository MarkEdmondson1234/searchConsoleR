#' Creates a random character code
#' 
#' @keywords internal
createCode <- function(seed=NULL, num=20){
  if (!is.null(seed)) set.seed(seed)
  
  paste0(sample(c(1:9, LETTERS, letters), num, replace = T), collapse='')
} 

is.error <- function(test_me){
  inherits(test_me, "try-error")
}

#' Returns the authentication parameter "code" in redirected URLs
#' 
#' @keywords internal
authReturnCode <- function(session, securityCode){    
  message("AuthReturnCode")

  pars <- shiny::parseQueryString(session$clientData$url_search)
  
  if(!is.null(pars$state)){
    if(pars$state != securityCode){
      warning("securityCode check failed in Authentication! Code:", 
              pars$state, 
              " Expected:", 
              securityCode)
      return(NULL)
      } 
  }
  
  if(!is.null(pars$code)){
    message("Returning code: ", pars$code)
    return(pars$code)
  } else {
    message("No code found")
    NULL
  }
}

## valid shiny session object?
is_shiny <- function(shiny_session){
  inherits(shiny_session, "ShinySession")
}


#' Returns the authentication URL
#' 
#' @keywords internal
shinygaGetTokenURL <- 
  function(state,
           redirect.uri,
           client.id     = getOption("SearchConsoleR.webapp.client_id"),
           client.secret = getOption("SearchConsoleR.webapp.client_secret"),
           scope         = getOption("SearchConsoleR.scope")) {
    
    scopeEnc <- sapply(scope, URLencode, reserved=TRUE)
    scopeEnc <- paste(scopeEnc, sep='', collapse='+')
    
    url <- paste('https://accounts.google.com/o/oauth2/auth?',
                 'scope=',scopeEnc,'&',
                 'state=',state,'&',
                 'redirect_uri=', redirect.uri, '&',
                 'response_type=code&',
                 'client_id=', client.id, '&',
                 'approval_prompt=auto&',
                 'access_type=online', sep='', collapse='');
    return(url)
  }


#' get the apps URL as default
#' 
#' only works in reactive shiny enironment
#' @keywords internal
getShinyURL <- function(session){
  message("GetShinyURL")
  
  if(!is.null(session)){
    pathname <- session$clientData$url_pathname
    ## hack for shinyapps.io
    if(session$clientData$url_hostname == "internal.shinyapps.io"){
      split_hostname <- strsplit(pathname, "/")[[1]]
      hostname <-  paste(split_hostname[2],"shinyapps.io", sep=".")
      pathname <- paste0("/",split_hostname[3],"/")
      
    } else {
      hostname <- session$clientData$url_hostname
    }
    
    paste0(session$clientData$url_protocol,
           "//",
           hostname,
           ifelse(hostname == "127.0.0.1",
                  ":",
                  pathname),
           session$clientData$url_port)
  } else {
    NULL
  }
  
  
}


#' Returns the authentication Token
#' 
#' Once a user browses to ShinyGetTokenURL and is redirected back with request
#' shinygaGetToken takes that code and returns a token needed for Google APIs
#' Uses the same client.id and client.secret as ShinyGetTokenURL
#' 
#' @keywords internal
shinygaGetToken <- function(code,
                            redirect.uri,
                            client.id     = getOption("SearchConsoleR.webapp.client_id"),
                            client.secret = getOption("SearchConsoleR.webapp.client_secret")){
  
  raw.data <- httr::POST('https://accounts.google.com/o/oauth2/token',
                         encode = "form",
                         body = list(code = code,
                                     client_id = client.id,
                                     client_secret = client.secret,
                                     redirect_uri = redirect.uri,
                                     grant_type = 'authorization_code')
  )
  
  token.data <- httr::content(raw.data)
  now        <- as.numeric(Sys.time())
  token      <- c(token.data, timestamp = c('first'=now, 'refresh'=now))
  
  # environment to store credentials
  # a better way, integrate with future integrations
  .state <- new.env(parent = emptyenv())
  .state$token <- token
  
  return(token)
}

