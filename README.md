# searchConsoleR

[![Travis-CI Build Status](https://travis-ci.org/MarkEdmondson1234/searchConsoleR.svg?branch=master)](https://travis-ci.org/MarkEdmondson1234/searchConsoleR)

R interface with Google Search Console (formally Google Webmaster Tools) API v3.

## Setup Guide

Install dependency `googleAuthR` from CRAN:
```
install.packages("googleAuthR")
library(googleAuthR)
```

Install `searchConsoleR` from CRAN:
```
install.packages("searchConsoleR")
library(searchConsoleR)
```

If you want the development version of `searchConsoleR` on Github:

```
devtools::install_github("MarkEdmondson1234/searchConsoleR")
library(searchConsoleR)
```

## News

### 0.1.2.9002

* Return an empty dataframe of NAs if no resutls in fetch instead of NULL
* Include andriod-app check from #7
* Add `walk_data` parameter to `search_analytics` to get more data
* Set default start and end dates in `search_analytics` to 93 days ago and 3 days ago respectivily. 

You can get 10 times the data using batching:

```r
nobatch <- search_analytics("http://www.example.com", 
                            "2016-01-01","2016-02-01", 
                            dimensions = c("date","query"), 
                            rowLimit = 5000)

batch <- search_analytics("http://www.example.com", 
                          "2016-01-01","2016-02-01", 
                          dimensions = c("date","query"), 
                          walk_data = TRUE)

str(nobatch)
'data.frame':	4969 obs. of  6 variables:
 $ date       : Date, format: "2016-01-04" "2016-01-14" ...
 $ query      : chr  "iphone 6", "iphone 6s" "apple watch" ...
 $ clicks     : num  19 19 17 17 16 16 16 16 15 15 ...
 $ impressions: num  175 20 175 23 20 173 19 19 21 157 ...
 $ ctr        : num  0.1086 0.95 0.0971 0.7391 0.8 ...
 $ position   : num  2.77 1 3.81 1 1 ...
 - attr(*, "aggregationType")= chr "byProperty"
 
 str(batch)
 'data.frame':	46483 obs. of  6 variables:
 $ date       : Date, format: "2016-01-01" "2016-01-01" ...
 $ query      : chr  "iphone 6" "iphone" "iphone 6s" "apple watch" ...
 $ clicks     : num  10 8 6 6 5 4 3 3 2 2 ...
 $ impressions: num  108 304 94 45 7 49 17 193 2 23 ...
 $ ctr        : num  0.0926 0.0263 0.0638 0.1333 0.7143 ...
 $ position   : num  3.4 6.54 3.83 3.96 1.29 ...
 - attr(*, "aggregationType")= chr "byProperty"

```

### 0.1.2.9000 

* Correct bug for error in country code.  Will now return the 'Unknown Region' if not recognised (e.g. `CXX`)
* Add `scr_auth` function that wraps `googleAuthR::gar_auth` so you don't need to load googleAuthR explicitly.

### 0.1.2 - on CRAN

* Move to using googleAuthR for authentication backend.

### 0.1.1
* Change search_analytics() so if no dimensions will still return data, instead of NULL

## Shiny Compatible
Authentication can be done locally or within a Shiny app. See a very bare bones example here: https://mark.shinyapps.io/searchConsoleRDemo/

## Info Links

[Google Search Console](http://www.google.com/webmasters/tools/)

[Search Console v3 API docs](https://developers.google.com/webmaster-tools/)

## Function Quick Guide

### Search analytics
* `search_analytics()` - download Google SEO data into an R dataframe.

### Website admin
* `list_websites()` - list websites in your Google Search Console.
* `add_website()` - add a website to your Google Search Console.
* `delete_website()` - delete a website from your Google Search Console.

### Sitemaps
* `list_sitemaps()` - list sitemaps recognised in Google Search Console.
* `add_sitemap()` - add sitemap URL location to Google Search Console.
* `delete_sitemap()` - remove sitemap URL location in Google Search Console.

### Error listings
* `crawl_errors()` - list various types of crawl errors googlebot has found.
* `list_crawl_error_samples()` - get a list of example URLs with errors.
* `error_sample_url()` - show details about an example URL error (for example, links to a 404 URL)
* `fix_sample_url()` - mark a URL as fixed.

### Authentication functions from googleAuthR

* `scr_auth()` - main authentication function. Works locally and within a Shiny environment.



## Work flow

Work flow always starts with authenticating with Google:
```
library(searchConsoleR)
scr_auth()
```

Your browser window should open up and go through the Google sign in OAuth2 flow. Verify with a user that has Search Console access to the websites you want to work with.

Check out the documentation of any function for a guide on what else can be done.
```
?searchConsoleR
```

If you authenticate ok, you should be able to see a list of your websites in the Search Console via:

```
sc_websites <- list_websites()
sc_websites
```

We'll need one unique ```sc_websites$siteUrl``` for the majority of the other functions.

Most people will find the Search Analytics most useful.  All methods from the web interface are available.  

Here is an example query, which downloads the top 100 rows of queries per page for the month of July 2015, for United Kingdom desktop web searches:

```
gbr_desktop_queries <- 
    search_analytics("http://example.com", 
                     "2015-07-01", "2015-07-31", 
                     c("query", "page"), 
                     dimensionFilterExp = c("device==DESKTOP","country==GBR"), 
                     searchType="web", rowLimit = 100)
```

For a lot more details see: 
```
?search_analytics
```

## Demo script

Here is an example for downloading daily data and exporting to .csv

```
## A script to download and archive Google search analytics
##
## Demo of searchConsoleR R package.
##
## Version 1 - 10th August 2015
##
## Mark Edmondson (http://markedmondson.me)

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
scr_auth()

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
```

## The dimensionFilterExp parameter

This parameter is used in search_analytics to filter the result.

Filter using this format: ```filter operator expression```

Filter can be one of:

* `country`,
* `device`
* `page`
* `query`

Operator can be one of ```~~, ==, !~, !=``` where the symbols mean:

* `~~` : 'contains',
* `==` : 'equals',
* `!~` : 'notContains',
* `!=` : 'notEquals'

Expression formatting:

* for ```page``` or ```query``` is free text.
* for ```country``` must be the three letter country code as per the [the ISO 3166-1 alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) standard. e.g. USA, GBR = United Kingdon, DNK = Denmark
* for ```device``` must be one of:  'MOBILE', 'DESKTOP' or 'TABLET'

You can have multiple ```AND``` filters by putting them in a character vector.  The below looks for desktop searches in the United Kingdom, not showing the homepage and not including queries containing 'brandterm'.

```
c("device==DESKTOP","country==GBR", "page!=/home", "query!~brandterm")
```

```OR``` filters aren't yet supported in the API.

## Using your own Google API project 

As default `searchConsoleR` uses its own Google API project to grant requests, but if you want to use your own keys:

1. Set up your project in the [Google API Console](https://code.google.com/apis/console) to use the search console v3 API.

### For local use
2. Click 'Create a new Client ID', and choose "Installed Application".
3. Note your Client ID and secret.
4. Modify these options after `searchConsoleR` has been loaded:
  + `options("searchConsoleR.client_id" = "YOUR_CLIENT_ID")`
  + `options("searchConsoleR.client_secret" = "YOUR_CLIENT_SECRET")`

### For Shiny use
2. Click 'Create a new Client ID', and choose "Web Application".
3. Note your Client ID and secret.
4. Add the URL of where your Shiny app will run, as well as your local host for testing including a port number.  e.g. https://mark.shinyapps.io/searchConsoleRDemo/ and http://127.0.0.1:4624
5. In your Shiny script modify these options:
  + `options("searchConsoleR.webapp.client_id" = "YOUR_CLIENT_ID")`
  + `options("searchConsoleR.webapp.client_secret" = "YOUR_CLIENT_SECRET")`
6. Run the app locally specifying the port number you used e.g. `shiny::runApp(port=4624)`
7. Or deploy to your Shiny Server that deploys to web port (80 or 443).
