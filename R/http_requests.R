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
searchconsole_GET <- function(url, 
                              to_json = TRUE, ...) {
    

    req <- httr::GET(url, get_google_token(), ...)

    httr::stop_for_status(req)
    ## TO DO: interpret some common problems for user? for example, a well-formed
    ## ws_feed for a non-existent spreadsheet will trigger "client error: (400)
    ## Bad Request" ... can we confidently say what the problem is?
    
    ok_content_types <- c("application/json; charset=UTF-8")
    if(!(req$headers$`content-type` %in% ok_content_types)) {
      stop(sprintf(paste("Not expecting content-type to be:\n%s"),
                   req$headers[["content-type"]]))
      # usually when the content-type is unexpectedly binary, it means we need to
      # refresh the token ... we should have a better message or do something
      # constructive when this happens ... sort of waiting til I can review all
      # the auth stuff
    }
    
    # This is only FALSE when calling gs_ws_modify() where we are using regex
    # substitution, waiting for xml2 to support XML editing
    if(to_json) {
      req$content <- req %>%
        httr::content(as = "text", type = "application/json",encoding = "UTF-8") %>%
        jsonlite::fromJSON()
    }
    
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
  
  token <- get_google_token()
  
  if(is.null(token)) {
    stop("Must be authorized user in order to perform request")
  } else {
    
    req <-
      httr::POST(url,
                 encode="form",
                 body = the_body)
    httr::stop_for_status(req)
    
    req$content <- httr::content(req, encoding = "UTF-8")
    
    if(!is.null(req$content)) {
      ## known example of this: POST request triggered by gs_ws_new()
      req$content <- req$content %>% xml2::read_xml()
    }
    
    req
    
  }
}

#' Create DELETE request
#'
#' Make DELETE request to Search Console API.
#'
#' @param url the url of the page to retrieve
#'
#' @keywords internal
searchconsole_DELETE <- function(url) {
  req <- httr::DELETE(url, get_google_token())
  httr::stop_for_status(req)
  ## I haven't found any use yet for this return value, but adding for symmetry
  ## with other http functions
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
  
  token <- get_google_token()
  
  if(is.null(token)) {
    stop("Must be authorized in order to perform request")
  }
  
  req <-
    httr::PUT(url,
              config = token,
              body = the_body)
  
  httr::stop_for_status(req)
  
  req$content <- httr::content(req, type = "text/xml")
  if(!is.null(req$content)) {
    ## known example of this: POST request triggered by gs_ws_new()
    req$content <- XML::xmlToList(req$content)
  }
  
  req
  
}