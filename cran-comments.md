## Test environments  
* local OS X install, R 3.4.2 (2017-09-28)
* ubuntu 12.04 (on travis-ci), R 3.4.2 (2017-09-28)
* win-builder R Under development (unstable) (2017-09-12 r73242)
* win-builder R version 3.4.2 (2017-09-28)

## R CMD check results

0 errors | 0 warnings | 1 note

## New minor release

This is a new minor release

## Bug fixes

- `MAX_FLAG` and `MIN_FLAG` columns now report `NA` when there is no flag

## Minor changes

- Comment for Bob and Hugh in DESCRIPTION now only ORCID url

- dplyr version set to >= 0.7.0 not 0.7 as before

- Start-up message statement is more clear in relation to WMO resolution 40,
that GSODR does not redistribute any weather data itself

- Remove unnecessary function, .onLoad(), from zzz.R

- Function titles in documentation now in title case

- Correct grammar in documentation

- Update internal stations list

## Reverse dependencies

- No ERRORs or WARNINGs found

## Downstream dependencies

- There currently are no downstream dependencies for this package
