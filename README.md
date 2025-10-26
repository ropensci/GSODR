---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# {GSODR}: Global Surface Summary of the Day (GSOD) Weather Data Client<br /> <img src="man/figures/logo.png" style="float:right;" alt="logo" width="120" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/ropensci/GSODR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ropensci/GSODR/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ropensci/GSODR/graph/badge.svg?token=7KOFeomenq)](https://app.codecov.io/gh/ropensci/GSODR)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.439850.svg)](https://doi.org/10.5281/zenodo.439850) 
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/GSODR)](https://cran.r-project.org/package=GSODR)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) 
[![JOSS](http://joss.theoj.org/papers/10.21105/joss.00177/status.svg)](https://joss.theoj.org/papers/10.21105/joss.00177) 
[![](https://badges.ropensci.org/79_status.svg)](https://github.com/ropensci/software-review/issues/79)
<!-- badges: end -->

## Introduction

The GSOD or [Global Surface Summary of the Day (GSOD)](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00516) data provided by the US National Centers for Environmental Information (NCEI) are a valuable source of weather data with global coverage.
{GSODR} aims to make it easy to find, transfer and format the data you need for use in analysis and provides six main functions for facilitating this:

- `get_GSOD()` - this function queries and transfers files from the NCEI's web server, reformats them and returns a data frame.

- `reformat_GSOD()` - this function takes individual station files from the local disk and re-formats them returning a data frame.

- `nearest_stations()` - this function returns a `data.table` of stations with their metadata and the distance in which they fall from the given radius (kilometres) of a point given as latitude and longitude in order from nearest to farthest.

- `get_inventory()` - this function downloads the latest station inventory information from the NCEI's server and returns the header information about the latest version as a message in the console and a tidy data frame of the stations' inventory for each month that data are reported.

- `get_history()` - this function downloads the latest version of the isd-history.csv file from the NCEI's server and returns a {data.table} of the information for each station that is available. A version of this file is distributed with {GSODR} internally and can be updated with `update_station_list()`.

- `get_updates()` - this function downloads the changelog for the GSOD data from the NCEI's server and reorders it by the most recent changes first.

- `update_station_list()` - this function downloads the latest station list from the NCEI's server updates the package's internal database of stations and their metadata. **Not recommended for normal use.**

When reformatting data either with `get_GSOD()` or `reformat_GSOD()`, all units are converted to International System of Units (SI), _e.g._, inches to millimetres and Fahrenheit to Celsius.
File output is returned as a `data.table` object, summarising each year by station, which also includes vapour pressure and relative humidity elements calculated from existing data in GSOD.
Additional data are calculated by this R package using the original data and included in the final data.
These include vapour pressure (ea and es) and relative humidity calculated using the improved August-Roche-Magnus approximation (Alduchov and Eskridge 1996).

For more information see the description of the data provided by NCEI, <https://www.ncei.noaa.gov/data/global-summary-of-the-day/doc/readme.txt>.

## How to Install

### Stable Version

A stable version of {GSODR} is available from [CRAN](https://cran.r-project.org/package=GSODR).

```r
install.packages("GSODR")
```

### Development Version

A development version is available from from GitHub.
If you wish to install the development version that may have new features or bug fixes before the CRAN version does (but also may not work properly), please install from the [rOpenSci R Universe](https://ropensci.org/r-universe/).
We strive to keep the main branch on GitHub functional and working properly.

```r
install.packages("GSODR", repos = "https://ropensci.r-universe.dev")
```

## Using {GSODR}

The most common work might be getting data for a single location.
Here's an example of fetching data for a station in Toowoomba, Queensland, AU in 2021.


``` r
library(GSODR)
tbar <- get_GSOD(years = 2021, station = "955510-99999")
tbar
#>             STNID              NAME   CTRY
#>            <char>            <char> <char>
#>   1: 955510-99999 TOOWOOMBA AIRPORT     AS
#>   2: 955510-99999 TOOWOOMBA AIRPORT     AS
#>   3: 955510-99999 TOOWOOMBA AIRPORT     AS
#>   4: 955510-99999 TOOWOOMBA AIRPORT     AS
#>   5: 955510-99999 TOOWOOMBA AIRPORT     AS
#>  ---                                      
#> 358: 955510-99999 TOOWOOMBA AIRPORT     AS
#> 359: 955510-99999 TOOWOOMBA AIRPORT     AS
#> 360: 955510-99999 TOOWOOMBA AIRPORT     AS
#> 361: 955510-99999 TOOWOOMBA AIRPORT     AS
#> 362: 955510-99999 TOOWOOMBA AIRPORT     AS
#>        COUNTRY_NAME  ISO2C  ISO3C  STATE
#>              <char> <char> <char> <char>
#>   1: AMERICAN SAMOA     AS    ASM       
#>   2: AMERICAN SAMOA     AS    ASM       
#>   3: AMERICAN SAMOA     AS    ASM       
#>   4: AMERICAN SAMOA     AS    ASM       
#>   5: AMERICAN SAMOA     AS    ASM       
#>  ---                                    
#> 358: AMERICAN SAMOA     AS    ASM       
#> 359: AMERICAN SAMOA     AS    ASM       
#> 360: AMERICAN SAMOA     AS    ASM       
#> 361: AMERICAN SAMOA     AS    ASM       
#> 362: AMERICAN SAMOA     AS    ASM       
#>      LATITUDE LONGITUDE ELEVATION    BEGIN
#>         <num>     <num>     <num>    <int>
#>   1:   -27.55   151.917       642 19980301
#>   2:   -27.55   151.917       642 19980301
#>   3:   -27.55   151.917       642 19980301
#>   4:   -27.55   151.917       642 19980301
#>   5:   -27.55   151.917       642 19980301
#>  ---                                      
#> 358:   -27.55   151.917       642 19980301
#> 359:   -27.55   151.917       642 19980301
#> 360:   -27.55   151.917       642 19980301
#> 361:   -27.55   151.917       642 19980301
#> 362:   -27.55   151.917       642 19980301
#>           END   YEARMODA  YEAR MONTH   DAY
#>         <int>     <Date> <int> <int> <int>
#>   1: 20250727 2021-01-01  2021     1     1
#>   2: 20250727 2021-01-02  2021     1     2
#>   3: 20250727 2021-01-03  2021     1     3
#>   4: 20250727 2021-01-04  2021     1     4
#>   5: 20250727 2021-01-05  2021     1     5
#>  ---                                      
#> 358: 20250727 2021-12-27  2021    12    27
#> 359: 20250727 2021-12-28  2021    12    28
#> 360: 20250727 2021-12-29  2021    12    29
#> 361: 20250727 2021-12-30  2021    12    30
#> 362: 20250727 2021-12-31  2021    12    31
#>       YDAY  TEMP TEMP_ATTRIBUTES  DEWP
#>      <int> <num>           <int> <num>
#>   1:     1  20.9              16  18.1
#>   2:     2  21.2              16  17.8
#>   3:     3  21.0              16  19.2
#>   4:     4  22.2              16  19.4
#>   5:     5  23.6              16  19.8
#>  ---                                  
#> 358:   361  20.5              24  16.2
#> 359:   362  16.7              24  13.1
#> 360:   363  18.1              24  13.7
#> 361:   364  18.4              24  13.5
#> 362:   365  18.4              24  17.0
#>      DEWP_ATTRIBUTES    SLP SLP_ATTRIBUTES
#>                <int>  <num>          <int>
#>   1:              15 1011.5             16
#>   2:              16 1009.1             16
#>   3:              16 1008.3             16
#>   4:              15 1008.6             16
#>   5:              16 1009.3             16
#>  ---                                      
#> 358:              24 1009.3             24
#> 359:              24 1012.0             24
#> 360:              24 1012.4             24
#> 361:              24 1012.6             24
#> 362:              21 1010.9             24
#>        STP STP_ATTRIBUTES VISIB
#>      <num>          <int> <num>
#>   1: 940.5             16    NA
#>   2: 938.2             16    NA
#>   3: 937.4             16    NA
#>   4: 937.7             16    NA
#>   5: 938.4             16    NA
#>  ---                           
#> 358: 938.1             24    NA
#> 359: 940.7             24    NA
#> 360: 941.0             24    NA
#> 361: 941.2             24    NA
#> 362: 939.7             24    NA
#>      VISIB_ATTRIBUTES  WDSP WDSP_ATTRIBUTES
#>                 <int> <num>           <int>
#>   1:                0   8.0              16
#>   2:                0   6.2              16
#>   3:                0   4.9              16
#>   4:                0   3.9              16
#>   5:                0   3.4              16
#>  ---                                       
#> 358:                0   7.0              24
#> 359:                0   8.2              24
#> 360:                0   8.7              24
#> 361:                0   8.4              24
#> 362:                0   9.2              24
#>      MXSPD  GUST   MAX MAX_ATTRIBUTES   MIN
#>      <num> <num> <num>         <char> <num>
#>   1:   9.8    NA  25.6              *  16.7
#>   2:   9.3    NA  25.7              *  17.6
#>   3:   8.2    NA  25.5              *  17.7
#>   4:   5.7    NA  25.0              *  18.8
#>   5:   7.7    NA  28.1              *  19.0
#>  ---                                       
#> 358:   9.8    NA  27.2              *  17.0
#> 359:  10.8    NA  20.2              *  13.5
#> 360:  10.8    NA  24.0              *  13.4
#> 361:  11.8    NA  24.5              *  13.9
#> 362:  12.3    NA  22.2              *  14.8
#>      MIN_ATTRIBUTES  PRCP PRCP_ATTRIBUTES
#>              <char> <num>          <char>
#>   1:           <NA>  2.03               G
#>   2:           <NA>  0.25               G
#>   3:           <NA> 19.05               G
#>   4:           <NA>  0.25               G
#>   5:           <NA>  0.51               G
#>  ---                                     
#> 358:              *  0.00               I
#> 359:              *  0.00               I
#> 360:           <NA>  0.00               I
#> 361:           <NA>  0.25               G
#> 362:           <NA>  7.11               G
#>       SNDP I_FOG I_RAIN_DRIZZLE I_SNOW_ICE
#>      <num> <num>          <num>      <num>
#>   1:    NA     1              1          0
#>   2:    NA     0              0          0
#>   3:    NA     1              1          0
#>   4:    NA     0              0          0
#>   5:    NA     0              0          0
#>  ---                                      
#> 358:    NA     0              0          0
#> 359:    NA     0              0          0
#> 360:    NA     0              0          0
#> 361:    NA     0              1          0
#> 362:    NA     0              1          0
#>      I_HAIL I_THUNDER I_TORNADO_FUNNEL    EA
#>       <num>     <num>            <num> <num>
#>   1:      0         0                0   2.1
#>   2:      0         0                0   2.0
#>   3:      0         0                0   2.2
#>   4:      0         0                0   2.2
#>   5:      0         0                0   2.3
#>  ---                                        
#> 358:      0         0                0   1.8
#> 359:      0         0                0   1.5
#> 360:      0         0                0   1.6
#> 361:      0         0                0   1.5
#> 362:      0         0                0   1.9
#>         ES    RH
#>      <num> <num>
#>   1:   2.5  84.0
#>   2:   2.5  81.0
#>   3:   2.5  89.5
#>   4:   2.7  84.2
#>   5:   2.9  79.3
#>  ---            
#> 358:   2.4  76.4
#> 359:   1.9  79.3
#> 360:   2.1  75.5
#> 361:   2.1  73.1
#> 362:   2.1  91.6
```

## Other Sources of Weather Data in R

There are several other sources of weather data and ways of retrieving them through R.
Several are also [rOpenSci](https://ropensci.org) projects.

[{GSODTools}](https://github.com/environmentalinformatics-marburg/GSODTools) by [Florian Detsch](https://github.com/fdetsch) is an R package that offers similar functionality as {GSODR}, but also has the ability to graph the data and working with data for time series analysis.

[{nasapower}](https://CRAN.R-project.org/package=nasapower) from [rOpenSci](https://docs.ropensci.org/nasapower/) aims to make it quick and easy to automate downloading of the NASA-POWER global meteorology, surface solar energy and climatology data in your R session as a tidy `tibble` object for analysis and use in modelling or other purposes.
POWER (Prediction Of Worldwide Energy Resource) data are freely available for download with varying spatial resolutions dependent on the original data and with several temporal resolutions depending on the POWER parameter and community.

[{riem}](https://CRAN.R-project.org/package=riem) from [rOpenSci](https://docs.ropensci.org/riem/) allows to get weather data from Automated Surface Observing System (ASOS) stations (airports) in the whole world thanks to the Iowa Environment Mesonet website.

[{rnoaa}](https://CRAN.R-project.org/package=rnoaa), from [rOpenSci](https://docs.ropensci.org/rnoaa/) offers tools for interacting with and downloading weather data from the United States National Oceanic and Atmospheric Administration but lacks support for GSOD data.

[{stationaRy}](https://cran.r-project.org/package=stationaRy), from Richard Iannone offers hourly meteorological data from stations located all over the world.
There is a wealth of data available, with historic weather data accessible from nearly 30,000 stations.

[{weathercan}](https://CRAN.R-project.org/package=weathercan) from [rOpenSci](https://github.com/ropensci/weathercan) makes it easier to search for and download multiple months/years of historical weather data from Environment and Climate Change Canada (ECCC) website.

[{weatherOz}](https://CRAN.R-project.org/package=weatherOz) aims to facilitate access and download weather and climate data for Australia from Australian data sources.
Data are sourced from from the Western Australian Department of Primary Industries and Regional Development (DPIRD) and the Scientific Information for Land Owners (SILO) API endpoints and the Australian Government Bureau of Meteorology’s (BOM) FTP server.

[{worldmet}](https://CRAN.R-project.org/package=worldmet) provides an easy way to access data from the NOAA Integrated Surface Database (ISD) (the same database {GSODR} provides access to.
The ISD contains detailed surface meteorological data from around the world for over 35,000 locations.
However, rather than daily values, the package outputs (typically hourly meteorological data) and works very well with the [{openair}](https://CRAN.R-project.org/package=openair) package.

## Notes

### Citing GSOD data

> Cite as: NOAA National Centers of Environmental Information. 1999. Global Surface Summary of the Day - GSOD. 1.0. [indicate subset used]. NOAA National Centers for Environmental Information. Accessed [date].

### NOAA policy

Users of these data should take into account the following:

> The data summaries provided here are based on data exchanged under the World Meteorological Organization (WMO) World Weather Watch Program according to WMO Resolution 40 (Cg-XII). This allows WMO member countries to place restrictions on the use or re-export of their data for commercial purposes outside of the receiving country.
Data for selected countries may, at times, not be available through this system.
Those countries' data summaries and products which are available here are intended for free and unrestricted use in research, education, and other non-commercial activities.
However, for non-U.S. locations' data, the data or any derived product shall not be provided to other users or be used for the re-export of commercial services.

## Meta

- Please [report any issues or bugs](https://github.com/ropensci/GSODR/issues).

- License: MIT

- To cite {GSODR}, please use: Adam H. Sparks, Tomislav Hengl and Andrew Nelson (2017). GSODR: Global Summary Daily Weather Data in R. _The Journal of Open Source Software_, **2(10)**. DOI: 10.21105/joss.00177.

## Code of Conduct
  
Please note that this package is released with a [Contributor Code of Conduct](https://ropensci.org/code-of-conduct/). 
By contributing to this project, you agree to abide by its terms.

## References

Alduchov, O.A. and Eskridge, R.E., 1996. Improved Magnus form approximation of saturation vapor pressure. Journal of Applied Meteorology and Climatology, 35(4), pp. 601-609 DOI: 10.1175/1520-0450(1996)035<0601:IMFAOS>2.0.CO;2.
