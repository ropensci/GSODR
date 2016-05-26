#GSODR

[![Travis-CI Build Status](https://travis-ci.org/adamhsparks/GSODR.svg?branch=master)](https://travis-ci.org/adamhsparks/GSODR)
[![Build status](https://ci.appveyor.com/api/projects/status/8daqtllo2sg6me07/branch/master)](https://ci.appveyor.com/project/adamhsparks/GSODR/branch/master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/GSODR?color=brightgreen)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/GSODR)](https://cran.r-project.org/package=GSODR)

An R package that provides a function that automates downloading and cleaning data from the "[Global Surface Summary of the Day (GSOD)](https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod)" data provided by the US National Climatic Data Center (NCDC). Stations are individually checked for number of missing days to assure data quality, stations with too many missing observations are omitted. All units are converted to metric, e.g. feet to metres and Fahrenheit to Celsius. Output is saved as a Comma Separated Value (CSV) file summarizing each year by station, which includes vapor pressure and relative humidity variables calculated from existing data in GSOD.

This package was largely based on Tomislav Hengl's work in "[A Practical Guide to Geostatistical Mapping](http://spatial-analyst.net/book/getGSOD.R)", with updates for speed, cross-platform functionality and some added functionality.

Be sure to have disk space free and allocate the proper time for this to run. This is a time, RAM and disk space intensive process, however it does not require much processing power. 

For more information see the description of the data provided by NCDC, [http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt](http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt).

## To install this package
### Stable release from CRAN
A stable release of GSODR is available on CRAN.

`install.packages("GSODR", dep = TRUE)`

### Development version from GitHub
If you wish to install the development version that may have new features (but also may not work properly), install the devtools package, available from CRAN.

`install.packages("devtools")`

Use `install_github("author/package")` to install this package.

`devtools::install_github("adamhsparks/GSODR")`

## Using get_GSOD()
See `?get_GSOD()` for the help file.

## Function description
This package consists of a single function, `get_GSOD()`, which generates a 
.csv file in the respective year directory containing the following variables:  
**STNID** - Station number (WMO/DATSAV3 number) for the location;  
**WBAN** - number where applicable--this is the historical "Weather Bureau Air
Force Navy" number - with WBAN being the acronym;  
**STATION NAME** - Unique text identifier;  
**CTRY** - Country;  
**LAT** - Latitude. *Station dropped in cases where values are <-90 or >90 degrees or Lat = 0 and Lon = 0*;  
**LON** - Longitude. *Station dropped in cases where values are <-180 or >180 degrees or Lat = 0 and Lon = 0*;  
**ELEV.M** - Elevation converted to metres. *Station dropped where ELEV is NA*;  
**YEARMODA** - Date in YYYY-MM-DD format;  
**YEAR** - The year;  
**MONTH** - The month;  
**DAY** - The day;  
**YDAY** - Sequential day of year (not in original GSOD);  
**TEMP** - Mean daily temperature converted to degrees C to tenths. Missing =
-9999.99;  
**TEMP.COUNT** - Number of observations used in calculating mean daily
temperature;  
**DEWP**-  Mean daily dewpoint converted to degrees C to tenths. Missing =
-9999.99;  
**DEWP.COUNT** - Number of observations used in calculating mean daily dew point;  
**SLP** - Mean sea level pressure in millibars to tenths. Missing = -9999.99;  
**SLP.COUNT** - Number of observations used in calculating mean sea level
pressure;  
**STP** - Mean station pressure for the day in millibars to tenths
Missing = -9999.99;  
**STP.COUNT** - Number of observations used in calculating mean station pressure;  
**VISIB** - Mean visibility for the day converted to kilometers to tenths
Missing = -9999.99;  
**VISIB.COUNT** - Number of observations used in calculating mean daily
visibility;  
**WDSP** - Mean daily wind speed value converted to metres/second to tenths
Missing = -9999.99;  
**WDSP.COUNT** - Number of observations used in calculating mean daily windspeed;  
**MXSPD** - Maximum sustained wind speed reported for the day converted to
metres/second to tenths. Missing = -9999.99;  
**GUST** = Maximum wind gust reported for the day converted to metres/second to
tenths. Missing = -9999.99;  
**MAX** - Maximum temperature reported during the day converted to Celsius to
tenths--time of max temp report varies by country and region, so this will
sometimes not be the max for the calendar day;  
**MAX.FLAG** - Blank indicates max temp was taken from the explicit max
temp report and not from the 'hourly' data.  * indicates max temp was derived
from the hourly data (i.e., highest hourly or synoptic-reported temperature);  
**MIN**- Minimum temperature reported during the day converted to Celsius to
tenths--time of min temp report varies by country and region, so this will
sometimes not be the max for the calendar day;  
**MIN.FLAG** - Blank indicates max temp was taken from the explicit max
temp report and not from the 'hourly' data. * indicates max temp was derived
from the hourly data (i.e., highest hourly or synoptic-reported temperature);  
**PRCP** - Total precipitation (rain and/or melted snow) reported during the day
converted to millimetres to hundredths;   will usually not end with the
midnight observation--i.e., may include latter part of previous day. .00
indicates no measurable precipitation (includes a trace). Missing = -9999.99;
*Note:  Many stations do not report '0' on days with no precipitation--
therefore, '-9999.99' will often appear on these days. For example, a
station may only report a 6-hour amount for the period during which rain
fell.* See FLAGS.PRCP column for source of data;  
**PRCP.FLAG** -  
A = 1 report of 6-hour precipitation amount;  
B = Summation of 2 reports of 6-hour precipitation amount;  
C = Summation of 3 reports of 6-hour precipitation amount;  
D = Summation of 4 reports of 6-hour precipitation amount;  
E = 1 report of 12-hour precipitation amount;  
F = Summation of 2 reports of 12-hour precipitation amount;  
G = 1 report of 24-hour precipitation amount;  
H = Station reported '0' as the amount for the day (eg, from 6-hour reports),
but also reported at least one occurrence of precipitation in hourly
observations--this could indicate a trace occurred, but should be considered
as incomplete data for the day;  
I = Station did not report any precip data for the day and did not report any
occurrences of precipitation in its hourly observations--it's still possible
that precip occurred but was not reported;  
**SNDP** - Snow depth in millimetres to tenths. Missing = -9999.99;  
**I.FOG** - (1 = yes, 0 = no/not reported) for the occurrence during the day;  
**I.RAIN_DRIZZLE** - (1 = yes, 0 = no/not reported) for the occurrence during
the day;  
**I.SNOW_ICE** - (1 = yes, 0 = no/not reported) for the occurrence during
the day;  
**I.HAIL** - (1 = yes, 0 = no/not reported) for the occurrence during the
day;  
**I.THUNDER**  - (1 = yes, 0 = no/not reported) for the occurrence during the
day;  
**I.TORNADO_FUNNEL** - (1 = yes, 0 = no/not reported) for the occurrence during
the day;  

### Values calculated by this package and included in final output:
**ea** - Mean daily actual vapour pressure;  
**es** - Mean daily saturation vapour pressure;  
**RH** - Mean daily relative humidity;  

## Disclaimer
Users of these data should take into account the following (from the NCDC
website): 
> The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification."

## Examples
```r
# Download weather station for Toowoomba, Queensland for 2010, save resulting
# file in the user's Downloads directory.

get_GSOD(years = 2010, station = "955510-99999", path = "~/Downloads")
```

```r
# Download global GSOD data for agroclimatology work for years 2009 and 2010
# and generate yearly summary files, GSOD_2009_XY and GSOD_2010_XY in folders
# named 2009 and 2010 in the user's Downloads directory with a maximum of
# five missing days per weather station allowed.

get_GSOD(years = 2010:2011, path = "~/Downloads", agroclimatology = TRUE)
```

```r
# Download data for Australia for year 2010 and generate a yearly
# summary file, GSOD_2010_XY files in the user's Downloads directory with a
maximum of five missing days per station allowed.

get_GSOD(years = 2010, country = "Australia", path = "~/Downloads")
```
