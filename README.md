
<div style="clear:both"><h1><em>GSODR</em>: Global Surface Summary of the Day ('GSOD') Weather Data Client</h1></div>
<img src="man/figures/logo.png" style="float:right;" alt="logo" width="120" />

<!-- badges: start -->

[![tic](https://github.com/ropensci/GSODR/workflows/tic/badge.svg?branch=main)](https://github.com/ropensci/GSODR/actions)
[![codecov](https://app.codecov.io/gh/ropensci/GSODR/branch/master/graph/badge.svg?token=7KOFeomenq)](https://app.codecov.io/gh/ropensci/GSODR)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.439850.svg)](https://doi.org/10.5281/zenodo.439850) 
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/GSODR)](https://cran.r-project.org/package=GSODR)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) 
[![JOSS](http://joss.theoj.org/papers/10.21105/joss.00177/status.svg)](https://joss.theoj.org/papers/10.21105/joss.00177) 
[![](https://badges.ropensci.org/79_status.svg)](https://github.com/ropensci/software-review/issues/79)

<!-- badges: end -->

--------------------

## Introduction

The GSOD or [Global Surface Summary of the Day (GSOD)](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00516) data provided by the US National Centers for Environmental Information (NCEI) are a valuable source of weather data with global coverage.
_**GSODR**_ aims to make it easy to find, transfer and format the data you need for use in analysis and provides five main functions for facilitating this:

- `get_GSOD()` - this function queries and transfers files from the NCEI's web server, reformats them and returns a data frame.

- `reformat_GSOD()` - this function takes individual station files from the local disk and re-formats them returning a data frame.

- `nearest_stations()` - this function returns a vector of station IDs that fall within the given radius (kilometres) of a point given as latitude and longitude in order from nearest to farthest.

- `update_station_list()` - this function downloads the latest station list from the NCEI's server updates the package's internal database of stations and their metadata.

- `get_inventory()` - this function downloads the latest station inventory information from the NCEI's server and returns the header information about the latest version as a message in the console and a tidy data frame of the stations' inventory for each month that data are reported.

When reformatting data either with `get_GSOD()` or `reformat_GSOD()`, all units are converted to International System of Units (SI), _e.g._, inches to millimetres and Fahrenheit to Celsius.
File output is returned as a `data.table` object, summarising each year by station, which also includes vapour pressure and relative humidity elements calculated from existing data in GSOD.
Additional data are calculated by this R package using the original data and included in the final data.
These include vapour pressure (ea and es) and relative humidity calculated using the improved August-Roche-Magnus approximation (Alduchov and Eskridge 1996).

For more information see the description of the data provided by NCEI, <https://www.ncei.noaa.gov/data/global-summary-of-the-day/doc/readme.txt>.

## How to Install

### Stable Version

A stable version of _GSODR_ is available from [CRAN](https://cran.r-project.org/package=GSODR).

```r
install.packages("GSODR")
```

### Development Version

A development version is available from from GitHub.
If you wish to install the development version that may have new features or bug fixes before the CRAN version does (but also may not work properly), please install the [remotes](https://github.com/r-lib/remotes) package, available from CRAN.
We strive to keep the main branch on GitHub functional and working properly.

```r
if (!require("remotes")) {
  install.packages("remotes", repos = "http://cran.rstudio.com/")
  library("remotes")
}

install_github("ropensci/GSODR")
```

## Other Sources of Weather Data in R

There are several other sources of weather data and ways of retrieving them through R.
Several are also [rOpenSci](https://ropensci.org) projects.

The [_**GSODTools**_](https://github.com/environmentalinformatics-marburg/GSODTools) by [Florian Detsch](https://github.com/fdetsch) is an R package that offers similar functionality as _**GSODR**_, but also has the ability to graph the data and working with data for time series analysis.

The [_**gsod**_](https://github.com/databrew/gsod) package from [DataBrew](https://www.databrew.cc/posts/gsod.html) aims to streamline the way that researchers and data scientists interact with and utilise weather data and relies on _**GSODR**_, but provides data in the package rather than downloading so it is faster (though available data may be out of date).

[_**rnoaa**_](https://CRAN.R-project.org/package=rnoaa), from [rOpenSci](https://docs.ropensci.org/rnoaa/) offers tools for interacting with and downloading weather data from the United States National Oceanic and Atmospheric Administration but lacks support for GSOD data.

[_**stationaRy**_](https://cran.r-project.org/package=stationaRy), from Richard Iannone offers hourly meteorological data from stations located all over the world.
There is a wealth of data available, with historic weather data accessible from nearly 30,000 stations.

[_**riem**_](https://CRAN.R-project.org/package=riem) from [rOpenSci](https://docs.ropensci.org/riem/) allows to get weather data from Automated Surface Observing System (ASOS) stations (airports) in the whole world thanks to the Iowa Environment Mesonet website.

[_**weathercan**_](https://CRAN.R-project.org/package=weathercan) from [rOpenSci](https://github.com/ropensci/weathercan) makes it easier to search for and download multiple months/years of historical weather data from Environment and Climate Change Canada (ECCC) website.

[_**clifro**_](https://CRAN.R-project.org/package=clifro) from [rOpenSci](https://docs.ropensci.org/clifro/) is a web portal to the New Zealand National Climate Database and provides public access (via subscription) to around 6,500 various climate stations (see <https://cliflo.niwa.co.nz/> for more information).
Collating and manipulating data from CliFlo (hence clifro) and importing into R for further analysis, exploration and visualisation is now straightforward and coherent.
The user is required to have an Internet connection, and a current CliFlo subscription (free) if data from stations, other than the public Reefton electronic weather station, is sought.

## Notes

### NOAA policy

Users of these data should take into account the following:

> The data summaries provided here are based on data exchanged under the World Meteorological Organization (WMO) World Weather Watch Program according to WMO Resolution 40 (Cg-XII). This allows WMO member countries to place restrictions on the use or re-export of their data for commercial purposes outside of the receiving country.
Data for selected countries may, at times, not be available through this system.
Those countries' data summaries and products which are available here are intended for free and unrestricted use in research, education, and other non-commercial activities.
However, for non-U.S. locations' data, the data or any derived product shall not be provided to other users or be used for the re-export of commercial services.

## Meta

- Please [report any issues or bugs](https://github.com/ropensci/GSODR/issues).

- License: MIT

- To cite _**GSODR**_, please use: Adam H. Sparks, Tomislav Hengl and Andrew Nelson (2017). GSODR: Global Summary Daily Weather Data in R. _The Journal of Open Source Software_, **2(10)**. DOI: 10.21105/joss.00177.

## Code of Conduct
  
Please note that the GSODR project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.

## References

Alduchov, O.A. and Eskridge, R.E., 1996. Improved Magnus form approximation of saturation vapor pressure. Journal of Applied Meteorology and Climatology, 35(4), pp. 601-609 DOI: 10.1175/1520-0450(1996)035<0601:IMFAOS>2.0.CO;2.
