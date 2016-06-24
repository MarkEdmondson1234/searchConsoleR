# 0.2.1.9000

* hmm

# 0.2.1

* Add batching per the new API feature to go over 5000 rows. (#12)

# 0.2.0

* Return an empty dataframe of NAs if no resutls in fetch instead of NULL
* Include android-app check (#7)
* Add `walk_data` parameter to `search_analytics` to get more data
* Set default start and end dates in `search_analytics` to 93 days ago and 3 days ago respectivily.
* Correct bug for error in country code.  Will now return the 'Unknown Region' if not recognised (e.g. `CXX`)
* Add `scr_auth` function that wraps `googleAuthR::gar_auth` so you don't need to load googleAuthR explicitly.

# 0.1.2 - on CRAN

* Move to using googleAuthR for authentication backend.

### 0.1.1
* Change search_analytics() so if no dimensions will still return data, instead of NULL
