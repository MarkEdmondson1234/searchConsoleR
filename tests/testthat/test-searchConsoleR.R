library(testthat)

context("Auth")

## will only work locally at the moment
test_that("Can auth", {
  options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/webmasters")
  token <- scr_auth()
  
  expect_s3_class(token, "Token2.0")
})

context("Get website list")

test_that("Get website list", {
  
  www <- list_websites()
  
  expect_s3_class(www, "data.frame")
})

context("Can get search analytics data", {
  
  www <- list_websites()
  
  sa <- search_analytics(www$siteUrl[[220]], dimensions = c("query","page"))
  
  expect_s3_class(sa, "data.frame")
  
})

context("Can get search analytics data lots of dims with batching", {
  
  www <- list_websites()
  
  sa <- search_analytics(my_example, 
                         startDate = "2017-04-01", endDate = "2017-04-01",
                         dimensions = c("date","device", "country" ,"query","page"), 
                         walk_data = "byBatch", 
                         rowLimit = 9999)
  
  expect_s3_class(sa, "data.frame")
  
})
