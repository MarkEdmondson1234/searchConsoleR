options("googleAuthR.scopes.selected" = getOption("searchConsoleR.scope") )
options("googleAuthR.client_id" = getOption("searchConsoleR.client_id"))
options("googleAuthR.client_secret" = getOption("searchConsoleR.client_secret"))
options("googleAuthR.webapp.client_id" = getOption("searchConsoleR.webapp.client_id"))
options("googleAuthR.webapp.client_secret" = getOption("searchConsoleR.webapp.client_secret"))


#' Query search traffic keyword data
#' 
#' @description Download your Google SEO data.
#' 
#' @param siteURL The URL of the website you have auth access to.
#' @param startDate Start date of requested range, in YYYY-MM-DD.
#' @param endDate End date of the requested date range, in YYYY-MM-DD.
#' @param dimensions Zero or more dimensions to group results by: "date", "country", "device", "page" or "query"
#' @param searchType Search type filter, default 'web'.
#' @param dimensionFilterExp A character vector of expressions to filter. e.g. c("device==TABLET", "country~~GBR")
#' @param aggregationType How data is aggregated.
#' @param rowLimit How many rows, maximum is 5000.
#' @param prettyNames If TRUE, converts SO 3166-1 alpha-3 country code to full name and 
#'   creates new column called countryName.
#' @param walk_data Make an API call per day, which can increase the amount of data returned.
#' 
#' @return A dataframe with columns in order of dimensions plus metrics, with attribute "aggregationType"
#' 
#' @seealso Guide to Search Analytics: \url{https://support.google.com/webmasters/answer/6155685}
#'   API docs: \url{https://developers.google.com/webmaster-tools/v3/searchanalytics/query}
#' @export
#' 
#' @details 
#'  \strong{startDate}: Start date of the requested date range, in YYYY-MM-DD format, 
#'    in PST time (UTC - 8:00). Must be less than or equal to the end date. 
#'    This value is included in the range.
#'    
#'  \strong{endDate}: End date of the requested date range, in YYYY-MM-DD format, 
#'    in PST time (UTC - 8:00). Must be greater than or equal to the start date. 
#'    This value is included in the range.
#'    
#'  \strong{dimensions}: [Optional] Zero or more dimensions to group results by. 
#'       \itemize{
#'         \item 'date'
#'         \item 'country'
#'         \item 'device'
#'         \item 'page'
#'         \item 'query'
#'       }
#'  The grouping dimension values are combined to create a unique key 
#'    for each result row. If no dimensions are specified, 
#'    all values will be combined into a single row. 
#'    There is no limit to the number of dimensions that you can group by, 
#'    but you cannot group by the same dimension twice. Example: c(country, device)
#'  
#'  \strong{dimensionFilterExp}:
#'  Results are grouped in the order that you supply these dimensions. 
#'  dimensionFilterExp expects a character vector of expressions in the form:
#'   ("device==TABLET", "country~~GBR", "dimension operator expression")
#'   \itemize{
#'     \item dimension  
#'       \itemize{
#'         \item 'country'
#'         \item 'device'
#'         \item 'page'
#'         \item 'query'
#'       }
#'     \item operator 
#'       \itemize{
#'         \item '~~' meaning 'contains'
#'         \item '==' meaning 'equals'
#'         \item '!~' meaning 'notContains'
#'         \item '!=' meaning 'notEquals
#'       }
#'     
#'     \item expression 
#'        \itemize{
#'          \item country: an ISO 3166-1 alpha-3 country code.
#'          \item device: 'DESKTOP','MOBILE','TABLET'.
#'          \item page: not checked, a string in page URLs without hostname.
#'          \item query: not checked, a string in keywords.
#'        
#'        }
#'   }
#'  
#'  
#'  \strong{searchType}: [Optional] The search type to filter for. Acceptable values are:
#'  \itemize{
#'    \item "web": [Default] Web search results
#'    \item "image": Image search results
#'    \item "video": Video search results
#'  }
#'  
#'  \strong{aggregationType}: [Optional] How data is aggregated. 
#'  \itemize{
#'    \item If aggregated by property, all data for the same property is aggregated; 
#'    \item If aggregated by page, all data is aggregated by canonical URI. 
#'    \item If you filter or group by page, choose auto; otherwise you can aggregate either by property or by page, depending on how you want your data calculated; 
#'  }
#'    See the API documentation to learn how data is calculated differently by site versus by page. 
#'    Note: If you group or filter by page, you cannot aggregate by property.
#'    If you specify any value other than auto, the aggregation type in the result will match the requested type, or if you request an invalid type, you will get an error. 
#'    The API will never change your aggregation type if the requested type is invalid.
#'    Acceptable values are:
#'  \itemize{
#'    \item "auto": [Default] Let the service decide the appropriate aggregation type.
#'    \item "byPage": Aggregate values by URI.
#'    \item "byProperty": Aggregate values by property.
#'  }
#'  
search_analytics <- function(siteURL, 
                             startDate = Sys.Date() - 93, 
                             endDate = Sys.Date() - 3, 
                             dimensions = NULL, 
                             searchType = c("web","video","image"),
                             dimensionFilterExp = NULL,
                             aggregationType = c("auto","byPage","byProperty"),
                             rowLimit = 1000,
                             prettyNames = TRUE,
                             walk_data = FALSE){
  
  searchType      <- match.arg(searchType)
  aggregationType <- match.arg(aggregationType)
  
  startDate <- as.character(startDate)
  endDate   <- as.character(endDate)  

  message("Fetching search analytics for ", 
          paste("url:", siteURL, 
                "dates:", startDate, endDate,
                "dimensions:", paste(dimensions, collapse = " ", sep=";"),
                "dimensionFilterExp:", paste(dimensionFilterExp, collapse = " ", sep=";"), 
                "searchType:", searchType, 
                "aggregationType:", aggregationType))
  
  siteURL <- check.Url(siteURL, reserved=T)

  if(any(is.na(as.Date(startDate, "%Y-%m-%d")), is.na(as.Date(endDate, "%Y-%m-%d")))){
    stop("dates not in correct %Y-%m-%d format. Got these:", startDate, " - ", endDate)
  }
  
  if(any(as.Date(startDate, "%Y-%m-%d") > Sys.Date()-3, as.Date(endDate, "%Y-%m-%d") > Sys.Date()-3)){
    warning("Search Analytics usually not available within 3 days (96 hrs) of today(",Sys.Date(),"). Got:", startDate, " - ", endDate)
  }
  
  if(as.Date(startDate, "%Y-%m-%d") < Sys.Date()-93){
    warning("Search Analytics usually not available 93 days before today(",Sys.Date(),"). Got:", startDate, " - ", endDate)
  }
  
  if(!is.null(dimensions) && !dimensions %in% c('date','country', 'device', 'page', 'query')){
    stop("dimension must be NULL or one or more of 'date','country', 'device', 'page', 'query'. 
         Got this: ", paste(dimensions, sep=", "))
  }
  
  if(!searchType %in% c("web","image","video")){
    stop('searchType not one of "web","image","video".  Got this: ', searchType)
  }

  
  if(!aggregationType %in% c("auto","byPage","byProperty")){
    stop('aggregationType not one of "auto","byPage","byProperty". Got this: ', aggregationType)
  }
  
  if(aggregationType %in% c("byProperty") && 'page' %in% dimensions ){
    stop("Can't aggregate byProperty and include page in dimensions.")
  }
  
  
  if(rowLimit > 5000){
    stop("rowLimit must be 5000 or lower. Got this: ", rowLimit)
  }
  
  if(walk_data){
    message("Walking data per day: setting rowLimit to 5000 per day.")
    rowLimit <- 5000
    if(!'date' %in% dimensions){
      stop("To walk data per date requires 'date' to be one of the dimensions. 
           Got this: ", paste(dimensions, sep=", "))
    }
  }
  
  ## require pre-existing token, to avoid recursion
    
  ## a list of filter expressions 
  ## expects dimensionFilterExp like c("device==TABLET", "country~~GBR")
  parsedDimFilterGroup <- lapply(dimensionFilterExp, parseDimFilterGroup)
  
  body <- list(
    startDate = startDate,
    endDate = endDate,
    dimensions = as.list(dimensions),  
    searchType = searchType,
    dimensionFilterGroups = list(
      list( ## you don't want more than one of these until different groupType available
        groupType = "and", ##only one available for now
        filters = parsedDimFilterGroup
      )
    ),
    aggregationType = aggregationType,
    rowLimit = rowLimit
  )
  
  search_analytics_g <- 
    googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                   "POST",
                                   path_args = list(sites = "siteURL",
                                                    searchAnalytics = "query"),
                                   data_parse_function = parse_search_analytics
                                   )
  
  if(walk_data){
    walk_vector <- seq(as.Date(startDate), as.Date(endDate), 1)
    
    out <- googleAuthR::gar_batch_walk(search_analytics_g,
                                       walk_vector = walk_vector,
                                       gar_paths = list(sites = siteURL),
                                       body_walk = c("startDate", "endDate"),
                                       the_body = body,
                                       batch_size = 1,
                                       dim = dimensions)
    
  } else {
    
    out <-   search_analytics_g(the_body=body, 
                                path_arguments=list(sites = siteURL), 
                                dim = dimensions)
    
  }
  
  out

}


#' Retrieves dataframe of websites user has in Search Console
#'
#' @return a dataframe of siteUrl and permissionLevel
#'
#' @export
#' @family search console website functions
list_websites <- function() {
  
  l <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/sites",
                                      "GET",
                                      data_parse_function = function(x) x$siteEntry)
  l()
}

