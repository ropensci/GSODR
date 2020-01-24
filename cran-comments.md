# Test environments

  -  macOS, R version 3.6.2 (2019-12-12)

  -  Manjaro Linux, R version 3.6.2 (2019-12-12)

  -  win-builder, R Under development (unstable) (2020-01-07 r77633)

  -  win-builder, R version 3.6.2 (2019-12-12)

# R CMD check results

0 errors | 0 warnings | 1 note

# New Major Release

## Bug fixes

* Corrects internal bug that provided a warning message when GSOD files were
parsed

* Fixes bug where not all files downloaded were cleaned up on the function
exit when fetching station inventories

* Fixes bug where station inventories from `get_inventory()` lacked the
location metadata, _i.e._ country and other geographic information

## Major changes

* Requires R >= 3.5.0 due to the storage of .Rds files using the latest version

# Reverse dependencies

- No ERRORs or WARNINGs found
