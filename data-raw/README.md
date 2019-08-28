
# GSODR data-raw contents

## Fetch country-list

This document details how to fetch the country list provided by the NCEI for
the GSOD stations from the FTP server and merge it with ISO codes from the
[_countrycode_](https://cran.r-project.org/package=countrycode)
package for inclusion in the _GSODR_ package in /data/country-list.rda. These
codes are used when a user selects a single country for a data query.

[fetch_country-list.md](fetch_country-list.md)

## Fetch isd-history

This document details how the GSOD station history data file,
["isd-history.csv"](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv),
is fetched from the NCEI FTP server and saved for inclusion in the _GSODR_ 
package in /data/isd_history.rda. These data are used for determining the years
that a station reported data for filtering user requests before sending them to
the server to reduce failed requests.

[fetch_isd-history.md](fetch_isd-history.md)
