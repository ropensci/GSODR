#GSODR

[![Travis-CI Build Status](https://travis-ci.org/adamhsparks/GSODR.svg?branch=master)](https://travis-ci.org/adamhsparks/GSODR)
[![Build status](https://ci.appveyor.com/api/projects/status/8daqtllo2sg6me07/branch/master)](https://ci.appveyor.com/project/adamhsparks/GSODR/branch/master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/GSODR?color=brightgreen)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/GSODR)](https://cran.r-project.org/package=GSODR)

An R package that provides a function that automates downloading and cleaning data from the "[Global Surface Summary of the Day (GSOD)](https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod)" data provided by the US National Climatic Data Center (NCDC). Stations are individually checked for number of missing days to assure data quality, stations with too many missing observations are omitted. All units are converted to metric, e.g. feet to metres and Fahrenheit to Celcius. Output is saved as a .csv file summarizing each year by station, which includes vapor pressure and relative humidity variables calculated from existing data in GSOD.

This package is largely based on Tomislav Hengl's work in "[A Practical Guide to Geostatistical Mapping](http://spatial-analyst.net/book/getGSOD.R)", with updates for speed, cross-platform functionality and some added functionality.

Be sure to have disk space free and allocate the proper time for this to run. This is a time, processor and disk space intensive process.

For more information see the description of the data provided by NCDC, http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt.

## To install this package
### Stable release from CRAN
GSODR is available on CRAN.

`install.packages("GSODR", dep = TRUE)`

### The development version from GitHub
Install the devtools package, available from CRAN.

`install.packages("devtools")`

Load the devtools package.

`library(devtools)`

Use `install_github("author/package")` to install this package.

`install_github("adamhsparks/GSODR")`

##Using get_GSOD()
See `?get_GSOD()` for the help file.

Example from help file, to download data for years 2009 and 2010 and generate yearly summary files, GSOD_2009.csv and GSOD_2010.csv files in your Downloads directory with a maximum of five missing days per weather station allowed.

`get_GSOD(years = 2009:2010, max_missing = 5, path = "~/Downloads")`
