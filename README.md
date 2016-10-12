
<!-- README.md is generated from README.Rmd. Please edit that file -->
GSODR: Global Surface Summary Daily Weather Data in R
=====================================================

[![Travis-CI Build
Status](https://travis-ci.org/adamhsparks/GSODR.svg?branch=master)](https://travis-ci.org/adamhsparks/GSODR)
[![Build
status](https://ci.appveyor.com/api/projects/status/8daqtllo2sg6me07/branch/master?svg=true)](https://ci.appveyor.com/project/adamhsparks/GSODR/branch/master?svg=true)
[![rstudio mirror
downloads](http://cranlogs.r-pkg.org/badges/GSODR?color=blue)](https://github.com/metacran/cranlogs.app)
[![cran
version](http://www.r-pkg.org/badges/version/GSODR)](https://cran.r-project.org/package=GSODR)

The GSODR package is an R package that provides a function that
automates downloading and cleaning data from the "[Global Surface
Summary of the Day
(GSOD)](https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod)"
weather station data provided by the US National Climatic Data Center
(NCDC). Station files are individually checked for number of missing
days to assure data quality, stations with too many missing observations
are omitted. All units are converted to International System of Units
(SI), e.g., inches to millimetres and Fahrenheit to Celsius. Output is
saved as a Comma Separated Value (CSV) file or in a spatial GeoPackage
(GPKG) file, implemented by most major GIS software, summarising each
year by station, which also includes vapour pressure and relative
humidity variables calculated from existing data in GSOD.

There are several other sources of weather data and ways of retrieving
them through R. In particular, the excellent
[rnoaa](https://cran.r-project.org/web/packages/rnoaa/index.html)
package from [ROpenSci](https://ropensci.org) offers tools for
interacting with and downloading weather data from the United States
National Oceanic and Atmospheric Administration but lacks support GSOD
data.

This package was largely based on Tomislav Hengl's work
"[getGSOD.R](http://spatial-analyst.net/book/getGSOD.R)", which can be
found in his book, "[A Practical Guide to Geostatistical
Mapping](http://spatial-analyst.net/book)", with updates to take
advantage of modern R capabilities, cross-platform functionality, and
more options for data retrieval and error correction.

It is recommended that you have a good Internet connection to download
the data files as they can be quite large and slow to download.

For more information on GSOD data see the description of the data
provided by NCDC, <http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt>.

Quick Start
===========

Install
-------

### Stable version

A stable version of GSODR is available from
[CRAN](https://cran.r-project.org/package=GSODR).

``` r
install.packages("GSODR")
```

### Development version

A development version is available from from GitHub. If you wish to
install the development version that may have new features (but also may
not work properly), install the devtools package, available from CRAN. I
strive to keep the master branch on GitHub functional and working
properly this may not always happen. If you find bugs, please file a
report as an issue.

``` r
install.packages("devtools")
devtools::install_github("adamhsparks/GSODR")
```

Using GSODR
-----------

### Query the NCDC FTP server for GSOD data

GSODR's main function, `get_GSOD()` downloads and cleans GSOD data from
the NCDC server. Following are a few examples of it's capabilities.

``` r

library(GSODR)

# Download weather station for Toowoomba, Queensland for 2010, save resulting
# file, GSOD-955510-99999-2010.csv, in the user's home directory.

get_GSOD(years = 2010, station = "955510-99999", dsn = "~/",
         filename = "955510-99999")

# Download GSOD data and generate agroclimatology files for years 2010 and 2011,
# GSOD-agroclimatology-2010.csv and GSOD-agroclimatology-2011.csv, in the user's
# home directory with a maximum of five missing days per weather station allowed.

get_GSOD(years = 2010:2011, dsn = "~/", filename = "GSOD-agroclimatology",
         agroclimatology = TRUE, max_missing = 5)

# Download data for Philippines for year 2010 and generate a spatial, year
# summary file, GSOD-RP-2010.gpkg, in the user's home directory with a
# maximum of five missing days per station allowed and no CSV file creation.

get_GSOD(years = 2010, country = "Philippines", dsn = "~/", filename = "PHL_2010"
         GPKG = TRUE, CSV = FALSE)
```

### Finding stations

GSODR provides a function, `nearest_stations()`, which will return a
data frame object of stations in the GSOD data set that are within a
specified radius of a given point expressed as latitude and longitude in
decimal degrees.

``` r
library(GSODR)

# Find stations within 50km of Toowoomba, QLD.

nearest_stations(LAT = -27.5598, LON = 151.9507, distance = 50)
#>      USAF  WBAN                        STN_NAME CTRY STATE CALL     LAT
#> 1: 945510 99999                       TOOWOOMBA   AS    NA   NA -27.583
#> 2: 945520 99999                           OAKEY   AS    NA YBOK -27.411
#> 3: 945620 99999 UNIVERSITY OF QUEENSLAND GATTON   AS    NA   NA -27.550
#> 4: 949999 00170                  GATTON (LAWES)   AS    NA   NA -27.550
#> 5: 949999 00183      GATTONDPI RESEARCH STATION   AS    NA   NA -27.530
#> 6: 955510 99999               TOOWOOMBA AIRPORT   AS    NA   NA -27.550
#>        LON ELEV_M    BEGIN      END        STNID ELEV_M_SRTM_90m
#> 1: 151.933  676.0 19561231 20120503 945510-99999             670
#> 2: 151.735  406.9 19730430 20161002 945520-99999             404
#> 3: 152.333   94.0 20030330 20161002 945620-99999              90
#> 4: 152.330   29.0 19711231 19840429 949999-00170              92
#> 5: 152.330   95.0 19831130 19840629 949999-00183              88
#> 6: 151.917  642.0 19980301 20161002 955510-99999             635
```

Output
======

The function, `get_GSOD()`, generates a Comma Separated Value (CSV) file
or GeoPackage (GPKG) file Station data are merged with weather data for
the final file which includes the following fields:

-   **STNID** - Station number (WMO/DATSAV3 number) for the location;

-   **WBAN** - number where applicable--this is the historical "Weather
    Bureau Air Force Navy" number - with WBAN being the acronym;

-   **STN\_NAME** - Unique text identifier;

-   **CTRY** - Country in which the station is located;

-   **LAT** - Latitude. *Station dropped in cases where values are
    &lt;-90 or &gt;90 degrees or Lat = 0 and Lon = 0*;

-   **LON** - Longitude. *Station dropped in cases where values are
    &lt;-180 or &gt;180 degrees or Lat = 0 and Lon = 0*;

-   **ELEV\_M** - Elevation in metres;

-   **ELEV\_M\_SRTM\_90m** - Elevation in metres corrected for possible
    errors, derived from the CGIAR-CSI SRTM 90m database (Jarvis et al.
    2008);

-   **YEARMODA** - Date in YYYY-mm-dd format;

-   **YEAR** - The year (YYYY);

-   **MONTH** - The month (mm);

-   **DAY** - The day (dd);

-   **YDAY** - Sequential day of year (not in original GSOD);

-   **TEMP** - Mean daily temperature converted to degrees C to tenths.
    Missing = -9999;

-   **TEMP\_CNT** - Number of observations used in calculating mean
    daily temperature;

-   **DEWP** - Mean daily dew point converted to degrees C to tenths.
    Missing = -9999;

-   **DEWP\_CNT** - Number of observations used in calculating mean
    daily dew point;

-   **SLP** - Mean sea level pressure in millibars to tenths. Missing =
    -9999;

-   **SLP\_CNT** - Number of observations used in calculating mean sea
    level pressure;

-   **STP** - Mean station pressure for the day in millibars to tenths.
    Missing = -9999;

-   **STP\_CNT** - Number of observations used in calculating mean
    station pressure;

-   **VISIB** - Mean visibility for the day converted to kilometres to
    tenths Missing = -9999;

-   **VISIB\_CNT** - Number of observations used in calculating mean
    daily visibility;

-   **WDSP** - Mean daily wind speed value converted to metres/second to
    tenths Missing = -9999;

-   **WDSP\_CNT** - Number of observations used in calculating mean
    daily wind speed;

-   **MXSPD** - Maximum sustained wind speed reported for the day
    converted to metres/second to tenths. Missing = -9999;

-   **GUST** - Maximum wind gust reported for the day converted to
    metres/second to tenths. Missing = -9999;

-   **MAX** - Maximum temperature reported during the day converted to
    Celsius to tenths--time of max temp report varies by country and
    region, so this will sometimes not be the max for the calendar day.
    Missing = -9999;

-   **MAX\_FLAG** - Blank indicates max temp was taken from the explicit
    max temp report and not from the 'hourly' data. An "\*" indicates
    max temp was derived from the hourly data (i.e., highest hourly or
    synoptic-reported temperature);

-   **MIN**- Minimum temperature reported during the day converted to
    Celsius to tenths--time of min temp report varies by country and
    region, so this will sometimes not be the max for the calendar day.
    Missing = -9999;

-   **MIN\_FLAG** - Blank indicates max temp was taken from the explicit
    max temp report and not from the 'hourly' data. An "\*" indicates
    min temp was derived from the hourly data (i.e., highest hourly or
    synoptic-reported temperature);

-   **PRCP** - Total precipitation (rain and/or melted snow) reported
    during the day converted to millimetres to hundredths; will usually
    not end with the midnight observation, i.e., may include latter part
    of previous day. A value of ".00" indicates no measurable
    precipitation (includes a trace). Missing = -9999; *Note: Many
    stations do not report '0' on days with no precipitation--
    therefore, '-9999' will often appear on these days. For example, a
    station may only report a 6-hour amount for the period during which
    rain fell.* See FLAGS\_PRCP column for source of data;

-   **PRCP\_FLAG** -

    -   A = 1 report of 6-hour precipitation amount;

    -   B = Summation of 2 reports of 6-hour precipitation amount;

    -   C = Summation of 3 reports of 6-hour precipitation amount;

    -   D = Summation of 4 reports of 6-hour precipitation amount;

    -   E = 1 report of 12-hour precipitation amount;

    -   F = Summation of 2 reports of 12-hour precipitation amount;

    -   G = 1 report of 24-hour precipitation amount;

    -   H = Station reported '0' as the amount for the day (e.g., from
        6-hour reports), but also reported at least one occurrence of
        precipitation in hourly observations--this could indicate a
        trace occurred, but should be considered as incomplete data for
        the day;

    -   I = Station did not report any precip data for the day and did
        not report any occurrences of precipitation in its hourly
        observations--it's still possible that precipitation occurred
        but was not reported;

-   **SNDP** - Snow depth in millimetres to tenths. Missing = -9999;

-   **I\_FOG** - Indicator for fog, (1 = yes, 0 = no/not reported) for
    the occurrence during the day;

-   **I\_RAIN\_DRIZZLE** - Indicator for rain or drizzle, (1 = yes, 0 =
    no/not reported) for the occurrence during the day;

-   **I\_SNOW\_ICE** - Indicator for snow or ice pellets, (1 = yes, 0 =
    no/not reported) for the occurrence during the day;

-   **I\_HAIL** - Indicator for hail, (1 = yes, 0 = no/not reported) for
    the occurrence during the day;

-   **I\_THUNDER** - Indicator for thunder, (1 = yes, 0 = no/not
    reported) for the occurrence during the day;

-   **I\_TORNADO\_FUNNEL** - Indicator for tornado or funnel cloud, (1 =
    yes, 0 = no/not reported) for the occurrence during the day;

-   **ea** - Mean daily actual vapour pressure;

-   **es** - Mean daily saturation vapour pressure;

-   **RH** - Mean daily relative humidity.

Notes
=====

Elevation Values
----------------

90m hole-filled SRTM digital elevation (Jarvis *et al.* 2008) was used
to identify and correct/remove elevation errors in data for station
locations between -60˚ and 60˚ latitude. This applies to cases here
where elevation was missing in the reported values as well. In case the
station reported an elevation and the DEM does not, the station reported
is taken. For stations beyond -60˚ and 60˚ latitude, the values are
station reported values in every instance. See
<https://github.com/adamhsparks/GSODR/blob/devel/data-raw/fetch_isd-history.md>
for more detail on the correction methods.

WMO Resolution 40. NOAA Policy
------------------------------

*Users of these data should take into account the following (from the
[NCDC
website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):*

> "The following data and products may have conditions placed on their
> international commercial use. They can be used within the U.S. or for
> non-commercial international activities without restriction. The
> non-U.S. data cannot be redistributed for commercial purposes.
> Re-distribution of these data by others must provide this same
> notification." [WMO Resolution 40. NOAA
> Policy](http://www.wmo.int/pages/about/Resolution40.html)

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.

References
==========

Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled SRTM for
the globe Version 4, available from the CGIAR-CSI SRTM 90m Database
(<http://srtm.csI_cgiar.org>)
