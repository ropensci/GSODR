Fetch, clean and correct altitude in GSOD isd\_history.csv data
================
Adam H. Sparks
2018-08-15

# Introduction

This document details how the GSOD station history data file,
[“isd-history.csv”](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv),
is fetched from the NCEI ftp server, error checked and new elevation
values generated. The new elevation values are then saved for inclusion
in package as /extdata/isd\_history.rda. The resulting values are merged
with the most recent station history data file from the NCEI when the
user runs the `get_GSOD()` function. The resulting data frame of station
information, based on the merging of the `SRTM_GSOD_elevation` data
frame with the most recently available “isd-history.csv” file will
result in the following changes to the data:

  - Stations where latitude or longitude are NA or both 0 are removed

  - Stations where latitude is \< -90˚ or \> 90˚ are removed

  - Stations where longitude is \< -180˚ or \> 180˚ are removed

  - A new field, STNID, a concatenation of the USAF and WBAN fields, is
    added

  - Stations are checked against Natural Earth 1:10 ADM0 cultural data,
    stations not mapping in the isd-history reported country are dropped

  - 90m hole-filled SRTM digital elevation (Jarvis *et al.* 2008) is
    used to identify and correct/remove elevation errors in data for
    station locations between -60˚ and 60˚ latitude. This applies to
    cases here where elevation was missing in the reported values as
    well. In case the station reported an elevation and the DEM does
    not, the station reported value is taken. For stations beyond -60˚
    and 60˚ latitude, the values are station reported values in every
    instance for the 90m column.

# Data Processing

