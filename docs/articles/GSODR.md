---
title: "GSODR"
author: "Adam H Sparks"
date: "2017-10-19"
output:
  html_document:
    toc: true
    toc_float: true
    toc_depth: 3
    theme: spacelab
vignette: >
  %\VignetteEngine{knitr::knitr}
  %\VignetteIndexEntry{GSODR}
  %\VignetteEncoding{UTF-8}
---



# Introduction

The GSOD or [Global Surface Summary of the Day (GSOD)](https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod)
data provided by the US National Centers for Environmental Information (NCEI)
are a valuable source of weather data with global coverage. However, the data
files are cumbersome and difficult to work with. _GSODR_ aims to make it easy to
find, transfer and format the data you need for use in analysis and provides
four main functions for facilitating this:

- `get_GSOD()` - the main function that will query and transfer files from the
FTP server, reformat them and return a data frame in R or save a file to disk

- `reformat_GSOD()` - the workhorse, this function takes individual station
files on the local disk and re-formats them returning a data frame in R

- `nearest_stations()` - this function returns a data frame containing a list of
stations and their metadata that fall within the given radius of a point
specified by the user  

- `update_station_list()` - this function downloads the latest station list from
the NCEI FTP server updates the package's internal database of stations and
their metadata.

When reformatting data either with `get_GSOD()` or `reformat_GSOD()`, all units
are converted to International System of Units (SI), e.g., inches to millimetres
and Fahrenheit to Celsius. File output can be saved as a Comma Separated Value
(CSV) file or in a spatial GeoPackage (GPKG) file, implemented by most major
GIS software, summarising each year by station, which also includes vapour
pressure and relative humidity elements calculated from existing data in GSOD.

For more information see the description of the data provided by NCEI,
<http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt>.

# Retrieving and Reformatting Data in R

## Plot Global Station Locations

## Find Stations in Australia

