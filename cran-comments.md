## Test environments
* local OS X install, R version 3.3.1 (2016-06-21)
* Ubuntu 12.04 (on travis-ci), R version 3.3.1 (2016-06-21)
* Windows (on win-builder), R version 3.3.1 (2016-06-21)
* Windows (on win-builder), R Under development (unstable) (2016-07-13 r70908)

## R CMD check results
There were no ERRORs or WARNINGs. 

## New minor release
This is a new minor release.

## Bug fixes
  * Fix bug in precipitation calculation. Documentation states that PRCP is in
  mm to hundredths. Issues with conversion and missing values meant that this
  was not the case. Thanks to Gwenael Giboire for reporting and help with fixing
  this  
  
## Changes
  * Users can now select to merge output for station queries across multiple
  years. Previously one year = one file per station. Now were set by user, 
  `merge_station_years = TRUE` parameter, only one output file is generated  
  * Country list is now included in the package to reduce run time necessary
  when querying for a specific country. However, this means any time that the
  country-list.txt file is updated, this package needs to be updated as well  
  * Updated `stations` list with latest version from NCDC published 12-07-2016  
  
## Improvements
  * Country level, agroclimatology and global data query conversions and
  calculations are processed in parallel now to reduce runtime  
  * Improved documentation with spelling fixes, clarification and updates  
  * Enable `ByteCompile` option upon installation for small increase in speed  
  * Use `write.csv.raw` from `iotools` to greatly improve runtime by decreasing
  time used to write CSV files to disk  
  * Use `writeOGR` from `rgdal` to improve runtime by decreasing time used to
  write shapefiles to disk  

## Reverse dependencies
* There are no reverse dependencies  

## Downstream dependencies
* There currently are no downstream dependencies for this package  
