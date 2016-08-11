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
    affiliation: Centre for Crop Health, University of Southern Queensland, Toowoomba, Queensland, Australia
  - name: Tomislav Hengl
    orcid: 
    affiliation: 
  - name: Andy Nelson
    orcid: 
    affiliation: 
  - name: Kay Sumfleth
    orcid: 
    affiliation: 
date: 11/08/2012
bibliography: paper.bib
---

# Summary

The GSODR package [@GSODR] is an R package [@R-base] for automated
downloading, parsing, cleaning and converting of Global Surface Summary of the
Day (GSOD) [@NCDC] weather data into Comma Separated Values (CSV) or
Geopackage (GPKG) [@geopackage] files. An earlier R script, getGSOD.R, published
in the freely available book, "A Practical Guide to Geostatistical Mapping", 
[@Hengl2009] provides basic functionality on Windows based computers, but lacks
cross-platform support and does not take advantage of modern techniques in R
which improve the computing resources used to complete the process. The rnoaa
[@rnoaa] package offers an excellent suite of tools for interacting with and
downloading weather data from the United States National Oceanic and Atmospheric
Administration but lacks GSOD data retrieval. Several other APIs and R packages
exist to access weather data, but most are region or continent specific, rather
than a global set of data as the GSOD data is. This package was developed to
provide a function that simplifies downloading GSOD data and formatting it to
easily be used in research and a function to help identify stations within a
given radius of a point of interest. To help facilitate speed and provided extra
data, a list which only includes stations with valid latitude and longitide
values is provided with the package. This station list includes a data set of
200 metre buffered elevation values, derived from the CGIAR-CSI SRTM hole-filled
90 metre data set [@Jarvis2008] as well.

Upon download, stations are individually checked for a user-specified number of
missing days. Stations files with too many missing observations are omitted from
the final output to help ensure data quality. All units are converted from
United States Customary System (USCS) to International System of Units (SI),
e.g., inches to millimetres and Fahrenheit to Celsius. Wind speed is also
converted from knots to metres per second. Additional useful variables,
saturation vapor pressure (es), actual vapor pressure (ea) and relative humidity
are calculated from the original data and included in the final data set. Final
output are saved in a user-defined location on a local disk for use in R or
Geographic Information System (GIS) software.

# References

