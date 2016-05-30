Fetch, clean and correct altitude in GSOD isd\_history.csv Data
================
Adam H. Sparks - Center for Crop Health, University of Southern Queensland
05-30-2016

Introduction
============

This script will fetch station data from the ftp server and clean up for inclusion in package in /data/stations.rda for the GSODR package.

The following changes are made:

-   Stations where latitude or longitude are NA or both 0 were removed

-   Stations where latitude is &lt; -90˚ or &gt; 90˚ were removed

-   Stations where longitude is &lt; -180˚ or &gt; 180˚ were removed

-   A new field, STNID, a concatenation of the USAF and WBAN fields, was added

-   Stations were checked against FAO-GAUL 2015 data, countries not mapping in the isd-history reported country were dropped

-   90m hole-filled SRTM digital elevation (Jarvis *et al.* 2008) was used to identify and correct/remove elevation errors in dat for station locations between -60˚ and 60˚. *Only for agroclimatology option data*

R Data Processing
=================

Load libraries and set up workspace
-----------------------------------

``` r
library(sp)
library(readr)
library(raster)

dem_tiles <- list.files(path.expand("~/tmp/srtm"), full.names = TRUE)
crs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
cor_stations <- list()
```

Download, reformat and clean station data file from NCDC
--------------------------------------------------------

``` r
# Download data
stations <- read_csv(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
  col_types = "ccccccddddd",
  col_names = c("USAF", "WBAN", "STN.NAME", "CTRY", "STATE", "CALL",
                "LAT", "LON", "ELEV.M", "BEGIN", "END"), skip = 1,
  na = c("-999.9", "-999.0"))

# Clean data
stations <- stations[!is.na(stations$LAT) & !is.na(stations$LON), ]
stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
stations <- stations[stations$LAT > -90 & stations$LAT < 90, ]
stations <- stations[stations$LON > -180 & stations$LON < 180, ]
stations$STNID <- paste(stations$USAF, stations$WBAN, sep = "-")

stations <- as.data.frame(stations) # convert to dataframe object 

# Create spatial object extracting elevation values using spatial points
coordinates(stations) <- ~LON + LAT
proj4string(stations) <- CRS(crs)
```

Loop to check elevation values for inconsistencies
--------------------------------------------------

GSOD data have some inconsistencies in them, some of this has been removed above with filtering. Further filtering is used remove stations reporting locations in countries that do not match the physical coordinates reported. Using [FAO-GAUL (Global Administrative Unit Layers) 2015](http://www.fao.org/geonetwork/srv/en/metadata.show?id=12691), the stations reported countries are checked against the country in which the coordinates map.

Also, reported elevation may differ from actual. Hijmans *et al.* (2005) created their own digital elevation model using Jarvis *et al.* (2004) and [GTOPO30 data](https://lta.cr.usgs.gov/GTOPO30) for areas where there was no SRTM data available (&gt;60˚). Here only the hole-filled SRTM data, V4 (Jarvis *et al.* 2008) was used for correction of agroclimatology data (-60˚ to 60˚). Any incorrect station elevations beyond these values were ignored in this data set.

The hole-filled SRTM data is large enough that it won't all fit in-memory on most desktop computers. Using tiles allows this process to run on a modest machine with minimal effort but does take some time to loop through all of the tiles.

Data can be downloaded from the [CGIAR-CSI's](http://csi.cgiar.org/WhtIsCGIAR_CSI.asp) ftp server, [srtm.csi.cgiar.org](ftp://srtm.csi.cgiar.org), using an FTP client to facilitate this next step.

``` r
for (i in dem_tiles) {

  # Load the DEM tile
  dem <- raster(list.files(paste0(i, "/"), pattern = glob2rx("*.tif"),
                                   full.names = TRUE))
  sub_stations <- crop(stations, dem)
  gI <- extract(dem, sub_stations)

  sub_stations <- as.data.frame(sub_stations)
  sub_stations$ELEV.M.COR <- gI

  # if original elevation == 0 and DEM indicates difference >= 15m, use DEM
  sub_stations[, 13] <- ifelse(sub_stations[, 9] == 0 &
                                 sub_stations[, 13] >= sub_stations[, 9] + 15,
                               sub_stations[, 9],
                               sub_stations[, 13])

  # if original elevation > 0 and DEM indicates difference <= / >= 50m, use DEM
  sub_stations[, 13] <- ifelse(sub_stations[, 9] > 0 &
                                 sub_stations[, 13] >= sub_stations[, 9] + 50 |
                                 sub_stations[, 13] >= sub_stations[, 9] - 50,
                               sub_stations[, 9],
                               sub_stations[, 13])

  # if DEM elevation == NA, use original elevation
  sub_stations[, 13] <- ifelse(is.na(sub_stations[, 13]) &
                                 !is.na(sub_stations[, 9]),
                               sub_stations[, 9], sub_stations[, 13])

  # if original elevation == NA, use DEM elevation
  sub_stations[, 13] <- ifelse(is.na(sub_stations[, 9]) & !is.na(sub_stations[, 13]),
                               sub_stations[, 9], sub_stations[, 13])
  
  cor_stations[[i]] <- sub_stations
  
}
```

Combine list into one dataframe, check and write data to disk
=============================================================

``` r
stations <- data.table::rbindlist(cor_stations)

summary(stations)
```

    ## < table of extent 0 x 0 >

``` r
#devtools::use_data(stations, overwrite = TRUE)
```

Figures and tables
==================

<!-- insert graphs of uncorrected vs corrected elevation? Table of dropped stations? --->
Notes
=====

Users of these data should take into account the following (from the [NCDC website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

> "The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification." [WMO Resolution 40. NOAA Policy](http://www.wmo.int/pages/about/Resolution40.html)

References
==========

Hijmans, RJ, SJ Cameron, JL Parra, PG Jones, A Jarvis, 2005, Very High Resolution Interpolated Climate Surfaces for Global Land Areas. *International Journal of Climatology*. 25: 1965-1978. [DOI:10.1002/joc.1276](http://dx.doi.org/10.1002/joc.1276)

Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m Database (<http://srtm.csi.cgiar.org>)

Jarvis, A, J Rubiano, A Nelson, A Farrow and M Mulligan, 2004, Practical use of SRTM Data in the Tropics: Comparisons with Digital Elevation Models Generated From Cartographic Data. Working Document no. 198. Cali, CO. International Centre for Tropical Agriculture (CIAT): 32.