_GSODR_ provides lists of weather station locations and elevation values. Using [_dplyr_](https://CRAN.R-project.org/package=dplyr), we can find all the
stations in Australia.


```r
library(GSODR)
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
load(system.file("extdata", "country_list.rda", package = "GSODR"))
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

station_locations <- left_join(isd_history, country_list,
                               by = c("CTRY" = "FIPS"))

# create data.frame for Australia only
Oz <- filter(station_locations, COUNTRY_NAME == "AUSTRALIA")

Oz
```

```
## # A tibble: 1,412 x 16
##      USAF  WBAN                      STN_NAME  CTRY STATE  CALL     LAT
##     <chr> <chr>                         <chr> <chr> <chr> <chr>   <dbl>
##  1 695023 99999           HORN ISLAND   (HID)    AS  <NA>  KQXC -10.583
##  2 749430 99999            AIDELAIDE RIVER SE    AS  <NA>  <NA> -13.300
##  3 749432 99999     BATCHELOR FIELD AUSTRALIA    AS  <NA>  <NA> -13.049
##  4 749438 99999          IRON RANGE AUSTRALIA    AS  <NA>  <NA> -12.700
##  5 749439 99999      MAREEBA AS/HOEVETT FIELD    AS  <NA>  <NA> -17.050
##  6 749440 99999                     REID EAST    AS  <NA>  <NA> -19.767
##  7 749441 99999  TOWNSVILLE AUSTRALIA/GARBUTT    AS  <NA>  ABTL -19.249
##  8 749442 99999                     WOODSTOCK    AS  <NA>  <NA> -19.600
##  9 749443 99999 JACKY JACKY AUSTRALIA/HIGGINS    AS  <NA>  <NA> -10.933
## 10 749455 99999            LAKE BUCHANAN WEST    AS  <NA>  <NA> -21.417
## # ... with 1,402 more rows, and 9 more variables: LON <dbl>, ELEV_M <dbl>,
## #   BEGIN <dbl>, END <dbl>, STNID <chr>, ELEV_M_SRTM_90m <dbl>,
## #   COUNTRY_NAME <chr>, iso2c <chr>, iso3c <chr>
```

```r
filter(Oz, STN_NAME == "TOOWOOMBA")
```

```
## # A tibble: 1 x 16
##     USAF  WBAN  STN_NAME  CTRY STATE  CALL     LAT     LON ELEV_M    BEGIN
##    <chr> <chr>     <chr> <chr> <chr> <chr>   <dbl>   <dbl>  <dbl>    <dbl>
## 1 945510 99999 TOOWOOMBA    AS  <NA>  <NA> -27.583 151.933    676 19561231
## # ... with 6 more variables: END <dbl>, STNID <chr>,
## #   ELEV_M_SRTM_90m <dbl>, COUNTRY_NAME <chr>, iso2c <chr>, iso3c <chr>
```

## Using the get_GSOD() Function in _GSODR_ to Download a Single Station and Year

Now that we've seen where the reporting stations are located, we can download
weather data from the station Toowoomba, Queensland, Australia for 2010 by using
the STNID in the `station` parameter of `get_GSOD()`.


```r
tbar <- get_GSOD(years = 2010, station = "945510-99999")
```

```
## 
## Checking requested station file for availability on server
```

```
## 
## Downloading individual station files.
```

```r
tbar
```

```
## # A tibble: 0 x 0
```

## Find Stations Within a Specified Distance of a Given Lat/Lon Value

Using the `nearest_stations()` function, you can find stations closest to a
given point specified by latitude and longitude in decimal degrees. This can be
used to generate a vector to pass along to `get_GSOD()` and download the
stations of interest.

There are missing stations in this query. Not all that are listed and queried
actually have files on the server.


```r
tbar_stations <- nearest_stations(LAT = -27.5598,
                                  LON = 151.9507,
                                  distance = 50)

tbar <- get_GSOD(years = 2010, station = tbar_stations)
```

```
## 
## This station, 949999-00170, only provides data for years 1971 to 1984.
```

```
## 
## This station, 949999-00183, only provides data for years 1983 to 1984.
```

```
## 
## Checking requested station file for availability on server
```

```
## 
## Downloading individual station files.
```

If you wished to drop the stations, 949999-00170 and 949999-00183 from the
query, you could do this.


```r
remove <- c("949999-00170", "949999-00183")

Tbar_stations <- tbar_stations[!tbar_stations %in% remove]

Tbar <- get_GSOD(years = 2010,
                 station = tbar_stations,
                 dsn = "~/")
```

```
## 
## This station, 949999-00170, only provides data for years 1971 to 1984.
```

```
## 
## This station, 949999-00183, only provides data for years 1983 to 1984.
```

```
## 
## Checking requested station file for availability on server
```

```
## 
## Downloading individual station files.
```

## Plot Maximum and Miniumum Temperature Values

Using the first data downloaded for a single station, 955510-99999, plot the
temperature for 2010 using `read_csv()` from Hadley's
[`readr`](https://CRAN.R-project.org/package=readr) package.


```r
library(ggplot2)
library(lubridate)
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following object is masked from 'package:base':
## 
##     date
```

```r
library(tidyr)

# Create a dataframe of just the date and temperature values that we want to
# plot
tbar_temps <- tbar[, c("YEARMODA", "TEMP", "MAX", "MIN")]

# Gather the data from wide to long
tbar_temps <- gather(tbar_temps, Measurement, gather_cols = TEMP:MIN)

ggplot(data = tbar_temps, aes(x = ymd(YEARMODA), y = value,
                              colour = Measurement)) +
  geom_line() +
  scale_color_brewer(type = "qual", na.value = "black") +
  scale_y_continuous(name = "Temperature") +
  scale_x_date(name = "Date") +
  theme_bw()
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)
![GSOD Toowoomba Temperatures](./figure/Toowoomba_temperature.png)

# Creating Spatial Files

Because the stations provide geospatial location information, it is possible to
create a spatial file. [GeoPackage files](http://www.geopackage.org) are a open,
standards-based, platform-independent, portable, self-describing compact
format for transferring geospatial information, which handle vector files much
like shapefiles do, but eliminate many of the issues that shapefiles have with
field names and the number of files. The `get_GSOD()` function can create a
GeoPackage file, which can be used with a GIS for further analysis and mapping
with other spatial objects.

After getting weather stations for Australia and creating a GeoPackage file,
_rgdal_ can import the data into R and _raster_ provides a function,
`getData()`, to download an outline of Australia useful for plotting the
station locations in this country.


```r
get_GSOD(years = 2015, country = "Australia", dsn = "~/", filename = "AUS",
         CSV = FALSE, GPKG = TRUE)
#> trying URL 'ftp://ftp.ncdc.noaa.gov/pub/data/gsod/2015/gsod_2015.tar'
#> Content type 'unknown' length 106352640 bytes (101.4 MB)
#> ==================================================
#> downloaded 101.4 MB


#> Finished downloading file.

#> Starting data file processing.


#> Writing GeoPackage file to disk.
```

Importing the GeoPackage file can be a bit tricky. The dsn will be the full path
along with the file name. The layer to be specified is "GSOD", this is specified
in the `get_GSOD()` function and will not change. The file name, specified in
the dsn will, but the layer name will not.


```r
library(rgdal)
#> Loading required package: sp
#> rgdal: version: 1.1-10, (SVN revision 622)
#>  Geospatial Data Abstraction Library extensions to R successfully loaded
#>  Loaded GDAL runtime: GDAL 1.11.5, released 2016/07/01
#>  Path to GDAL shared files: /usr/local/Cellar/gdal/1.11.5_1/share/gdal
#>  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
#>  Path to PROJ.4 shared files: (autodetected)
#>  Linking to sp version: 1.2-3

AUS_stations <- readOGR(dsn = path.expand("~/AUS.gpkg"), layer = "GSOD")
#> OGR data source with driver: GPKG
#> Source: "/Users/asparks/AUS-2015.gpkg", layer: "GSOD"
#> with 186977 features
#> It has 46 fields

class(AUS_stations)
#> [1] "SpatialPointsDataFrame"
#> attr(,"package")
#> [1] "sp"
```

Since GeoPackage files are formatted as SQLite databases you can use the
existing R tools for SQLite files
[(J. Stachelek 2016)](https://jsta.github.io/2016/07/14/geopackage-r.html). One
easy way is using _dplyr_, which we've already used to filter the stations.

This option is much faster to load since it does not load the geometry.


```r
AUS_sqlite <- tbl(src_sqlite(path.expand("~/AUS.gpkg")), "GSOD")
class(AUS_sqlite)
#> [1] "tbl_dbi"  "tbl_sql"  "tbl_lazy" "tbl"

print(AUS_sqlite, n = 5)
#> Source:   table<GSOD> [?? x 48]
#> Database: sqlite 3.19.3 [/Users/U8004755/AUS.gpkg]
#>    fid         geom   USAF  WBAN        STNID  STN_NAME  CTRY STATE  CALL ELEV_M ELEV_M_SRTM_90m    BEGIN      END YEARMODA
#>  <int>       <blob>  <chr> <chr>        <chr>     <chr> <chr> <chr> <chr>  <dbl>           <dbl>    <dbl>    <dbl>    <chr>
#> 1     1 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150101
#> 2     2 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150102
#> 3     3 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150103
#> 4      4 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150104
#> 5     5 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150105
#> ... with more rows, and 34 more variables: YEAR <chr>, MONTH <chr>, DAY <chr>, YDAY <dbl>, TEMP <dbl>, TEMP_CNT <int>,
#>   DEWP <dbl>, DEWP_CNT <int>, SLP <dbl>, SLP_CNT <int>, STP <dbl>, STP_CNT <int>, VISIB <dbl>, VISIB_CNT <int>, WDSP <dbl>,
#>   WDSP_CNT <int>, MXSPD <dbl>, GUST <dbl>, MAX <dbl>, MAX_FLAG <chr>, MIN <dbl>, MIN_FLAG <chr>, PRCP <dbl>, PRCP_FLAG <chr>,
#>   SNDP <dbl>, I_FOG <int>, I_RAIN_DRIZZLE <int>, I_SNOW_ICE <int>, I_HAIL <int>, I_THUNDER <int>, I_TORNADO_FUNNEL <int>,
#>   EA <dbl>, ES <dbl>, RH <dbl>
```

# Reformating Local Data Files

You may have already downloaded GSOD data or may just wish to use an FTP client
to download the files from the server to you local disk and not use the
capabilities of `get_GSOD()`. In that case the `reformat_GSOD()` function is
useful.

There are two ways, you can either provide `reformat_GSOD()` with a list of
specified station files or you can supply it with a directory containing all of
the "WBAN-WMO-YYYY.op.gz" station files that you wish to reformat.

## Reformat a list of local files


```r
y <- c("~/GSOD/gsod_1960/200490-99999-1960.op.gz",
       "~/GSOD/gsod_1961/200490-99999-1961.op.gz")
x <- reformat_GSOD(file_list = y)
```

## Reformat all local files found in directory


```r
x <- reformat_GSOD(dsn = "~/GSOD/gsod_1960")
```

# Updating _GSODR's_ Internal Database of Station Locations and Metadata

_GSODR_ uses internal databases of station data from the NCEI to provide
location and other metadata, e.g. elevation, station names, WMO codes, etc. to
make the process of querying for weather data faster. This database is created
and packaged with _GSODR_ for distribution and is updated with new releases.
Users have the option of updating these databases after installing _GSODR_.
While this option gives the users the ability to keep the database up-to-date
and gives _GSODR's_ authors flexibility in maintaining it, this also means that
reproducibility may be affected since the same version of _GSODR_ may have
different databases on different machines. If reproducibility is necessary,
care should be taken to ensure that the version of the databases is the same
across different machines.

The database file `isd_history.rda` can be located on your local system by using
the following command, `paste0(.libPaths(), "/GSODR/extdata")[1]`, unless you have specified another location for library installations and
installed _GSODR_ there, in which case it would still be in `GSODR/extdata`.

# Checking NCEI's GSOD Station Data Inventory

_GSODR_ provides a function, `get_inventory()` to retrieve an inventory of the
number of weather observations by station-year-month for the beginning of record
through to current.

Following is an example of how to retreive the inventory and check a station in
Toowoomba, Queensland, Australia, which was used in an earlier example.


```r
inventory <- get_inventory()
```

```
## THIS INVENTORY SHOWS THE NUMBER OF WEATHER OBSERVATIONS BY STATION-YEAR-MONTH FOR BEGINNING OF RECORD THROUGH SEPTEMBER 2017.  THE DATABASE CONTINUES TO BE UPDATED AND ENHANCED, AND THIS INVENTORY WILL BE  UPDATED ON A REGULAR BASIS.
```

```r
inventory
```

```
## # A tibble: 616,555 x 14
##           STNID  YEAR   JAN   FEB   MAR   APR   MAY   JUN   JUL   AUG
##           <chr> <int> <int> <int> <int> <int> <int> <int> <int> <int>
##  1 007005-99999  2012    18     0     0     0     0     0     0     0
##  2 007011-99999  2012   771     0   183     0     0     0   142    13
##  3 007018-99999  2013     0     0     0     0     0     0   710     0
##  4 007025-99999  2012    21     0     0     0     0     0     0     0
##  5 007026-99999  2012     0     0     0     0     0     0   367     0
##  6 007026-99999  2014     0     0     0     0     0     0   180     0
##  7 007026-99999  2016     0     0     0     0     0   794     0     0
##  8 007026-99999  2017     0   914  2626   380   277   406  1230  1009
##  9 007034-99999  2012     0     0     0     0     0     0     0     0
## 10 007037-99999  2012     0     0     0     0     0     0   830    35
## # ... with 616,545 more rows, and 4 more variables: SEP <int>, OCT <int>,
## #   NOV <int>, DEC <int>
```

```r
subset(inventory, STNID == "955510-99999")
```

```
## # A tibble: 20 x 14
##           STNID  YEAR   JAN   FEB   MAR   APR   MAY   JUN   JUL   AUG
##           <chr> <int> <int> <int> <int> <int> <int> <int> <int> <int>
##  1 955510-99999  1998     0     0   222   223   221   211   226   217
##  2 955510-99999  1999   213   201   235   224   244   229   239   247
##  3 955510-99999  2000   241   227   247   238   246   237   245   240
##  4 955510-99999  2001   245   223   246   238   239   236   243   240
##  5 955510-99999  2002   245   219   246   236   243   229   243   246
##  6 955510-99999  2003   244   217   220   232   235   233   246   242
##  7 955510-99999  2004   240   227   241   229   233   224   235   244
##  8 955510-99999  2005   243   221   243   241   247   242   248   247
##  9 955510-99999  2006   245   223   246   232   241   238   247   247
## 10 955510-99999  2007   247   222   244   240   248   240   244   244
## 11 955510-99999  2008   247   228   248   239   248   239   248   247
## 12 955510-99999  2009   245   222   246   235   244   237   248   248
## 13 955510-99999  2010   248   223   248   240   244   240   242   247
## 14 955510-99999  2011   247   224   247   240   247   240   248   247
## 15 955510-99999  2012   248   232   248   240   248   240   248   247
## 16 955510-99999  2013   236   220   247   233   248   239   252   246
## 17 955510-99999  2014   243   224   247   240   246   239   241   243
## 18 955510-99999  2015   248   222   248   239   247   240   247   246
## 19 955510-99999  2016   246   228   245   240   246   240   248   248
## 20 955510-99999  2017   240   224   248   240   248   237   248   247
## # ... with 4 more variables: SEP <int>, OCT <int>, NOV <int>, DEC <int>
```

# Additional Climate Data

Additional climate data,
[_GSODRdata_](https://github.com/adamhsparks/GSODRdata), formatted for use with
GSOD data provided by _GSODR_ are available as an R package install able through
GitHub due to the package size, 5.1Mb, being too large for CRAN.


```r
#install.packages("devtools")
devtools::install_github("adamhsparks/GSODRdata")
library("GSODRdata")
```

# Notes

## Elevation Values

90 metre (90m) hole-filled SRTM digital elevation (Jarvis *et al.* 2008) was
used to identify and correct/remove elevation errors in data for station
locations between -60˚ and 60˚ latitude. This applies to cases here where
elevation was missing in the reported values as well. In case the station
reported an elevation and the DEM does not, the station reported is taken. For
stations beyond -60˚ and 60˚ latitude, the values are station reported values
in every instance. See
<https://github.com/ropensci/GSODR/blob/master/data-raw/fetch_isd-history.md>
for more detail on the correction methods.

## WMO Resolution 40. NOAA Policy

*Users of these data should take into account the following (from the [NCEI website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):*

> "The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification." [WMO Resolution 40. NOAA Policy](https://public.wmo.int/en/our-mandate/what-we-do/data-exchange-and-technology-transfer)

# References
Stachelek, J. (2016) Using the Geopackage Format with R.
URL: https://jsta.github.io/2016/07/14/geopackage-r.html


# Appendices

Appendix 1: GSODR Final Data Format, Contents and Units
------------------------------

_GSODR_ formatted data include the following fields and units:

- **STNID** - Station number (WMO/DATSAV3 number) for the location;

- **WBAN** - number where applicable--this is the historical "Weather Bureau
Air Force Navy" number - with WBAN being the acronym;

- **STN\_NAME** - Unique text identifier;

- **CTRY** - Country in which the station is located;

- **LAT** - Latitude. *Station dropped in cases where values are < -90 or > 90
degrees or Lat = 0 and Lon = 0*;

- **LON** - Longitude. *Station dropped in cases where values are < -180 or >
180 degrees or Lat = 0 and Lon = 0*;

- **ELEV\_M** - Elevation in metres;

- **ELEV\_M\_SRTM\_90m** - Elevation in metres corrected for possible errors,
derived from the CGIAR-CSI SRTM 90m database (Jarvis et al. 2008);

- **YEARMODA** - Date in YYYY-mm-dd format;

- **YEAR** - The year (YYYY);

- **MONTH** - The month (mm);

- **DAY** - The day (dd);

- **YDAY** - Sequential day of year (not in original GSOD);

- **TEMP** - Mean daily temperature converted to degrees C to tenths. Missing =
NA;

- **TEMP\_CNT** - Number of observations used in calculating mean daily
temperature;

- **DEWP** - Mean daily dew point converted to degrees C to tenths. Missing =
NA;

- **DEWP\_CNT** - Number of observations used in calculating mean daily dew
point;

- **SLP** - Mean sea level pressure in millibars to tenths. Missing = NA;

- **SLP\_CNT** - Number of observations used in calculating mean sea level
pressure;

- **STP** - Mean station pressure for the day in millibars to tenths. Missing
= NA;

- **STP\_CNT** - Number of observations used in calculating mean station
pressure;

- **VISIB** - Mean visibility for the day converted to kilometres to tenths
Missing = NA;

- **VISIB\_CNT** - Number of observations used in calculating mean daily
visibility;

- **WDSP** - Mean daily wind speed value converted to metres/second to tenths.
Missing = NA;

- **WDSP\_CNT** - Number of observations used in calculating mean daily wind
speed;

- **MXSPD** - Maximum sustained wind speed reported for the day converted to
metres/second to tenths. Missing = NA;

- **GUST** - Maximum wind gust reported for the day converted to metres/second
to tenths. Missing = NA;

- **MAX** - Maximum temperature reported during the day converted to Celsius to
tenths--time of max temp report varies by country and region, so this will
sometimes not be the max for the calendar day. Missing = NA;

- **MAX\_FLAG** - Blank indicates max temp was taken from the explicit max temp
report and not from the 'hourly' data. An "\*" indicates max temp was derived
from the hourly data (i.e., highest hourly or synoptic-reported temperature);

- **MIN** - Minimum temperature reported during the day converted to Celsius to
tenths--time of min temp report varies by country and region, so this will
sometimes not be the max for the calendar day. Missing = NA;

- **MIN\_FLAG** - Blank indicates max temp was taken from the explicit min temp report and not from the 'hourly' data. An "\*" indicates min temp was derived from the hourly data (i.e., highest hourly or synoptic-reported temperature);

- **PRCP** - Total precipitation (rain and/or melted snow) reported during the
day converted to millimetres to hundredths; will usually not end with the
midnight observation, i.e., may include latter part of previous day. A value of
".00" indicates no measurable precipitation (includes a trace). Missing = NA;
*Note: Many stations do not report '0' on days with no precipitation--
therefore, 'NA' will often appear on these days. For example, a station may
only report a 6-hour amount for the period during which rain fell.* See
`FLAGS_PRCP` column for source of data;

- **PRCP\_FLAG** -

    - A = 1 report of 6-hour precipitation amount;

    - B = Summation of 2 reports of 6-hour precipitation amount;

    - C = Summation of 3 reports of 6-hour precipitation amount;

    - D = Summation of 4 reports of 6-hour precipitation amount;

    - E = 1 report of 12-hour precipitation amount;

    - F = Summation of 2 reports of 12-hour precipitation amount;

    - G = 1 report of 24-hour precipitation amount;

    - H = Station reported '0' as the amount for the day (e.g., from 6-hour
    reports), but also reported at least one occurrence of precipitation in
    hourly observations--this could indicate a rrace occurred, but should be
    considered as incomplete data for the day;

    - I = Station did not report any precipitation data for the day and did not
    report any occurrences of precipitation in its hourly observations--it's
    still possible that precipitation occurred but was not reported;

- **SNDP** - Snow depth in millimetres to tenths. Missing = NA;

- **I\_FOG** - Indicator for fog, (1 = yes, 0 = no/not reported) for the
occurrence during the day;

- **I\_RAIN\_DRIZZLE** - Indicator for rain or drizzle, (1 = yes, 0 =
no/not reported) for the occurrence during the day;

- **I\_SNOW\_ICE** - Indicator for snow or ice pellets, (1 = yes, 0 =
no/not reported) for the occurrence during the day;

- **I\_HAIL** - Indicator for hail, (1 = yes, 0 = no/not reported) for the
occurrence during the day;

- **I\_THUNDER** - Indicator for thunder, (1 = yes, 0 = no/not reported) for the
occurrence during the day;

- **I_TORNADO_FUNNEL** - Indicator for tornado or funnel cloud, (1 = yes, 0 =
no/not reported) for the occurrence during the day;

- **ea** - Mean daily actual vapour pressure;

- **es** - Mean daily saturation vapour pressure;

- **RH** - Mean daily relative humidity.

## Appendix 2: Map of GSOD Station Locations

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13-1.png)