#' Adds website to Search Console
#' 
#' @param siteURL The URL of the website to add.
#'
#' @return TRUE if successful, raises an error if not.
#' @family search console website functions
#' 
#' @export
add_website <- function(siteURL) {
  
  siteURL <- check.Url(siteURL, reserved = TRUE)
  
  aw <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                      "PUT",
                                      path_args = list(sites = "siteURL"))
  
  aw(path_arguments = list(sites = siteURL))
  TRUE
  
}

#' Deletes website in Search Console
#' 
#' @param siteURL The URL of the website to delete.
#' 
#' @return TRUE if successful, raises an error if not.
#' @family data fetching functions
#' 
#' @export
#' @family search console website functions
delete_website <- function(siteURL) {
  
  siteURL <- check.Url(siteURL, reserved = TRUE)
  
  
  dw <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                      "DELETE",
                                      path_args = list(sites = "siteURL"))
  
  dw(path_arguments = list(sites = siteURL))
  TRUE
  
}

#' Gets sitemap information for the URL supplied.
#' 
#' See here for details: https://developers.google.com/webmaster-tools/v3/sitemaps 
#' 
#' @param siteURL The URL of the website to get sitemap information from. Must include protocol (http://).
#' 
#' @return A list of two dataframes: $sitemap with general info and $contents with sitemap info.
#' @family data fetching functions
#' 
#' @export
#' @family sitemap admin functions
list_sitemaps <- function(siteURL) {
  
  siteURL <- check.Url(siteURL, reserved = TRUE)
  
  ls <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                      "GET",
                                      path_args = list(sites = "siteURL",
                                                       sitemaps = ""),
                                      data_parse_function = parse_sitemaps)
  
  ls(path_arguments = list(sites = siteURL))
  
}

