## Test environments
* local OS X install, R 3.3.0
* Ubuntu 12.04 (on travis-ci), R 3.3.0
* win-builder (release)
* win-builder (R Under development (unstable) (2016-05-07 r70590))

## R CMD check results
There were no ERRORs or WARNINGs. 

## New minor release
This is a new minor release. In this version I have:
  * Fixed bug related to MIN/MAX columns when agroclimatology or all stations are selected where flags were not removed properly from numeric values.
  * Add more detail to DESCRIPTION regarding flags found in original GSOD data.

## Reverse dependencies

* There are no reverse dependencies.

## Downstream dependencies
* There currently are no downstream dependencies for this package
