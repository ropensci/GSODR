GSODR
================

[![Travis-CI Build
Status](https://travis-ci.org/adamhsparks/GSODR.svg?branch=master)](https://travis-ci.org/adamhsparks/GSODR)
[![Build
status](https://ci.appveyor.com/api/projects/status/8daqtllo2sg6me07/branch/master?svg=true)](https://ci.appveyor.com/project/adamhsparks/GSODR/branch/master?svg=true)
[![rstudio mirror
downloads](http://cranlogs.r-pkg.org/badges/GSODR?color=brightgreen)](https://github.com/metacran/cranlogs.app)
[![cran
version](http://www.r-pkg.org/badges/version/GSODR)](https://cran.r-project.org/package=GSODR)

An R package that provides a function that automates downloading and
cleaning data from the "[Global Surface Summary of the Day
(GSOD)](https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod)"
data provided by the US National Climatic Data Center (NCDC). Stations
are individually checked for number of missing days to assure data
quality, stations with too many missing observations are omitted. All
units are converted to metric, e.g., inches to milimetres and Fahrenheit to
Celsius. Output is saved as a Comma Separated Value (CSV) file or ESRI
format shapefile summarizing each year by station, which includes vapor
pressure and relative humidity variables calculated from existing data
in GSOD.

This package was largely based on Tomislav Hengl's work in "[A Practical
Guide to Geostatistical
Mapping](http://spatial-analyst.net/book/getGSOD.R)", with updates for
speed, cross-platform functionality, and more options for data
retrieval and error correction.

Be sure to have disk space free and allocate the proper time for this to
run. This is a time, RAM and disk space intensive process. For any query
of GSOD data other than a single station, the process runs in parallel
to clean and reformat the data.

For more information see the description of the data provided by NCDC,
<http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt>.

To install this package
-----------------------

### Stable release from CRAN

A stable release of GSODR is available on CRAN.

``` r
install.packages("GSODR", dependencies = TRUE)
```

### Development version from GitHub

If you wish to install the development version that may have new
features (but also may not work properly), install the devtools package,
available from CRAN.

``` r
install.packages("devtools", dependencies = TRUE)
devtools::install_github("adamhsparks/GSODR")
```

Output
======

This package consists of a single function, `get_GSOD()`, which generates
a .csv file or ESRI format shapefile in the respective year directory
containing the following variables:  
**STNID** - Station number (WMO/DATSAV3 number) for the location;  
**WBAN** - number where applicable--this is the historical "Weather
Bureau Air Force Navy" number - with WBAN being the acronym;  
**STN.NAME** - Unique text identifier;  
**CTRY** - Country;  
**LAT** - Latitude. *Station dropped in cases where values are &lt;-90
or &gt;90 degrees or Lat = 0 and Lon = 0*;  
**LON** - Longitude. *Station dropped in cases where values are &lt;-180
or &gt;180 degrees or Lat = 0 and Lon = 0*;  
**ELEV.M** - Elevation converted to metres.  
**ELEV.M.SRTM.90m** - Elevation in metres corrected for possible errors,
see Notes for more;  
**YEARMODA** - Date in YYYY-MM-DD format;  
**YEAR** - The year;  
**MONTH** - The month;  
**DAY** - The day;  
**YDAY** - Sequential day of year (not in original GSOD);  
**TEMP** - Mean daily temperature converted to degrees C to tenths.
Missing = -9999;  
**TEMP.CNT** - Number of observations used in calculating mean daily
temperature;  
**DEWP**- Mean daily dewpoint converted to degrees C to tenths. Missing
= -9999;  
**DEWP.CNT** - Number of observations used in calculating mean daily dew
point;  
**SLP** - Mean sea level pressure in millibars to tenths. Missing =
-9999;  
**SLP.CNT** - Number of observations used in calculating mean sea level
pressure;  
**STP** - Mean station pressure for the day in millibars to tenths.
Missing = -9999;  
**STP.CNT** - Number of observations used in calculating mean station
pressure;  
**VISIB** - Mean visibility for the day converted to kilometers to
tenths Missing = -9999;  
**VISIB.CNT** - Number of observations used in calculating mean daily
visibility;  
**WDSP** - Mean daily wind speed value converted to metres/second to
tenths Missing = -9999;  
**WDSP.CNT** - Number of observations used in calculating mean daily
windspeed;  
**MXSPD** - Maximum sustained wind speed reported for the day converted
to metres/second to tenths. Missing = -9999;  
**GUST** - Maximum wind gust reported for the day converted to
metres/second to tenths. Missing = -9999;  
**MAX** - Maximum temperature reported during the day converted to
Celsius to tenths--time of max temp report varies by country and region,
so this will sometimes not be the max for the calendar day. Missing =
-9999;  
**MAX.FLAG** - Blank indicates max temp was taken from the explicit max
temp report and not from the 'hourly' data. \* indicates max temp was
derived from the hourly data (i.e., highest hourly or synoptic-reported
temperature);  
**MIN**- Minimum temperature reported during the day converted to
Celsius to tenths--time of min temp report varies by country and region,
so this will sometimes not be the max for the calendar day. Missing =
-9999; ;  
**MIN.FLAG** - Blank indicates max temp was taken from the explicit max
temp report and not from the 'hourly' data. \* indicates max temp was
derived from the hourly data (i.e., highest hourly or synoptic-reported
temperature);  
**PRCP** - Total precipitation (rain and/or melted snow) reported during
the day converted to millimetres to hundredths; will usually not end
with the midnight observation--i.e., may include latter part of previous
day. .00 indicates no measurable precipitation (includes a trace).
Missing = -9999; *Note: Many stations do not report '0' on days with no
precipitation-- therefore, '-9999' will often appear on these days. For
example, a station may only report a 6-hour amount for the period during
which rain fell.* See FLAGS.PRCP column for source of data;  
**PRCP.FLAG** -  
A = 1 report of 6-hour precipitation amount;  
B = Summation of 2 reports of 6-hour precipitation amount;  
C = Summation of 3 reports of 6-hour precipitation amount;  
D = Summation of 4 reports of 6-hour precipitation amount;  
E = 1 report of 12-hour precipitation amount;  
F = Summation of 2 reports of 12-hour precipitation amount;  
G = 1 report of 24-hour precipitation amount;  
H = Station reported '0' as the amount for the day (eg., from 6-hour
reports), but also reported at least one occurrence of precipitation in
hourly observations--this could indicate a trace occurred, but should be
considered as incomplete data for the day;  
I = Station did not report any precip data for the day and did not
report any occurrences of precipitation in its hourly observations--it's
still possible that precip occurred but was not reported;  
**SNDP** - Snow depth in millimetres to tenths. Missing = -9999;  
**I.FOG** - Indicator for fog, (1 = yes, 0 = no/not reported) for the
occurrence during the day;  
**I.RAIN\_DZL** - Indicator for rain or drizzle, (1 = yes, 0 = no/not
reported) for the occurrence during the day;  
**I.SNW\_ICE** - Indicator for snow or ice pellets, (1 = yes, 0 = no/not
reported) for the occurrence during the day;  
**I.HAIL** - Indicator for hail, (1 = yes, 0 = no/not reported) for the
occurrence during the day;  
**I.THUNDER** - Indicator for thunder, (1 = yes, 0 = no/not reported)
for the occurrence during the day;  
**I.TDO\_FNL** - Indicator for tornado or funnel cloud, (1 = yes, 0 =
no/not reported) for the occurrence during the day;

### Values calculated by this package and included in final output:

**ea** - Mean daily actual vapour pressure;  
**es** - Mean daily saturation vapour pressure;  
**RH** - Mean daily relative humidity;

Notes
-----

### Elevation Values

90m hole-filled SRTM digital elevation (Jarvis *et al.* 2008) was used
to identify and correct/remove elevation errors in data for station
locations between -60˚ and 60˚ latitude. This applies to cases here
where elevation was missing in the reported values as well. In case the
station reported an elevation and the DEM does not, the station reported
is taken. For stations beyond -60˚ and 60˚latitude, the values are
station reported values in every instance. See
<https://github.com/adamhsparks/GSODR/blob/devel/data-raw/fetch_isd-history.md>
for more detail on the correction methods.

### WMO Resolution 40. NOAA Policy

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

Examples
--------
``` r
# Download weather station for Toowoomba, Queensland for 2010, save resulting
# file, GSOD-955510-99999-2010.csv, in the user's home directory.

get_GSOD(years = 2010, station = "955510-99999", path = "~/")


# Download global GSOD data for agroclimatology work for years 2009 and 2010
# and generate yearly summary files, GSOD-agroclimatology-2010.csv and
# GSOD-agroclimatology-2011.csv, in the user's home directory with a maximum
# of five missing days per weather station allowed.

get_GSOD(years = 2010:2011, path = "~/", agroclimatology = TRUE)


# Download data for Philippines for year 2010 and generate a yearly
# summary file, GSOD-PHL-2010.csv, file in the user's home directory with a
# maximum of five missing days per station allowed.

get_GSOD(years = 2010, country = "Philippines", path = "~/")
```

References
==========

Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled SRTM for
the globe Version 4, available from the CGIAR-CSI SRTM 90m Database
(<http://srtm.csi.cgiar.org>)
