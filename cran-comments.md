## Test environments
* local OS X install, R 3.3.0
* Ubuntu 12.04 (on travis-ci), R 3.3.0
* win-builder (release)
* win-builder (R Under development (unstable) (2016-05-24 r70665))

## R CMD check results
There were no ERRORs or WARNINGs. 

## New minor release
This is a new minor release. In this version I have:
Changes
  * Fixed an issue when reading .op files into R where temperature was incorrectly read causing negative values where T >= 100F, this issue caused RH values of >100% and incorrect TEMP values
  * Made spelling corrections
  * Included MIN/MAX flag columns
  * Included station data in package rather than downloading from NCDC every time get_GSOD() is run
  * Clarified documentation and descriptions

## Reverse dependencies

* There are no reverse dependencies.

## Downstream dependencies
* There currently are no downstream dependencies for this package
