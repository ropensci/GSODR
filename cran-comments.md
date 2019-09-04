# Test environments

  -  macOS, R version 3.6.1 (2019-07-05)

  -  Ubuntu Linux 18.04.1, R version 3.6.1 (2019-07-05)

  -  win-builder, R Under development (unstable) ()

  -  win-builder, R version 3.6.1 (2019-07-05)


# R CMD check results

0 errors | 0 warnings | 1 note

# New Major Release

## Bug fixes

- `get_GSOD()` now uses https rather than FTP server, correcting bug where the
data could not be downloaded any longer

## Major changes

- Corrected elevation values are no longer available from GSODR, this makes
package updates much easier

- Objects are returned as `data.table` objects

## Minor changes

- Implement better error handling when attempting to fetch station inventories

- Reduced package dependencies

- Improved vignettes

- Users may now specify country by FIPS code when using `get_GSOD()`

- Improved test coverage

- Updated internal database of station locations

# Reverse dependencies

- No ERRORs or WARNINGs found
