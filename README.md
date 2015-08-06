# searchConsoleR
R interface with Google Search Console (formally Google Webmaster Tools) API v3.

Still under development (mostly documentation) but working.

## Shiny Compatible
Authentication can be done locally or within a Shiny app. 

See a very bare bones example here: https://mark.shinyapps.io/searchConsoleRDemo/

## Function list

* search_analytics() - download Google SEO data into an R dataframe.

* list_websites() - list websites in your Google Search Console.
* add_website() - add a website to your Google Search Console.
* delete_website() - delete a website from your Google Search Console.

* list_sitemaps() - list sitemaps recognised in Google Search Console.
* add_sitemap() - add sitemap URL location to Google Search Console.
* delete_sitemap() - remove sitemap URL location in Google Search Console.

* crawl_errors() - list various types of crawl errors googlebot has found.

* list_crawl_error_samples() - get a list of example URLs with errors.
* error_sample_url() - show details about an example URL error (for example, links to a 404 URL)
* fix_sample_url() - make a URL as fixed.

* scr_auth() - main authentication function. Works locally and within a Shiny environment.
* getShinyURL() - detects the Shiny domain URL. Needed for authentication flow.
* shinygaGetTokenURL() - Imported from shinyga() package. Needed for authentication flow, gives the URL a user must click on to get verified.