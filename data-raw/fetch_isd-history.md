Fetch, clean and correct altitude in GSOD isd\_history.csv Data
================
Adam H. Sparks
2017-05-04

Introduction
============

This document details how the GSOD station history data file, ["isd-history.csv"](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv), is fetched from the NCEI ftp server, error checked and new elevation values generated. The new elevation values are then saved for inclusion in package as /data/SRTM\_GSOD\_elevation.rda. The resulting values are merged with the most recent station history data file from the NCEI when the user runs the `get_GSOD()` function. The resulting data frame of station information, based on the merging of the `SRTM_GSOD_elevation` data frame with the most recently available "isd-history.csv" file will result in the following changes to the data:

-   Stations where latitude or longitude are NA or both 0 are removed

-   Stations where latitude is &lt; -90˚ or &gt; 90˚ are removed

-   Stations where longitude is &lt; -180˚ or &gt; 180˚ are removed

-   A new field, STNID, a concatenation of the USAF and WBAN fields, is added

-   Stations are checked against Natural Earth 1:10 ADM0 Cultural data, stations not mapping in the isd-history reported country are dropped

-   90m hole-filled SRTM digital elevation (Jarvis *et al.* 2008) is used to identify and correct/remove elevation errors in data for station locations between -60˚ and 60˚ latitude. This applies to cases here where elevation was missing in the reported values as well. In case the station reported an elevation and the DEM does not, the station reported value is taken. For stations beyond -60˚ and 60˚ latitude, the values are station reported values in every instance for the 90m column.

Data Processing
===============

Set up workspace
----------------

``` r
# check for presence of countrycode package and install if needed
if (!require("countrycode")) {
  install.packages("countrycode")
}
```

    ## Loading required package: countrycode

``` r
if (!require("data.table")) {
  install.packages("data.table")
}
```

    ## Loading required package: data.table

``` r
if (!require("dplyr")) {
  install.packages("dplyr")
}
```

    ## Loading required package: dplyr

    ## -------------------------------------------------------------------------

    ## data.table + dplyr code now lives in dtplyr.
    ## Please library(dtplyr)!

    ## -------------------------------------------------------------------------

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:data.table':
    ## 
    ##     between, first, last

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
if (!require("foreach")) {
  install.packages("foreach")
}
```

    ## Loading required package: foreach

``` r
if (!require("ggplot2")) {
  install.packages("ggplot2")
}
```

    ## Loading required package: ggplot2

``` r
if (!require("parallel")) {
  install.packages("parallel")
}
```

    ## Loading required package: parallel

``` r
if (!require("raster")) {
  install.packages("raster")
}
```

    ## Loading required package: raster

    ## Loading required package: sp

    ## 
    ## Attaching package: 'raster'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     select

    ## The following object is masked from 'package:data.table':
    ## 
    ##     shift

``` r
if (!require("readr")) {
  install.packages("readr")
}
```

    ## Loading required package: readr

``` r
if (!require("rnaturalearth")) {
  install.packages("rnaturalearth")
}
```

    ## Loading required package: rnaturalearth

``` r
dem_tiles <- list.files(path.expand("~/Data/CGIAR-CSI SRTM"), 
                        pattern = glob2rx("*.tif"), full.names = TRUE)
crs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
cor_stations <- list()
tf <- tempfile()
```

Download from Natural Earth and NCEI
------------------------------------

``` r
# import Natural Earth cultural 1:10m data
NE <- rnaturalearth::ne_countries(scale = 10)

# download data
stations <- readr::read_csv(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
  col_types = "ccccccddddd",
  col_names = c("USAF", "WBAN", "STN_NAME", "CTRY", "STATE", "CALL",
                "LAT", "LON", "ELEV_M", "BEGIN", "END"), skip = 1)

stations[stations == -999.9] <- NA
stations[stations == -999] <- NA