## Set up workspace

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
if (!require("doParallel")) {
  install.packages("doParallel", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: doParallel

    ## Loading required package: foreach

    ## Loading required package: iterators

    ## Loading required package: parallel

``` r
if (!require("foreach")) {
  install.packages("foreach", repos = "https://cran.rstudio.com/")
}

if (!require("ggplot2")) {
  install.packages("ggplot2", repos = "https://cran.rstudio.com/")
}
```

    ## Loading required package: ggplot2

``` r
if (!require("parallel")) {
  install.packages("parallel", repos = "https://cran.rstudio.com/")
}

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

## Download from Natural Earth and NCEI

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
  col_types = "ccc")[-1, ]
```

## Reformat and clean station data file from NCEI

``` r
# clean data
stations <- stations[!is.na(stations$LAT) & !is.na(stations$LON), ]
stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
stations <- stations[stations$LAT > -90 & stations$LAT < 90, ]
stations <- stations[stations$LON > -180 & stations$LON < 180, ]
stations$STNID <- as.character(paste(stations$USAF, stations$WBAN, sep = "-"))

# join countries with countrycode data
countries <- dplyr::left_join(countries, countrycode::codelist,
                              by = c("FIPS" = "fips"))

# create xy object to check for geographic location agreement with reported
xy <- dplyr::left_join(stations, countries, by = c("CTRY" = "FIPS"))
```

## Check data for inconsistencies

### Check for country of station location

GSOD data have some inconsistencies in them, some of this has been
removed above with filtering. Further filtering is used remove stations
reporting locations in countries that do not match the physical
coordinates reported. Using [Natural Earth Data 1:10 Cultural
Data](http://www.naturalearthdata.com/downloads/10m-cultural-vectors/),
the stations reported countries are checked against the country in which
the coordinates map.

Also, reported elevation may differ from actual. Hijmans *et al.* (2005)
created their own digital elevation model using Jarvis *et al.* (2004)
and [GTOPO30 data](https://lta.cr.usgs.gov/GTOPO30) for areas where
there was no SRTM data available (\>+/-60˚ latitude). Here only the
hole-filled SRTM data, V4 (Jarvis *et al.* 2008) was used for correction
of agroclimatology data (-60˚ to 60˚ latitude). Any incorrect station
elevations beyond these values were ignored in this data set. Stations
with incorrect elevation were identified using `raster::extract(x, y,
buffer = 200, fun = mean)` so that surrounding cells are also used to
determine the elevation at that point, reducing the chances of over or
underestimating in mountainous areas. See Hijmans *et al.* (2005) for
more detailed information on this methodology.

The hole-filled SRTM data is large enough that it won’t all fit
in-memory on most desktop computers. Using tiles allows this process to
run on a modest machine with minimal effort but does take some time to
loop through all of the tiles.

Data can be downloaded from the
[CGIAR-CSI’s](http://csi.cgiar.org/WhtIsCGIAR_CSI.asp) ftp server,
[srtm.csi.cgiar.org](ftp://srtm.csi.cgiar.org), using an FTP client to
facilitate this next
step.

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

Zero observations (rows) in `stations_discard`, the data look good, no
need to remove any

### Elevation data supplement

Next use the `raster::extract()` function to get the mean elevation data
from the 90m elevation data and supplement the elevation data from the
NCEI.

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

Some stations occur in areas where DEM has no data, in this case, use
original station elevation for these stations.

``` r
corrected_elev <- dplyr::mutate(corrected_elev,
                                ELEV_M_SRTM_90m = ifelse(
                                  is.na(ELEV_M_SRTM_90m),
                                  ELEV_M, ELEV_M_SRTM_90m))
# round SRTM_90m_Buffer field to whole number in cases where station reported
# data was used and rename column
corrected_elev[, 13] <- round(corrected_elev[, 13], 0)
```

In some cases duplicate stations occur, use the mean value of duplicate
rows for corrected elevation and create a data frame with only `STNID`
and the new elevation values. `STNID` is used for a left-join with the
`stations` object.

``` r
corrected_elev <- corrected_elev %>%
  dplyr::group_by(STNID) %>%
  dplyr::summarise(ELEV_M_SRTM_90m = mean(ELEV_M_SRTM_90m))
```

Left-join the new station elevation data with the `stations` object. For
stations above/below 60/-60 latitude or bouys, `ELEV_M_SRTM_90m` will be
`NA` as there is no SRTM data for these locations.

``` r
# convert any factors in stations object to character for left_join
stations <- dplyr::mutate_if(
  as.data.frame(stations),
  is.factor,
  as.character)

# Perform left join to join corrected elevation with original station data,
# this will include stations below/above -60/60
isd_history <- 
  dplyr::left_join(stations, corrected_elev,
                   by = "STNID") %>% 
  tibble::as_tibble()

str(isd_history)
```

    ## Classes 'tbl_df', 'tbl' and 'data.frame':    28029 obs. of  13 variables:
    ##  $ USAF           : chr  "010010" "010014" "010015" "010016" ...
    ##  $ WBAN           : chr  "99999" "99999" "99999" "99999" ...
    ##  $ STN_NAME       : chr  "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN" "BRINGELAND" "RORVIK/RYUM" ...
    ##  $ CTRY           : chr  "NO" "NO" "NO" "NO" ...
    ##  $ STATE          : chr  NA NA NA NA ...
    ##  $ CALL           : chr  "ENJA" "ENSO" NA NA ...
    ##  $ LAT            : num  70.9 59.8 61.4 64.8 60 ...
    ##  $ LON            : num  -8.67 5.34 5.87 11.23 2.25 ...
    ##  $ ELEV_M         : num  9 48.8 327 14 48 8 12 8 9 14 ...
    ##  $ BEGIN          : num  19310101 19861120 19870117 19870116 19880320 ...
    ##  $ END            : num  20180812 20180812 20111020 19910806 20050228 ...
    ##  $ STNID          : chr  "010010-99999" "010014-99999" "010015-99999" "010016-99999" ...
    ##  $ ELEV_M_SRTM_90m: num  NA 48 NA NA 48 NA NA NA NA NA ...

``` r
isd_history
```

    ## # A tibble: 28,029 x 13
    ##    USAF  WBAN  STN_NAME CTRY  STATE CALL    LAT    LON ELEV_M  BEGIN    END
    ##    <chr> <chr> <chr>    <chr> <chr> <chr> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
    ##  1 0100… 99999 JAN MAY… NO    <NA>  ENJA   70.9  -8.67    9   1.93e7 2.02e7
    ##  2 0100… 99999 SORSTOK… NO    <NA>  ENSO   59.8   5.34   48.8 1.99e7 2.02e7
    ##  3 0100… 99999 BRINGEL… NO    <NA>  <NA>   61.4   5.87  327   1.99e7 2.01e7
    ##  4 0100… 99999 RORVIK/… NO    <NA>  <NA>   64.8  11.2    14   1.99e7 1.99e7
    ##  5 0100… 99999 FRIGG    NO    <NA>  ENFR   60.0   2.25   48   1.99e7 2.01e7
    ##  6 0100… 99999 VERLEGE… NO    <NA>  <NA>   80.0  16.2     8   1.99e7 2.02e7
    ##  7 0100… 99999 HORNSUND NO    <NA>  <NA>   77    15.5    12   1.99e7 2.02e7
    ##  8 0100… 99999 NY-ALES… NO    <NA>  ENAS   78.9  11.9     8   1.97e7 2.01e7
    ##  9 0100… 99999 ISFJORD… SV    <NA>  <NA>   78.1  13.6     9   1.96e7 2.01e7
    ## 10 0100… 99999 EDGEOYA  NO    <NA>  <NA>   78.2  22.8    14   1.97e7 2.02e7
    ## # ... with 28,019 more rows, and 2 more variables: STNID <chr>,
    ## #   ELEV_M_SRTM_90m <dbl>

# Figures

``` r
ggplot(data = isd_history, aes(x = ELEV_M, y = ELEV_M_SRTM_90m)) +
  geom_point(alpha = 0.4, size = 0.5) +
  geom_abline(slope = 1, colour = "white")
```

![GSOD Reported Elevation versus CGIAR-CSI SRTM Buffered
Elevation](fetch_isd-history_files/figure-gfm/Buffered%20SRTM%2090m%20vs%20Reported%20Elevation-1.png)

Buffered versus non-buffered elevation values were previously checked
and found not to be different while also not showing any discernible
geographic patterns. However, The buffered elevation data are higher
than the non-buffered data. To help avoid within cell and between cell
variation the buffered values are the values that are included in the
final data for distribution with the GSODR package following the
approach of Hijmans *et al.* (2005).

The final dataframe for distribution with *GSODR* includes the new
elevation values along with the cleaned “isd-history.csv” data.

``` r
# write rda file to disk for use with GSODR package
save(isd_history, file = "../inst/extdata/isd_history.rda",
     compress = "bzip2")
```

The `isd_history.rda` file is bundled in the GSODR package and includes
the new elevation data as the field; ELEV\_M\_SRTM\_90m.

# Notes

## NOAA Policy

Users of these data should take into account the following (from the
[NCEI
website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

> “The following data and products may have conditions placed on their
> international commercial use. They can be used within the U.S. or for
> non-commercial international activities without restriction. The
> non-U.S. data cannot be redistributed for commercial purposes.
> Re-distribution of these data by others must provide this same
> notification.” [WMO Resolution 40. NOAA
> Policy](http://www.wmo.int/pages/about/Resolution40.html)

## R System Information

    ## ─ Session info ──────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.5.1 (2018-07-02)
    ##  os       macOS Sierra 10.12.6        
    ##  system   x86_64, darwin16.7.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2018-08-15                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package            * version date       source        
    ##  assertthat           0.2.0   2017-04-11 CRAN (R 3.5.1)
    ##  backports            1.1.2   2017-12-13 CRAN (R 3.5.1)
    ##  bindr                0.1.1   2018-03-13 CRAN (R 3.5.1)
    ##  bindrcpp           * 0.2.2   2018-03-29 CRAN (R 3.5.1)
    ##  class                7.3-14  2015-08-30 CRAN (R 3.5.1)
    ##  classInt             0.2-3   2018-04-16 CRAN (R 3.5.1)
    ##  cli                  1.0.0   2017-11-05 CRAN (R 3.5.1)
    ##  clisymbols           1.2.0   2017-05-21 CRAN (R 3.5.1)
    ##  codetools            0.2-15  2016-10-05 CRAN (R 3.5.1)
    ##  colorspace           1.3-2   2016-12-14 CRAN (R 3.5.1)
    ##  countrycode        * 1.00.0  2018-02-11 CRAN (R 3.5.1)
    ##  crayon               1.3.4   2017-09-16 CRAN (R 3.5.1)
    ##  curl                 3.2     2018-03-28 CRAN (R 3.5.1)
    ##  DBI                  1.0.0   2018-05-02 CRAN (R 3.5.1)
    ##  digest               0.6.15  2018-01-28 CRAN (R 3.5.1)
    ##  doParallel         * 1.0.11  2017-09-28 CRAN (R 3.5.1)
    ##  dplyr              * 0.7.6   2018-06-29 CRAN (R 3.5.1)
    ##  e1071                1.7-0   2018-07-28 CRAN (R 3.5.1)
    ##  evaluate             0.11    2018-07-17 CRAN (R 3.5.1)
    ##  fansi                0.3.0   2018-08-13 CRAN (R 3.5.1)
    ##  foreach            * 1.4.4   2017-12-12 CRAN (R 3.5.1)
    ##  ggplot2            * 3.0.0   2018-07-03 CRAN (R 3.5.1)
    ##  glue                 1.3.0   2018-07-17 CRAN (R 3.5.1)
    ##  gtable               0.2.0   2016-02-26 CRAN (R 3.5.1)
    ##  highr                0.7     2018-06-09 CRAN (R 3.5.1)
    ##  hms                  0.4.2   2018-03-10 CRAN (R 3.5.1)
    ##  htmltools            0.3.6   2017-04-28 CRAN (R 3.5.1)
    ##  iterators          * 1.0.10  2018-07-13 CRAN (R 3.5.1)
    ##  knitr                1.20    2018-02-20 CRAN (R 3.5.1)
    ##  labeling             0.3     2014-08-23 CRAN (R 3.5.1)
    ##  lattice              0.20-35 2017-03-25 CRAN (R 3.5.1)
    ##  lazyeval             0.2.1   2017-10-29 CRAN (R 3.5.1)
    ##  magrittr           * 1.5     2014-11-22 CRAN (R 3.5.1)
    ##  munsell              0.5.0   2018-06-12 CRAN (R 3.5.1)
    ##  pillar               1.3.0   2018-07-14 CRAN (R 3.5.1)
    ##  pkgconfig            2.0.1   2017-03-21 CRAN (R 3.5.1)
    ##  plyr                 1.8.4   2016-06-08 CRAN (R 3.5.1)
    ##  purrr                0.2.5   2018-05-29 CRAN (R 3.5.1)
    ##  R6                   2.2.2   2017-06-17 CRAN (R 3.5.1)
    ##  raster             * 2.6-7   2017-11-13 CRAN (R 3.5.1)
    ##  Rcpp                 0.12.18 2018-07-23 CRAN (R 3.5.1)
    ##  readr              * 1.1.1   2017-05-16 CRAN (R 3.5.1)
    ##  rgdal                1.3-4   2018-08-03 CRAN (R 3.5.1)
    ##  rlang                0.2.1   2018-05-30 CRAN (R 3.5.1)
    ##  rmarkdown            1.10    2018-06-11 CRAN (R 3.5.1)
    ##  rnaturalearth      * 0.1.0   2017-03-21 CRAN (R 3.5.1)
    ##  rnaturalearthhires   0.1.0   2018-06-13 local         
    ##  rprojroot            1.3-2   2018-01-03 CRAN (R 3.5.1)
    ##  scales               1.0.0   2018-08-09 CRAN (R 3.5.1)
    ##  sessioninfo          1.0.0   2017-06-21 CRAN (R 3.5.1)
    ##  sf                   0.6-3   2018-05-17 CRAN (R 3.5.1)
    ##  sp                 * 1.3-1   2018-06-05 CRAN (R 3.5.1)
    ##  spData               0.2.9.3 2018-08-01 CRAN (R 3.5.1)
    ##  stringi              1.2.4   2018-07-20 CRAN (R 3.5.1)
    ##  stringr              1.3.1   2018-05-10 CRAN (R 3.5.1)
    ##  tibble               1.4.2   2018-01-22 CRAN (R 3.5.1)
    ##  tidyselect           0.2.4   2018-02-26 CRAN (R 3.5.1)
    ##  units                0.6-0   2018-06-09 CRAN (R 3.5.1)
    ##  utf8                 1.1.4   2018-05-24 CRAN (R 3.5.1)
    ##  withr                2.1.2   2018-03-15 CRAN (R 3.5.1)
    ##  yaml                 2.2.0   2018-07-25 CRAN (R 3.5.1)

# References

Hijmans, RJ, SJ Cameron, JL Parra, PG Jones, A Jarvis, 2005, Very High
Resolution Interpolated Climate Surfaces for Global Land Areas.
*International Journal of Climatology*. 25: 1965-1978.
[DOI:10.1002/joc.1276](http://dx.doi.org/10.1002/joc.1276)

Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled SRTM for
the globe Version 4, available from the CGIAR-CSI SRTM 90m Database
(<http://srtm.csi.cgiar.org>)

Jarvis, A, J Rubiano, A Nelson, A Farrow and M Mulligan, 2004, Practical
use of SRTM Data in the Tropics: Comparisons with Digital Elevation
Models Generated From Cartographic Data. Working Document no. 198. Cali,
CO. International Centre for Tropical Agriculture (CIAT): 32.
[URL](http://srtm.csi.cgiar.org/PDF/Jarvis4.pdf)
