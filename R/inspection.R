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
