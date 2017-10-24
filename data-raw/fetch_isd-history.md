Fetch, clean and correct altitude in GSOD isd\_history.csv data
================
Adam H. Sparks
2017-10-24

Introduction
============

This document details how the GSOD station history data file, ["isd-history.csv"](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv), is fetched from the NCEI ftp server, error checked and new elevation values generated. The new elevation values are then saved for inclusion in package as /extdata/SRTM\_GSOD\_elevation.rda. The resulting values are merged with the most recent station history data file from the NCEI when the user runs the `get_GSOD()` function. The resulting data frame of station information, based on the merging of the `SRTM_GSOD_elevation` data frame with the most recently available "isd-history.csv" file will result in the following changes to the data:

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
  install.packages("countrycode", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: countrycode

``` r
if (!require("dplyr")) {
  install.packages("dplyr", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: dplyr

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
if (!require("foreach")) {
  install.packages("foreach", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: foreach

``` r
if (!require("ggplot2")) {
  install.packages("ggplot2", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: ggplot2

``` r
if (!require("parallel")) {
  install.packages("parallel", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: parallel

``` r
if (!require("raster")) {
  install.packages("raster", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: raster

    ## Loading required package: sp

    ## 
    ## Attaching package: 'raster'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     select

``` r
if (!require("readr")) {
  install.packages("readr", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: readr

``` r
if (!require("rnaturalearth")) {
  install.packages("rnaturalearth", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: rnaturalearth

``` r
library(magrittr) # comes with dplyr above
```

    ## 
    ## Attaching package: 'magrittr'

    ## The following object is masked from 'package:raster':
    ## 
    ##     extract

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
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt",
  col_types = "ccc",
  col_names = c("FIPS", "ID", "`COUNTRY NAME`"),
)[-1, c(1, 3)]
```

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

### Check for country of station location

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

### Elevation data supplement

Next use the `raster::extract()` function to get the mean elevation data from the 90m elevation data and supplement the elevation data from the NCEI.

``` r
# create a spatial object for extracting elevation values using spatial points
stations <- as.data.frame(stations)
sp::coordinates(stations) <- ~ LON + LAT
sp::proj4string(stations) <- sp::CRS(crs)

# set up cluster for parallel processing
library(foreach)
cl <- parallel::makeCluster(parallel::detectCores())
doParallel::registerDoParallel(cl)

corrected_elev <- dplyr::bind_rows(
foreach(i = dem_tiles, .packages = "magrittr") %dopar% {
# Load the DEM tile
dem <- raster::raster(i)
sub_stations <- raster::crop(stations, dem)

# in some cases the DEM represents areas where there is no station
# check for that here and if no stations, go on to next iteration
if (!is.null(sub_stations)) {
# use a 200m buffer to extract elevation from the DEM

  sub_stations$ELEV_M_SRTM_90m <- 
  raster::extract(dem, sub_stations,
                  buffer = 200,
                  fun = mean)
  
# convert spatial object back to normal data frame and add new fields
sub_stations <- as.data.frame(sub_stations)

# set any factors back to character
sub_stations <- sub_stations %>%
  dplyr::mutate_if(is.factor, as.character)

return(sub_stations)
    }
  }
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

# retain only distinct rows in case of duplicate data

corrected_elev <- corrected_elev %>%
  dplyr::distinct(corrected_elev)
```

Tidy up the `corrected_elev` object by converting any factors to character prior to performing a left-join with the `stations` object and remove duplicate rows. For stations above/below 60/-60 latitude, `ELEV_M_SRTM_90m` will be `NA` as there is no SRTM data for these latitudes.

``` r
# convert any factors in stations object to character for left_join
stations <- dplyr::mutate_if(as.data.frame(stations), is.factor, as.character)

# Perform left join to join corrected elevation with original station data,
# this will include stations below/above -60/60
isd_history <- 
  dplyr::left_join(stations, corrected_elev) %>% 
  tibble::as_tibble()
```

    ## Joining, by = c("USAF", "WBAN", "STN_NAME", "CTRY", "STATE", "CALL", "LAT", "LON", "ELEV_M", "BEGIN", "END", "STNID")

``` r
str(isd_history)
```

    ## Classes 'tbl_df', 'tbl' and 'data.frame':    28455 obs. of  13 variables:
    ##  $ USAF           : chr  "008268" "010010" "010014" "010015" ...
    ##  $ WBAN           : chr  "99999" "99999" "99999" "99999" ...
    ##  $ STN_NAME       : chr  "WXPOD8278" "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN" "BRINGELAND" ...
    ##  $ CTRY           : chr  "AF" "NO" "NO" "NO" ...
    ##  $ STATE          : chr  NA NA NA NA ...
    ##  $ CALL           : chr  NA "ENJA" "ENSO" NA ...
    ##  $ LAT            : num  33 70.9 59.8 61.4 64.8 ...
    ##  $ LON            : num  65.57 -8.67 5.34 5.87 11.23 ...
    ##  $ ELEV_M         : num  1156.7 9 48.8 327 14 ...
    ##  $ BEGIN          : num  20120301 19310101 19861120 19870117 19870116 ...
    ##  $ END            : num  20120323 20171019 20171019 20111020 19910806 ...
    ##  $ STNID          : chr  "008268-99999" "010010-99999" "010014-99999" "010015-99999" ...
    ##  $ ELEV_M_SRTM_90m: num  1160 NA 48 NA NA 48 NA NA NA NA ...

``` r
isd_history
```

    ## # A tibble: 28,455 x 13
    ##      USAF  WBAN            STN_NAME  CTRY STATE  CALL    LAT    LON ELEV_M
    ##     <chr> <chr>               <chr> <chr> <chr> <chr>  <dbl>  <dbl>  <dbl>
    ##  1 008268 99999           WXPOD8278    AF  <NA>  <NA> 32.950 65.567 1156.7
    ##  2 010010 99999 JAN MAYEN(NOR-NAVY)    NO  <NA>  ENJA 70.933 -8.667    9.0
    ##  3 010014 99999          SORSTOKKEN    NO  <NA>  ENSO 59.792  5.341   48.8
    ##  4 010015 99999          BRINGELAND    NO  <NA>  <NA> 61.383  5.867  327.0
    ##  5 010016 99999         RORVIK/RYUM    NO  <NA>  <NA> 64.850 11.233   14.0
    ##  6 010017 99999               FRIGG    NO  <NA>  ENFR 59.980  2.250   48.0
    ##  7 010020 99999       VERLEGENHUKEN    NO  <NA>  <NA> 80.050 16.250    8.0
    ##  8 010030 99999            HORNSUND    NO  <NA>  <NA> 77.000 15.500   12.0
    ##  9 010040 99999       NY-ALESUND II    NO  <NA>  ENAS 78.917 11.933    8.0
    ## 10 010050 99999       ISFJORD RADIO    SV  <NA>  <NA> 78.067 13.633    9.0
    ## # ... with 28,445 more rows, and 4 more variables: BEGIN <dbl>, END <dbl>,
    ## #   STNID <chr>, ELEV_M_SRTM_90m <dbl>

Figures
=======

``` r
ggplot(data = isd_history, aes(x = ELEV_M, y = ELEV_M_SRTM_90m)) +
  geom_point(alpha = 0.4, size = 0.5) +
  geom_abline(slope = 1, colour = "white")
```

![GSOD Reported Elevation versus CGIAR-CSI SRTM Buffered Elevation](fetch_isd-history_files/figure-markdown_github-ascii_identifiers/Buffered%20SRTM%2090m%20vs%20Reported%20Elevation-1.png)

Buffered versus non-buffered elevation values were previously checked and found not to be different while also not showing any discernible geographic patterns. However, The buffered elevation data are higher than the non-buffered data. To help avoid within cell and between cell variation the buffered values are the values that are included in the final data for distribution with the GSODR package following the approach of Hijmans *et al.* (2005).

The final dataframe for distribution with *GSODR* includes the new elevation values along with the cleaned "isd-history.csv" data.

``` r
# write rda file to disk for use with GSODR package
save(isd_history, file = "../inst/extdata/isd_history.rda",
     compress = "bzip2")
```

The `isd_history.rda` file is bundled in the GSODR package and includes the new elevation data as the field; ELEV\_M\_SRTM\_90m.

Notes
=====

NOAA Policy
-----------

Users of these data should take into account the following (from the [NCEI website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

> "The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification." [WMO Resolution 40. NOAA Policy](http://www.wmo.int/pages/about/Resolution40.html)

R System Information
--------------------

    ## Session info -------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.4.2 (2017-09-28)
    ##  system   x86_64, darwin16.7.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-10-24

    ## Packages -----------------------------------------------------------------

    ##  package            * version    date      
    ##  assertthat           0.2.0      2017-04-11
    ##  backports            1.1.1      2017-09-25
    ##  base               * 3.4.2      2017-10-03
    ##  bindr                0.1        2016-11-13
    ##  bindrcpp           * 0.2        2017-06-17
    ##  codetools            0.2-15     2016-10-05
    ##  colorspace           1.3-2      2016-12-14
    ##  compiler             3.4.2      2017-10-03
    ##  countrycode        * 0.19       2017-02-06
    ##  curl                 3.0        2017-10-06
    ##  datasets           * 3.4.2      2017-10-03
    ##  DBI                  0.7        2017-06-18
    ##  devtools             1.13.3     2017-08-02
    ##  digest               0.6.12     2017-01-27
    ##  doParallel           1.0.11     2017-09-28
    ##  dplyr              * 0.7.4      2017-09-28
    ##  evaluate             0.10.1     2017-06-24
    ##  foreach            * 1.4.3      2015-10-13
    ##  ggplot2            * 2.2.1.9000 2017-10-16
    ##  glue                 1.1.1      2017-06-21
    ##  graphics           * 3.4.2      2017-10-03
    ##  grDevices          * 3.4.2      2017-10-03
    ##  grid                 3.4.2      2017-10-03
    ##  gtable               0.2.0      2016-02-26
    ##  highr                0.6        2016-05-09
    ##  hms                  0.3        2016-11-22
    ##  htmltools            0.3.6      2017-04-28
    ##  iterators            1.0.8      2015-10-13
    ##  knitr                1.17       2017-08-10
    ##  labeling             0.3        2014-08-23
    ##  lattice              0.20-35    2017-03-25
    ##  lazyeval             0.2.0      2016-06-12
    ##  magrittr           * 1.5        2014-11-22
    ##  memoise              1.1.0      2017-04-21
    ##  methods            * 3.4.2      2017-10-03
    ##  munsell              0.4.3      2016-02-13
    ##  parallel           * 3.4.2      2017-10-03
    ##  pkgconfig            2.0.1      2017-03-21
    ##  plyr                 1.8.4      2016-06-08
    ##  R6                   2.2.2      2017-06-17
    ##  raster             * 2.5-8      2016-06-02
    ##  Rcpp                 0.12.13    2017-09-28
    ##  readr              * 1.1.1      2017-05-16
    ##  rgdal                1.2-13     2017-10-07
    ##  rlang                0.1.2.9000 2017-10-23
    ##  rmarkdown            1.6        2017-06-15
    ##  rnaturalearth      * 0.1.0      2017-03-21
    ##  rnaturalearthhires   0.1.0      2017-06-01
    ##  rprojroot            1.2        2017-01-16
    ##  scales               0.5.0.9000 2017-09-15
    ##  sf                   0.5-4      2017-08-28
    ##  sp                 * 1.2-5      2017-06-29
    ##  stats              * 3.4.2      2017-10-03
    ##  stringi              1.1.5      2017-04-07
    ##  stringr              1.2.0      2017-02-18
    ##  tibble               1.3.4      2017-08-22
    ##  tools                3.4.2      2017-10-03
    ##  udunits2             0.13       2016-11-17
    ##  units                0.4-6      2017-08-27
    ##  utils              * 3.4.2      2017-10-03
    ##  withr                2.0.0      2017-10-17
    ##  yaml                 2.1.14     2016-11-12
    ##  source                            
    ##  CRAN (R 3.4.1)                    
    ##  cran (@1.1.1)                     
    ##  local                             
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.2)                    
    ##  CRAN (R 3.4.1)                    
    ##  local                             
    ##  CRAN (R 3.4.1)                    
    ##  cran (@3.0)                       
    ##  local                             
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  cran (@1.0.11)                    
    ##  cran (@0.7.4)                     
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  Github (tidyverse/ggplot2@ffb40f3)
    ##  CRAN (R 3.4.1)                    
    ##  local                             
    ##  local                             
    ##  local                             
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.2)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  local                             
    ##  CRAN (R 3.4.1)                    
    ##  local                             
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  cran (@0.12.13)                   
    ##  CRAN (R 3.4.1)                    
    ##  cran (@1.2-13)                    
    ##  Github (tidyverse/rlang@cbdc3f3)  
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  local                             
    ##  CRAN (R 3.4.1)                    
    ##  Github (hadley/scales@d767915)    
    ##  CRAN (R 3.4.2)                    
    ##  CRAN (R 3.4.1)                    
    ##  local                             
    ##  CRAN (R 3.4.1)                    
    ##  CRAN (R 3.4.1)                    
    ##  cran (@1.3.4)                     
    ##  local                             
    ##  CRAN (R 3.4.1)                    
    ##  cran (@0.4-6)                     
    ##  local                             
    ##  Github (jimhester/withr@a43df66)  
    ##  CRAN (R 3.4.1)

References
==========

Hijmans, RJ, SJ Cameron, JL Parra, PG Jones, A Jarvis, 2005, Very High Resolution Interpolated Climate Surfaces for Global Land Areas. *International Journal of Climatology*. 25: 1965-1978. [DOI:10.1002/joc.1276](http://dx.doi.org/10.1002/joc.1276)

Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m Database (<http://srtm.csi.cgiar.org>)

Jarvis, A, J Rubiano, A Nelson, A Farrow and M Mulligan, 2004, Practical use of SRTM Data in the Tropics: Comparisons with Digital Elevation Models Generated From Cartographic Data. Working Document no. 198. Cali, CO. International Centre for Tropical Agriculture (CIAT): 32. [URL](http://srtm.csi.cgiar.org/PDF/Jarvis4.pdf)
