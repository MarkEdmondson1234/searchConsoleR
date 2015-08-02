#' Retrieves dataframe of websites user has in Search Console
#'
#' @return a dataframe of siteUrl and permissionLevel
#'
#' @export
list_websites <- function() {
  
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/sites/list
    req <- searchconsole_GET("https://www.googleapis.com/webmasters/v3/sites")
    
    req$content$siteEntry
    
  } else {
    
    stop("Invalid Token")
    
  }
  
}

#' Adds website to Search Console
#' 
#' @param siteURL The URL of the website to add.
#'
#' @return TRUE if successful.
#'
#' @export
add_website <- function(siteURL) {
  
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/sites/add
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", siteURL)
    searchconsole_PUT(req_url, the_body = NULL)
    
    TRUE
    
  } else {
    
    stop("Invalid Token")
    
  }
  
}

#' Deletes website in Search Console
#' 
#' @param siteURL The URL of the website to delete.
#'
#' @return TRUE if successful.
#'
#' @export
delete_website <- function(siteURL) {
  
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/sites/delete
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", siteURL)
    searchconsole_DELETE(req_url)
    
    TRUE
    
  } else {
    
    stop("Invalid Token")
    
  }
  
}

#' Gets sitemap information for the URL supplied.
#' 
#' See here for details: https://developers.google.com/webmaster-tools/v3/sitemaps 
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#'
#' @return A list of two dataframes: $sitemap with general info and $contents with sitemap info.
#'
#' @export

list_sitemaps <- function(siteURL) {
  
  if(!grepl("http",siteURL)){
   stop("siteURL must include protocol, e.g. http://example.com") 
  }
  
  if(!grepl("%3A%2F%2F", siteURL)){
    siteURL <- URLencode(siteURL, reserved=T)
    message("Encoding URL to ", siteURL)
  }
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/sitemaps
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", siteURL,"/sitemaps")
    req <- searchconsole_GET(req_url)
    
    list(sitemap = req$content$sitemap[, setdiff(names(req$content$sitemap), "contents")],
         contents = req$content$sitemap$contents[[1]])
    
  } else {
    
    stop("Invalid Token")
    
  }
  
}

#' Submit a sitemap.
#' 
#' See here for details: https://developers.google.com/webmaster-tools/v3/sitemaps/submit
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#' @param feedpath The URL of the sitemap to submit. Must include protocol (http://).
#'
#' @return TRUE if successful.
#'
#' @export
add_sitemap <- function(siteURL, feedpath) {
  
  if(any(!grepl("http",siteURL), 
         !grepl("http",feedpath)
         )){
    stop("URLs must include protocol, e.g. http://example.com") 
  }
  
  if(!grepl("%3A%2F%2F", siteURL)){
    siteURL <- URLencode(siteURL, reserved=T)
    message("Encoding URL to ", siteURL)
  }
  
  if(!grepl("%3A%2F%2F", feedpath)){
    siteURL <- URLencode(feedpath, reserved=T)
    message("Encoding sitemap URL to ", feedpath)
  }
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/sitemaps/submit
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", 
                      siteURL,"/sitemaps/",
                      feedpath)
    
    searchconsole_PUT(req_url, the_body = NULL)
    
    TRUE
    
  } else {
    
    stop("Invalid Token")
    
  }
  
}

#' Delete a sitemap.
#' 
#' See here for details: https://developers.google.com/webmaster-tools/v3/sitemaps/delete
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#' @param feedpath The URL of the sitemap to submit. Must include protocol (http://).
#'
#' @return TRUE if successful.
#'
#' @export
delete_sitemap <- function(siteURL, feedpath) {
  
  if(any(!grepl("http",siteURL), 
         !grepl("http",feedpath)
  )){
    stop("URLs must include protocol, e.g. http://example.com") 
  }
  
  if(!grepl("%3A%2F%2F", siteURL)){
    siteURL <- URLencode(siteURL, reserved=T)
    message("Encoding URL to ", siteURL)
  }
  
  if(!grepl("%3A%2F%2F", feedpath)){
    siteURL <- URLencode(feedpath, reserved=T)
    message("Encoding sitemap URL to ", feedpath)
  }
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/sitemaps/delete
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", 
                      siteURL,"/sitemaps/",
                      feedpath)
    
    searchconsole_DELETE(req_url)
    
    TRUE
    
  } else {
    
    stop("Invalid Token")
    
  }
  
}

