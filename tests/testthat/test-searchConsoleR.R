library(testthat)

## Use a test website as specified in SC_TEST_WEBSITE arg

my_example <- Sys.getenv("SC_TEST_WEBSITE")

context("Auth")

## will only work locally at the moment
test_that("Can auth", {
  skip_on_cran()
  token <- scr_auth()
  
  expect_s3_class(token, "Token2.0")
})

context("Get website list")

test_that("Get website list", {
  skip_on_cran()
  www <- list_websites()
  
  expect_s3_class(www, "data.frame")
})

context("Get search analytics")

test_that("Can get search analytics data", {
  skip_on_cran()
  sa <- search_analytics(my_example, dimensions = c("query","page"))
  
  expect_s3_class(sa, "data.frame")
  
})

test_that("Can get search analytics data lots of dims with batching", {
  skip_on_cran()
  sa1 <- search_analytics(my_example, 
                         dimensions = c("date","device", "country" ,"query","page"), 
                         walk_data = "byBatch", 
                         rowLimit = 9999)
  
  expect_s3_class(sa1, "data.frame")
  
})

test_that("Can get search analytics data lots of dims with date", {
  skip_on_cran()
  sa2 <- search_analytics(my_example, startDate = Sys.Date() - 10, 
                         dimensions = c("date","device", "country" ,"query","page"), 
                         walk_data = "byDate")
  
  expect_s3_class(sa2, "data.frame")
  
})


test_that("searchAppearance dimension", {
  skip_on_cran()
  sa3 <- search_analytics(my_example, 
                         dimensions = c("searchAppearance"))
  
  expect_s3_class(sa3, "data.frame")
  
})
