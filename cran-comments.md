## Test environments
* local OS X install, R 3.3.0
* Ubuntu 12.04 (on travis-ci), R 3.3.0
* win-builder (release)
* There currently is no devel version

## R CMD check results
There were no ERRORs or WARNINGs. 

## New minor release
This is a new minor release. In this version I have:
  * Fixed a bug when importing isd-history.csv file. Previous issues caused all lat/lon/elev values to be >0. Values now range between -90/90 latitude and -180/180 longitude.
  * Fixed a bug where WDSP was mistyped as WDPS causing the creation of a new column, rather than the conversion of the existing
  * Fixed a bug if Agroclimatology selected. Previously this resulted in no records being returned. It now returns stations between -60/60 latitude.
  * Fixed a bug for country selection. Some countries did not return proper ISO code. All countries now should return a valid code.
  * Set default encoding to UTF8.
  * Use write.csv, not readr::write_csv due to issue converting double to string: https://github.com/hadley/readr/issues/387

## Reverse dependencies

* There are no reverse dependencies.

## Downstream dependencies
* There currently are no downstream dependencies for this package
