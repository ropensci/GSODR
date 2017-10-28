## Test environments  
* local OS X install, R 3.4.2 (2017-09-28)
* ubuntu 12.04 (on travis-ci), R 3.4.2 (2017-09-28)
* win-builder R Under development (unstable) (2017-09-12 r73242)
* win-builder R version 3.4.2 (2017-09-28)

## R CMD check results

0 errors | 0 warnings | 1 note

## New major release

This is a new major release with reduced dependencies and new functionality

## Bug fixes

- Fixes bug reported in [issue 36](https://github.com/ropensci/GSODR/issues/36)
```r
> t <- get_GSOD(years = 2010, station = "955510-99999")
Error in .f(.x[[i]], ...) : 
955510-99999 is not a valid station ID number, please check your entry.
Valid Station IDs can be found in the isd-history.txt file
available from the US NCEI FTP server by combining the USAF and WBAN
columns, e.g., '007005' '99999' is '007005-99999' from this file 
<ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.txt>
```

## Major changes

- The _data.table_ and _fields_ packages are no longer imported. All internal
functions now use _dplyr_ or base R functionality, reducing the dependencies of
_GSODR_

- Any data frames returned by _GSODR_ functions are returned as a `tibble()`
object

- The `YEARMODA` column is now returned as `Date` without time, rather than
`Character`

- Add new function, `get_inventory()`, which downloads the NCEI's station
inventory document and returns a `tibble()` object of the data

- Use larger images and provide a table of contents in vignettes

- Updated and enhanced introductory vignette

- Update internal stations list

## Reverse dependencies

- No ERRORs or WARNINGs found

## Downstream dependencies

- There currently are no downstream dependencies for this package
