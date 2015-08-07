#' Get URL content based on if its Shiny or local
#' 
#' @description
#' This changes the auth type depending on if its local or on Shiny
#' 
#' @param url the url of the page to retrieve
#' @param session a shiny session object if in a shiny app.
#' @param request_type the type of httr request function: GET, POST, PUT, DELETE etc.
#' @param the_body body of POST request
#' @param params A named character vector of other parameters to add to request.
#' 
#' @details Example of params: c(param1="foo", param2="bar")
#' 
#' 
#' @keywords internal
doHttrRequest <- function(url,
                          session = NULL,
                          request_type="GET", 
                          the_body=NULL, 
                          params=NULL, ...){
  
  ## add any other params
  ## expects named character e.g. c(param1="foo", param2="bar")
  if(!is.null(params)){
    
    param_string <- paste(names(params), params, 
                          sep='=', collapse='&')

    url <- paste0(url, '?',param_string)

  }
  
  arg_list <- list(url = url, 
                   config = get_google_token(session), 
                   body = the_body)
  if(!is.null(list(...))){
    arg_list <- c(arg_list, list(...))    
  }
  
  arg_list <- c(arg_list, list(httr::verbose()))

  req <- do.call(request_type, 
                 args = arg_list,
                 envir = asNamespace("httr"))
  
  ok_content_types <- c("application/json; charset=UTF-8")
  if(!(req$headers$`content-type` %in% ok_content_types)) {
    
    stop(sprintf(paste("Not expecting content-type to be:\n%s"),
                 req$headers[["content-type"]]))
    
  }
  
  httr::stop_for_status(req)
  
  # message("DEBUG:: str(req)::", str(req))

  req
}

#' Create GET request
#'
#' Make GET request to Search Console API.
#'
#' @param url the url of the page to retrieve
#' @param to_json whether to convert response contents to JSON or
#'   leave as character string
#' @param use_auth logical; indicates if authorization should be used, defaults
#'   to \code{FALSE} if \code{url} implies public visibility and \code{TRUE}
#'   otherwise
#' @param params A named character vector of other parameters to add to request.
#'
#' @keywords internal
searchconsole_GET <- function(url,
                              session = NULL, 
                              to_json = TRUE, 
                              params=NULL) {
    
  req <- doHttrRequest(url, session, request_type = "GET", params = params)
  
  if(to_json) {
    content <- httr::content(req, as = "text", type = "application/json",encoding = "UTF-8")
    content <- jsonlite::fromJSON(content)
    req$content <- content
  }
  
  req
    
}

#' Create POST request
#'
#' Make POST request to Search Console API.
#'
#' @param url the url of the page to retrieve
#' @param the_body body of POST request
#' @param params A named character vector of other parameters to add to request.
#'
#' @keywords internal
searchconsole_POST <- function(url, 
                               session = NULL, 
                               the_body = NULL, 
                               params=NULL, ...) {
  
  req <- doHttrRequest(url, session, "POST", 
                       the_body = the_body, 
                       params = params, encode = "json", ...)
    
  content <- httr::content(req, as = "text", type = "application/json",encoding = "UTF-8")
  content <- jsonlite::fromJSON(content)
  req$content <- content
  
  req
    
}

#' Create DELETE request
#'
#' Make DELETE request to Search Console API.
#'
#' @param url the url of the page to retrieve
#' @param params A named character vector of other parameters to add to request.
#' @keywords internal
searchconsole_DELETE <- function(url, 
                                 session = NULL, 
                                 params=NULL) {
  
  req <- doHttrRequest(url, session, "DELETE", params = params)

  req
}

#' Create PUT request
#'
#' Make PUT request to Search Console API.
#'
#' @param url the url of the page to retrieve
#' @param the_body body of PUT request
#' @param params A named character vector of other parameters to add to request.
#' 
#' @keywords internal
searchconsole_PUT <- function(url, 
                              session = NULL, 
                              the_body = NULL, 
                              params=NULL) {
  
  req <- doHttrRequest(url, session, "PUT", the_body = the_body, params = params)
  
  req
  
}