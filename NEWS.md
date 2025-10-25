# GSODR (development version)

# GSODR 4.1.4

## Bug fixes

- Handles mixture of FIPS and ISO2C country codes in isd-history.txt now, ensuring that all stations are accessible through this package.

# GSODR 4.1.3

- Skip test on CRAN (`test-get_updates()`) that should have been skipped but wasn't

# GSODR 4.1.2

## Bug fixes

- Enforce {data.table} >= 1.15.4 due to issue with `fifelse()` as reported in <https://github.com/ropensci/GSODR/issues/121>

- Fix issue with working directory changing as reported in <https://github.com/ropensci/GSODR/issues/124>

# GSODR 4.1.1

## Bug fixes

- This is a continuation of the bug in the GSOD CSV file format data from the previous release.
  The missing values should be 9999.9 as 999.9 is a valid "STP" value.
  However, this does not appear to be the value that's actually used for missing data in this field.
  So, I've elected to set the STP field to `NA` when "STP_ATTRIBUTES" are equal to "0" or no observations used in reporting "STP" to see if this overcomes the issue.

# GSODR 4.1.0

## Minor changes

- Added citation information for the data themselves to README.

- Adds new function, `get_updates()`, which gets the changelog for the GSOD data and returns it sorted with most recent changes first.

## Bug fixes

