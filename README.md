# searchConsoleR

[![Travis-CI Build Status](https://travis-ci.org/MarkEdmondson1234/SearchConsoleR.svg?branch=master)](https://travis-ci.org/MarkEdmondson1234/SearchConsoleR)

R interface with Google Search Console (formally Google Webmaster Tools) API v3.

## News

### 0.2

Move to using googleAuthR for authentication backend.

### 0.1.1
Change search_analytics() so if no dimensions will still return data, instead of NULL

## Shiny Compatible
Authentication can be done locally or within a Shiny app. See a very bare bones example here: https://mark.shinyapps.io/searchConsoleRDemo/

The code for this Shiny app is in the ```./tests/shiny_test``` folder of the package

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

### Authentication functions
* `scr_auth()` - main authentication function. Works locally and within a Shiny environment.
* `getShinyURL()` - detects the Shiny domain URL. Needed for authentication flow.
* `shinygaGetTokenURL()` - Imported from shinyga() package. Needed for authentication flow, gives the URL a user must click on to get verified.

## Guide

Install searchConsoleR from github using [devtools](https://cran.r-project.org/web/packages/devtools/index.html).

```
## load the library or download it if necessary
if(!require(searchConsoleR)){
  if(!require(devtools)){
    install.packages("devtools")
  } else {
    devtools::install_github("MarkEdmondson1234/searchConsoleR")
  }
}
library(searchConsoleR)
```

Work flow always starts with authenticating with Google.
```
scr_auth()
```

Your browser window should open up and go through the Google sign in OAuth2 flow. Verify with a user that has Search Console access to the websites you want to work with.

Check out the documentation of any function for a guide on what else can be done.
```
?scr_auth
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
![google search analytics R package][search_analytics_help]

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
