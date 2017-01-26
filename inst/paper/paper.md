---
title: 'GSODR: Global Summary Daily Weather Data in R'
authors:
- affiliation: 1
  name: Adam H Sparks
  orcid: 0000-0002-0061-8359
- affiliation: 2
  name: Tomislav Hengl
  orcid: 0000-0002-9921-5129
- affiliation: 3
  name: Andrew Nelson
  orcid: 0000-0002-7249-3778
date: "27 January 2017"
output: pdf_document
bibliography: paper.bib
tags:
- Global Surface Summary of the Day
- GSOD
- meteorology
- climatology
- weather data
- R
affiliations:
- index: 1
  name: Centre for Crop Health, University of Southern Queensland, Toowoomba Queensland
    4350, Australia
- index: 2
  name: ISRIC - World Soil Information, P.O. Box 353, 6700 AJ Wageningen, The Netherlands
- index: 3
  name: Faculty of Geo-Information and Earth Observation (ITC), University of Twente,
    Enschede 7500 AE, The Netherlands
---

# Summary

The GSODR package [@GSODR] is an R package [@R-base] providing automated
downloading, parsing and cleaning of Global Surface Summary of the
Day (GSOD) [@NCDC] weather data for use in R or saving as local files in either
a Comma Separated Values (CSV) or GeoPackage (GPKG) [@geopackage] file. It
builds on or complements several other scripts and packages. We take advantage
of modern techniques in R to make more efficient use of available computing
resources to complete the process, e.g., data.table [@data.table], plyr [@plyr]
and readr [@readr], which allow the data cleaning, conversions and disk 
input/output processes to function quickly and efficiently. The rnoaa [@rnoaa]
package already offers an excellent suite of tools for interacting with and
downloading weather data from the United States National Oceanic and 
Atmospheric Administration, but lacks options for GSOD data retrieval. Several
other APIs and R packages exist to access weather data, but most are region or
continent specific, whereas GSOD is global. This package was developed to
provide:

  * two functions that simplify downloading GSOD data and formatting it to
  easily be used in research; and

  * a function to help identify stations within a given radius of a point of
interest.

Alternative elevation data based on a 200 meter buffer of 
elevation values derived from the CGIAR-CSI SRTM 90m Database [@Jarvis2008]
are included. These data are useful to help address possible inaccuracies and
in many cases, fill in for missing elevation values in the reported station
elevations.

When using this package, GSOD stations are checked for inaccurate longitude and
latitude values and any stations that have missing or have incorrect values are
omitted from the final data set. Users may set a threshold for station files
with too many missing observations for omission from the final output to help
ensure data quality. All units are converted from the United States Customary
System (USCS) to the International System of Units (SI), e.g., inches to
millimetres and Fahrenheit to Celsius. Wind speed is also converted from knots
to metres per second. Additional useful values, actual vapour pressure,
saturated water vapour pressure, and relative humidity are calculated and
included in the final output. Station metadata are merged with weather data for
the final data set.

# References
