
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
[![DOI](https://zenodo.org/badge/32764550.svg)](https://zenodo.org/badge/latestdoi/32764550)

Introduction to GSODR
=====================

The GSODR package is an R package that provides a function that
automates downloading and cleaning of data from the "[Global Surface
Summary of the Day
(GSOD)](https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod)"
weather station data provided by the US National Climatic Data Center
(NCDC). Data are formatted for easy use in R, returned as a `data.frame`
object in R summarising each year by station, with options to save as a
Comma Separated Value (CSV) file or as a spatial GeoPackage (GPKG) file,
implemented by most major GIS softwares.

Station files are individually checked for number of missing days to
assure data quality, stations with too many missing observations are
omitted. All units are converted to International System of Units (SI),
e.g., inches to millimetres and Fahrenheit to Celsius.

Additional data are calculated by this R package using the original data
and included in the final data. These include vapour pressure (ea and
es) and relative humidity.

There are several other sources of weather data and ways of retrieving
them through R. In particular, the excellent
[rnoaa](https://CRAN.R-project.org/package=rnoaa) package from
[ROpenSci](https://ropensci.org) offers tools for interacting with and
downloading weather data from the United States National Oceanic and
Atmospheric Administration but lacks support GSOD data.

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
not work properly), install the [devtools
package](https://CRAN.R-project.org/package=devtools), available from
CRAN. We strive to keep the master branch on GitHub functional and
working properly, although this may not always happen.

If you find bugs, please file a report as an issue.

``` r
install.packages("devtools")
devtools::install_github("adamhsparks/GSODR")
```

Using GSODR
-----------

### Query the NCDC FTP server for GSOD data

GSODR's main function, `get_GSOD`, downloads and cleans GSOD data from
the NCDC server. Following are a few examples of its capabilities.

#### Example 1 - Download weather station for Toowoomba, Queensland for 2010

``` r

library(GSODR)

Tbar <- get_GSOD(years = 2010, station = "955510-99999")
#> 
#> Downloading the station file(s) now.
#> 
#> Finished downloading file. Parsing the station file(s) now.

head(Tbar)
#>     USAF  WBAN        STNID          STN_NAME CTRY STATE CALL    LAT
#> 1 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55
#> 2 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55
#> 3 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55
#> 4 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55
#> 5 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55
#> 6 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55
#>       LON ELEV_M ELEV_M_SRTM_90m    BEGIN      END YEARMODA YEAR MONTH DAY
#> 1 151.917    642             635 19980301 20161021 20100101 2010    01  01
#> 2 151.917    642             635 19980301 20161021 20100102 2010    01  02
#> 3 151.917    642             635 19980301 20161021 20100103 2010    01  03
#> 4 151.917    642             635 19980301 20161021 20100104 2010    01  04
#> 5 151.917    642             635 19980301 20161021 20100105 2010    01  05
#> 6 151.917    642             635 19980301 20161021 20100106 2010    01  06
#>   YDAY TEMP TEMP_CNT DEWP DEWP_CNT    SLP SLP_CNT   STP STP_CNT VISIB
#> 1    1 21.2        8 17.9        8 1013.4       8 942.0       8    NA
#> 2    2 23.2        8 19.4        8 1010.5       8 939.3       8    NA
#> 3    3 21.4        8 18.9        8 1012.3       8 940.9       8  14.3
#> 4    4 18.9        8 16.4        8 1015.7       8 944.1       8  23.3
#> 5    5 20.5        8 16.4        8 1015.5       8 944.0       8    NA
#> 6    6 21.9        8 18.7        8 1013.7       8 942.3       8    NA
#>   VISIB_CNT WDSP WDSP_CNT MXSPD GUST   MAX MAX_FLAG   MIN MIN_FLAG PRCP
#> 1         0  2.2        8   6.7   NA 25.78          17.78           1.5
#> 2         0  1.9        8   5.1   NA 26.50          19.11           0.3
#> 3         6  3.9        8  10.3   NA 28.72          19.28        * 19.8
#> 4         4  4.5        8  10.3   NA 24.11          16.89        *  1.0
#> 5         0  3.9        8  10.8   NA 24.61          16.72           0.3
#> 6         0  3.2        8   7.7   NA 26.78          17.50           0.0
#>   PRCP_FLAG SNDP I_FOG I_RAIN_DRIZZLE I_SNOW_ICE I_HAIL I_THUNDER
#> 1         G   NA     0              0          0      0         0
#> 2         G   NA     0              0          0      0         0
#> 3         G   NA     1              1          0      0         0
#> 4         G   NA     0              0          0      0         0
#> 5         G   NA     0              0          0      0         0
#> 6         G   NA     1              0          0      0         0
#>   I_TORNADO_FUNNEL  EA  ES   RH
#> 1                0 2.1 2.5 84.0
#> 2                0 2.3 2.8 82.1
#> 3                0 2.2 2.5 88.0
#> 4                0 1.9 2.2 86.4
#> 5                0 1.9 2.4 79.2
#> 6                0 2.2 2.6 84.6
```

#### Example 2 - Download GSOD data and generate agroclimatology files

For years 2010 and 2011, download data and create the files,
GSOD-agroclimatology-2010.csv and GSOD-agroclimatology-2011.csv, in the
user's home directory with a maximum of five missing days per weather
station allowed. Use parallel processing to run the process more
quickly.

``` r

get_GSOD(years = 2010:2011, dsn = "~/", filename = "GSOD-agroclimatology",
         agroclimatology = TRUE, max_missing = 5, threads = 3)
```

#### Example 3 - Download data for a single country and plot it

Download data for Philippines for year 2010 and generate a spatial, year
summary file, PHL-2010.gpkg, in the user's home directory with a maximum
of five missing days per station allowed and no CSV file.

``` r
get_GSOD(years = 2010, country = "Philippines", dsn = "~/", filename = "PHL",
         GPKG = TRUE, CSV = FALSE, threads = 2)
```

``` r
library(rgdal)
#> Loading required package: sp
#> rgdal: version: 1.1-10, (SVN revision 622)
#>  Geospatial Data Abstraction Library extensions to R successfully loaded
#>  Loaded GDAL runtime: GDAL 1.11.5, released 2016/07/01
#>  Path to GDAL shared files: /usr/local/Cellar/gdal/1.11.5_1/share/gdal
#>  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
#>  Path to PROJ.4 shared files: (autodetected)
#>  Linking to sp version: 1.2-3
library(spacetime)
library(plotKML)
#> plotKML version 0.5-6 (2016-05-02)
#> URL: http://plotkml.r-forge.r-project.org/

layers <- ogrListLayers(dsn = path.expand("~/PHL-2010.gpkg"))
pnts <- readOGR(dsn = path.expand("~/PHL-2010.gpkg"), layers[1])
#> OGR data source with driver: GPKG 
#> Source: "/Users/asparks/PHL-2010.gpkg", layer: "GSOD"
#> with 2190 features
#> It has 46 fields

# Plot results in Google Earth as a spacetime object:
pnts$DATE = as.Date(paste(pnts$YEAR, pnts$MONTH, pnts$DAY, sep = "-"))
row.names(pnts) <- paste("point", 1:nrow(pnts), sep = "")

tmp_ST <- STIDF(sp = as(pnts, "SpatialPoints"),
                time = pnts$DATE - 0.5,
                data = pnts@data[, c("TEMP", "STNID")],
                endTime = pnts$DATE + 0.5)

shape = "http://maps.google.com/mapfiles/kml/pal2/icon18.png"

kml(tmp_ST, dtime = 24 * 3600, colour = TEMP, shape = shape, labels = TEMP,
    file.name = "Temperatures_PHL_2010-2010.kml", folder.name = "TEMP")
#> KML file opened for writing...
#> Writing to KML...
#> Closing  Temperatures_PHL_2010-2010.kml

system("zip -m Temperatures_PHL_2010-2010.kmz Temperatures_PHL_2010-2010.kml")
```

Compare the GSOD weather data from the Philippines with climatic data
provided by the GSODR package in the `GSOD_clim` data set.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(ggplot2)
library(reshape2)

data(GSOD_clim)
cnames <- paste0("CHELSA_temp_", 1:12, "_1979-2013")
clim_temp <- GSOD_clim[GSOD_clim$STNID %in% pnts$STNID,
                       paste(c("STNID", cnames))]
clim_temp_df <- data.frame(STNID = rep(clim_temp$STNID, 12),
                           MONTHC = as.vector(sapply(1:12, rep,
                                                    times = nrow(clim_temp))), 
                           CHELSA_TEMP = as.vector(unlist(clim_temp[, cnames])))

pnts$MONTHC <- as.numeric(paste(pnts$MONTH))
temp <- left_join(pnts@data, clim_temp_df, by = c("STNID", "MONTHC"))
#> Warning in left_join_impl(x, y, by$x, by$y, suffix$x, suffix$y): joining
#> factors with different levels, coercing to character vector

temp <- temp %>% 
  group_by(MONTH) %>% 
  mutate(AVG_DAILY_TEMP = round(mean(TEMP), 1))

df_melt <- na.omit(melt(temp[, c("STNID", "DATE", "CHELSA_TEMP", "TEMP", "AVG_DAILY_TEMP")],
                        id = c("DATE", "STNID")))

ggplot(df_melt, aes(x = DATE, y = value)) +
  geom_point(aes(color = variable), alpha = 0.5) +
  scale_x_date(date_labels = "%b") +
  ylab("Temperature (C)") +
  xlab("Month") +
  labs(colour = "") +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap( ~ STNID)
```

![Comparison of GSOD daily values and average monthly values with CHELSA
climate monthly values](README-example_3.2-1.png)

### Example 4 - Finding stations within a given radius and download them

GSODR provides a function, `nearest_stations`, which will return a list
of stations in the GSOD data set that are within a specified radius
(kilometres) of a given point expressed as latitude and longitude in
decimal degrees.

``` r
# Find stations within 50km of Toowoomba, QLD.

n <- nearest_stations(LAT = -27.5598, LON = 151.9507, distance = 50)

n
#> [1] "945510-99999" "945520-99999" "945620-99999" "949999-00170"
#> [5] "949999-00183" "955510-99999"

toowoomba <- get_GSOD(years = 2015, station = n, threads = 3)
#> This station, 945510-99999, only provides data for years 1956 to 2012.
#> This station, 949999-00170, only provides data for years 1971 to 1984.
#> This station, 949999-00183, only provides data for years 1983 to 1984.
#> 
#> Downloading the station file(s) now.
#> 
#> Finished downloading file. Parsing the station file(s) now.
#> A file corresponding to station,ftp://ftp.ncdc.noaa.gov/pub/data/gsod/2015/945510-99999-2015.op.gzwas not found on
#>                       the server. Any others requested will be processed.
#> A file corresponding to station,ftp://ftp.ncdc.noaa.gov/pub/data/gsod/2015/949999-00170-2015.op.gzwas not found on
#>                       the server. Any others requested will be processed.
#> A file corresponding to station,ftp://ftp.ncdc.noaa.gov/pub/data/gsod/2015/949999-00183-2015.op.gzwas not found on
#>                       the server. Any others requested will be processed.

str(toowoomba)
#> 'data.frame':    1094 obs. of  48 variables:
#>  $ USAF            : chr  "945520" "945520" "945520" "945520" ...
#>  $ WBAN            : chr  "99999" "99999" "99999" "99999" ...
#>  $ STNID           : chr  "945520-99999" "945520-99999" "945520-99999" "945520-99999" ...
#>  $ STN_NAME        : chr  "OAKEY" "OAKEY" "OAKEY" "OAKEY" ...
#>  $ CTRY            : chr  "AS" "AS" "AS" "AS" ...
#>  $ STATE           : chr  NA NA NA NA ...
#>  $ CALL            : chr  "YBOK" "YBOK" "YBOK" "YBOK" ...
#>  $ LAT             : num  -27.4 -27.4 -27.4 -27.4 -27.4 ...
#>  $ LON             : num  152 152 152 152 152 ...
#>  $ ELEV_M          : num  407 407 407 407 407 ...
#>  $ ELEV_M_SRTM_90m : num  404 404 404 404 404 404 404 404 404 404 ...
#>  $ BEGIN           : num  19730430 19730430 19730430 19730430 19730430 ...
#>  $ END             : num  20161021 20161021 20161021 20161021 20161021 ...
#>  $ YEARMODA        : chr  "20150101" "20150102" "20150103" "20150104" ...
#>  $ YEAR            : chr  "2015" "2015" "2015" "2015" ...
#>  $ MONTH           : chr  "01" "01" "01" "01" ...
#>  $ DAY             : chr  "01" "02" "03" "04" ...
#>  $ YDAY            : num  1 2 3 4 5 6 7 8 9 10 ...
#>  $ TEMP            : num  24.9 24.3 22.3 23 22.5 22.6 21.8 22.6 24.6 24.9 ...
#>  $ TEMP_CNT        : int  24 24 24 24 24 24 24 24 24 24 ...
#>  $ DEWP            : num  18.4 18.2 17.4 16.3 17.7 14.3 15.7 16.4 16.4 16.4 ...
#>  $ DEWP_CNT        : int  24 24 24 24 24 24 24 24 24 24 ...
#>  $ SLP             : num  1014 1017 1017 1014 1015 ...
#>  $ SLP_CNT         : int  16 16 16 16 16 16 16 16 16 16 ...
#>  $ STP             : num  968 971 971 969 969 ...
#>  $ STP_CNT         : int  16 16 16 16 16 16 16 16 16 16 ...
#>  $ VISIB           : num  10 10 10 10 10 10 NA NA 10 NA ...
#>  $ VISIB_CNT       : int  8 8 4 5 7 4 0 0 4 0 ...
#>  $ WDSP            : num  2.3 2.8 2.8 2.3 3 3.5 3.1 2.5 2.9 2.7 ...
#>  $ WDSP_CNT        : int  24 24 24 24 24 24 24 24 24 24 ...
#>  $ MXSPD           : num  8.2 9.8 10.3 7.2 9.8 9.8 9.8 8.8 8.2 8.2 ...
#>  $ GUST            : num  NA NA NA NA NA NA NA NA NA 12.4 ...
#>  $ MAX             : num  31.8 31 27.3 29.3 27.6 ...
#>  $ MAX_FLAG        : chr  "" "" "" "" ...
#>  $ MIN             : num  18.9 18.2 17.7 16.8 16.4 ...
#>  $ MIN_FLAG        : chr  "*" "" "*" "*" ...
#>  $ PRCP            : num  0 0 0 0 0 0 0 0 0 0 ...
#>  $ PRCP_FLAG       : chr  "G" "G" "G" "G" ...
#>  $ SNDP            : num  NA NA NA NA NA NA NA NA NA NA ...
#>  $ I_FOG           : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ I_RAIN_DRIZZLE  : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ I_SNOW_ICE      : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ I_HAIL          : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ I_THUNDER       : int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ I_TORNADO_FUNNEL: int  0 0 0 0 0 0 0 0 0 0 ...
#>  $ EA              : num  2.1 2.1 2 1.9 2 1.6 1.8 1.9 1.9 1.9 ...
#>  $ ES              : num  3.1 3 2.7 2.8 2.7 2.7 2.6 2.7 3.1 3.1 ...
#>  $ RH              : num  67.7 70 74.1 67.9 74.1 59.3 69.2 70.4 61.3 61.3 ...
```

Final data format and contents
------------------------------

The function, `get_GSOD`, returns a `data.frame` object in R and can
also save a Comma Separated Value (CSV) file or GeoPackage (GPKG) file
for use in a GIS. Station data are merged with weather data for the
final file which includes the following fields:

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
    Missing = NA;

-   **TEMP\_CNT** - Number of observations used in calculating mean
    daily temperature;

-   **DEWP** - Mean daily dew point converted to degrees C to tenths.
    Missing = NA;

-   **DEWP\_CNT** - Number of observations used in calculating mean
    daily dew point;

-   **SLP** - Mean sea level pressure in millibars to tenths. Missing =
    NA;

-   **SLP\_CNT** - Number of observations used in calculating mean sea
    level pressure;

-   **STP** - Mean station pressure for the day in millibars to tenths.
    Missing = NA;

-   **STP\_CNT** - Number of observations used in calculating mean
    station pressure;

-   **VISIB** - Mean visibility for the day converted to kilometres to
    tenths Missing = NA;

-   **VISIB\_CNT** - Number of observations used in calculating mean
    daily visibility;

-   **WDSP** - Mean daily wind speed value converted to metres/second to
    tenths Missing = NA;

-   **WDSP\_CNT** - Number of observations used in calculating mean
    daily wind speed;

-   **MXSPD** - Maximum sustained wind speed reported for the day
    converted to metres/second to tenths. Missing = NA;

-   **GUST** - Maximum wind gust reported for the day converted to
    metres/second to tenths. Missing = NA;

-   **MAX** - Maximum temperature reported during the day converted to
    Celsius to tenths--time of max temp report varies by country and
    region, so this will sometimes not be the max for the calendar day.
    Missing = NA;

-   **MAX\_FLAG** - Blank indicates max temp was taken from the explicit
    max temp report and not from the 'hourly' data. An "\*" indicates
    max temp was derived from the hourly data (i.e., highest hourly or
    synoptic-reported temperature);

-   **MIN** - Minimum temperature reported during the day converted to
    Celsius to tenths--time of min temp report varies by country and
    region, so this will sometimes not be the max for the calendar day.
    Missing = NA;

-   **MIN\_FLAG** - Blank indicates max temp was taken from the explicit
    min temp report and not from the 'hourly' data. An "\*" indicates
    min temp was derived from the hourly data (i.e., highest hourly or
    synoptic-reported temperature);

-   **PRCP** - Total precipitation (rain and/or melted snow) reported
    during the day converted to millimetres to hundredths; will usually
    not end with the midnight observation, i.e., may include latter part
    of previous day. A value of ".00" indicates no measurable
    precipitation (includes a trace). Missing = NA; *Note: Many stations
    do not report '0' on days with no precipitation-- therefore, 'NA'
    will often appear on these days. For example, a station may only
    report a 6-hour amount for the period during which rain fell.* See
    FLAGS\_PRCP column for source of data;

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
    precipitation in hourly observations--this could indicate a trace
    occurred, but should be considered as incomplete data for the day;

-   I = Station did not report any precipitation data for the day and
    did not report any occurrences of precipitation in its hourly
    observations--it's still possible that precipitation occurred but
    was not reported;

-   **SNDP** - Snow depth in millimetres to tenths. Missing = NA;

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
