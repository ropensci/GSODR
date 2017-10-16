
## Test environments  

- macOS 10.12.6 (local install), R version 3.4.2 (2017-09-28)

- Ubuntu 14.04.5 LTS (on travis-ci), R version 3.4.2 (2017-09-28)

- Windows (on win-builder), R version 3.4.2 (2017-09-28)

- Windows (on win-builder), R Under development (unstable) (2017-09-12 r73242)

## R CMD check results

There were no ERRORs or WARNINGs

## New minor release

This is a new minor release, mainly for bug fixes

## Bug fixes

- Fix documentation in vignette where first example would not run due to changes
in package data formats

- Fix bug in GSODR vignette where examples would not run due to libraries not
being loaded

- Fix bug where prior server queries would be pre/appended to subsequent
queries

- Fix bug where invalid stations would return an empty data frame, should stop
and return message about checking the `station` value supplied to `get_GSOD()`
and check if data are available for the years requested

## Minor changes

- Update Appendix 2 of GSODR vignette, map of station locations, to be more
clear and follow same format as that of `bomrang` package

- Update example output in GSODR vignette where applicable

## Major changes

- Update internal stations list

## Reverse dependencies

- No ERRORs or WARNINGs found

## Downstream dependencies

- There currently are no downstream dependencies for this package
