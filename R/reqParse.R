#' Parsing function for \code{\link{search_analytics}}
#' 
#' @param x req$content from API response
#' @param dim the dimensions passed from search_analytics
#' @param pn PrettyNames passed from search_analytics
#' 
#' @keywords internal
#' @family parsing functions
parse_search_analytics <- function(x, dim, prettyNames=TRUE){
  
  the_data <- x$rows

  if(!is.null(dim)){
    # a bit of jiggery pokery (data processing)
    dimensionCols <- data.frame(Reduce(rbind, 
                                       lapply(the_data$keys, function(x) 
                                         rbind(x))), 
                                row.names=NULL, stringsAsFactors = F)
    
    ## if no rows, get out of here.
    if(!nrow(dimensionCols) > 0) {
      warning("No data found")
      empty_df <- data.frame(matrix(NA, nrow = 1, ncol = length(dim) + 4))
      names(empty_df) <- c(dim, 'clicks','impressions','ctr','position')
      if('date' %in% dim) empty_df$date <- as.Date(NA)
      return(empty_df)
    }
    
    names(dimensionCols ) <- dim
    dimensionCols <- lapply(dimensionCols, unname)
    
    if('date' %in% names(dimensionCols)){
      dimensionCols$date <- as.Date(dimensionCols$date)
    }
    
    if(all('country' %in% names(dimensionCols), prettyNames)){
      dimensionCols$countryName <- sapply(dimensionCols$country, lookupCountryCode)
    }
    
    metricCols <- the_data[setdiff(names(the_data), 'keys')]
    
    the_df <- data.frame(dimensionCols , metricCols, stringsAsFactors = F, row.names = NULL)
    
  } else { ## no dimensions
    if(!is.null(the_data)){
      the_df <- the_data
    } else {
      warning("No data found")
      empty_df <- data.frame(matrix(NA, nrow = 1, ncol = 4))
      names(empty_df) <- c('clicks','impressions','ctr','position')

      return(empty_df)
    }

  }

  attr(the_df, "aggregationType") <- x$responseAggregationType
  
  the_df
  
}

#' Parsing function for \code{\link{list_sitemaps}}
#' 
#' @param x req$content from API response
#' 
#' @keywords internal
#' @family parsing functions
parse_sitemaps <- function(x){
  list(sitemap = x$sitemap[, setdiff(names(x$sitemap), "contents")],
       contents = x$sitemap$contents[[1]])
  
}

#' Parsing function for \code{\link{crawl_errors}}
#' 
#' @param x req$content from API response
#' 
#' @keywords internal
#' @family parsing functions
parse_crawlerrors <- function(x){
  cpt <- x$countPerTypes
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
  
}

#' Parsing function for \code{\link{list_crawl_error_samples}}
#' 
#' @param x req$content from API response
#' 
#' @keywords internal
#' @family parsing functions
parse_crawlerror_sample <- function(x){
  errs <- x$urlCrawlErrorSample
  
  if(!is.null(errs)){
    errs$last_crawled <- RFC_convert(errs$last_crawled)
    errs$first_detected <- RFC_convert(errs$first_detected)
    
    errs      
  } else {
    message("No error samples available.")
    NULL
  }
  
}

#' Parsing function for \code{\link{error_sample_url}}
#' 
#' @param x req$content from API response
#' 
#' @keywords internal
#' @family parsing functions
parse_errorsample_url <- function(x){
  raw_details <- x
  
  if(all(c('last_crawled', 'first_detected') %in% names(raw_details))){
    raw_details$last_crawled <- RFC_convert(raw_details$last_crawled)
    raw_details$first_detected <- RFC_convert(raw_details$first_detected)
    inner_details <- Reduce(rbind, raw_details$urlDetails)
    
    data.frame(linkedFrom=inner_details, 
               last_crawled=raw_details$last_crawled,
               first_detected=raw_details$first_detected,
               pageUrl=raw_details$pageUrl) 
    
  }
  
}
