#' Perform an inspection of URL index coverage
#' 
#' @param inspectionUrl URL to inspect
#' @param siteUrl The URL of the property as defind in Search Console
#' @param languageCode Optional.  An IETF BCP-47 language code representing the requested language for translated issue messages e.g. "en-US" (the default)
#' @export
#' @importFrom googleAuthR gar_api_generator gar_batch_walk
#' 
#' @return An R list containing the crawl information
#' @seealso \url{https://developers.google.com/webmaster-tools/v1/urlInspection.index/inspect}
#' @examples 
#' 
#' \dontrun{
#' 
#' # siteUrl parameter has to be one of these
#' list_websites()
#' 
#' # get a URL from your website
#' inspection("https://code.markedmondson.me/searchConsoleR/",
#'            "sc-domain:code.markedmondson.me")
#' }
inspection <- function(inspectionUrl,
                       siteUrl,
                       languageCode = NULL){
  
  stopifnot(is.character(inspectionUrl),
            is.character(siteUrl))
  
  endpoint <- "https://searchconsole.googleapis.com/v1/urlInspection/index:inspect"
  
  body <- list(
    inspectionUrl = inspectionUrl,
    siteUrl = siteUrl,
    languageCode = languageCode
  )
  
  f <- gar_api_generator(
    endpoint, "POST", 
    data_parse_function = parse_inspection,
    checkTrailingSlash = FALSE
  )
  
  default_project_message()
  
  f(the_body = body)
  
}

parse_inspection <- function(x){
  o <- x[["inspectionResult"]]
  
  o$indexStatusResult$lastCrawlTime <- RFC_convert(o$indexStatusResult$lastCrawlTime)
  
  structure(o, class = "inspectionResult")
  
}

#' @export
print.inspectionResult <- function(x, ...){
  cat("==SearchConsoleInspectionResult==\n")
  cat("inspectionResultLink: ", x$inspectionResultLink)
  
  if(!is.null(x$indexStatusResult)){
    cat("\n===indexStatusResult===\n")
    print(x$indexStatusResult)
  }
  
  if(!is.null(x$ampResult)){
    cat("\n===AmpResult===\n")
    print(x$ampResult)
  }
  
  if(!is.null(x$mobileUsabilityResult)){
    cat("\n===MobileUsabilityResult===\n")
    print(x$mobileUsabilityResult)
  }
  
  if(!is.null(x$richResultsResult)){
    cat("\n===richResults===\n")
    print(x$richResultsResult)
  }
}


is_default_project <- function(){
  
  # if no service auth then its not using default client.id #324
  if(googleAuthR::gar_has_token()){
    token <- googleAuthR::gar_token()
    if(!is.null(token$auth_token$secrets) &&
       token$auth_token$secrets$type == "service_account") return(FALSE)
  }
  
  # if set web json then its shiny #333
  if(!is.null(getOption("googleAuthR.webapp.client_id")) &&
     getOption("googleAuthR.webapp.client_id") != ""){
    return(FALSE)
  }
  
  getOption("googleAuthR.client_id") %in% c("858905045851-iuv6uhh34fqmkvh4rq31l7bpolskdo7h.apps.googleusercontent.com")
}

default_project_message <- function(){
  
  if(is_default_project()){
    cli::cli_alert_info("Default Google Project for searchConsoleR is set.  \n This is shared with all searchConsoleR users and only has 2000 query quota per day. \n If making a lot of Inspection API calls, please consider setting your own ClientId from your own Google Project \n")
    
  }
  
}
