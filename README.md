
[![Travis-CI Build
Status](https://travis-ci.org/ropensci/GSODR.svg?branch=master)](https://travis-ci.org/ropensci/GSODR)
[![Build
status](https://ci.appveyor.com/api/projects/status/s09kh2nj59o35ob1/branch/master?svg=true)](https://ci.appveyor.com/project/ropensci/gsodr/branch/master)
[![codecov](https://codecov.io/gh/ropensci/GSODR/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/GSODR)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.439850.svg)](https://doi.org/10.5281/zenodo.439850)
[![JOSS](http://joss.theoj.org/papers/10.21105/joss.00177/status.svg)](http://joss.theoj.org/papers/14021f4e4931cdaab4ea41be27df2df6)
[![](https://badges.ropensci.org/79_status.svg)](https://github.com/ropensci/onboarding/issues/79)

# _GSODR_: Global Summary Daily Weather Data in R

## Introduction to _GSODR_

The GSOD or
[Global Surface Summary of the Day (GSOD)](https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod)
data provided by the US National Centers for Environmental Information
(NCEI) are a valuable source of weather data with global coverage.
However, the data files are cumbersome and difficult to work with.
_GSODR_ aims to make it easy to find, transfer and format the data you
need for use in analysis and provides four main functions for
facilitating this:

- `get_GSOD()`, queries and transfers files from the FTP server,
    reformats them and returns a `data.frame()` object in R session or
    saves a file to disk with options for a GeoPackage spatially enabled
    file or comma `separated values (CSV) file,

- `reformat_GSOD()`, the workhorse, takes individual station files on
    the local disk and reformats them, returns a `data.frame()` object
    in R session or saves a file to disk with options for a GeoPackage
    spatially enabled file or comma separated values (CSV) file,

- `nearest_stations()`, returns a `vector()` object containing a list
    of stations and their metadata that fall within the given radius of
    a point specified by the user,

- `update_station_list()`, downloads the latest station list from the
    NCEI FTP server updates the package's internal database of stations
    and their metadata.

When reformatting data either with `get_GSOD()` or `reformat_GSOD()`,
all units are converted to International System of Units (SI), e.g.,
inches to millimetres and Fahrenheit to Celsius. File output can be
saved as a Comma Separated Value (CSV) file or in a spatial GeoPackage
(GPKG) file, implemented by most major GIS software, summarising each
year by station, which also includes vapour pressure and relative
humidity elements calculated from existing data in GSOD.

Additional data are calculated by this R package using the original data and
included in the final data. These include vapour pressure (ea and es) and
relative humidity.

It is recommended that you have a good Internet connection to download the data
files as they can be quite large and slow to download.

For more information see the description of the data provided by NCEI,
<http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt>.

## Quick Start Install

### Stable version

A stable version of _GSODR_ is available from
[CRAN](https://cran.r-project.org/package=GSODR).

```r
install.packages("GSODR")
```

### Development version

A development version is available from from GitHub. If you wish to
install the development version that may have new features (but also may
not work properly), install the
[devtools package](https://CRAN.R-project.org/package=devtools),
available from CRAN. We strive to keep the master branch on GitHub functional
and working properly.

```r
#install.packages("devtools")
devtools::install_github("ropensci/GSODR", build_vignettes = TRUE)
```

------------------------------------------------------------------------

## Using _GSODR_

### Query the NCEI FTP server for GSOD data

_GSODR's_ main function, `get_GSOD()`, downloads and cleans GSOD data
from the NCEI server. Following are a few examples of its capabilities.

#### Example - Download weather station data for Toowoomba, Queensland for 2010

```r
library(GSODR)

Tbar <- get_GSOD(years = 2010, station = "955510-99999")
#>
#> Checking requested station file for availability on server.
#> Starting data file processing

head(Tbar)
#>    WBAN        STNID          STN_NAME CTRY STATE CALL    LAT     LON
#> 1 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 2 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 3 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 4 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 5 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 6 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#>   ELEV_M ELEV_M_SRTM_90m    BEGIN      END YEARMODA YEAR MONTH DAY YDAY
#> 1    642             635 19980301 20161122 20100101 2010    01  01    1
#> 2    642             635 19980301 20161122 20100102 2010    01  02    2
#> 3    642             635 19980301 20161122 20100103 2010    01  03    3
#> 4    642             635 19980301 20161122 20100104 2010    01  04    4
#> 5    642             635 19980301 20161122 20100105 2010    01  05    5
#> 6    642             635 19980301 20161122 20100106 2010    01  06    6
#>   TEMP TEMP_CNT DEWP DEWP_CNT    SLP SLP_CNT   STP STP_CNT VISIB VISIB_CNT
#> 1 21.2        8 17.9        8 1013.4       8 942.0       8    NA         0
#> 2 23.2        8 19.4        8 1010.5       8 939.3       8    NA         0
#> 3 21.4        8 18.9        8 1012.3       8 940.9       8  14.3         6
#> 4 18.9        8 16.4        8 1015.7       8 944.1       8  23.3         4
#> 5 20.5        8 16.4        8 1015.5       8 944.0       8    NA         0
#> 6 21.9        8 18.7        8 1013.7       8 942.3       8    NA         0
#>   WDSP WDSP_CNT MXSPD GUST   MAX MAX_FLAG   MIN MIN_FLAG PRCP PRCP_FLAG
#> 1  2.2        8   6.7   NA 25.78          17.78           1.5         G
#> 2  1.9        8   5.1   NA 26.50          19.11           0.3         G
#> 3  3.9        8  10.3   NA 28.72          19.28        * 19.8         G
#> 4  4.5        8  10.3   NA 24.11          16.89        *  1.0         G
#> 5  3.9        8  10.8   NA 24.61          16.72           0.3         G
#> 6  3.2        8   7.7   NA 26.78          17.50           0.0         G
#>   SNDP I_FOG I_RAIN_DRIZZLE I_SNOW_ICE I_HAIL I_THUNDER I_TORNADO_FUNNEL
#> 1   NA     0              0          0      0         0                0
#> 2   NA     0              0          0      0         0                0
#> 3   NA     1              1          0      0         0                0
#> 4   NA     0              0          0      0         0                0
#> 5   NA     0              0          0      0         0                0
#> 6   NA     1              0          0      0         0                0
#>    EA  ES   RH
#> 1 2.1 2.5 84.0
#> 2 2.3 2.8 82.1
#> 3 2.2 2.5 88.0
#> 4 1.9 2.2 86.4
#> 5 1.9 2.4 79.2
#> 6 2.2 2.6 84.6
```

## Other Sources of Weather Data in R

There are several other sources of weather data and ways of retrieving
them through R. In particular, the excellent
[`rnoaa`](https://CRAN.R-project.org/package=rnoaa) package also from
[rOpenSci](https://ropensci.org) offers tools for interacting with and
downloading weather data from the United States National Oceanic and
Atmospheric Administration but lacks support GSOD data.

## Other Sources for Fetching GSOD Weather Data

The
[_GSODTools_](https://github.com/environmentalinformatics-marburg/GSODTools)
by [Florian Detsch](https://github.com/fdetsch) is an R package that
offers similar functionality as _GSODR_, but also has the ability to
graph the data and working with data for time series analysis.

The [_ULMO_](https://github.com/ulmo-dev/ulmo) library offers an
interface to retrieve GSOD data using Python.

## Notes

### Data Sources

#### CHELSA climate layers

CHELSA (climatic surfaces at 1 km resolution) is based on a
quasi-mechanistical statistical downscaling of the ERA interim global
circulation model (Karger et al. 2016). ESA's CCI-LC cloud probability
monthly averages are based on the MODIS snow products (MOD10A2).
<http://chelsa-climate.org/>

#### Elevation Values

90m hole-filled SRTM digital elevation (Jarvis _et al._ 2008) was used
to identify and correct/remove elevation errors in data for station
locations between -60˚ and 60˚ latitude. This applies to cases here
where elevation was missing in the reported values as well. In case the
station reported an elevation and the DEM does not, the station reported
is taken. For stations beyond -60˚ and 60˚ latitude, the values are
station reported values in every instance. See
<https://github.com/ropensci/GSODR/blob/master/data-raw/fetch_isd-history.md>
for more detail on the correction methods.

#### WMO Resolution 40. NOAA Policy

_Users of these data should take into account the following (from the [NCEI website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):_

> "The following data and products may have conditions placed on their
> international commercial use. They can be used within the U.S. or for
> non-commercial international activities without restriction. The
> non-U.S. data cannot be redistributed for commercial purposes.
> Re-distribution of these data by others must provide this same
> notification."
> [WMO Resolution 40. NOAA Policy](https://public.wmo.int/en/our-mandate/what-we-do/data-exchange-and-technology-transfer)

## Meta

- Please [report any issues or bugs](https://github.com/ropensci/GSODR/issues).

- License: MIT

- To cite _GSODR_, please use:
  Adam H Sparks, Tomislav Hengl and Andrew Nelson (2017). GSODR:
  Global Summary Daily Weather Data in R. _The Journal of Open Source
  Software_, **2(10)**. DOI: 10.21105/joss.00177. URL:
  <https://doi.org/10.21105%2Fjoss.00177>

- Please note that this project is released with a
  [Contributor Code of Conduct](CONDUCT.md). By participating in this project
  you agree to abide by its terms.

## References

Jarvis, A., Reuter, H. I., Nelson, A., Guevara, E. (2008) Hole-filled
SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m
Database (<http://srtm.csi.cgiar.org>)

Karger, D. N., Conrad, O., Bohner, J., Kawohl, T., Kreft, H.,
Soria-Auza, R. W., _et al_. (2016) Climatologies at high resolution for
the Earth land surface areas. _arXiv preprint_ **arXiv:1607.00217**.
(<http://chelsa-climate.org/>)

[![ropensci](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