#' Submit a sitemap.
#' 
#' See here for details: https://developers.google.com/webmaster-tools/v3/sitemaps/submit
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#' @param feedpath The URL of the sitemap to submit. Must include protocol (http://).
#' 
#' @return TRUE if successful, raises an error if not.
#'
#' @export
#' @family sitemap admin functions
add_sitemap <- function(siteURL, feedpath) {
  
  siteURL <- check.Url(siteURL, reserved = TRUE)
  feedpath <- check.Url(feedpath, reserved = TRUE)
  
  as <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                      "PUT",
                                      path_args = list(sites = "siteURL",
                                                       sitemaps = "feedpath"))
  
  as(path_arguments = list(sites = siteURL,
                          sitemaps = feedpath))
  TRUE
  
}

#' Delete a sitemap.
#' 
#' See here for details: https://developers.google.com/webmaster-tools/v3/sitemaps/delete
#' 
#' @param siteURL The URL of the website you are deleting the sitemap from. Must include protocol (http://).
#' @param feedpath The URL of the sitemap to delete. Must include protocol (http://).
#' 
#' @return TRUE if successful, raises an error if not.
#'
#' @export
#' @family sitemap admin functions
delete_sitemap <- function(siteURL, feedpath) {
  
  siteURL <- check.Url(siteURL, reserved = TRUE)
  feedpath <- check.Url(feedpath, reserved = TRUE)
  
  ds <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                      "DELETE",
                                      path_args = list(sites = "siteURL",
                                                       sitemaps = "feedpath"))
  
  ds(path_arguments = list(sites = siteURL,
                          sitemaps = feedpath))
  
  TRUE
  
}

