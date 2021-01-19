# Test environments

  - macOS, R version 4.0.3 (2020-10-10)

  - win-builder, R Under development (2020-09-17 r79226)

  - win-builder, R version 4.0.2 (2020-06-22)

# R CMD check results

0 errors | 0 warnings | 1 note

# New Major Release

## Major changes

* Remove parallel processing functionality.
A bug that I was unable to properly debug with `future.apply::future_lapply()` caused the `get_GSOD()` and `reformat_GSOD()` functions to run without completing or responding was fixed by simply using R's base `lapply()` function.
If parallel processing is needed, users should implement their own solutions to download and process in parallel.

## Bug fixes

* Fix bug that caused the package to run without responding.

* Fix test that failed on CRAN's Solaris server for some reason.

* Removes a working DOI link from the reference for the equation used because win-builder checks say it doesn't work (even though it does and there's nothing wrong with the link any time I check).

# Reverse dependencies

- No ERRORs or WARNINGs found
