## Test environments
* local OS X install, R 3.3.0
* Ubuntu 12.04 (on travis-ci), R-3.3.0
* Windows Server 2012 R2 x64 (build 9600) (on appveyor), R-3.3.0
* win-builder, R Under development (unstable) (2016-05-31 r70688)

## R CMD check results
There were no ERRORs or WARNINGs. 

## New minor release
This is a new minor release.

### Bug fixes
  * Fix bug with connection timing out for single station queries commit:  [a126641e00dc7acc21844ff0436e5702f8b6e04a](https://github.com/adamhsparks/GSODR/commit/a126641e00dc7acc21844ff0436e5702f8b6e04a)
  * Somehow the previously working function that checked country names broke
  with the toupper() function. A new [function from juba](http://stackoverflow.com/questions/16516593/convert-from-lowercase-to-uppercase-all-values-in-all-character-variables-in-dat)
  fixes this issue and users can now select country again.

### Changes
  * User entered values for a single station are now checked against actual
  station values for validity
  * stations.rda is compressed
  * stations.rda now includes a field for "corrected" elevation using
  hole-filled SRTM data from Jarvis et al. 2008, see
  [https://github.com/adamhsparks/GSODR/blob/devel/data-raw/fetch_isd-history.md](https://github.com/adamhsparks/GSODR/blob/devel/data-raw/fetch_isd-history.md)
  for a description
  * Updated documentation
  
  * Set NA or missing values in CSV or Shapefile to -9999 from -9999.99 to align with other data sources such as Worldclim
  
### Improvements
  * Documentation is more complete and easier to use

## Reverse dependencies
* There are no reverse dependencies.

## Downstream dependencies
* There currently are no downstream dependencies for this package
