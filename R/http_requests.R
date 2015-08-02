#' Create GET request
#'
#' Make GET request to Search Console API.
#'
#' @param url the url of the page to retrieve
#' @param to_xml whether to convert response contents to an \code{xml_doc} or
#'   leave as character string
#' @param use_auth logical; indicates if authorization should be used, defaults
#'   to \code{FALSE} if \code{url} implies public visibility and \code{TRUE}
#'   otherwise
#' @param ... optional; further named parameters, such as \code{query},
#'   \code{path}, etc, passed on to \code{\link[httr]{modify_url}}. Unnamed
#'   parameters will be combined with \code{\link[httr]{config}}.
#'
#' @keywords internal
searchconsole_GET <- function(url, to_json = TRUE) {
    
  req <- doHttrRequest(url, "GET")

  ok_content_types <- c("application/json; charset=UTF-8")
  if(!(req$headers$`content-type` %in% ok_content_types)) {
    
    stop(sprintf(paste("Not expecting content-type to be:\n%s"),
                 req$headers[["content-type"]]))

  }
  
  if(to_json) {
    req$content <- req %>%
      httr::content(as = "text", type = "application/json",encoding = "UTF-8") %>%
      jsonlite::fromJSON()
  }
  
  req
    
}

#' Get URL content based on if its Shiny or local
#' 
#' This changes the auth type depending on if its local or on Shiny
#' 
#' @param url the url of the page to retrieve
#' @param request_type the type of httr request function: GET, POST, PUT, DELETE etc.
#' @param the_body body of POST request
#' 
#' @keywords internal
doHttrRequest <- function(url, request_type="GET", the_body=NULL){
  
  if(!.state$shiny){
    
    arg_list <- list(url = url, 
                     config = get_google_token(), 
                     body = the_body)
    
  } else {
    shiny_token <- .state$token
    url <- paste(url,
                 '?access_token=', 
                 shiny_token$access_token, 
                 sep='', collapse='')
    
    arg_list <- list(url = url, 
                     config = list(), 
                     body = the_body)

  }
  
  req <- do.call(request_type, 
                 args = arg_list,
                 envir = asNamespace("httr"))
  httr::stop_for_status(req)
  
  req
}


#' Create POST request
#'
#' Make POST request to Search Console API.
#'
#' @param url the url of the page to retrieve
#' @param the_body body of POST request
#'
#' @keywords internal
searchconsole_POST <- function(url, the_body) {
  
  req <- doHttrRequest(url, "POST", the_body = the_body)
    
  req$content <- httr::content(req, encoding = "UTF-8")
  
#   if(!is.null(req$content)) {
#     req$content <- req$content %>% xml2::read_xml()
#   }
  
  req
    
}

#' Create DELETE request
#'
#' Make DELETE request to Search Console API.
#'
#' @param url the url of the page to retrieve
#'
#' @keywords internal
searchconsole_DELETE <- function(url) {
  
  req <- doHttrRequest(url, "DELETE")

  req
}

#' Create PUT request
#'
#' Make PUT request to Search Console API.
#'
#' @param url the url of the page to retrieve
#' @param the_body body of PUT request
#'
#' @keywords internal
searchconsole_PUT <- function(url, the_body) {
  
  req <- doHttrRequest(url, "PUT", the_body = the_body)
  
  req
  
}