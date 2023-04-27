#' Query search traffic keyword data
#'
#' @description Download your Google SEO data.
#'
#' @param siteURL The URL of the website you have auth access to.
#' @param startDate Start date of requested range, in YYYY-MM-DD.
#' @param endDate End date of the requested date range, in YYYY-MM-DD.
#' @param dimensions Zero or more dimensions to group results by:
#'      \code{"date", "country", "device", "page" , "query" or "searchAppearance"}
#' @param searchType Search type filter, default 'web'.
#' @param dimensionFilterExp A character vector of expressions to filter.
#'      e.g. \code{("device==TABLET", "country~~GBR", "query**^a")}
#' @param aggregationType How data is aggregated.
#' @param rowLimit How many rows to fetch.  Ignored if \code{walk_data} is "byDate"
#' @param prettyNames If TRUE, converts SO 3166-1 alpha-3 country code to full name and
#'   creates new column called countryName.
#' @param walk_data Make multiple API calls. One of \code{("byBatch","byDate","none")}
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
#'         \item 'searchAppearance' (can only appear on its own)
#'       }
#'  The grouping dimension values are combined to create a unique key
#'    for each result row. If no dimensions are specified,
#'    all values will be combined into a single row.
#'    There is no limit to the number of dimensions that you can group by apart from \code{searchAppearance} can only be grouped alone.
#'    You cannot group by the same dimension twice. 
#'    
#'    Example: \code{c('country', 'device')}
#'    
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
#'         \item 'searchAppearance'
#'       }
#'     \item operator
#'       \itemize{
#'         \item '~~' meaning 'contains'
#'         \item '==' meaning 'equals'
#'         \item '!~' meaning 'notContains'
#'         \item '!=' meaning 'notEquals'
#'         \item '**' meaning 'includingRegex'
#'         \item '!*' meaning 'excludingRegex'
#'       }
#'
#'     \item expression
#'        \itemize{
#'          \item country: an ISO 3166-1 alpha-3 country code.
#'          \item device: 'DESKTOP','MOBILE','TABLET'.
#'          \item page: not checked, a string in page URLs without hostname.
#'          \item query: not checked, a string in keywords.
#'          \item searchAppearance: 'AMP_BLUE_LINK', 'AMP_TOP_STORIES', 'RICHCARD', 'PAGE_EXPERIENCE', 'ORGANIC_SHOPPING', 'REVIEW_SNIPPET', 'VIDEO', 'WEBLITE'
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
#'    \item "news": "News" tab in Google Search
#'    \item "googleNews": Results from news.google.com. Doesn't include results from the "news" tab in Google Search
#'    \item "discover": Discover results
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
#'  \strong{batchType}: [Optional] Batching data into multiple API calls
#' \itemize{
#'   \item byBatch Use the API call to batch
#'   \item byData Runs a call over each day in the date range.
#'   \item none No batching
#'  }
#'
#'  \strong{dataState}: [Optional] Which data should be downloaded from the GSC
#'  \itemize{
#'    \item "final": [Default] Response will include only final data
#'    \item "all": Response will include fresh data (they may not be fully calculated)
#'  }
#'
#' @examples
#'
#' \dontrun{
#'
#'    library(searchConsoleR)
#'    scr_auth()
#'    sc_websites <- list_websites()
#'    
#'    default_fetch <- search_analytics("http://www.example.com")
#'
#'    gbr_desktop_queries <-
#'        search_analytics("http://www.example.com",
#'                          start = "2016-01-01", end = "2016-03-01",
#'                          dimensions = c("query", "page"),
#'                          dimensionFilterExp = c("device==DESKTOP", "country==GBR"),
#'                          searchType = "web", rowLimit = 100)
#'
#'    batching <-
#'         search_analytics("http://www.example.com",
#'                          start = "2016-01-01", end = "2016-03-01",
#'                          dimensions = c("query", "page", "date"),
#'                          searchType = "web", rowLimit = 100000,
#'                          walk_data = "byBatch")
#'
#'   }
#' @importFrom googleAuthR gar_api_generator gar_batch_walk gar_api_page
search_analytics <- function(siteURL,
                             startDate = Sys.Date() - 93,
                             endDate = Sys.Date() - 3,
                             dimensions = NULL,
                             searchType = c("web","video","image","news","discover","googleNews"),
                             dimensionFilterExp = NULL,
                             aggregationType = c("auto","byPage","byProperty"),
                             rowLimit = 1000,
                             prettyNames = TRUE,
                             walk_data = c("byBatch","byDate","none"),
                             dataState = c("final", "all")){

  if(!googleAuthR::gar_has_token()){
    stop("Not authenticated. Run scr_auth()", call. = FALSE)
  }

  searchType      <- match.arg(searchType)
  aggregationType <- match.arg(aggregationType)
  walk_data       <- match.arg(walk_data)
  dataState       <- match.arg(dataState)

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

  if(any(as.Date(startDate, "%Y-%m-%d") > Sys.Date()-3, as.Date(endDate, "%Y-%m-%d") > Sys.Date()-3) && dataState == "final"){
    warning("Search Analytics usually not available within 3 days (96 hrs) of today(",Sys.Date(),"). Got:", startDate, " - ", endDate)
  }
  
  if(any(as.Date(startDate, "%Y-%m-%d") > Sys.Date()-3, as.Date(endDate, "%Y-%m-%d") > Sys.Date()-3) && dataState == "all"){
    warning("Search Analytics working with \"fresh data\" which could not be complet in last three days before today(",Sys.Date(),"). Got:", startDate, " - ", endDate)
  }

  if(!is.null(dimensions) & !all(dimensions %in% c('date','country', 'device', 'page', 'query','searchAppearance'))){
    stop("dimension must be NULL or one or more of 'date','country', 'device', 'page', 'query', 'searchAppearance'.
         Got this: ", paste(dimensions, sep=", "))
  }

  if(aggregationType %in% c("byProperty") & 'page' %in% dimensions ){
    stop("Can't aggregate byProperty and include page in dimensions.")
  }
  
  # if batching by day, row limits make no sense so we get 5000 per day.
  if(walk_data == "byDate"){
    message("Batching data via method: ", walk_data)
    message("Will fetch up to 25000 rows per day")
    rowLimit <- 25000
  } else if(walk_data == "byBatch"){
    # if batching byBatch, we set to 25000 per API call, repeating API calls
    #   up to the limit you have set
    if(rowLimit > 25000){
      message("Batching data via method: ", walk_data)
      message("With rowLimit set to ", rowLimit ," will need up to [", (rowLimit %/% 25000) + 1, "] API calls")
      rowLimit0 <- rowLimit
      rowLimit <- 25000
    } else {
      # its batched, but we can get all rows in one API call
      walk_data <- "none"
    }
  }

  ## a list of filter expressions
  ## expects dimensionFilterExp like c("device==TABLET", "country~~GBR")
  parsedDimFilterGroup <- lapply(dimensionFilterExp, parseDimFilterGroup)

  body <- list(
    startDate = startDate,
    endDate = endDate,
    dimensions = as.list(dimensions),
    type = searchType,
    dimensionFilterGroups = list(
      list( ## you don't want more than one of these until different groupType available
        groupType = "and", ##only one available for now
        filters = parsedDimFilterGroup
      )
    ),
    aggregationType = aggregationType,
    rowLimit = rowLimit,
    dataState = dataState
  )

  search_analytics_g <- gar_api_generator(
    "https://www.googleapis.com/webmasters/v3/",
    "POST",
    path_args = list(sites = "siteURL",
                     searchAnalytics = "query"),
    data_parse_function = parse_search_analytics)
  
  
  # set this here as it may get reset if other googleAuthR packages there
  options(googleAuthR.batch_endpoint = 'https://www.googleapis.com/batch/webmasters/v3')
  
  if(walk_data == "byDate"){

    if(!'date' %in% dimensions){
      warning("To walk data per date requires 'date' to be one of the dimensions. Adding it")
      dimensions <- c("date", dimensions)
    }

    walk_vector <- seq(as.Date(startDate), as.Date(endDate), 1)

    out <- gar_batch_walk(search_analytics_g,
                          walk_vector = walk_vector,
                          gar_paths = list(sites = siteURL),
                          body_walk = c("startDate", "endDate"),
                          the_body = body,
                          batch_size = 1,
                          dim = dimensions)

  } else if(walk_data == "byBatch") {

    ## byBatch uses API batching, but this pulls out less data
    ## 0 impression keywords not included.
    walk_vector <- seq(0, rowLimit0, 25000)
    
    do_it <- TRUE
    i <- 1
    pages <- list()
    while(do_it){
      message("Page [",i,"] of max [", length(walk_vector),"] API calls")
      this_body <- utils::modifyList(body, list(startRow = walk_vector[i]))
      this_page <- search_analytics_g(the_body = this_body, 
                                     list(sites = siteURL),
                                     dim = dimensions)

      if(all(is.na(this_page[[1]]))){
        do_it <- FALSE
      } else {
        message("Downloaded ", nrow(this_page), " rows")
        pages <- rbind(pages, this_page)
      }
     
      i <- i + 1
      if(i>length(walk_vector)){
        do_it <- FALSE
      }

    }
    
    out <- pages

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
  
  f <- function(x){
    if(is.null(x$siteEntry)){
      message("No websites found for this authentication")
      return(data.frame())
    }
    
    x$siteEntry
  }

  l <- googleAuthR::gar_api_generator("https://www.googleapis.com/webmasters/v3/sites",
                                      "GET",
                                      data_parse_function = f)
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
  stop("Crawl errors are no longer available in the API")
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
