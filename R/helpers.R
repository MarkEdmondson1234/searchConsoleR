#' Walk through dates to get more date
#' 
#' 
#' 
search_analytics_walk <- function(...){
  
  walked <- Reduce(rbind, lapply(dates, function(x) search_analytics("http://www.bang-olufsen.com", x, x, dimensions=c("date","query"))))
}