#' Creates a random character code
#' 
#' @param seed random seed.
#' @param num number of characters the code should be.
#' 
#' @return a string of random digits and letters.
#' 
#' @keywords internal
createCode <- function(seed=NULL, num=20){
  if (!is.null(seed)) set.seed(seed)
  
  paste0(sample(c(1:9, LETTERS, letters), num, replace = T), collapse='')
} 

#' Is this a try error?
#' 
#' Utility to test errors
#' 
#' @param test_me an object created with try()
#' 
#' @return Boolean
#' 
#' @keywords internal
is.error <- function(test_me){
  inherits(test_me, "try-error")
}

#' Returns the authentication parameter "code" in redirected URLs
#' 
#' Checks the URL of the Shiny app to get the state and code URL parameters.
#' 
#' @param session A shiny session object
#' @param securityCode A random string to check the auth comes form the same origin.
#' 
#' @return The Google auth token in the code URL parameter.
#' 
#' @keywords internal
authReturnCode <- function(session, securityCode){

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
    return(pars$code)
  } else {
    NULL
  }
}

#' Is this a valid shiny session object?
#' 
#' Checks that a valid Shiny session object has been passed.
#' 
#' @param shiny_session a Shiny session object.
#' 
#' @return Boolean
#' 
#' @keywords internal
is_shiny <- function(shiny_session){
  inherits(shiny_session, "ShinySession")
}


#' Returns the Google authentication URL
#' 
#' The URL a user authenticates the Shiny app on.
#' 
#' @param state A random string used to check auth is from same origin.
#' @param redirect.uri Where a user will go after authentication.
#' @param client.id From the Google API console.
#' @param client.secret From the Google API console.
#' @param scope What Google API service to get authentication for.
#' 
#' @return The URL for authentication.
#' 
#' @keywords internal
shinygaGetTokenURL <- 
  function(state,
           redirect.uri,
           client.id     = getOption("searchConsoleR.webapp.client_id"),
           client.secret = getOption("searchConsoleR.webapp.client_secret"),
           scope         = getOption("searchConsoleR.scope")) {
    
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


#' Get the Shiny Apps URL.
#' 
#' Needed to for the redirect URL in Google Auth
#' 
#' @param session The shiny session object.
#' 
#' @return The URL of the Shiny App its called from.
#' 
#' @keywords internal
getShinyURL <- function(session){
  
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


#' Returns the authentication Token.
#' 
#' Once a user browses to ShinyGetTokenURL and is redirected back with request
#' shinygaGetToken takes that code and returns a token needed for Google APIs
#' Uses the same client.id and client.secret as ShinyGetTokenURL.
#' 
#' @param code The code returned from a successful Google authentication.
#' @param redirect.uri Where a user will go after authentication.
#' @param client.id From the Google API console.
#' @param client.secret From the Google API console.
#' 
#' @return A list including the token needed for Google API requests.
#' 
#' @keywords internal
shinygaGetToken <- function(code,
                            redirect.uri,
                            client.id     = getOption("searchConsoleR.webapp.client_id"),
                            client.secret = getOption("searchConsoleR.webapp.client_secret")){
  
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
  
  return(token)
}