#' Fetch a time-series of Googlebot crawl errors.
#' 
#' @description 
#' Get a list of errors detected by Googlebot over time.
#' See here for details: https://developers.google.com/webmaster-tools/v3/urlcrawlerrorscounts/query
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#' @param category Crawl error category. Defaults to 'all'
#' @param platform The user agent type. 'all', 'mobile', 'smartphoneOnly' or 'web'.
#' @param latestCountsOnly Default FALSE. Only the latest crawl error counts returned if TRUE.
#' 
#' @return dataframe of errors with $platform $category $count and $timecount.
#'
#' @details The timestamp is converted to a date as they are only available daily.
#' 
#' Category is one of: authPermissions, manyToOneRedirect, notFollowed, notFound,
#'   other, roboted, serverError, soft404.
#'   
#'   Platform is one of: mobile, smartphoneOnly or web.
#' 
#' @export
#' @family working with search console errors
crawl_errors <- function(siteURL, 
                         category="all",
                         platform=c("all","mobile","smartphoneOnly","web"),
                         latestCountsOnly = FALSE) {
  platform <- match.arg(platform)
  siteURL <- check.Url(siteURL, reserved = TRUE)
  
  latestCountsOnly <- ifelse(latestCountsOnly, 'true', 'false')
  
  ## require pre-existing token, to avoid recursion
  if(is.valid.category.platform(category, platform, include.all = TRUE)) {
    
    params <- list('category' = category,
                   'latestCountsOnly' = latestCountsOnly,
                   'platform' = platform)
    params <- params[params != 'all']
    
    ce <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                         "GET",
                                         path_args = list(sites = "siteURL",
                                                          urlCrawlErrorsCounts = "query"),
                                         pars_args = params,
                                         data_parse_function = parse_crawlerrors)
    
    ce(path_arguments = list(sites = siteURL), pars_arguments = params)
  
  }
}

#' Lists a site's sample URLs for crawl errors.
#' 
#' @description Category is one of: authPermissions, manyToOneRedirect, notFollowed, notFound,
#'   other, roboted, serverError, soft404.
#'   
#'   Platform is one of: mobile, smartphoneOnly or web.
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#' @param category Crawl error category. Default 'notFound'.
#' @param platform User agent type. Default 'web'.
#'
#' @details
#' See here for details: \url{https://developers.google.com/webmaster-tools/v3/urlcrawlerrorssamples}
#' 
#' @return A dataframe of $pageUrl, $last_crawled, $first_detected, $response
#'
#' @export
#' @family working with search console errors
list_crawl_error_samples <- function(siteURL,
                                     category="notFound",
                                     platform="web") {
  
  siteURL <- check.Url(siteURL, reserved=T)

  ## require pre-existing token, to avoid recursion
  if(is.valid.category.platform(category, platform)) {
    
    params <- list('category' = category,
                   'platform' = platform)
    
    lces <- 
      googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                     "GET",
                                     path_args = list(sites = "siteURL",
                                                      urlCrawlErrorsSamples = ""),
                                     pars_args = params,
                                     data_parse_function = parse_crawlerror_sample)
    
    lces(path_arguments = list(sites = siteURL), pars_arguments = params)
  }
  
}

