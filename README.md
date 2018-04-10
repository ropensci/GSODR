GSODR: Global Surface Summary of the Day (GSOD) Weather Data from R
================

[![Travis-CI Build
Status](https://travis-ci.org/ropensci/GSODR.svg?branch=master)](https://travis-ci.org/ropensci/GSODR)
[![Build
status](https://ci.appveyor.com/api/projects/status/s09kh2nj59o35ob1/branch/master?svg=true)](https://ci.appveyor.com/project/ropensci/gsodr/branch/master)
[![codecov](https://codecov.io/gh/ropensci/GSODR/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/GSODR)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.439850.svg)](https://doi.org/10.5281/zenodo.439850)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/GSODR)](https://cran.r-project.org/package=GSODR)
[![JOSS](http://joss.theoj.org/papers/10.21105/joss.00177/status.svg)](http://joss.theoj.org/papers/14021f4e4931cdaab4ea41be27df2df6)
[![](https://badges.ropensci.org/79_status.svg)](https://github.com/ropensci/onboarding/issues/79)

## Introduction to *GSODR*

The GSOD or [Global Surface Summary of the Day
(GSOD)](https://data.noaa.gov/dataset/dataset/global-surface-summary-of-the-day-gsod)
data provided by the US National Centers for Environmental Information
(NCEI) are a valuable source of weather data with global coverage.
However, the data files are cumbersome and difficult to work with.
*GSODR* aims to make it easy to find, transfer and format the data you
need for use in analysis and provides five main functions for
facilitating this:

  - `get_GSOD()` - this function queries and transfers files from the
    NCEI’s FTP server, reformats them and returns a tidy data frame in
    R. **NOTE** If you have used file exporting capabilities in versions
    prior to 1.2.0, these have been removed now in the latest version.
    This means less dependencies when installing. Examples of how to
    export the data are found in the GSODR vignette.

  - `reformat_GSOD()` - this function takes individual station files
    from the local disk and re-formats them returning a tidy data frame
    in R

  - `nearest_stations()` - this function returns a vector of station IDs
    that fall within the given radius (kilometres) of a point given as
    latitude and longitude

  - `update_station_list()` - this function downloads the latest station
    list from the NCEI’s FTP server updates the package’s internal
    database of stations and their metadata.

  - `get_inventory()` - this function downloads the latest station
    inventory information from the NCEI’s FTP server and returns the
    header information about the latest version as a message in the
    console and a tidy data frame of the stations’ inventory for each
    month that data are reported.

When reformatting data either with `get_GSOD()` or `reformat_GSOD()`,
all units are converted to International System of Units (SI), *e.g.*,
inches to millimetres and Fahrenheit to Celsius. File output is returned
as a `tibble()`, summarising each year by station, which also includes
vapour pressure and relative humidity elements calculated from existing
data in GSOD. Additional data are calculated by this R package using the
original data and included in the final data. These include vapour
pressure (ea and es) and relative humidity.

It is recommended that you have a good Internet connection to download
the data files as they can be quite large and slow to download.

For more information see the description of the data provided by NCEI,
<http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt>.

## Quick Start Install

### Stable Version

A stable version of *GSODR* is available from
[CRAN](https://cran.r-project.org/package=GSODR).

``` r
install.packages("GSODR")
```

### Development Version

A development version is available from from GitHub. If you wish to
install the development version that may have new features or bug fixes
before the CRAN version does (but also may not work properly), please
install the [devtools
package](https://CRAN.R-project.org/package=devtools), available from
CRAN. We strive to keep the master branch on GitHub functional and
working properly.

``` r
#install.packages("devtools")
devtools::install_github("ropensci/GSODR", build_vignettes = TRUE)
```

-----

## Using *GSODR*

*GSODR’s* main function, `get_GSOD()`, downloads and cleans GSOD data
from the NCEI server. Following is an example of its capabilities, for
more detailed examples of its capabilities, please see the [*GSODR*
introduction
vignette](https://ropensci.github.io/GSODR/articles/GSODR.html).

### Example - Download weather station data for Toowoomba, Queensland for 2010

``` r
library(GSODR)
```

    ## 
    ## GSOD is distributed free by the U.S. NCEI with the
    ## following conditions.
    ## 'The following data and products may have conditions placed
    ## their international commercial use. They can be used within
    ## the U.S. or for non-commercial international activities
    ## without restriction. The non-U.S. data cannot be
    ## redistributed for commercial purposes. Re-distribution of
    ## these data by others must provide this same notification.
    ## WMO Resolution 40. NOAA Policy'
    ## 
    ## GSODR does not redistribute any weather data itself. It 
    ## only provides an interface for R users to download these
    ## data, however it does redistribute station metadata in the
    ## package.

``` r
tbar <- get_GSOD(years = 2010, station = "955510-99999")

tbar
```

    ## # A tibble: 365 x 48
    ##    USAF   WBAN  STNID    STN_NAME     CTRY  STATE CALL    LAT   LON ELEV_M
    ##    <chr>  <chr> <chr>    <chr>        <chr> <chr> <chr> <dbl> <dbl>  <dbl>
    ##  1 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ##  2 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ##  3 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ##  4 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ##  5 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ##  6 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ##  7 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ##  8 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ##  9 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ## 10 955510 99999 955510-… TOOWOOMBA A… AS    <NA>  <NA>  -27.6  152.   642.
    ## # ... with 355 more rows, and 38 more variables: ELEV_M_SRTM_90m <dbl>,
    ## #   BEGIN <dbl>, END <dbl>, YEARMODA <date>, YEAR <chr>, MONTH <chr>,
    ## #   DAY <chr>, YDAY <dbl>, TEMP <dbl>, TEMP_CNT <int>, DEWP <dbl>,
    ## #   DEWP_CNT <int>, SLP <dbl>, SLP_CNT <int>, STP <dbl>, STP_CNT <int>,
    ## #   VISIB <dbl>, VISIB_CNT <int>, WDSP <dbl>, WDSP_CNT <int>, MXSPD <dbl>,
    ## #   GUST <dbl>, MAX <dbl>, MAX_FLAG <chr>, MIN <dbl>, MIN_FLAG <chr>,
    ## #   PRCP <dbl>, PRCP_FLAG <chr>, SNDP <dbl>, I_FOG <int>,
    ## #   I_RAIN_DRIZZLE <int>, I_SNOW_ICE <int>, I_HAIL <int>, I_THUNDER <int>,
    ## #   I_TORNADO_FUNNEL <int>, EA <dbl>, ES <dbl>, RH <dbl>

## Other Sources of Weather Data in R

There are several other sources of weather data and ways of retrieving
them through R. Several are also [rOpenSci](https://ropensci.org)
projects.

[*rnoaa*](https://CRAN.R-project.org/package=rnoaa), from
[rOpenSci](https://ropensci.org) offers tools for interacting with and
downloading weather data from the United States National Oceanic and
Atmospheric Administration but lacks support for GSOD data.

[*bomrang*](https://CRAN.R-project.org/package=bomrang), from
[rOpenSci](https://ropensci.org) provides functions to interface with
Australia Government Bureau of Meteorology (BoM) data, fetching data and
returning a tidy data frame of précis forecasts, current weather data
from stations, agriculture bulletin data, BoM 0900 or 1500 weather
bulletins or a raster stack object of satellite imagery from GeoTIFF
files. Data (c) Australian Government Bureau of Meteorology Creative
Commons (CC) Attribution 3.0 licence or Public Access Licence (PAL) as
appropriate. See <http://www.bom.gov.au/other/copyright.shtml> for
further details.

[*riem*](https://CRAN.R-project.org/package=riem) from
[rOpenSci](https://ropensci.org) allows to get weather data from
Automated Surface Observing System (ASOS) stations (airports) in the
whole world thanks to the Iowa Environment Mesonet website.

[*CliFlo*](https://CRAN.R-project.org/package=clifro) from
[rOpenSci](https://ropensci.org) is a web portal to the New Zealand
National Climate Database and provides public access (via subscription)
to around 6,500 various climate stations (see
<https://cliflo.niwa.co.nz/> for more information). Collating and
manipulating data from CliFlo (hence clifro) and importing into R for
further analysis, exploration and visualisation is now straightforward
and coherent. The user is required to have an internet connection, and a
current CliFlo subscription (free) if data from stations, other than the
public Reefton electronic weather station, is sought.

[*weatherData*](https://CRAN.R-project.org/package=weatherData) provides
a selection of functions to fetch weather data from Weather Underground
and return it as a clean data frame.

## Other Sources for Fetching GSOD Weather Data

The
[*GSODTools*](https://github.com/environmentalinformatics-marburg/GSODTools)
by [Florian Detsch](https://github.com/fdetsch) is an R package that
offers similar functionality as *GSODR*, but also has the ability to
graph the data and working with data for time series analysis.

The [*ULMO*](https://github.com/ulmo-dev/ulmo) library offers an
interface to retrieve GSOD data using Python.

## Notes

### Other Data Sources

#### Elevation Values

90m hole-filled SRTM digital elevation (Jarvis *et al.* 2008) was used
to identify and correct/remove elevation errors in data for station
locations between -60˚ and 60˚ latitude. This applies to cases here
where elevation was missing in the reported values as well. In case the
station reported an elevation and the DEM does not, the station reported
is taken. For stations beyond -60˚ and 60˚ latitude, the values are
station reported values in every instance. See
<https://github.com/ropensci/GSODR/blob/master/data-raw/fetch_isd-history.md>
for more detail on the correction methods.

### WMO Resolution 40. NOAA Policy

*Users of these data should take into account the following (from the
[NCEI
website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):*

> “The following data and products may have conditions placed on their
> international commercial use. They can be used within the U.S. or for
> non-commercial international activities without restriction. The
> non-U.S. data cannot be redistributed for commercial purposes.
> Re-distribution of these data by others must provide this same
> notification.” [WMO Resolution 40. NOAA
> Policy](https://public.wmo.int/en/our-mandate/what-we-do/data-exchange-and-technology-transfer)

## Meta

  - Please [report any issues or
    bugs](https://github.com/ropensci/GSODR/issues).

  - License: MIT

  - To cite *GSODR*, please use: Adam H Sparks, Tomislav Hengl and
    Andrew Nelson (2017). GSODR: Global Summary Daily Weather Data in R.
    *The Journal of Open Source Software*, **2(10)**. DOI:
    10.21105/joss.00177.

  - Please note that this project is released with a [Contributor Code
    of Conduct](CONDUCT.md). By participating in this project you agree
    to abide by its terms.

## References

Jarvis, A., Reuter, H. I., Nelson, A., Guevara, E. (2008) Hole-filled
SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m
Database
(<http://srtm.csi.cgiar.org>)

[![ropensci](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
