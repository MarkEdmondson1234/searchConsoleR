# 0.3.0.9000

* Support up to 25,000 rows per API call (#44)

# 0.3.0

* Update authentication options for `scr_auth()` to include auto-authentication etc. from googleAuthR `0.6.2`
* Added `searchAppearance` as a dimension option in `search_analytics()`
* Remove warning if data is more than 90 days old as it will soon allow 12 months (woop)

# 0.2.1

* Add batching per the new API feature to go over 5000 rows. (#12)

# 0.2.0

* Return an empty dataframe of NAs if no results in fetch instead of NULL
* Include android-app check (#7)
* Add `walk_data` parameter to `search_analytics` to get more data
* Set default start and end dates in `search_analytics` to 93 days ago and 3 days ago respectively.
* Correct bug for error in country code.  Will now return the 'Unknown Region' if not recognised (e.g. `CXX`)
* Add `scr_auth` function that wraps `googleAuthR::gar_auth` so you don't need to load googleAuthR explicitly.

# 0.1.2 - on CRAN

* Move to using googleAuthR for authentication backend.

### 0.1.1
* Change `search_analytics()` so if no dimensions will still return data, instead of NULL
