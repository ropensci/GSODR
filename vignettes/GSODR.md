<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{GSODR}
%\VignetteEncoding{UTF-8}
-->

# Introduction
An R package that provides a function that automates downloading and
cleaning data from the [Global Surface Summary of the Day (GSOD)](https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod)
data provided by the US National Climatic Data Center (NCDC). Stations
are individually checked for number of missing days to assure data
quality, those stations with too many missing observations as defined by the
user are omitted. All units are converted to International System of Units (SI),
e.g., inches to millimetres and Fahrenheit to Celsius. Output is saved as a
Comma Separated Value (CSV) file or in a spatial GeoPackage (GPKG) file,
implemented by most major GIS software, summarising each year by station, which
also includes vapour pressure and relative humidity variables calculated from
existing data in GSOD.

This package was largely based on Tomislav Hengl's work,
[getGSOD.R](http://spatial-analyst.net/book/getGSOD.R)
in "[A Practical Guide to Geostatistical Mapping](http://spatial-analyst.net)",
with updates for speed, cross-platform functionality, and more options for data
retrieval and error correction.

For more information see the description of the data provided by NCDC,
<http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt>.

# Using the package

## Load GSODR

```r
library(GSODR)
```

## Plot Global Station Locations

The `get_GSOD()` function automatically fetches the most recent station data
from the NCDC website and removes stations that are missing data (as shown
below). Using this data we can plot the station locations that are included in
GSOD that provide valid geo-locations after cleaning.

```r
  GSOD_stations <- readr::read_csv(
    "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
    col_types = "ccccccddddd",
    col_names = c("USAF", "WBAN", "STN_NAME", "CTRY", "STATE", "CALL",
                  "LAT", "LON", "ELEV_M", "BEGIN", "END"), skip = 1)

  GSOD_stations[GSOD_stations == -999.9] <- NA
  GSOD_stations[GSOD_stations == -999] <- NA

  GSOD_stations <- GSOD_stations[!is.na(GSOD_stations$LAT) &
                                   !is.na(GSOD_stations$LON), ]
  GSOD_stations <- GSOD_stations[GSOD_stations$LAT != 0 &
                                   GSOD_stations$LON != 0, ]
  GSOD_stations <- GSOD_stations[GSOD_stations$LAT > -90 &
                                   GSOD_stations$LAT < 90, ]
  GSOD_stations <- GSOD_stations[GSOD_stations$LON > -180 &
                                   GSOD_stations$LON < 180, ]
  GSOD_stations$STNID <- as.character(paste(GSOD_stations$USAF,
                                            GSOD_stations$WBAN, sep = "-"))
  
  SRTM_GSOD_elevation <- data.table::setkey(GSODR::SRTM_GSOD_elevation, STNID)
  data.table::setDT(GSOD_stations)
  data.table::setkey(GSOD_stations, STNID)
  GSOD_stations <- GSOD_stations[SRTM_GSOD_elevation, on = "STNID"]
  
  GSOD_stations <- GSOD_stations[!is.na(GSOD_stations$LAT), ]
  GSOD_stations <- GSOD_stations[!is.na(GSOD_stations$LON), ]
```

Using [ggplot2](https://CRAN.R-project.org/package=ggplot2) and the 
[ggalt](https://CRAN.R-project.org/package=ggalt) package it is possible to plot
the station locations using alpha transparency to see the densest part of the
network and use the Robinson projection for the map.

```{r
library(ggplot2)
library(ggalt)

ggplot(GSOD_stations, aes(x = LON, y = LAT)) +
  geom_point(alpha = 0.1) +
  coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs") +
  theme_bw()
```

![GSOD Station Locations](figure/GSOD_station_locations.png)

## Find Stations in Australia

GSODR provides lists of weather station locations and elevation values. Using
[dplyr](https://CRAN.R-project.org/package=dplyr), we can find all the stations
in Australia.
```r
library(dplyr)
station_locations <- left_join(GSOD_stations, GSODR::GSOD_country_list,
                               by = c("CTRY" = "FIPS"))

# create data.frame for Australia only
Oz <- filter(station_locations, COUNTRY_NAME == "AUSTRALIA")
head(Oz)

#>     USAF  WBAN                  STN_NAME CTRY STATE CALL     LAT     LON
#> 1 695023 99999       HORN ISLAND   (HID)   AS  <NA> KQXC -10.583 142.300
#> 2 749430 99999        AIDELAIDE RIVER SE   AS  <NA> <NA> -13.300 131.133
#> 3 749432 99999 BATCHELOR FIELD AUSTRALIA   AS  <NA> <NA> -13.049 131.066
#> 4 749438 99999      IRON RANGE AUSTRALIA   AS  <NA> <NA> -12.700 143.300
#> 5 749439 99999  MAREEBA AS/HOEVETT FIELD   AS  <NA> <NA> -17.050 145.400
#> 6 749440 99999                 REID EAST   AS  <NA> <NA> -19.767 146.850
#>   ELEV_M    BEGIN      END        STNID ELEV_M_SRTM_90m COUNTRY_NAME iso2c
#> 1     NA 19420804 20030816 695023-99999              24    AUSTRALIA    AU
#> 2    131 19430228 19440821 749430-99999              96    AUSTRALIA    AU
#> 3    107 19421231 19430610 749432-99999              83    AUSTRALIA    AU
#> 4     18 19420917 19440930 749438-99999              63    AUSTRALIA    AU
#> 5    443 19420630 19440630 749439-99999             449    AUSTRALIA    AU
#> 6    122 19421012 19430405 749440-99999              75    AUSTRALIA    AU
#>   iso3c
#> 1   AUS
#> 2   AUS
#> 3   AUS
#> 4   AUS
#> 5   AUS
#> 6   AUS

filter(Oz, STN_NAME == "TOOWOOMBA")
#>     USAF  WBAN  STN_NAME CTRY STATE CALL     LAT     LON ELEV_M    BEGIN
#> 1 945510 99999 TOOWOOMBA   AS  <NA> <NA> -27.583 151.933    676 19561231
#>        END        STNID ELEV_M_SRTM_90m COUNTRY_NAME iso2c iso3c
#> 1 20120503 945510-99999             670    AUSTRALIA    AU   AUS
```

## Using the `get_GSOD()` Function in GSODR to Download a Single Station and
Year

Download weather data from the station Toowoomba, Queensland, Australia for 2010
and save it in the user's home directory using the STNID in the `station`
parameter of `get_GSOD()`.

```r
get_GSOD(years = 2010, station = "955510-99999", dsn = "~/",
         filename = "Toowoomba_Airport")
```

## Find Stations Within a Specified Distance of a Point

Using the `nearest_stations()` function, you can find stations closest to a
given point specified by latitude and longitude in decimal degrees. This can be
used to generate a vector to pass along to `get_GSOD()` and download the
stations of interest.

There are missing stations in this query. Not all that are listed and queried
actually have files on the server.

```r
tbar_stations <- nearest_stations(LAT = -27.5598, LON = 151.9507, distance = 50)
tbar_stations <- tbar_stations$STNID

get_GSOD(years = 2010, station = tbar_stations, dsn = "~/",
         filename = "Toowoomba_50km_2010")
```
If you wished to drop the stations, 949999-00170 and 949999-00183 from the
query, you could do this.

```r
remove <- c("949999-00170", "949999-00183")
tbar_stations <- tbar_stations[!tbar_stations %in% remove]

get_GSOD(years = 2010, station = tbar_stations, dsn = "~/",
         filename = "Toowoomba_50km")
```

## Plot Maximum and Miniumum Temperature Values

Using the first data downloaded for a single station, 955510-99999, plot the
temperature for 2010, setting the "-9999" value to NA on import using 
`read_csv()` from Hadley's [readr](https://CRAN.R-project.org/package=readr)
package.

```r
library(lubridate)
library(readr)
library(tidyr)

# Import the data for Toowoomba previously downloaded and cleaned
tbar <- read_csv("~/Toowoomba_Airport-2010.csv", na = "-9999")

#> Parsed with column specification:
#> cols(
#>   .default = col_double(),
#>   USAF = col_integer(),
#>   WBAN = col_integer(),
#>   STNID = col_character(),
#>   STN_NAME = col_character(),
#>   CTRY = col_character(),
#>   STATE = col_character(),
#>   CALL = col_character(),
#>   YEARMODA = col_integer(),
#>   YEAR = col_integer(),
#>   MONTH = col_character(),
#>   DAY = col_character(),
#>   TEMP_CNT = col_integer(),
#>   DEWP_CNT = col_integer(),
#>   SLP_CNT = col_integer(),
#>   STP_CNT = col_integer(),
#>   VISIB_CNT = col_integer(),
#>   WDSP_CNT = col_integer(),
#>   MAX_FLAG = col_character(),
#>   MIN_FLAG = col_character(),
#>   PRCP_FLAG = col_character()
#>   # ... with 6 more columns
#> )
#> See spec(...) for full column specifications.

# Create a dataframe of just the date and temperature values that we want to
# plot
tbar_temps <- tbar[, c(14, 19, 33, 35)]

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
![GSOD Station Locations](figure/Toowoomba_temperature.png)

## Creating spatial files

Because the stations provide geospatial location information, it is possible
to create a spatial file. [GeoPackage files](http://www.geopackage.org) are a
open, standards-based, platform-independent, portable, self-describing compact
format for transferring geospatial information, which handle vector files much
like shapefiles do, but eliminate many of the issues that shapefiles have with
field names and the number of files. The `get_GSOD()` function can create a
GeoPackage file, which can be used with a GIS for further analysis and mapping
with other spatial objects.

After getting weather stations for Australia and creating a GeoPackage file,
the rgdal package can import the data into R and the raster package can download
an outline of Australia useful for plotting the station locations in this
country.

```r
get_GSOD(years = 2015, country = "Australia", dsn = "~/", filename = "AUS",
         CSV = FALSE, GPKG = TRUE)
#> trying URL 'ftp://ftp.ncdc.noaa.gov/pub/data/gsod/2015/gsod_2015.tar'
#> Content type 'unknown' length 106352640 bytes (101.4 MB)
#> ==================================================
#> downloaded 101.4 MB


#> Finished downloading file.
              
#> Parsing the indivdual station files now.


#> Finished parsing files. Writing files to disk now.
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

AUS_stations <- readOGR(dsn = path.expand("~/AUS-2015.gpkg"), layer = "GSOD")
#> OGR data source with driver: GPKG 
#> Source: "/Users/asparks/AUS-2015.gpkg", layer: "GSOD"
#> with 165168 features
#> It has 46 fields

class(AUS_stations)
#> [1] "SpatialPointsDataFrame"
#> attr(,"package")
#> [1] "sp"
```

Since GeoPackage files are formatted as SQLite databases you can use the
existing R tools for SQLite files
[(J. Stachelek 2016)](https://jsta.github.io/2016/07/14/geopackage-r.html).
One easy way is using dplyr, which we've already used to filter the stations.

This option is much faster to load since it does not load the geometry.

```r
AUS_sqlite <- tbl(src_sqlite(path.expand("~/AUS-2015.gpkg")), "GSOD")
class(AUS_sqlite)
#> [1] "tbl_sqlite" "tbl_sql"    "tbl_lazy"   "tbl"       

print(AUS_sqlite, n = 5)
#> Source:   query [?? x 48]
#> Database: sqlite 3.8.6 [/Users/asparks/AUS-2015.gpkg]
#> 
#>     fid       geom   USAF  WBAN        STNID          STN_NAME  CTRY STATE
#>   <int>     <list>  <chr> <chr>        <chr>             <chr> <chr> <chr>
#> 1     1 <raw [29]> 941030 99999 941030-99999 BROWSE ISLAND AWS    AS -9999
#> 2     2 <raw [29]> 941030 99999 941030-99999 BROWSE ISLAND AWS    AS -9999
#> 3     3 <raw [29]> 941030 99999 941030-99999 BROWSE ISLAND AWS    AS -9999
#> 4     4 <raw [29]> 941030 99999 941030-99999 BROWSE ISLAND AWS    AS -9999
#> 5     5 <raw [29]> 941030 99999 941030-99999 BROWSE ISLAND AWS    AS -9999
#> # ... with more rows, and 40 more variables: CALL <chr>, ELEV_M <dbl>,
#> #   ELEV_M_SRTM_90m <dbl>, BEGIN <dbl>, END <dbl>, YEARMODA <chr>,
#> #   YEAR <chr>, MONTH <chr>, DAY <chr>, YDAY <dbl>, TEMP <dbl>,
#> #   TEMP_CNT <int>, DEWP <dbl>, DEWP_CNT <int>, SLP <dbl>, SLP_CNT <int>,
#> #   STP <dbl>, STP_CNT <int>, VISIB <dbl>, VISIB_CNT <int>, WDSP <dbl>,
#> #   WDSP_CNT <int>, MXSPD <dbl>, GUST <dbl>, MAX <dbl>, MAX_FLAG <chr>,
#> #   MIN <dbl>, MIN_FLAG <chr>, PRCP <dbl>, PRCP_FLAG <chr>, SNDP <dbl>,
#> #   I_FOG <int>, I_RAIN_DRIZZLE <int>, I_SNOW_ICE <int>, I_HAIL <int>,
#> #   I_THUNDER <int>, I_TORNADO_FUNNEL <int>, EA <dbl>, ES <dbl>, RH <dbl>

```
# Generating hourly temperature data from daily using the `chillR` package

The [chillR](https://CRAN.R-project.org/package=chillR) package from
[Eike Luedeling](http://eikeluedeling.com/index.html)
has a function, `make_hourly_temps()` that can be used to temporally downscale
daily weather data to hourly using the station's latitude. Here's how that's
possible using the Toowoomba-Airport data.

To use this function it is necessary to rename the MAX, MIN, YEAR and YDAY
columns and convert the `tibble` to a standard `data.frame` object so that
`make_hourly_temps()` will recognize the columns and can operate on the
data.

```r
library(chillR)

# rename columns and convert the object to a standard data.frame
colnames(tbar)[colnames(tbar) == "MAX"] <- "Tmax"
colnames(tbar)[colnames(tbar) == "MIN"] <- "Tmin"
colnames(tbar)[colnames(tbar) == "YEAR"] <- "Year"
colnames(tbar)[colnames(tbar) == "YDAY"] <- "JDay"
tbar <- as.data.frame(tbar)

# generate hourly temperature values
tbar <- make_hourly_temps(tbar[, 8], tbar)

head(tbar)
#>     USAF  WBAN        STNID          STN_NAME CTRY STATE CALL    LAT     LON
#> 1 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 2 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 3 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 4 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 5 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#> 6 955510 99999 955510-99999 TOOWOOMBA AIRPORT   AS  <NA> <NA> -27.55 151.917
#>   ELEV_M ELEV_M_SRTM_90m    BEGIN      END YEARMODA Year MONTH DAY JDay TEMP
#> 1    642             635 19980301 20161012 20100101 2010    01  01    1 21.2
#> 2    642             635 19980301 20161012 20100102 2010    01  02    2 23.2
#> 3    642             635 19980301 20161012 20100103 2010    01  03    3 21.4
#> 4    642             635 19980301 20161012 20100104 2010    01  04    4 18.9
#> 5    642             635 19980301 20161012 20100105 2010    01  05    5 20.5
#> 6    642             635 19980301 20161012 20100106 2010    01  06    6 21.9
#>   TEMP_CNT DEWP DEWP_CNT    SLP SLP_CNT   STP STP_CNT   VISIB VISIB_CNT WDSP
#> 1        8 17.9        8 1013.4       8 942.0       8 -9999.0         0  2.2
#> 2        8 19.4        8 1010.5       8 939.3       8 -9999.0         0  1.9
#> 3        8 18.9        8 1012.3       8 940.9       8    14.3         6  3.9
#> 4        8 16.4        8 1015.7       8 944.1       8    23.3         4  4.5
#> 5        8 16.4        8 1015.5       8 944.0       8 -9999.0         0  3.9
#> 6        8 18.7        8 1013.7       8 942.3       8 -9999.0         0  3.2
#>   WDSP_CNT MXSPD  GUST  Tmax MAX_FLAG  Tmin MIN_FLAG PRCP PRCP_FLAG  SNDP
#> 1        8   6.7 -9999 25.78          17.78           1.5         G -9999
#> 2        8   5.1 -9999 26.50          19.11           0.3         G -9999
#> 3        8  10.3 -9999 28.72          19.28        * 19.8         G -9999
#> 4        8  10.3 -9999 24.11          16.89        *  1.0         G -9999
#> 5        8  10.8 -9999 24.61          16.72           0.3         G -9999
#> 6        8   7.7 -9999 26.78          17.50           0.0         G -9999
#>   I_FOG I_RAIN_DRIZZLE I_SNOW_ICE I_HAIL I_THUNDER I_TORNADO_FUNNEL  EA  ES
#> 1     0              0          0      0         0                0 2.1 2.5
#> 2     0              0          0      0         0                0 2.3 2.8
#> 3     1              1          0      0         0                0 2.2 2.5
#> 4     0              0          0      0         0                0 1.9 2.2
#> 5     0              0          0      0         0                0 1.9 2.4
#> 6     1              0          0      0         0                0 2.2 2.6
#>     RH   Hour_1   Hour_2   Hour_3   Hour_4   Hour_5   Hour_6   Hour_7
#> 1 84.0 19.33310 18.93008 18.58862 18.29238 18.03077 17.79654 19.07710
#> 2 82.1 20.26111 19.96258 19.70963 19.49017 19.29635 19.12280 20.30435
#> 3 88.0 20.65993 20.30230 19.99924 19.73627 19.50402 19.29606 20.80028
#> 4 86.4 19.43190 18.77359 18.21567 17.73153 17.30391 16.92099 18.04830
#> 5 79.2 18.16871 17.79381 17.47604 17.20026 16.95667 16.73853 17.98054
#> 6 84.6 18.79480 18.46000 18.17619 17.92986 17.71226 17.51739 18.97600
#>     Hour_8   Hour_9  Hour_10  Hour_11  Hour_12  Hour_13  Hour_14 Hour_15
#> 1 20.43922 21.71918 22.87744 23.87823 24.69062 25.28952 25.65643   25.78
#> 2 21.56323 22.74626 23.81688 24.74198 25.49295 26.04658 26.38576   26.50
#> 3 22.40926 23.92141 25.28995 26.47253 27.43256 28.14034 28.57395   28.72
#> 4 19.27962 20.43694 21.48442 22.38961 23.12447 23.66627 23.99820   24.11
#> 5 19.32699 20.59262 21.73821 22.72823 23.53201 24.12463 24.48771   24.61
#> 6 20.56074 22.05049 23.39905 24.56455 25.51084 26.20854 26.63602   26.78
#>    Hour_16  Hour_17  Hour_18  Hour_19  Hour_20  Hour_21  Hour_22  Hour_23
#> 1 25.65643 25.28952 24.69062 23.87823 22.87744 22.83846 21.74620 21.09297
#> 2 26.38576 26.04658 25.49295 24.74198 23.81688 23.74516 22.43863 21.65652
#> 3 28.57395 28.14034 27.43256 26.47253 25.28995 25.10619 22.70519 21.26643
#> 4 23.99820 23.66627 23.12447 22.38961 21.48442 21.39624 20.03163 19.21299
#> 5 24.48771 24.12463 23.53201 22.72823 21.73821 21.67330 20.45728 19.72692
#> 6 26.63602 26.20854 25.51084 24.56455 23.39905 23.34622 22.11384 21.37271
#>    Hour_24
#> 1 20.62538
#> 2 21.09647
#> 3 20.23575
#> 4 18.62628
#> 5 19.20322
#> 6 20.84102
```

# Notes

## Elevation Values

90 metre (90m) hole-filled SRTM digital elevation (Jarvis *et al.* 2008) was
used to identify and correct/remove elevation errors in data for station
locations between -60˚ and 60˚ latitude. This applies to cases here
where elevation was missing in the reported values as well. In case the
station reported an elevation and the DEM does not, the station reported
is taken. For stations beyond -60˚ and 60˚ latitude, the values are
station reported values in every instance. See
<https://github.com/adamhsparks/GSODR/blob/devel/data-raw/fetch_isd-history.md>
for more detail on the correction methods.

## WMO Resolution 40. NOAA Policy

*Users of these data should take into account the following (from the
[NCDC website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):*

> "The following data and products may have conditions placed on their 
international commercial use. They can be used within the U.S. or for
non-commercial international activities without restriction. The
non-U.S. data cannot be redistributed for commercial purposes.
Re-distribution of these data by others must provide this same
notification." [WMO Resolution 40. NOAA
Policy](http://www.wmo.int/pages/about/Resolution40.html)

# References
Stachelek, J. 2016. Using the Geopackage Format with R. 
URL: https://jsta.github.io/2016/07/14/geopackage-r.html
