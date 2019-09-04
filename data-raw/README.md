
# GSODR data-raw contents

## Fetch isd-history

This document details how the GSOD station history data file,
["isd-history.csv"](https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv),
is fetched from the NCEI server and saved for inclusion in the _GSODR_ 
package in /data/isd_history.rda. These data are used for determining the years
that a station reported data for filtering user requests before sending them to
the server to reduce failed requests.

[fetch_isd-history.md](fetch_isd-history.md)
