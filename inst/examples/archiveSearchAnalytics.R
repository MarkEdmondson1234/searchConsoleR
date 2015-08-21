## A script to download and archive Google search analytics
##
## Demo of searchConsoleR R package.
##
## Version 1 - 10th August 2015
##
## Mark Edmondson (http://markedmondson.me)

library(googleAuthR)

## load the library or download it if necessary
if(!require(searchConsoleR)){
  if(!require(devtools)){
    install.packages("devtools")
  } else {
    devtools::install_github("MarkEdmondson1234/searchConsoleR")
  }
}
library(searchConsoleR)


## change this to the website you want to download data for. Include http
website <- "http://copenhagenish.me"

## data is in search console reliably 3 days ago, so we donwnload from then
## today - 3 days
start <- Sys.Date() - 3
## one days data, but change it as needed
end <- Sys.Date() - 3 

## what to download, choose between data, query, page, device, country
download_dimensions <- c('date','query')

## what type of Google search, choose between 'web', 'video' or 'image'
type <- c('web')

## other options available, check out ?search_analytics in the R console

## Authorize script with Search Console.  
## First time you will need to login to Google,
## but should auto-refresh after that so can be put in 
## Authorize script with an account that has access to website.
gar_auth()

## first time stop here and wait for authorisation

## get the search analytics data
data <- search_analytics(siteURL = website, 
                         startDate = start, 
                         endDate = end, 
                         dimensions = download_dimensions, 
                         searchType = type)

## do stuff to the data
## combine with Google Analytics, filter, apply other stats etc.

## write a csv to a nice filename
filename <- paste("search_analytics",
                  Sys.Date(),
                  paste(download_dimensions, collapse = "",sep=""),
                  type,".csv",sep="-")

write.csv(data, filename)
