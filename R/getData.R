#' Retrieves dataframe of websites user has in Search Console
#'
#' @return a dataframe of siteUrl and permissionLevel
#'
#' @keywords internal
list_websites <- function() {
  
  ## require pre-existing token, to avoid recursion that would arise if
  ## gdrive_GET() called scr_auth()
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    message("Token found and legit")
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/sites/list
    req <- searchconsole_GET("https://www.googleapis.com/webmasters/v3/sites")
    
    req$content$siteEntry
    
  } else {
    
    NULL
    
  }
  
}

#' Adds website to Search Console
#'
#' @return NULL
#'
#' @keywords internal
add_website <- function(siteURL) {
  
  ## require pre-existing token, to avoid recursion that would arise if
  ## gdrive_GET() called scr_auth()
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/sites/add
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", siteURL)
    req <- searchconsole_PUT(req_url, the_body = NULL)
    
    TRUE
    
  } else {
    
    NULL
    
  }
  
}

#' Deletes website in Search Console
#'
#' @return TRUE if it worked
#'
#' @keywords internal
delete_website <- function(siteURL) {
  
  ## require pre-existing token, to avoid recursion that would arise if
  ## gdrive_GET() called scr_auth()
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/sites/add
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", siteURL)
    searchconsole_DELETE(req_url)
    
    TRUE
    
  } else {
    
    NULL
    
  }
  
}