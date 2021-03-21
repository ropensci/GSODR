# Test environments

  - macOS, R version 4.0.4 (2021-02-15)

  - win-builder, R Under development (unstable) (2021-03-19 r80100)

  - win-builder, R version 4.0.4 (2021-02-15)

# R CMD check results

0 errors | 0 warnings | 1 note

## New features

* Diffs in the isd_history are now recorded in the `/data-raw/fetch_isd-history.md` file and shipped with GSODR as `isd_history.rda`, which can be viewed by using `load(system.file("extdata", "isd_diff.rda", package = "GSODR"))`.

* Update and improve documentation to reflect country name and ISO code columns.

* Fix bug where COUNTRY_NAME (country name in English), ISO2C and ISO3C were omitted from the final output from `get_GSOD()` and `reformat_GSOD()`.

## Minor improvements

* Update NCEI data usage statement

# Reverse dependencies

- No ERRORs or WARNINGs found
