#' searchConsoleR
#'
#' Provides an interface with the Google Search Console API v3, 
#'   formally called Google Webmaster Tools. 
#'   
#' To get started, use \code{googleAuthR::gar_auth()} to authenticate.
#' 
#' @section Search analytics:
#' 
#' \code{\link{search_analytics}} - download Google SEO data into an R dataframe.
#' 
#' @section Website admin:
#' 
#' \code{\link{list_websites}} - list websites in your Google Search Console.
#' 
#' \code{\link{add_website}} - add a website to your Google Search Console.
#' 
#' \code{\link{delete_website}} - delete a website from your Google Search Console.

#' @section Sitemaps:
#' 
#' \code{\link{list_sitemaps}} - list sitemaps recognised in Google Search Console.
#' 
#' \code{\link{add_sitemap}} - add sitemap URL location to Google Search Console.
#' 
#' \code{\link{delete_sitemap}} - remove sitemap URL location in Google Search
#'   Console.

#' @section Error listings:
#' 
#' \code{\link{crawl_errors}} - list types of crawl errors googlebot has found.
#' 
#' \code{\link{list_crawl_error_samples}} - lists example URLs with errors.
#' 
#' \code{\link{error_sample_url}} - details about an example URL error.
#' 
#' \code{\link{fix_sample_url}} - mark a URL as fixed.
#' 
#' @docType package
#' @name searchConsoleR
NULL