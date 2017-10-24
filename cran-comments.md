
## Test environments  

- macOS 10.12.6 (local install), R version 3.4.2 (2017-09-28)

- Ubuntu 14.04.5 LTS (on travis-ci), R version 3.4.2 (2017-09-28)

- Windows (on win-builder), R version 3.4.2 (2017-09-28)

- Windows (on win-builder), R Under development (unstable) (2017-09-12 r73242)

## R CMD check results

There were no ERRORs or WARNINGs

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

- Add new function, `get_inventory()`, which downloads the NCEI's station
inventory document and returns a `tibble()` object of the data

- A new theme is used for the vignettes and documentation website, spacelab,
which provides a floating table of contents in vignettes and larger images

- Updated and enhanced introductory vignette

- Update internal stations list

## Reverse dependencies

- No ERRORs or WARNINGs found

## Downstream dependencies

- There currently are no downstream dependencies for this package
