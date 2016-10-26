---
title: 'GSODR: Global Surface Summary Daily Weather Data in R'
tags:
  - Global Surface Summary of the Day
  - GSOD
  - meteorology
  - climatology
  - weather data
  - R
authors:
  - name: Adam H Sparks
    orcid: 0000-0002-0061-8359
    affiliation: 1
  - name: Tomislav Hengl
    orcid: 0000-0002-9921-5129
    affiliation: 2
  - name: Andrew Nelson
    orcid: 0000-0002-7249-3778
    affiliation: 3
affiliations:
  - name: Centre for Crop Health, University of Southern Queensland, Toowoomba Queensland 4350, Australia
    index: 1
  - name: ISRIC - World Soil Information, P.O. Box 353, 6700 AJ Wageningen, The Netherlands
    index: 2
  - name: Faculty of Geo-Information and Earth Observation (ITC), University of Twente, Enschede 7500 AE, The Netherlands
    index: 3
date: "25 October 2016"
bibliography: paper.bib
---

# Summary

The GSODR package [@GSODR] is an R package [@R-base] for automated
downloading, parsing, cleaning and of Global Surface Summary of the
Day (GSOD) [@NCDC] weather data for use in R or saving into Comma Separated
Values (CSV) or Geopackage (GPKG) [@geopackage] files. It builds on or
complements several other scripts and packages. We take advantage of modern
techniques in R to make more efficient use of available computing resources used
to complete the process, e.g., data.table [@data.table], readr [@readr] and
foreach [@foreach], which allow the data cleaning, conversions and disk input/
output processes to take advantage of modern computer hardware. The rnoaa
[@rnoaa] package offers an excellent suite of tools for interacting with and
downloading weather data from the United States National Oceanic and Atmospheric
Administration, but lacks options for GSOD data retrieval. Several other APIs
and R packages exist to access weather data, but most are region or continent
specific, whereas GSOD is global. This package was developed to provide:

  * a function that simplifies downloading GSOD data and formatting it to easily
be used in research; and

  * a function to help identify stations within a given radius of a point of
interest.

A data set of alternative elevation data based on 200 meter buffered elevation
values, derived from the CGIAR-CSI SRTM 90m Database [@Jarvis2008] is included.
These data are useful to help address possible inaccuracies and in many cases,
missing elevation values, in the reported station elevations.

Upon download, stations are individually checked for a user-specified number of
missing days and missing or inaccurate longitude and latitude values, any values
that are missing or incorrect are omitted. Stations files with too many missing
observations are omitted from the final output to help ensure data quality. All
units are converted from the United States Customary System (USCS) to the
International System of Units (SI), e.g., inches to millimetres and Fahrenheit
to Celsius. Wind speed is also converted from knots to metres per second.
Additional useful values, actual vapour pressure, saturated water vapour
pressure, and relative humidity are calculated and included in the final output.
Station data are merged with weather data for the final file which includes the
following fields:

* **STNID** - Station number (WMO/DATSAV3 number) for the location;  

* **WBAN** - number where applicable--this is the historical "Weather
Bureau Air Force Navy" number - with WBAN being the acronym;  

* **STN_NAME** - Unique text identifier;  

* **CTRY** - Country in which the station is located;  

* **LAT** - Latitude. *Station omitted in cases where values are &lt;-90
or &gt;90 degrees or Lat = 0 and Lon = 0*;  

* **LON** - Longitude. *Station omitted in cases where values are &lt;-180
or &gt;180 degrees or Lat = 0 and Lon = 0*;  

* **ELEV_M** - Elevation in metres;  

* **ELEV_M_SRTM_90m** - Elevation in metres corrected for possible errors,
derived from the CGIAR-CSI SRTM 90m database [@Jarvis2008];

* **YEARMODA** - Date in YYYY-mm-dd format;  

* **YEAR** - The year (YYYY);  

* **MONTH** - The month (mm);  

* **DAY** - The day (dd);  

* **YDAY** - Sequential day of year (not in original GSOD);  

* **TEMP** - Mean daily temperature converted to degrees C to tenths.
Missing = -9999;  

* **TEMP_CNT** - Number of observations used in calculating mean daily
temperature;  

* **DEWP** - Mean daily dew point converted to degrees C to tenths. Missing
= -9999;  

