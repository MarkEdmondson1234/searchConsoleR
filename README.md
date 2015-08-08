# searchConsoleR
R interface with Google Search Console (formally Google Webmaster Tools) API v3.

Still under development 0.0.0.9000 but working.

## Shiny Compatible
Authentication can be done locally or within a Shiny app. See a very bare bones example here: https://mark.shinyapps.io/searchConsoleRDemo/

The code for this Shiny app is in the ```./tests/shiny_test``` folder of the package

### Search analytics trend
![searchConsoleR - google search console R package1][demo1]

### Search Analytics breakdown
![searchConsoleR - google search console R package2][demo2]

### Error trend
![searchConsoleR - google search console R package3][demo3]

### Sample URLs of errors
![searchConsoleR - google search console R package4][demo4]

 However, at the moment Shiny authentication is not multi-user: if a user is using the app and another authenticates, the first will lose access.  This may be fine for local or Shiny Server use, but not on public Shiny instances.  Multi-user Shiny authentication will be coming up in a future release.

## Links

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
devtools::install_github("MarkEdmondson1234/searchConsoleR")
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

[demo1]: https://github.com/MarkEdmondson1234/searchConsoleR/blob/master/images/searchConsoleR%20demo1.png
[demo2]: https://github.com/MarkEdmondson1234/searchConsoleR/blob/master/images/searchConsoleR%20demo2.png
[demo3]: https://github.com/MarkEdmondson1234/searchConsoleR/blob/master/images/searchConsoleR%20demo3.png
[demo4]: https://github.com/MarkEdmondson1234/searchConsoleR/blob/master/images/searchConsoleR%20demo4.png
[search_analytics_help]: https://github.com/MarkEdmondson1234/searchConsoleR/blob/master/images/search_analytics_help.png