#' Gets time-series of crawl errors
#' 
#' @description 
#' See here for details: https://developers.google.com/webmaster-tools/v3/urlcrawlerrorscounts/query
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#' @param category Crawl error category. Defaults to 'all'
#' @param platform The user agent type. 'all', 'mobile', 'smartphoneOnly' or 'web'.
#' @param latestCountsOnly Default FALSE. Only the latest crawl error counts returned if TRUE.
#' 
#' @return Dataframe of errors
#'
#' @details The timestamp is converted to as.Date without the time.
#' 
#' @export
crawl_errors <- function(siteURL, 
                         category="all",
                         platform="all",
                         latestCountsOnly=FALSE) {
  
  if(!grepl("http",siteURL)){
    stop("siteURL must include protocol, e.g. http://example.com") 
  }
  
  if(!grepl("%3A%2F%2F", siteURL)){
    siteURL <- URLencode(siteURL, reserved=T)
    message("Encoding URL to ", siteURL)
  }
  
  latestCountsOnly <- ifelse(latestCountsOnly, 'true', 'false')
  
  categories <- c('all',
                  'authPermissions', 
                  'manyToOneRedirect',
                  'notFollowed',
                  'notFound',
                  'other',
                  'roboted',
                  'serverError',
                  'soft404')
  
  platforms <- c('all',
                 'mobile',
                 'smartphoneOnly',
                 'web')
  
  if(!category %in% categories) {
    stop("Incorrect category.  Must be one of ", paste(categories, collapse=","))
  }
  
  if(!platform %in% platforms){
    stop("Incorrect platform. Must be one of ", paste(platforms, collapse=", "))
  }
  
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/urlcrawlerrorscounts/query
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", 
                      siteURL,
                      "/urlCrawlErrorsCounts/query")
    
    param_vector <- c('category'=category,
                      'latestCountsOnly'=latestCountsOnly,
                      'platform'=platform)
    param_vector <- param_vector[param_vector != 'all']
    
    req <- searchconsole_GET(req_url, params = param_vector)
    
    cpt <- req$content$countPerTypes
    ## data parsing gymnastics
    ldf <- Reduce(rbind, 
                  apply(cpt, 1, function(row) {
                    data.frame(platform = row['platform'], 
                               category = row['category'], 
                               count = row$entries$count, 
                               timecount = row$entries$timestamp )
                  })
    )
    
    ## transform to something useable
    ldf$platform <- as.character(ldf$platform)
    ldf$category <- as.character(ldf$category)
    ldf$count <- as.numeric(as.character(ldf$count))
    ldf$timecount <- RFC_convert(ldf$timecount, drop_time = TRUE)
    
    ldf
    
  } else {
    
    stop("Invalid Token")
    
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

#' Lists a site's sample URLs for crawl errors.
#' 
#' See here for details: https://developers.google.com/webmaster-tools/v3/urlcrawlerrorssamples 
#' 
#' @param siteURL The URL of the website to delete. Must include protocol (http://).
#' @param category Crawl error category. Default 'notFound'.
#' @param platform User agent type. Default 'web'. 
#'
#' @return A dataframe of $pageUrl, $last_crawled, $first_detected, $response
#' 
#' @description Category is one of: authPermissions, manyToOneRedirect, notFollowed, notFound,
#'   other, roboted, serverError, soft404.
#'   
#'   Platform is one of: mobile, smartphoneOnly or web.
#'
#' @export

list_crawl_error_samples <- function(siteURL,
                                     category="notFound",
                                     platform="web") {
  
  if(!grepl("http",siteURL)){
    stop("siteURL must include protocol, e.g. http://example.com") 
  }
  
  if(!grepl("%3A%2F%2F", siteURL)){
    siteURL <- URLencode(siteURL, reserved=T)
    message("Encoding URL to ", siteURL)
  }
  
  categories <- c('authPermissions', 
                  'manyToOneRedirect',
                  'notFollowed',
                  'notFound',
                  'other',
                  'roboted',
                  'serverError',
                  'soft404')
  
  platforms <- c('mobile',
                 'smartphoneOnly',
                 'web')
  
  if(!category %in% categories) {
    stop("Incorrect category.  Must be one of ", paste(categories, collapse=","))
  }
  
  if(!platform %in% platforms){
    stop("Incorrect platform. Must be one of ", paste(platforms, collapse=", "))
  }
  
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/urlcrawlerrorssamples
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", siteURL,"/urlCrawlErrorsSamples")
    
    param_vector <- c('category'=category,
                      'platform'=platform)
    
    req <- searchconsole_GET(req_url, params = param_vector)
    
    errs <- req$content$urlCrawlErrorSample
    
    errs$last_crawled <- RFC_convert(errs$last_crawled)
    errs$first_detected <- RFC_convert(errs$first_detected)
    
    errs
    
  } else {
    
    stop("Invalid Token")
    
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
#' @return A list of $pageUrl, $last_crawled, $first_detected and a $urlDetails sub-list.
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
error_sample_url <- function(siteURL,
                                pageURL,
                                category="notFound",
                                platform="web") {
  
  if(!grepl("http",siteURL)){
    stop("siteURL must include protocol, e.g. http://example.com") 
  }
  
  if(!grepl("%3A%2F%2F", siteURL)){
    siteURL <- URLencode(siteURL, reserved=T)
    message("Encoding URL to ", siteURL)
  }
  
  pageURL <- URLencode(pageURL, reserved = T)
  message("Encoding sampleURL to ", pageURL)
  
  categories <- c('authPermissions', 
                  'manyToOneRedirect',
                  'notFollowed',
                  'notFound',
                  'other',
                  'roboted',
                  'serverError',
                  'soft404')
  
  platforms <- c('mobile',
                 'smartphoneOnly',
                 'web')
  
  if(!category %in% categories) {
    stop("Incorrect category.  Must be one of ", paste(categories, collapse=","))
  }
  
  if(!platform %in% platforms){
    stop("Incorrect platform. Must be one of ", paste(platforms, collapse=", "))
  }
  
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/urlcrawlerrorssamples
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", 
                      siteURL,
                      "/urlCrawlErrorsSamples/",
                      pageURL)
    
    param_vector <- c('category'=category,
                      'platform'=platform)
    
    req <- searchconsole_GET(req_url, params = param_vector)
    
    details <- req$content
    
    details$last_crawled <- RFC_convert(details$last_crawled)
    details$first_detected <- RFC_convert(details$first_detected)
    
    details
    
  } else {
    
    stop("Invalid Token")
    
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
#' @return TRUE if successful.
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
                           category="notFound",
                           platform="web") {
  
  if(!grepl("http",siteURL)){
    stop("siteURL must include protocol, e.g. http://example.com") 
  }
  
  if(!grepl("%3A%2F%2F", siteURL)){
    siteURL <- URLencode(siteURL, reserved=T)
    message("Encoding URL to ", siteURL)
  }
  
  pageURL <- URLencode(pageURL, reserved = T)
  message("Encoding sampleURL to ", pageURL)
  
  categories <- c('authPermissions', 
                  'manyToOneRedirect',
                  'notFollowed',
                  'notFound',
                  'other',
                  'roboted',
                  'serverError',
                  'soft404')
  
  platforms <- c('mobile',
                 'smartphoneOnly',
                 'web')
  
  if(!category %in% categories) {
    stop("Incorrect category.  Must be one of ", paste(categories, collapse=","))
  }
  
  if(!platform %in% platforms){
    stop("Incorrect platform. Must be one of ", paste(platforms, collapse=", "))
  }
  
  ## require pre-existing token, to avoid recursion
  if(token_exists(verbose = FALSE) && is_legit_token(.state$token)) {
    
    ## docs here
    ## https://developers.google.com/webmaster-tools/v3/urlcrawlerrorssamples/markAsFixed
    req_url <- paste0("https://www.googleapis.com/webmasters/v3/sites/", 
                      siteURL,
                      "/urlCrawlErrorsSamples/",
                      pageURL)
    
    param_vector <- c('category'=category,
                      'platform'=platform)
    
    req <- searchconsole_DELETE(req_url, params = param_vector)
    
    req
    
  } else {
    
    stop("Invalid Token")
    
  }
  
}

