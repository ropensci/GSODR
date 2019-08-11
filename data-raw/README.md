
# GSODR data-raw Contents

## Fetch country-list

This document details how to fetch the country list provided by the NCEI for
the GSOD stations from the FTP server and merge it with ISO codes from the
[_countrycode_](https://cran.r-project.org/package=countrycode)
package for inclusion in the _GSODR_ package in /data/country-list.rda. These
codes are used when a user selects a single country for a data query.

[fetch_country-list.md](fetch_country-list.md)
