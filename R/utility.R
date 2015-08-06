#' Helper function for the query dimension filters
#' 
#' Saves the need for 3 parameters when you just have one
#' 
#' @param dfe A string of form: dimension operator expression e.g. country!~GBR
#' 
#' @details dimension = c('country','device','page','query')
#'   operator = c(`~~` = 'contains',
#'                `==` = 'equals',
#'                `!~` = 'notContains',
#'                 `!=` = 'notEquals)
#'  
#'  expression = country: an ISO 3166-1 alpha-3 country code.
#'               device: 'DESKTOP','MOBILE','TABLET'
#'               page: not checked
#'               query: not checked
#'          
#' @keywords internal
parseDimFilterGroup <- function(dfe){
  
  ## get lookup data
  country.codes <- ISO_3166_1$Alpha_3
  devices <- c('DESKTOP','MOBILE','TABLET')
  op_symbol <-  c("~~" = 'contains',
                  "==" = 'equals',
                  "!~" = 'notContains',
                  "!=" = 'notEquals')
  
  ## remove whitespace
  dfe <- stringr::str_replace_all(dfe, " ","")
  
  ## extract variables needed
  operator <- stringr::str_extract(dfe, "[\\!=~]{2}")
  dim_ex <- stringr::str_split_fixed(dfe, "[\\!=~]{2}", n=2)
  
  ## check variables
  if(!dim_ex[1] %in% c('country','device','page','query')){
    stop("dimension not one of: ", 
         paste(c('country','device','page','query')), 
         " Got this: ", 
         dim_ex[1])
  }
  
  if(!op_symbol[operator] %in% op_symbol){
    stop("Operator not one of ~~, ==, !~ or !=.")
  }
  
  if(is.na(operator) || nchar(dim_ex[2]) == 0){
    stop("Incorrect format of filter: Need 'dimension' 'operator' 'expression'. e.g. 'country!~GBR' or 'device==MOBILE'. Got this:   ", dfe)
  }
  
  if(dim_ex[1] == "country" && !dim_ex[2] %in% country.codes ){
    stop("country dimension indicated, but country code not an ISO 3166-1 alpha-3 type. e.g. GBR = United Kingdom. Got this:   ", dim_ex[2])
  }
  
  if(dim_ex[1] == "device" && !dim_ex[2] %in% devices ){
    stop("device dimension indicated, but device not one of DESKTOP, MOBILE or TABLET (no quotes). Got this:   ", dim_ex[2])
  }
  
  ## need to make non-box version
  ## https://github.com/hadley/httr/issues/159
  list(dimension = dim_ex[1],
       operator  = unname(op_symbol[operator]),
       expression = dim_ex[2])
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