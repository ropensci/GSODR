## Test environments  
* local OS X install, R 3.4.4 (2018-03-15)
* local Ubuntu 17.10, R 3.4.4 (2018-03-15)
* win-builder, R Under development 3.5.0 alpha (2018-03-27 r74477)
* local Windows 7, R version 3.4.4 (2018-03-15)

## R CMD check results

0 errors | 0 warnings | 1 note

## New minor release

This is a new minor release

## Major changes

- Remove ability to export files from `get_GSOD()` to slim down the package
dependencies and this functions parameters. Examples of how to convert to a
spatial object (both _sp_ and _sf_ are shown) and export ESRI Shapefiles and
GeoPackage files are now included in the vignette.

- As a result of the previous point, the _sp_ and _rgdal_ packages are no longer
Imports but are now in Suggests along with _sf_ for examples in the GSOD
vignette.

## Bug fixes

- Fix a nasty bug where GSOD files downloaded using Windows would not untar
properly. This caused the `get_GSOD()` function to fail.

- Correct options in "GSODR use case: Specified years/stations vignette" on line
201 where `file` was incorrectly used in place of `path`.

- Correct documentation for `reformat_GSOD()`

## Minor changes

- Update internal databases of station metadata

## Reverse dependencies

- No ERRORs or WARNINGs found

## Downstream dependencies

- There currently are no downstream dependencies for this package
