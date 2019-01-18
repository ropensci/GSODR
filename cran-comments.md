# Test environments

  -  macOS, R version 3.5.1 (2018-07-02)

  -  Ubuntu Linux 18.04.1, R version 3.5.1 (2018-07-02)

  -  win-builder, R Under development (unstable) (2019-01-14 r75992)

  -  win-builder, R version 3.5.1 (2018-04-23)


# R CMD check results

0 errors | 0 warnings | 1 note

# New Patch Release

## Bug fixes

- Fixes a bug where extra data could be appended to dataframe. See
<https://github.com/ropensci/GSODR/issues/49>. This also means that when you are
retrieving large amounts of data, e.g. global data for 20+ years, you won't fill
up your hard disk space due to the raw data before processing.

## Minor changes

- Update internal database of station locations

# Reverse dependencies

- No ERRORs or WARNINGs found
