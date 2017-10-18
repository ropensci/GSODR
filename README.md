GSODR
================

[![Travis-CI Build Status](https://travis-ci.org/ropensci/GSODR.svg?branch=master)](https://travis-ci.org/ropensci/GSODR) [![Build status](https://ci.appveyor.com/api/projects/status/s09kh2nj59o35ob1/branch/master?svg=true)](https://ci.appveyor.com/project/ropensci/gsodr/branch/master) [![codecov](https://codecov.io/gh/ropensci/GSODR/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/GSODR) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.439850.svg)](https://doi.org/10.5281/zenodo.439850) [![JOSS](http://joss.theoj.org/papers/10.21105/joss.00177/status.svg)](http://joss.theoj.org/papers/14021f4e4931cdaab4ea41be27df2df6) [![](https://badges.ropensci.org/79_status.svg)](https://github.com/ropensci/onboarding/issues/79)

*GSODR*: Global Summary Daily Weather Data in R
===============================================

Introduction to *GSODR*
-----------------------

The GSOD or [Global Surface Summary of the Day (GSOD)](https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod) data provided by the US National Centers for Environmental Information (NCEI) are a valuable source of weather data with global coverage. However, the data files are cumbersome and difficult to work with. *GSODR* aims to make it easy to find, transfer and format the data you need for use in analysis and provides four main functions for facilitating this:

-   `get_GSOD()`, queries and transfers files from the FTP server, reformats them and returns a `tibble()` object in R session and/or saves a file to disk with options for a GeoPackage spatially enabled file or comma \`separated values (CSV) file,

-   `reformat_GSOD()`, the workhorse, takes individual station files on the local disk and reformats them, returns a `data.frame()` object in R session or saves a file to disk with options for a GeoPackage spatially enabled file or comma separated values (CSV) file,

-   `nearest_stations()`, returns a `vector()` object containing a list of stations and their metadata that fall within the given radius of a point specified by the user,

-   `update_station_list()`, downloads the latest station list from the NCEI FTP server updates the package's internal database of stations and their metadata.

When reformatting data either with `get_GSOD()` or `reformat_GSOD()`, all units are converted to International System of Units (SI), e.g., inches to millimetres and Fahrenheit to Celsius. File output can be saved as a Comma Separated Value (CSV) file or in a spatial GeoPackage (GPKG) file, implemented by most major GIS software, summarising each year by station, which also includes vapour pressure and relative humidity elements calculated from existing data in GSOD.

Additional data are calculated by this R package using the original data and included in the final data. These include vapour pressure (ea and es) and relative humidity.

It is recommended that you have a good Internet connection to download the data files as they can be quite large and slow to download.

For more information see the description of the data provided by NCEI, <http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt>.

Quick Start Install
-------------------

### Stable version

A stable version of *GSODR* is available from [CRAN](https://cran.r-project.org/package=GSODR).

``` r
install.packages("GSODR")
```

### Development version

A development version is available from from GitHub. If you wish to install the development version that may have new features (but also may not work properly), install the [devtools package](https://CRAN.R-project.org/package=devtools), available from CRAN. We strive to keep the master branch on GitHub functional and working properly.

``` r
#install.packages("devtools")
devtools::install_github("ropensci/GSODR", build_vignettes = TRUE)
```

------------------------------------------------------------------------

Using *GSODR*
-------------

### Query the NCEI FTP server for GSOD data

*GSODR's* main function, `get_GSOD()`, downloads and cleans GSOD data from the NCEI server. Following are a few examples of its capabilities.

#### Example - Download weather station data for Toowoomba, Queensland for 2010

``` r
library(GSODR)
```

    ## 
    ## GSOD is distributed free by the US NCEI with the
    ## following conditions.
    ## 'The following data and products may have conditions placed
    ## their international commercial use. They can be used within
    ## the U.S. or for non-commercial international activities
    ## without restriction. The non-U.S. data cannot be
    ## redistributed for commercial purposes. Re-distribution of
    ## these data by others must provide this same notification.
    ## WMO Resolution 40. NOAA Policy'

``` r
Tbar <- get_GSOD(years = 2010, station = "955510-99999")
```

    ## 
    ## Checking requested station file for availability on server

    ## 
    ## Downloading individual station files.

``` r
Tbar
```

    ## # A tibble: 365 x 48
    ##      USAF  WBAN        STNID          STN_NAME  CTRY STATE  CALL    LAT
    ##     <chr> <chr>        <chr>             <chr> <chr> <chr> <chr>  <dbl>
    ##  1 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ##  2 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ##  3 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ##  4 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ##  5 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ##  6 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ##  7 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ##  8 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ##  9 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ## 10 955510 99999 955510-99999 TOOWOOMBA AIRPORT    AS  <NA>  <NA> -27.55
    ## # ... with 355 more rows, and 40 more variables: LON <dbl>, ELEV_M <dbl>,
    ## #   ELEV_M_SRTM_90m <dbl>, BEGIN <dbl>, END <dbl>, YEARMODA <chr>,
    ## #   YEAR <chr>, MONTH <chr>, DAY <chr>, YDAY <dbl>, TEMP <dbl>,
    ## #   TEMP_CNT <int>, DEWP <dbl>, DEWP_CNT <int>, SLP <dbl>, SLP_CNT <int>,
    ## #   STP <dbl>, STP_CNT <int>, VISIB <dbl>, VISIB_CNT <int>, WDSP <dbl>,
    ## #   WDSP_CNT <int>, MXSPD <dbl>, GUST <dbl>, MAX <dbl>, MAX_FLAG <chr>,
    ## #   MIN <dbl>, MIN_FLAG <chr>, PRCP <dbl>, PRCP_FLAG <chr>, SNDP <dbl>,
    ## #   I_FOG <int>, I_RAIN_DRIZZLE <int>, I_SNOW_ICE <int>, I_HAIL <int>,
    ## #   I_THUNDER <int>, I_TORNADO_FUNNEL <int>, EA <dbl>, ES <dbl>, RH <dbl>

Other Sources of Weather Data in R
----------------------------------

There are several other sources of weather data and ways of retrieving them through R. In particular, the excellent [`rnoaa`](https://CRAN.R-project.org/package=rnoaa) package also from [rOpenSci](https://ropensci.org) offers tools for interacting with and downloading weather data from the United States National Oceanic and Atmospheric Administration but lacks support GSOD data.

Other Sources for Fetching GSOD Weather Data
--------------------------------------------

The [*GSODTools*](https://github.com/environmentalinformatics-marburg/GSODTools) by [Florian Detsch](https://github.com/fdetsch) is an R package that offers similar functionality as *GSODR*, but also has the ability to graph the data and working with data for time series analysis.

The [*ULMO*](https://github.com/ulmo-dev/ulmo) library offers an interface to retrieve GSOD data using Python.

Notes
-----

### Other Data Sources

#### Elevation Values

90m hole-filled SRTM digital elevation (Jarvis *et al.* 2008) was used to identify and correct/remove elevation errors in data for station locations between -60˚ and 60˚ latitude. This applies to cases here where elevation was missing in the reported values as well. In case the station reported an elevation and the DEM does not, the station reported is taken. For stations beyond -60˚ and 60˚ latitude, the values are station reported values in every instance. See <https://github.com/ropensci/GSODR/blob/master/data-raw/fetch_isd-history.md> for more detail on the correction methods.

#### WMO Resolution 40. NOAA Policy

*Users of these data should take into account the following (from the [NCEI website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):*

> "The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification." [WMO Resolution 40. NOAA Policy](https://public.wmo.int/en/our-mandate/what-we-do/data-exchange-and-technology-transfer)

Meta
----

-   Please [report any issues or bugs](https://github.com/ropensci/GSODR/issues).

-   License: MIT

-   To cite *GSODR*, please use: &gt; Adam H Sparks, Tomislav Hengl and Andrew Nelson (2017). GSODR: Global Summary Daily Weather Data in R. *The Journal of Open Source Software*, **2(10)**. DOI: 10.21105/joss.00177.

-   Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

References
----------

Jarvis, A., Reuter, H. I., Nelson, A., Guevara, E. (2008) Hole-filled SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m Database (<http://srtm.csi.cgiar.org>)

[![ropensci](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
