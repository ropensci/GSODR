## Test environments
* local OS X install, R 3.3.0
* Ubuntu 12.04 (on travis-ci), R 3.3.0
* win-builder (release)
* win-builder (R Under development (unstable) (2016-05-07 r70590))

## R CMD check results
There were no ERRORs or WARNINGs. 

## New minor release
This is a new minor release. In this version I have:
  * Set values where MIN > MAX to NA
  * Set more MIN/MAX/DEWP values to NA. GSOD README indicates that 999 indicates missing values in these columns, this does not appear to always be true. There are instances where 99 is the value recorded for missing data. While 99F is possible, the vast majority of these recorded values are missing data, thus the function now converts them to NA
  * Fixed bug where YDAY not correctly calculated and reported in CSV file
  * CSV files for station only queries now are names with the Station Identifier. Previously named same as Global data
  * Likesise, CSV files for agroclimatology now are names with the Station Identifier. Previously named same as Global data

## Reverse dependencies

* There are no reverse dependencies.

## Downstream dependencies
* There currently are no downstream dependencies for this package
