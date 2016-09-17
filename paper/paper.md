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
    affiliation: Centre for Crop Health, University of Southern Queensland, Toowoomba Queensland 4350, Australia
  - name: Tomislav Hengl
    orcid: 
    affiliation: 
  - name: Andrew Nelson
    orcid: 0000-0002-7249-3778
    affiliation: Faculty of Geo-Information and Earth Observation (ITC), University of Twente, Enschede 7500 AE, The Netherlands
date: 11/08/2012
bibliography: paper.bib
---

# Summary

The GSODR package [@GSODR] is an R package [@R-base] for automated
downloading, parsing, cleaning and converting of Global Surface Summary of the
Day (GSOD) [@NCDC] weather data into Comma Separated Values (CSV) or
Geopackage (GPKG) [@geopackage] files. . It builds on or complements several
other scripts and packages. An earlier R script, getGSOD.R, published
in the freely available book, "A Practical Guide to Geostatistical Mapping", 
[@Hengl2009] provides basic functionality on Windows platforms, but lacks
cross-platform support and does not take advantage of modern techniques in R
R to make more efficient use of available computing resources used to complete
the process. The rnoaa [@rnoaa] package offers an excellent suite of tools for
interacting with and downloading weather data from the United States National
Oceanic and Atmospheric Administration, but lacks options for GSOD data
retrieval. Several other APIs and R packages exist to access weather data, but
most are region or continent specific, whereas GSOD is global. This package
was developed to provide:
* a function that simplifies downloading GSOD data and formatting it to easily
be used in research; and
* a function to help identify stations within a given radius of a point of
interest.
To help
facilitate speed and provided extra data, a list which only those GSOD stations
with valid latitude and longitude values is provided with the package, with
users having the option of retrieving and using the latest information from NOAA
if this list is out of date. Extra data included is a set of 200 metre buffered
elevation values, derived from the CGIAR-CSI SRTM 90m Database 
[@Jarvis2008] to help address discrepancies in reported elevation for the
stations.

Upon download, stations are individually checked for a user-specified number of
missing days. Stations files with too many missing observations are omitted from
the final output to help ensure data quality. All units are converted from the
United States Customary System (USCS) to the International System of Units (SI),
e.g., inches to millimetres and Fahrenheit to Celsius. Wind speed is also
converted from knots to metres per second. Additional useful variables,
saturation vapour pressure (es), actual vapour pressure (ea) and relative humidity
are calculated from the original data and are included in the final data set.
Final outputs are saved in a user-defined location on a local disk for use in R
or Geographic Information System (GIS) software.

# References

