
## Test environments  

- macOS 10.12.6 (local install), R version 3.4.1 (2017-06-30)

- Ubuntu 14.04.5 LTS (on travis-ci), R version 3.4.1 (2017-06-30)

- Windows (on win-builder), R version 3.4.1 (2017-06-30)

- Windows (on win-builder), R Under development (unstable) (2017-06-10 r72776)

## R CMD check results

There were no ERRORs or WARNINGs

## New minor release

This is a new minor release

## Major changes

- Data for station locations and unique identifiers is now provided with the
  package on installation. Previously this was fetched each time from the FTP
  server.

- The station metadata can now be updated if necessary by using
 `update_station_list()`, this change overwrites the internal data that were
  originally distributed with the package. This operation will fetch the latest
  list of stations and corresponding information from the NCEI FTP server. Any
  changes will be overwritten when the R package is updated, however, the
  package update should have the same or newer data included, so this should not
  be an issue.

- Replace _plyr_ functions with _purrr_; _plyr_ is no longer actively developed

- _plyr_ is no longer an import

- Move description of functions' output to individual vignettes to shorten help
  file documentation

## Reverse dependencies

- There are no reverse dependencies

## Downstream dependencies

- There currently are no downstream dependencies for this package
