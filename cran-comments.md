# Test environments

  - macOS, R version 3.6.3 (2020-02-29)

  - Ubuntu Linux, R version 3.6.3 (2020-02-29)

  - win-builder, R Under development 4.0.0 beta (2020-04-15 r78231)

  - win-builder, R version 3.6.3 (2020-02-29)

# R CMD check results

0 errors | 0 warnings | 1 note

Possibly mis-spelled words in DESCRIPTION are all last names:
  Alduchov (41:73)
  Eskridge (42:7)
  Magnus (41:51)

# New Minor Release

## Major changes

* Implement new calculations for EA, ES and RH using improved August-Roche-Magnus approximation (Alduchov & Eskridge 1996).
HT Rich Ianonne for his use in [stationaRy](https://cran.r-project.org/package=stationaRy).
This will result in different EA, ES and RH calculations from the prior versions of GSODR.
However, this new implementation should be more accurate as discussed in (Alduchov & Eskridge 1996).

> Alduchov, O.A. and Eskridge, R.E., 1996. Improved Magnus form approximation of saturation vapor pressure. Journal of Applied Meteorology and Climatology, 35(4), pp.601-609.

## Minor changes

* Update internal station list to latest

* Enhanced documentation

# Reverse dependencies

- No ERRORs or WARNINGs found
