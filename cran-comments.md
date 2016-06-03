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
  * Format documentation for easier reading and fix issues with MIN/MAX where MIN referred to MAX [(Issue 5)](https://github.com/adamhsparks/GSODR/issues/5)
  * Fix bug where the `tf` item was incorrectly set as `tf <- "~/tmp/GSOD-2010.tar`, not `tf <- tempfile`, in `get_GSOD` [(Issue 6)](https://github.com/adamhsparks/GSODR/issues/6)
  * CITATION file is updated and corrected
  
### Changes
  * User now has the ability to generate a shapefile as well as CSV file output [(Issue 3)](https://github.com/adamhsparks/GSODR/issues/3)
  
### Improvements
  * Documentation is more complete and easier to use

## Reverse dependencies
* There are no reverse dependencies.

## Downstream dependencies
* There currently are no downstream dependencies for this package