* **DEWP_CNT** - Number of observations used in calculating mean daily dew
point;  

* **SLP** - Mean sea level pressure in millibars to tenths. Missing =
-9999;  

* **SLP_CNT** - Number of observations used in calculating mean sea level
pressure;  

* **STP** - Mean station pressure for the day in millibars to tenths.
Missing = -9999;  

* **STP_CNT** - Number of observations used in calculating mean station
pressure;  

* **VISIB** - Mean visibility for the day converted to kilometres to
tenths Missing = -9999;  

* **VISIB_CNT** - Number of observations used in calculating mean daily
visibility;  

* **WDSP** - Mean daily wind speed value converted to metres/second to
tenths Missing = -9999;  

* **WDSP_CNT** - Number of observations used in calculating mean daily
wind speed;  

* **MXSPD** - Maximum sustained wind speed reported for the day converted
to metres/second to tenths. Missing = -9999;  

* **GUST** - Maximum wind gust reported for the day converted to
metres/second to tenths. Missing = -9999;  

* **MAX** - Maximum temperature reported during the day converted to
Celsius to tenths--time of max temp report varies by country and region,
so this will sometimes not be the max for the calendar day. Missing =
-9999;  

* **MAX_FLAG** - Blank indicates max temp was taken from the explicit max
temp report and not from the 'hourly' data. An "\*" indicates max temp was
derived from the hourly data (i.e., highest hourly or synoptic-reported
temperature);  

* **MIN**- Minimum temperature reported during the day converted to
Celsius to tenths--time of min temp report varies by country and region,
so this will sometimes not be the max for the calendar day. Missing =
-9999;  

* **MIN_FLAG** - Blank indicates max temp was taken from the explicit max
temp report and not from the 'hourly' data. An "\*" indicates min temp was
derived from the hourly data (i.e., highest hourly or synoptic-reported
temperature);  

* **PRCP** - Total precipitation (rain and/or melted snow) reported during
the day converted to millimetres to hundredths; will usually not end
with the midnight observation, i.e., may include latter part of previous
day. A value of ".00" indicates no measurable precipitation (includes a trace).
Missing = -9999; *Note: Many stations do not report '0' on days with no
precipitation-- therefore, '-9999' will often appear on these days. For
example, a station may only report a 6-hour amount for the period during
which rain fell.* See FLAGS_PRCP column for source of data;  

* **PRCP_FLAG** -  

    * A = 1 report of 6-hour precipitation amount;  

    * B = Summation of 2 reports of 6-hour precipitation amount;  

    * C = Summation of 3 reports of 6-hour precipitation amount;  

    * D = Summation of 4 reports of 6-hour precipitation amount;  

    * E = 1 report of 12-hour precipitation amount;  

    * F = Summation of 2 reports of 12-hour precipitation amount;  

    * G = 1 report of 24-hour precipitation amount;  

    * H = Station reported '0' as the amount for the day (e.g., from 6-hour
reports), but also reported at least one occurrence of precipitation in
hourly observations--this could indicate a trace occurred, but should be
considered as incomplete data for the day;  

    * I = Station did not report any precip data for the day and did not
report any occurrences of precipitation in its hourly observations--it's
still possible that precipitation occurred but was not reported;  

* **SNDP** - Snow depth in millimetres to tenths. Missing = -9999;  

* **I_FOG** - Indicator for fog, (1 = yes, 0 = no/not reported) for the
occurrence during the day;  

* **I_RAIN_DRIZZLE** - Indicator for rain or drizzle, (1 = yes, 0 = no/not
reported) for the occurrence during the day;  

* **I_SNOW_ICE** - Indicator for snow or ice pellets, (1 = yes, 0 = no/not
reported) for the occurrence during the day;  

* **I_HAIL** - Indicator for hail, (1 = yes, 0 = no/not reported) for the
occurrence during the day;  

* **I_THUNDER** - Indicator for thunder, (1 = yes, 0 = no/not reported)
for the occurrence during the day;  

* **I_TORNADO_FUNNEL** - Indicator for tornado or funnel cloud, (1 = yes, 0 =
no/not reported) for the occurrence during the day;

* **ea** - Mean daily actual vapour pressure;  

* **es** - Mean daily saturation vapour pressure;  

* **RH** - Mean daily relative humidity.

# References

