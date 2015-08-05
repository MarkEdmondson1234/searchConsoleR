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

#' Checks valid parameters for Google Search Console
#' 
#' The error type listings have certain categories/platform allowed.
#' 
#' @return TRUE if valid, raises an error if not.
#' 
#' @keywords internal
is.valid.category.platform <- function (category, platform, include.all=FALSE) {
  
  categories <- getOption("searchConsoleR.valid.categories")
  platforms  <- getOption("searchConsoleR.valid.platforms")
  
  if(include.all){
    categories <- c('all', categories)
    platforms <- c('all', platforms)
  }
  
  if(!category %in% categories) {
    stop("Incorrect category.  Must be one of ", paste(categories, collapse=","))
  }
  
  if(!platform %in% platforms){
    stop("Incorrect platform. Must be one of ", paste(platforms, collapse=", "))
  }
  
  TRUE
}

#' Checks Urls are in right format for API request
#' 
#' @param url The URL to check for use in API request
#' @param checkProtocol Check if URL starts with 'http'
#' @param ... Passed to URLencode()
#' 
#' @return Modified url if successful, raises an error if not.
#' 
#' @keywords internal
check.Url <- function(url, checkProtocol=TRUE, ...){
  
  if(!is.null(url)){
    if(checkProtocol && !grepl("http",url)){
      stop("URL must include protocol, e.g. http://example.com - got:", url) 
    }
    
    if(!grepl("%3A%2F%2F", url)){
      url <- URLencode(url, ...)
      message("Encoding URL to ", url)
    }
    
    url    
    
  } else {
    stop("Null URL")
  }
}

#' Converts RFC3339 to as.Date
#' 
#' @keywords internal
RFC_convert <- function(RFC, drop_time=FALSE){
  
  if(drop_time){
    d <-   as.Date(strptime(as.character(RFC), 
                            tz="UTC", 
                            "%Y-%m-%dT%H:%M:%OSZ"))
  } else {
    d <- strptime(as.character(RFC), 
                  tz="UTC", 
                  "%Y-%m-%dT%H:%M:%OSZ")
  }
  
  return(d)
}