#' Shows details of errors for individual sample URLs
#' 
#' See here for details: https://developers.google.com/webmaster-tools/v3/urlcrawlerrorssamples/get 
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#' @param pageURL A PageUrl taken from list_crawl_error_samples.
#' @param category Crawl error category. Default 'notFound'.
#' @param platform User agent type. Default 'web'.
#' 
#' @return Dataframe of $linkedFrom, with the calling URLs $last_crawled, $first_detected and a $exampleURL
#' @family working with search console errors
#' @description 
#' pageURL is the relative path (without the site) of the sample URL. 
#' It must be one of the URLs returned by list_crawl_error_samples. 
#' For example, for the URL https://www.example.com/pagename on the site https://www.example.com/, 
#' the url value is pagename (string)
#' 
#' Category is one of: authPermissions, manyToOneRedirect, notFollowed, notFound,
#'   other, roboted, serverError, soft404.
#'   
#'   Platform is one of: mobile, smartphoneOnly or web.
#'
#' @export
error_sample_url <- function(siteURL,
                             pageURL,
                             category="notFound",
                             platform="web") {
  
  siteURL <- check.Url(siteURL, reserved = TRUE)
  pageURL <- check.Url(pageURL, checkProtocol = FALSE, reserved = TRUE, repeated = TRUE)
  

  ## require pre-existing token, to avoid recursion
  if(is.valid.category.platform(category, platform)){
    
    params <- list('category' = category,
                   'platform' = platform)
    
    esu <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                          "GET",
                                          path_args = list(sites = "siteURL",
                                                           urlCrawlErrorsSamples = "pageURL"),
                                          pars_args = params,
                                          data_parse_function = parse_errorsample_url)
    
    esu(path_arguments = list(sites = siteURL,
                              urlCrawlErrorsSamples = pageURL), 
        pars_arguments = params)

  }
  
}

#' Mark As Fixed the individual sample URLs
#' 
#' See here for details: 
#' https://developers.google.com/webmaster-tools/v3/urlcrawlerrorssamples/markAsFixed
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#' @param pageURL A PageUrl taken from list_crawl_error_samples.
#' @param category Crawl error category. Default 'notFound'.
#' @param platform User agent type. Default 'web'.
#' 
#' @return TRUE if successful, raises an error if not.
#' @family working with search console errors
#' 
#' @description 
#' pageURL is the relative path (without the site) of the sample URL. 
#' It must be one of the URLs returned by list_crawl_error_samples. 
#' For example, for the URL https://www.example.com/pagename on the site https://www.example.com/, 
#' the url value is pagename (string)
#' 
#' Category is one of: authPermissions, manyToOneRedirect, notFollowed, notFound,
#'   other, roboted, serverError, soft404.
#'   
#'   Platform is one of: mobile, smartphoneOnly or web.
#'
#' @export
fix_sample_url <- function(siteURL,
                           pageURL,
                           category = "notFound",
                           platform = "web") {
  
  siteURL <- check.Url(siteURL, reserved = TRUE)
  pageURL <- check.Url(pageURL, checkProtocol = FALSE, reserved = TRUE)
 
  if(is.valid.category.platform(category, platform)){
    
    params <- list('category' = category,
                   'platform' = platform)
    
    fsu <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/",
                                          "DELETE",
                                          path_args = list(sites = "siteURL",
                                                           urlCrawlErrorsSamples = "pageURL"),
                                          pars_args = params)
    
    fsu(path_arguments = list(sites = siteURL,
                              urlCrawlErrorsSamples = pageURL), 
        pars_arguments = params)
    
    return(TRUE)
    
  }
  
  return(FALSE)
}