- This is really a bug in the GSOD data, not {GSODR}, but we do our best to please.
  As reported by @geospacedman in [#117](https://github.com/ropensci/GSODR/issues/117), STP values above 1000 were not properly reported.
  Upon further inspection, it was found that the GSOD data in the CSV files is incorrect and the leading "1" is truncated and the values are reported as "034" for _e.g._ "1034".
  Further, {data.table} drops the leading zeros by default on import with `fread()` unless `keepLeadingZeros = TRUE` is set, so that is now set and the 1 is appended when the values are >1000 and all should be well with the world again.

- Fixes title that ended with a full stop.

# GSDOR 4.0.0

## Major changes

- **Breaking change** `nearest_stations()` now returns a `data.table` of all station metadata and a value with the distance in kilometres from the user-provided coordinates.
  This function previous returned a single `character` vector.
  To replicate the previous functionality, you can use the following method by calling the `STNID` column name.

```r
nearest_stations(LAT = 14.16742, LON = 121.255669, distance = 50)$STNID
```

## Minor changes

- Update internal isd history database.

# GSODR 3.1.10

## Minor changes

- Use {roxyglobals} for handling global values.

- Update internal isd history database.

- Tidy up Appendix 2 in vignette, map of GSOD station locations.
  Add a caption and remove text from .png image itself.

## Bug fixes

- Fix codecov badge in README

# GSODR 3.1.9

## Bug fixes

- Fix duplicated elevation columns.

## Minor changes

- Remove {httr} as an Import. Use base functionality to check existence first and then {curl} will properly error if a download fails, we will use that functionality.

- Fix codecov badge to point at proper branch.

- Ensure function titles are all proper title case.

- Enhanced handling of data requests for incompatible station-year combinations. A `warning()` is issued for each bad combo, but if a `vector()` of stations is requested, any valid stations will still be downloaded with the bad combos omitted after the warning is emitted.

# GSODR 3.1.8

- Update CITATION file to follow CRAN's ~ever-changing whims~ guidelines.

# GSODR 3.1.7

## Bug fixes

- Fix bug where the `isd_history.Rda` data object was not updated using the `data_raw/fetch_isd-history.Rmd`.

- Fix bug where stations were not available in the internal `isd_history` file, this caused `NA` values to appear for some stations when run using `format_GSOD()` or to not be available for download with `get_GSOD()`.
  This adds 1,334 new stations that are now available through GSODR.
  These were always available through GSOD but this bug prevented them from being accessed through this package.

- Fix minor bug where `get_inventory()` returned garbage in the header of the object.

# GSODR 3.1.6

## Minor changes

- Redoc package to correct HTML issues.

- Update internal `isd-history` database.

- Update changed URLs.

# GSODR 3.1.5

## Minor changes

- Update internal `isd-history` database.

- Use `return(invisible(NULL))` for functions that check user inputs without any returns.

- Replace `class(years) == "character")` with `inherits(years, what = "character")` in an internal function, `.validate_years()`.

- Updates invalid URLs.

# GSODR 3.1.4

## Minor changes

- Skip **ANY** and **ALL** tests on CRAN.
  This fixes the "problems" with _GSODR_ failing on a Solaris instance when the server failed to respond.

- Update internal `isd-history` database.

- Use `\CRANpkg{}` in place of `\pkg{}` in documentation.

# GSODR 3.1.2

## Bug fixes

- Fix (more) bugs related to `NA` value replacements.

## Minor changes and improvements

- Simplify `NA` value replacement in "PRCP" column.

- The PRCP column values are rounded to two decimal places as in original GSOD data, not one.

- The TEMP_ATTRIBUTES, DEWP_ATTRIBUTES, SLP_ATTRIBUTES, STP_ATTRIBUTES, VISIB_ATTRIBUTES and WDSP_ATTRIBUTES columns are formatted as an integer not character.

- Better tests for the generated weather data `data.table` output checking values and formats.

- Tests are updated for updated data availability in the GSOD data due to continuous improvements to the data set.

- Standardise handling of author/contributor comments.
  None have a full stop now in the comment.

- Use `on.exit()` to reset the working directory to the original user-space value after changing the working directory to untar files located in `tempdir()`.

# GSODR 3.1.1

## Bug fixes

- Fixes bug reported in [#84](https://github.com/ropensci/GSODR/issues/84) in the FRSHTT columns where the values were all reported as `NA` even if there were observed values.

- Fixes bug where NA values reported as 99.99, 999.9 or 9999.9 were not replaced with `NA`.

- Fix bug where FRSHTT (Fog, Rain/Drizzle, Snow/Ice, Hail, Tornado, Thunder) column values split into the respective columns only returned `NA`, not the proper values as expected.
  Reported in [#84](https://github.com/ropensci/GSODR/issues/84).

## Minor changes

- Examples are no longer wrapped in `\donttest{}` but use `@examplesIf interactive()` instead.

# GSODR 3.1.0

## New features

- Include columns for COUNTRY_NAME (country name in English), ISO2C and ISO3C in the final output from `get_GSOD()` and `reformat_GSOD()`.

- Diffs in the isd_history are now recorded in the `/data-raw/fetch_isd-history.md` file and shipped with GSODR as `isd_history.rda`, which can be viewed by using `load(system.file("extdata", "isd_diff.rda", package = "GSODR"))`.

- Update and improve documentation to reflect country name and ISO code columns.

## Minor improvements

- Update NCEI data usage statement.

# GSODR 3.0.0

## Breaking changes

- Remove parallel processing functionality. A bug that I was unable to properly debug with `future.apply::future_lapply()` caused the `get_GSOD()` and `reformat_GSOD()` functions to run without completing or responding was fixed by simply using R's base `lapply()` function. If parallel processing is needed, users should implement their own solutions to download and process in parallel.

## Bug fixes

- Fix bug that caused the package to run without responding.

- Fix test that failed on CRAN's Solaris server for some reason.

- Removes a working DOI link from the reference for the equation used because win-builder checks say it doesn't work (even though it does and there's nothing wrong with the link any time I check).

# GSODR 2.1.2

## Bug fixes

- Fix bug where `nearest_stations()` did not always return the nearest station as the first value in the vector

## Minor changes

- Update internal isd-history database, adding 11 stations

- Fix any links that redirect found in DESCRIPTION, documentation or other materials in the package

# GSODR 2.1.1

## Bug fixes

- Fix bug where station metadata files could not be updated

## Minor changes

- Update internal station list to latest

- Correct an error in documentation for `update_station_list()`

- Remove spatial vignettes to slim down Suggests and make CI maintenance easier

# GSODR v2.1.0

## Major changes

- Implement new calculations for EA, ES and RH using improved August-Roche-Magnus approximation (Alduchov & Eskridge 1996). HT Rich Iannone for his use in [stationaRy](https://cran.r-project.org/package=stationaRy). This will result in different EA, ES and RH calculations from the prior versions of GSODR. However, this new implementation should be more accurate as discussed in (Alduchov & Eskridge 1996).

> Alduchov, O.A.
> and Eskridge, R.E., 1996.
> Improved Magnus form approximation of saturation vapor pressure.
> Journal of Applied Meteorology and Climatology, 35(4), pp.601-609.

## Minor changes

- Update internal station list to latest

- Enhanced documentation

# GSODR v2.0.1

## Bug fixes

- Corrects internal bug that provided a warning message when GSOD files were parsed

- Fixes bug where not all files downloaded were cleaned up on the function exit when fetching station inventories

- Fixes bug where station inventories from `get_inventory()` lacked the location metadata, _i.e._ country and other geographic information

## Minor changes

- Update vignette to use latest functions from tidyr, _i.e._ `tidyr::pivot_longer()`

- Update internal station list to latest

- Tidy up documentation, mainly fix functions' title capitalisation

- `get_GSOD()` checks the number of stations being requested.
  If the number is \>10, the entire annual file will be downloaded and requested stations will then be selected and returned.
  This saves time by reducing the number of requests made to the server.
  Users should not see any difference other than quicker responses for a large number of requested stations.

## Major changes

- Requires R \>= 3.5.0 due to the storage of .Rds files using the latest version

# GSODR 2.0.0

## Bug fixes

- `get_GSOD()` now uses https rather than FTP server, correcting bug where the data could not be downloaded any longer

## Major changes

- Corrected elevation values are no longer available from GSODR

- Objects are returned as `data.table` objects

## Minor changes

- `get_inventory()` now uses https rather than FTP server

- `update_station_list()` now uses https rather than FTP server

- Implement better error handling when attempting to fetch station inventories

- Reduced package dependencies

- Improved vignettes that are pre-compiled for faster package installation and updated content with linting and error corrections

- Users may now specify country by FIPS code when using `get_GSOD()`

- Improved test coverage

- Update internal database of station locations

# GSODR 1.3.2

## Bug fixes

- Fixes a bug where extra data could be appended to data frame. See <https://github.com/ropensci/GSODR/issues/49>. This also means that when you are retrieving large amounts of data, _e.g._ global data for 20+ years, you won't fill up your hard disk space due to the raw data before processing.

## Minor changes

- Update internal database of station locations

# GSODR 1.3.1

## Bug fixes

- Fix examples that did not run properly

## Minor changes

- Update internal database of station locations

# GSODR 1.3.0

## New Functionality

- Use `future_apply` in processing files after downloading. This allows for end users to use a parallel process of their choice.

# GSODR 1.2.3

## Bug fixes

- Refactor internal functionality to be more clear and efficient in execution
  - `country-list` is not loaded unless user has specified a country in `get_GSOD()`

  - An instance where the FIPS code was determined twice was removed

- Replace `\dontrun{}` with `\donttest{}` in documentation examples

- Ensure that DESCRIPTION file follows CRAN guidelines

## Minor changes

- Format help files, fixing errors and formatting for attractiveness

- Update internal database of station locations

- Store internal database of station locations fields `BEGIN` and `END` as integer, not double

- Clarify code of conduct statement in README that it only applies to this, GSODR, project

- Prompt user for input with warning about reproducibility if using the `update_station_list()` function

- Adds metadata header to the `tibble` returned by `get_inventory()`

- Remove start-up message to conform with rOpenSci guidelines

- Remove extra code, clean up code-chunks and use `hrbrthemes::theme_ipsum()` for [data-raw/fetch_isd-history.md](https://github.com/ropensci/GSODR/blob/main/data-raw/fetch_isd-history.md)

# GSODR 1.2.2

## Bug fixes

- Fix bug in creating `isd-history.rda` file where duplicate stations existed in the file distributed with `GSODR` but with different corrected elevation values

- Repatch bug reported and fixed previously in version 1.2.0 where Windows users could not successfully download files.
  This somehow snuck back in.

## Minor changes

- Refactor vignettes for clarity

# GSODR 1.2.1

## Bug fixes

- Introduce a message if a station ID is requested but files are not found on the server.
  This is in response to an inquiry from John Paul Bigouette where a station is reported as having data in the inventory but the files do not exist on the server.

- Fix bug that removed a few hundred stations from the internal `GSODR` database of stations in the `data-raw` files.

## Minor changes

- Clean documentation, shortening long lines, fixing formatting, incomplete sentences and broken links

- Clarify the reasons for errors that a user may encounter

- Update internal databases of station metadata

- Clean up this file

# GSODR 1.2.0

## Major changes

- Remove ability to export files from `get_GSOD()` to slim down the package dependencies and this functions parameters.
  Examples of how to convert to a spatial object (both _sp_ and _sf_ are shown) and export ESRI Shapefiles and GeoPackage files are now included in the vignette.

- As a result of the previous point, the _sp_ and _rgdal_ packages are no longer Imports but are now in Suggests along with _sf_ for examples in the GSOD vignette.

## Bug fixes

- Fix a nasty bug where GSOD files downloaded using Windows would not untar properly.
  This caused the `get_GSOD()` function to fail.
  Thanks to Ross Darnell, CSIRO, for reporting this.

- Correct options in "GSODR use case: Specified years/stations vignette" on line 201 where `file` was incorrectly used in place of `path`.
  Thanks to Ross Darnell, CSIRO, for reporting this.

- Correct documentation for `reformat_GSOD()`

## Minor changes

- Update internal databases of station metadata

- Vignettes contain pre-built figures for faster package installation when building vignettes

# GSODR 1.1.2

## Bug fixes

- Fix start-up message formatting

- Correct ORCID comment in author field of DESCRIPTION

- Update internal databases for country list and isd_history

## Minor changes

- Add X-schema tags to DESCRIPTION

# GSODR 1.1.1

## Bug fixes

- `MAX_FLAG` and `MIN_FLAG` columns now report `NA` when there is no flag

## Minor changes

- Comment for Bob and Hugh in DESCRIPTION now only ORCID url

- dplyr version set to \>= 0.7.0 not 0.7 as before

- Start-up message statement is more clear in relation to WMO resolution 40, that GSODR does not redistribute any weather data itself

- Remove unnecessary function, .onLoad(), from zzz.R

- Function titles in documentation now in title case

- Correct grammar in documentation

# GSODR 1.1.0

## Bug fixes

- Fixes bug reported in [issue 36](https://github.com/ropensci/GSODR/issues/36)

## Major changes

- The _data.table_ and _fields_ packages are no longer imported.
  All internal functions now use _dplyr_ or base R functionality, reducing the dependencies of _GSODR_

- Any data frames returned by _GSODR_ functions are returned as a `tibble()` object

- The `YEARMODA` column is now returned as `Date` without time, rather than `Character`

- Add new function, `get_inventory()`, which downloads the NCEI's station inventory document and returns a `tibble()` object of the data

- Use larger images and provide a table of contents in vignettes

- Updated and enhanced introductory vignette

- Update internal stations list

# GSODR 1.0.7

## Bug fixes

- Fix documentation in vignette where first example would not run due to changes in package data formats

- Fix bug in GSODR vignette where examples would not run due to libraries not being loaded

- Fix bug where prior server queries would be pre/appended to subsequent queries

- Fix bug where invalid stations would return an empty data frame, should stop and return message about checking the `station` value supplied to `get_GSOD()` and check if data are available for the years requested

## Minor changes

- Update Appendix 2 of GSODR vignette, map of station locations, to be more clear and follow same format as that of `bomrang` package

- Update example output in GSODR vignette where applicable

## Major changes

- Update internal stations list

# GSODR 1.0.6

## Bug fixes

- Fix bug where WSPD (mean wind-speed) conversion was miscalculated

# GSODR 1.0.5

## Major changes

- Add welcome message on start-up regarding data use and sharing

- Update internal stations list

## Minor changes

- Tidy up informative messages that the package returns while running

## Bug fixes

- Fix bug where "Error in read_connection\_(con):" when writing to CSV occurs

- Fix typo in line 160 of `get_GSOD()` where "Rda" should be "rda" to properly load internal package files

# GSODR 1.0.4

## Major changes

- Data distributed with GSODR are now internal to the package and not externally exposed to the user

- Vignettes have been updated and improved with an improved order of information presented and some have been combined for easier use

## Minor changes

- Clean code using linting

# GSODR 1.0.3

## Major changes

- Data for station locations and unique identifiers is now provided with the package on installation.
  Previously this was fetched each time from the ftp server.

- The station metadata can now be updated if necessary by using `update_station_list()`, this change overwrites the internal data that were originally distributed with the package.
  This operation will fetch the latest list of stations and corresponding information from the NCEI ftp server.
  Any changes will be overwritten when the R package is updated, however, the package update should have the same or newer data included, so this should not be an issue.

- Replace _plyr_ functions with _purrr_, _plyr_ is no longer actively developed

- _plyr_ is no longer an import

## Minor changes

- Fix bugs in the vignettes related to formatting and spelling

## Deprecated and defunct

- `get_station_list()` is no longer supported.
  Instead use the new

- `update_station_list()` to update the package's internal station database.

# GSODR 1.0.2.1

## Minor changes

- Correct references to _GSODRdata_ package where incorrectly referred to as _GSODdata_

# GSODR 1.0.2

## Minor changes

- Improved documentation (i.e., spelling corrections and more descriptive)

- More descriptive vignette for "GSODR use case: Specified years/stations vignette"

- Round MAX/MIN temp to one decimal place, not two

- Update SRTM elevation data

- Update country list data

- Fix missing images in README.html on CRAN

# GSODR 1.0.1

## Minor changes

- Update documentation for `get_GSOD()` when using `station` parameter

- Edit paper.md for submission to JOSS

- Remove extra packages listed as dependencies that are no longer necessary

- Correct Working_with_spatial_and_climate_data.Rmd where it was missing the first portion of documentation and thus examples did not work

# GSODR 1.0.0

## Major changes

- The `get_GSOD()` function returns a `data.frame` object in the current R session with the option to save data to local disk

- Multiple stations can be specified for download rather than just downloading a single station or all stations

- A new function, `nearest_stations()` is now included to find stations within a user specified radius (in kilometres) of a point given as latitude and longitude in decimal degrees

- A general use vignette is now included

- New vignette with a detailed use-case

- Output files now include fields for State (US only) and Call (International Civil Aviation Organization (ICAO) Airport Code)

- Use FIPS codes in place of ISO3c for file name and in output files because some stations do not have an ISO country code

- Spatial file output is now in GeoPackage format (GPKG).
  This results in a single file output unlike shapefile and allows for long field names

- Users can specify file name of output

- R \>= 3.2.0 now required

- Field names in output files use "\_" in place of "."

- Long field names now used in file outputs

- Country is specified using FIPS codes in file name and output file contents due to stations occurring in some locales that lack ISO 3166 3 letter country codes

- The `get_GSOD()` function will retrieve the latest station data from NCDC and automatically merge it with the CGIAR-CSI SRTM elevation values provided by this package.
  Previously, the package provided it's own list of station information, which was difficult to keep up-to-date

- A new `reformat_GSOD()` function reformats station files in "WMO-WBAN-YYYY.op.gz" format that have been downloaded from the United States National Climatic Data Center's (NCDC) FTP server.

- A new function, `get_station_list()` allows for fetching latest station list from the FTP server and querying by the user for a specified station or location.

- New data layers are provided through a separate package, `GSODRdata`, which provide climate data formatted for use with GSODR.
  - CHELSA (climatic surfaces at 1 km resolution),

  - MODCF \* Remotely sensed high-resolution global cloud dynamics for predicting ecosystem and biodiversity distributions,

  - ESACCI \* ESA's CCI-LC snow cover probability and

  - CRU CL2.0 (climatic surfaces at 10 minute resolution).

- Improved file handling for individual station downloads

- Missing values are handled as `NA` not -9999

- Change from GPL \>= 3 to MIT licence to bring into line with ropensci packages

- Now included in ropensci, [ropensci/GSODR](https://github.com/ropensci/GSODR)

## Minor changes

- `get_GSOD()` function optimised for speed as best possible after FTPing files from NCDC server

- All files are downloaded from server and then locally processed, previously these were sequentially downloaded by year and then processed

- A progress bar is now shown when processing files locally after downloading

- Reduced package dependencies

- The `get_GSOD()` function now checks stations to see if the years being queried are provided and returns a message alerting user if the station and years requested are not available

- When stations are specified for retrieval using the `station = ""` parameter, the `get_GSOD()` function now checks to see if the file exists on the server, if it does not, a message is returned and all other stations that have files are processed and returned in output

- Documentation has been improved throughout package

- Better testing of internal functions

## Bug Fixes

- Fixed: Remove redundant code in `get_GSOD()` function

- Fixed: The stations data frame distributed with the package now include stations that are located above 60 latitude and below -60 latitude

## Deprecated and defunct

- Missing values are reported as NA for use in R, not -9999 as previously

- The `path` parameter is now instead called `dsn` to be more inline with other tools like `readOGR()` and `writeOGR()`

- Shapefile file out is no longer supported.
  Use GeoPackage (GPKG) instead

- The option to remove stations with too many missing days is now optional, it now defaults to including all stations, the user must specify how many missing stations to check for an exclude

- The `max_missing` parameter is now user set, defaults to no check, return all stations regardless of missing days

# GSODR 0.1.9

## Bug Fixes

- Fix bug in precipitation calculation. Documentation states that PRCP is in mm to hundredths. Issues with conversion and missing values meant that this was not the case. Thanks to Gwenael Giboire for reporting and help with fixing this

## Minor changes

- Users can now select to merge output for station queries across multiple years.
  Previously one year = one file per station.
  Now are set by user, `merge_station_years = TRUE` parameter, only one output file is generated

- Country list is now included in the package to reduce run time necessary when querying for a specific country.
  However, this means any time that the country-list.txt file is updated, this package needs to be updated as well

- Updated `stations` list with latest version from NCDC published 12-07-2016

- Country list is now included in the package to reduce run time necessary when querying for a specific country.
  However, this means any time that the country-list.txt file is updated, this package needs to be updated as well

- Country level, agroclimatology and global data query conversions and calculations are processed in parallel now to reduce runtime

- Improved documentation with spelling fixes, clarification and updates

- Enable `ByteCompile` option upon installation for small increase in speed

- Use `write.csv.raw` from `[iotools]("https://cran.r-project.org/web/packages/iotools/index.html")` to greatly improve runtime by decreasing time used to write CSV files to disk

- Use `writeOGR()` from `rgdal`, in place of `raster's` `shapefile` to improve runtime by decreasing time used to write shapefiles to disk

- Country level, agroclimatology and global data query conversions and calculations are processed in parallel now to reduce runtime

- Improved documentation with spelling fixes, clarification and updates

- Enable `ByteCompile` option upon installation for small increase in speed

- Use `write.csv.raw` from `[iotools]("https://cran.r-project.org/web/packages/iotools/index.html")` to greatly improve runtime by decreasing time used to write CSV files to disk

# GSODR 0.1.8

## Bug Fixes

- Fix bug with connection timing out for single station queries.

- Somehow the previously working function that checked country names broke with the `toupper()` function.
  A new [function from juba](https://stackoverflow.com/questions/16516593/convert-from-lowercase-to-uppercase-all-values-in-all-character-variables-in-dat) fixes this issue and users can now select country again

- User entered values for a single station are now checked against actual station values for validity

- stations.rda is compressed

- stations.rda now includes a field for "corrected" elevation using hole-filled SRTM data from Jarvis et al. 2008

- Set NA or missing values in CSV or shapefile to -9999 from -9999.99 to align with other data sources such as WorldClim

## Minor changes

- Documentation is more complete and easier to use

# GSODR 0.1.7

## Bug Fixes

- Fix issues with MIN/MAX where MIN referred to MAX [(Issue 5)](https://github.com/ropensci/GSODR/issues/5)

- Fix bug where the `tf` item was incorrectly set as `tf <  * "~/tmp/GSOD-2010.tar`, not `tf <  * tempfile`, in `get_GSOD()` [(Issue 6)](https://github.com/ropensci/GSODR/issues/6)

- CITATION file is updated and corrected

## Minor changes

- User now has the ability to generate a shapefile as well as CSV file output [(Issue 3)](https://github.com/ropensci/GSODR/issues/3)

- Documentation is more complete and easier to use

# GSODR 0.1.6

## Bug Fixes

- Fix issue when reading .op files into R where temperature was incorrectly read causing negative values where T \>= 100F, this issue caused RH values of \>100% and incorrect TEMP values [(Issue 1)](https://github.com/ropensci/GSODR/issues/1)

- Spelling corrections

## Major changes

- Include MIN/MAX flag column

- Station data is now included in package rather than downloading from NCDC every time get_GSOD() is run, this data has some corrections where stations with missing LAT/LON values or elevation are omitted, this is **not** the original complete station list provided by NCDC.

# GSODR 0.1.5

## Bug Fixes

- Fixed bug where YDAY not correctly calculated and reported in CSV file

- CSV files for station only queries now are names with the Station Identifier.
  Previously named same as global data

- Likewise, CSV files for agroclimatology now are names with the Station Identifier.
  Previously named same as global data.

## Minor Changes

- Set values where MIN \> MAX to NA

- Set more MIN/MAX/DEWP values to NA.
  GSOD README indicates that 999 indicates missing values in these columns, this does not appear to always be true.
  There are instances where 99 is the value recorded for missing data.
  While 99F is possible, the vast majority of these recorded values are missing data, thus the function now converts them to NA

# GSODR 0.1.4

## Bug Fixes

- Fixed bug related to MIN/MAX columns when agroclimatology or all stations are selected where flags were not removed properly from numeric values.

# GSODR 0.1.3

## Bug fixes

- Bug fix in MIN/MAX with flags.
  Some columns have differing widths, which caused a flag to be left attached to some values

- Correct URL in README.md for CRAN to point to CRAN not GitHub

## Minor Changes

- Set NA to -9999.99

# GSODR 0.1.2

## Bug Fixes

- Bug fix in importing isd-history.csv file.
  Previous issues caused all lat/lon/elev values to be \>0.

- Bug fix where WDSP was mistyped as WDPS causing the creation of a new column, rather than the conversion of the existing

- Bug fix if Agroclimatology selected.
  Previously this resulted in no records.

- Set the default encoding to UTF8.

- Bug fix for country selection.
  Some countries did not return proper ISO code.

- Bug fix where WDSP was mistyped as WDPS causing the creation of a new column, rather than the conversion of the existing

- Use write.csv, not readr::write_csv due to issue converting double to string: <https://github.com/tidyverse/readr/issues/387>

# GSODR 0.1.1

## Major changes

- Now available on CRAN

- Add single quotes around possibly misspelled words and spell out comma-separated values and geographic information system rather than just using "CSV" or "GIS" in DESCRIPTION.

- Add full name of GSOD (Global Surface Summary of the Day) and URL for GSOD, <https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00516> to DESCRIPTION as requested by CRAN.

- Require user to specify directory for resulting .csv file output so that any files written to disk are interactive and with user's permission

# GSODR 0.1

- Initial submission to CRAN