countries <- readr::read_table(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt")[-1, c(1, 3)]
```

    ## Parsed with column specification:
    ## cols(
    ##   FIPS = col_character(),
    ##   ID = col_character(),
    ##   `COUNTRY NAME` = col_character()
    ## )

Reformat and clean station data file from NCEI
----------------------------------------------

``` r
# clean data
stations <- stations[!is.na(stations$LAT) & !is.na(stations$LON), ]
stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
stations <- stations[stations$LAT > -90 & stations$LAT < 90, ]
stations <- stations[stations$LON > -180 & stations$LON < 180, ]
stations$STNID <- as.character(paste(stations$USAF, stations$WBAN, sep = "-"))

# join countries with countrycode data
countries <- dplyr::left_join(countries, countrycode::countrycode_data,
                              by = c(FIPS = "fips105"))

# create xy object to check for geographic location agreement with reported
xy <- dplyr::left_join(stations, countries, by = c("CTRY" = "FIPS"))
```

Check data for inconsistencies
------------------------------

GSOD data have some inconsistencies in them, some of this has been removed above with filtering. Further filtering is used remove stations reporting locations in countries that do not match the physical coordinates reported. Using [Natural Earth Data 1:10 Cultural Data](http://www.naturalearthdata.com/downloads/10m-cultural-vectors/), the stations reported countries are checked against the country in which the coordinates map.

Also, reported elevation may differ from actual. Hijmans *et al.* (2005) created their own digital elevation model using Jarvis *et al.* (2004) and [GTOPO30 data](https://lta.cr.usgs.gov/GTOPO30) for areas where there was no SRTM data available (&gt;+/-60˚ latitude). Here only the hole-filled SRTM data, V4 (Jarvis *et al.* 2008) was used for correction of agroclimatology data (-60˚ to 60˚ latitude). Any incorrect station elevations beyond these values were ignored in this data set. Stations with incorrect elevation were identified using `raster::extract(x, y, buffer = 200, fun = mean)` so that surrounding cells are also used to determine the elevation at that point, reducing the chances of over or underestimating in mountainous areas. See Hijmans *et al.* (2005) for more detailed information on this methodology.

The hole-filled SRTM data is large enough that it won't all fit in-memory on most desktop computers. Using tiles allows this process to run on a modest machine with minimal effort but does take some time to loop through all of the tiles.

Data can be downloaded from the [CGIAR-CSI's](http://csi.cgiar.org/WhtIsCGIAR_CSI.asp) ftp server, [srtm.csi.cgiar.org](ftp://srtm.csi.cgiar.org), using an FTP client to facilitate this next step.

``` r
# quality check station locations for reported country and lat/lon position
# agreement

# create spatial object to check for location
xy <- as.data.frame(xy)
sp::coordinates(xy) <- ~ LON + LAT
sp::proj4string(xy) <- sp::CRS(crs)

# check for location in country
point_check <- sp::over(xy, NE)
point_check <- as.data.frame(point_check)
stations_discard <- point_check[point_check$FIPS %in% point_check$FIPS_10_ == FALSE, ]
nrow(stations_discard)
```

    ## [1] 0

Zero observations (rows) in `stations_discard`, the data look good, no need to remove any

``` r
# create a spatial object for extracting elevation values using spatial points
stations <- as.data.frame(stations)
sp::coordinates(stations) <- ~ LON + LAT
sp::proj4string(stations) <- sp::CRS(crs)

# set up cluster for parallel processing
library(foreach)
cl <- parallel::makeCluster(parallel::detectCores())
doParallel::registerDoParallel(cl)

corrected_elev <- tibble::as_tibble(
  data.table::rbindlist(foreach(i = dem_tiles) %dopar% {
    
    # Load the DEM tile
    dem <- raster::raster(i)
    sub_stations <- raster::crop(stations, dem)
    
    # in some cases the DEM represents areas where there is no station
    # check for that here and if no stations, go on to next iteration
    if (!is.null(sub_stations)) {
      
      # use a 200m buffer to extract elevation from the DEM
      sub_stations$ELEV_M_SRTM_90m <- raster::extract(dem, sub_stations,
                                                      buffer = 200,
                                                      fun = mean)
      
      # convert spatial object back to normal data frame and add new fields
      sub_stations <- as.data.frame(sub_stations)
      return(sub_stations)
    }
  }
  )
)
# stop cluster
parallel::stopCluster(cl)
```

Some stations occur in areas where DEM has no data, in this case, use original station elevation for these stations.

``` r
corrected_elev <- dplyr::mutate(corrected_elev,
                                ELEV_M_SRTM_90m = ifelse(is.na(ELEV_M_SRTM_90m),
                                                ELEV_M, ELEV_M_SRTM_90m))
# round SRTM_90m_Buffer field to whole number in cases where station reported
# data was used and rename column
corrected_elev[, 13] <- round(corrected_elev[, 13], 0)
```

Tidy up the `corrected_elev` object by converting any factors to character prior to performing a left-join with the `stations` object. For stations above/below 60/-60 latitude, `ELEV_M_SRTM_90m` will be `NA` as there is no SRTM data for these latitudes.

``` r
c <- sapply(corrected_elev, is.factor)
corrected_elev[c] <- lapply(corrected_elev[c], as.character)

# convert stations from a spatial object to a tibble for joining
stations <- tibble::as_tibble(stations)

# Perform left join to join corrected elevation with original station data,
# this will include stations below/above -60/60
isd_history <- dplyr::left_join(stations, corrected_elev)
```

    ## Joining, by = c("USAF", "WBAN", "STN_NAME", "CTRY", "STATE", "CALL", "LAT", "LON", "ELEV_M", "BEGIN", "END", "STNID")

``` r
summary(isd_history)
```

    ##      USAF               WBAN             STN_NAME        
    ##  Length:28347       Length:28347       Length:28347      
    ##  Class :character   Class :character   Class :character  
    ##  Mode  :character   Mode  :character   Mode  :character  
    ##                                                          
    ##                                                          
    ##                                                          
    ##                                                          
    ##      CTRY              STATE               CALL                LAT        
    ##  Length:28347       Length:28347       Length:28347       Min.   :-89.00  
    ##  Class :character   Class :character   Class :character   1st Qu.: 22.48  
    ##  Mode  :character   Mode  :character   Mode  :character   Median : 39.25  
    ##                                                           Mean   : 31.14  
    ##                                                           3rd Qu.: 49.85  
    ##                                                           Max.   : 89.37  
    ##                                                                           
    ##       LON               ELEV_M           BEGIN               END          
    ##  Min.   :-179.983   Min.   :-350.0   Min.   :19010101   Min.   :19051231  
    ##  1st Qu.: -83.316   1st Qu.:  23.0   1st Qu.:19570701   1st Qu.:20020423  
    ##  Median :   6.667   Median : 140.0   Median :19760305   Median :20160429  
    ##  Mean   :  -3.509   Mean   : 360.9   Mean   :19782661   Mean   :20048002  
    ##  3rd Qu.:  61.733   3rd Qu.: 435.0   3rd Qu.:20020419   3rd Qu.:20170501  
    ##  Max.   : 179.750   Max.   :5304.0   Max.   :20170428   Max.   :20170503  
    ##                     NA's   :219                                           
    ##     STNID           ELEV_M_SRTM_90m
    ##  Length:28347       Min.   :-361   
    ##  Class :character   1st Qu.:  25   
    ##  Mode  :character   Median : 156   
    ##                     Mean   : 380   
    ##                     3rd Qu.: 462   
    ##                     Max.   :5273   
    ##                     NA's   :3013

Figures
=======

``` r
ggplot(data = isd_history, aes(x = ELEV_M, y = ELEV_M_SRTM_90m)) +
  geom_point(alpha = 0.4, size = 0.5)
```

![GSOD Reported Elevation versus CGIAR-CSI SRTM Buffered Elevation](fetch_isd-history_files/figure-markdown_github/Buffered%20SRTM%2090m%20vs%20Reported%20Elevation-1.png)

Buffered versus non-buffered elevation values were previously checked and found not to be different while also not showing any discernible geographic patterns. However, The buffered elevation data are higher than the non-buffered data. To help avoid within cell and between cell variation the buffered values are the values that are included in the final data for distribution with the GSODR package following the approach of Hijmans *et al.* (2005).

Only values for elevation derived from the SRTM data and the STNID, used to join this with the original "isd-history.csv" file data when running `get_GSOD()` are included in the final data frame for distribution with the GSODR package.

``` r
# write rda file to disk for use with GSODR package
devtools::use_data(isd_history, overwrite = TRUE, compress = "bzip2")

# clean up Natural Earth data files before we leave
file.remove(list.files(pattern = glob2rx("ne_10m_admin_0_countries*")))
```

    ## logical(0)

The SRTM\_GSOD\_elevation.rda file included in the GSODR package includes the new elevation data as the field; ELEV\_M\_SRTM\_90m.

Notes
=====

NOAA Policy
-----------

Users of these data should take into account the following (from the [NCEI website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

> "The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification." [WMO Resolution 40. NOAA Policy](http://www.wmo.int/pages/about/Resolution40.html)

R System Information
--------------------

    ## Session info --------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.4.0 (2017-04-21)
    ##  system   x86_64, darwin15.6.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-05-04

    ## Packages ------------------------------------------------------------------

    ##  package            * version date       source        
    ##  assertthat           0.2.0   2017-04-11 CRAN (R 3.4.0)
    ##  backports            1.0.5   2017-01-18 CRAN (R 3.4.0)
    ##  codetools            0.2-15  2016-10-05 CRAN (R 3.4.0)
    ##  colorspace           1.3-2   2016-12-14 CRAN (R 3.4.0)
    ##  countrycode        * 0.19    2017-02-06 CRAN (R 3.4.0)
    ##  curl                 2.6     2017-04-27 cran (@2.6)   
    ##  data.table         * 1.10.4  2017-02-01 CRAN (R 3.4.0)
    ##  DBI                  0.6-1   2017-04-01 CRAN (R 3.4.0)
    ##  devtools             1.12.0  2016-12-05 CRAN (R 3.4.0)
    ##  digest               0.6.12  2017-01-27 CRAN (R 3.4.0)
    ##  doParallel           1.0.10  2015-10-14 CRAN (R 3.4.0)
    ##  dplyr              * 0.5.0   2016-06-24 CRAN (R 3.4.0)
    ##  evaluate             0.10    2016-10-11 CRAN (R 3.4.0)
    ##  foreach            * 1.4.3   2015-10-13 CRAN (R 3.4.0)
    ##  ggplot2            * 2.2.1   2016-12-30 CRAN (R 3.4.0)
    ##  gtable               0.2.0   2016-02-26 CRAN (R 3.4.0)
    ##  highr                0.6     2016-05-09 CRAN (R 3.4.0)
    ##  hms                  0.3     2016-11-22 CRAN (R 3.4.0)
    ##  htmltools            0.3.6   2017-04-28 cran (@0.3.6) 
    ##  iterators            1.0.8   2015-10-13 CRAN (R 3.4.0)
    ##  knitr                1.15.1  2016-11-22 CRAN (R 3.4.0)
    ##  labeling             0.3     2014-08-23 CRAN (R 3.4.0)
    ##  lattice              0.20-35 2017-03-25 CRAN (R 3.4.0)
    ##  lazyeval             0.2.0   2016-06-12 CRAN (R 3.4.0)
    ##  magrittr             1.5     2014-11-22 CRAN (R 3.4.0)
    ##  memoise              1.1.0   2017-04-21 CRAN (R 3.4.0)
    ##  munsell              0.4.3   2016-02-13 CRAN (R 3.4.0)
    ##  plyr                 1.8.4   2016-06-08 CRAN (R 3.4.0)
    ##  R6                   2.2.0   2016-10-05 CRAN (R 3.4.0)
    ##  raster             * 2.5-8   2016-06-02 CRAN (R 3.4.0)
    ##  Rcpp                 0.12.10 2017-03-19 CRAN (R 3.4.0)
    ##  readr              * 1.1.0   2017-03-22 CRAN (R 3.4.0)
    ##  rgdal                1.2-7   2017-04-25 cran (@1.2-7) 
    ##  rmarkdown            1.5     2017-04-26 cran (@1.5)   
    ##  rnaturalearth      * 0.1.0   2017-03-21 CRAN (R 3.4.0)
    ##  rnaturalearthhires   0.1.0   2017-05-04 local         
    ##  rprojroot            1.2     2017-01-16 CRAN (R 3.4.0)
    ##  scales               0.4.1   2016-11-09 CRAN (R 3.4.0)
    ##  sf                   0.4-1   2017-03-28 CRAN (R 3.4.0)
    ##  sp                 * 1.2-4   2016-12-22 CRAN (R 3.4.0)
    ##  stringi              1.1.5   2017-04-07 CRAN (R 3.4.0)
    ##  stringr              1.2.0   2017-02-18 CRAN (R 3.4.0)
    ##  tibble               1.3.0   2017-04-01 CRAN (R 3.4.0)
    ##  udunits2             0.13    2016-11-17 CRAN (R 3.4.0)
    ##  units                0.4-4   2017-04-20 CRAN (R 3.4.0)
    ##  withr                1.0.2   2016-06-20 CRAN (R 3.4.0)
    ##  yaml                 2.1.14  2016-11-12 CRAN (R 3.4.0)

References
==========

Hijmans, RJ, SJ Cameron, JL Parra, PG Jones, A Jarvis, 2005, Very High Resolution Interpolated Climate Surfaces for Global Land Areas. *International Journal of Climatology*. 25: 1965-1978. [DOI:10.1002/joc.1276](http://dx.doi.org/10.1002/joc.1276)

Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m Database (<http://srtm.csi.cgiar.org>)

Jarvis, A, J Rubiano, A Nelson, A Farrow and M Mulligan, 2004, Practical use of SRTM Data in the Tropics: Comparisons with Digital Elevation Models Generated From Cartographic Data. Working Document no. 198. Cali, CO. International Centre for Tropical Agriculture (CIAT): 32. [URL](http://srtm.csi.cgiar.org/PDF/Jarvis4.pdf)
