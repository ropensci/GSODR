Fetch, Clean and Correct Altitude in GSOD ‘isd\_history.csv’ Data
================
Adam H. Sparks
2019-08-13

# Introduction

This document details how the GSOD station history data file,
[“isd-history.csv”](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv),
is fetched from the NCEI ftp server, error checked and new elevation
values generated. The new elevation values are then saved for inclusion
in package as `/extdata/isd_history.rda`. The resulting values are
merged with the most recent station history data file from the NCEI when
the user runs the `get_GSOD()` function. The resulting data frame of
station information, based on the merging of the `corrected_elev` data
frame with the most recently available “isd-history.csv” file, will
result in the following changes to the data:

  - Stations where latitude or longitude are `NA` or both 0 are removed

  - Stations where latitude is \< -90˚ or \> 90˚ are removed

  - Stations where longitude is \< -180˚ or \> 180˚ are removed

  - A new field, `STNID`, a concatenation of the USAF and WBAN fields,
    is added

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
if (!require("dplyr")) {
  install.packages("dplyr", repos = "https://cran.rstudio.com/")
}

if (!require("sp")) {
  install.packages("sp", repos = "https://cran.rstudio.com/")
}

if (!require("parallel")) {
  install.packages("parallel", repos = "https://cran.rstudio.com/")
}

if (!require("doParallel")) {
  install.packages("doParallel", repos = "https://cran.rstudio.com/")
}

if (!require("foreach")) {
  install.packages("foreach", repos = "https://cran.rstudio.com/")
}

if (!require("ggplot2")) {
  install.packages("ggplot2", repos = "https://cran.rstudio.com/")
}

if (!require("raster")) {
  install.packages("raster", repos = "https://cran.rstudio.com/")
}

if (!require("readr")) {
  install.packages("readr", repos = "https://cran.rstudio.com/")
}

if (!require("rnaturalearth")) {
  install.packages("rnaturalearth", repos = "https://cran.rstudio.com/")
}

if (!require("hrbrthemes")) {
  install.packages("hrbrthemes", repos = "https://cran.rstudio.com/")
}

if (!require("sessioninfo")) {
  install.packages("sessioninfo", repos = "https://cran.rstudio.com/")
}

if (!require("skimr")) {
  install.packages("skimr", repos = "https://cran.rstudio.com/")
}

if (!require("data.table")) {
  install.packages("data.table", repos = "https://cran.rstudio.com/")
}

library(magrittr) # comes with dplyr above

dem_tiles <- list.files(
  path.expand("~/Data/CGIAR-CSI SRTM"),
  pattern = glob2rx("*.tif"),
  full.names = TRUE
)
crs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
cor_stations <- list()
tf <- tempfile(
)
```

## Download data from Natural Earth and NCEI

``` r
# import Natural Earth cultural 1:10m data
NE <- ne_countries(scale = 10)

# download data
stations <- read_csv(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
  col_types = "ccccccdddii",
  col_names = c(
    "USAF",
    "WBAN",
    "STN_NAME",
    "CTRY",
    "STATE",
    "CALL",
    "LAT",
    "LON",
    "ELEV_M",
    "BEGIN",
    "END"
  ),
  skip = 1
)
```

## Reformat and clean station data file from NCEI

``` r
# clean data
stations[stations == -999] <- NA # sets any wonky elevation values to NA
stations[stations == -999.9] <- NA # sets any wonky elevation values to NA
stations <- stations[!is.na(stations$LAT) & !is.na(stations$LON),]
stations <- stations[stations$LAT != 0 & stations$LON != 0,]
stations <- stations[stations$LAT > -90 & stations$LAT < 90,]
stations <- stations[stations$LON > -180 & stations$LON < 180,]
stations$STNID <-
  as.character(paste(stations$USAF, stations$WBAN, sep = "-"))
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
facilitate this next step.

``` r
# quality check station locations for reported country and lat/lon position
# agreement

# create spatial object to check for location
xy <- as.data.frame(stations)
coordinates(xy) <- ~ LON + LAT
proj4string(xy) <- CRS(crs)

# check for location in country
point_check <- over(xy, NE)
point_check <- as.data.frame(point_check)
stations_discard <-
  point_check[point_check$FIPS %in% point_check$FIPS_10_ == FALSE,]
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
coordinates(stations) <- ~ LON + LAT
proj4string(stations) <- CRS(crs)

# set up cluster for parallel processing
library(foreach)
cl <- makeCluster(detectCores())
registerDoParallel(cl)

corrected_elev <- bind_rows(
  foreach(i = dem_tiles, .packages = c("magrittr", "raster", "dplyr")) %dopar% {
    # Load the DEM tile
    dem <- raster(i)
    sub_stations <- crop(stations, dem)
    
    # in some cases the DEM represents areas where there is no station
    # check for that here and if no stations, go on to next iteration
    if (!is.null(sub_stations)) {
      # use a 100m buffer to extract elevation from the DEM
      
      sub_stations$ELEV_M_SRTM_90m <- 
        extract(dem, sub_stations,
                buffer = 100,
                fun = mean)
      
      # convert spatial object back to normal data frame and add new fields
      sub_stations <- as.data.frame(sub_stations)
      
      # set any factors back to character
      sub_stations <- sub_stations %>%
        mutate_if(is.factor, as.character)
      
      return(sub_stations)
    }
  }
)

# stop cluster
stopCluster(cl)
```

Some stations occur in areas where DEM has no data, in this case, use
original station elevation for these stations.

``` r
corrected_elev <- mutate(corrected_elev,
                         ELEV_M_SRTM_90m = ifelse(is.na(ELEV_M_SRTM_90m),
                                                  ELEV_M, ELEV_M_SRTM_90m))
```

In some cases duplicate stations occur, use the mean value of duplicate
rows for corrected elevation and create a data frame with only `STNID`
and the new elevation values. `STNID` is used for a left-join with the
`stations` object.

``` r
corrected_elev <- corrected_elev %>%
  group_by(STNID) %>%
  summarise(ELEV_M_SRTM_90m = mean(ELEV_M_SRTM_90m))
```

Round `ELEV_M_SRTM_90m` field to whole number in cases where station
reported data was used.

``` r
corrected_elev[, 2] <- round(corrected_elev[, 2], 0)
```

Left-join the new station elevation data with the `stations` object. For
stations above/below 60/-60 latitude or buoys, `ELEV_M_SRTM_90m` will be
`NA` as there is no SRTM data for these locations.

``` r
# convert any factors in stations object to character for left_join
stations <- mutate_if(as.data.frame(stations),
                      is.factor,
                      as.character)

# Perform left join to join corrected elevation with original station data,
# this will include stations below/above -60/60
isd_history <-
  left_join(stations, corrected_elev,
            by = "STNID")

# select the metadata columns of interest
isd_history <-
  isd_history[, c("STNID",
                  "STN_NAME",
                  "CTRY",
                  "STATE",
                  "LAT",
                  "LON",
                  "BEGIN",
                  "END",
                  "ELEV_M",
                  "ELEV_M_SRTM_90m")]

skim(isd_history)
```

    ## Skim summary statistics
    ##  n obs: 28123 
    ##  n variables: 10 
    ## 
    ## ── Variable type:character ───────────────────────────────────────────────────────────────────────────────
    ##  variable missing complete     n min max empty n_unique
    ##      CTRY     119    28004 28123   2   2     0      252
    ##     STATE   21396     6727 28123   2   2     0       73
    ##  STN_NAME       0    28123 28123   2  58     0    26104
    ##     STNID       0    28123 28123  12  12     0    28123
    ## 
    ## ── Variable type:integer ─────────────────────────────────────────────────────────────────────────────────
    ##  variable missing complete     n  mean        sd      p0   p25   p50   p75
    ##     BEGIN       0    28123 28123 2e+07 238545.21 1.9e+07 2e+07 2e+07 2e+07
    ##       END       0    28123 28123 2e+07 191898.69 1.9e+07 2e+07 2e+07 2e+07
    ##   p100     hist
    ##  2e+07 ▁▁▃▇▇▅▇▇
    ##  2e+07 ▁▁▁▁▁▁▂▇
    ## 
    ## ── Variable type:numeric ─────────────────────────────────────────────────────────────────────────────────
    ##         variable missing complete     n   mean     sd      p0    p25
    ##           ELEV_M     211    27912 28123 364.17 564.85 -388     24.1 
    ##  ELEV_M_SRTM_90m    2922    25201 28123 382.51 580.85 -389     26   
    ##              LAT       0    28123 28123  31.11  28.73  -89     22.48
    ##              LON       0    28123 28123  -3.58  87.89 -179.98 -83.47
    ##     p50    p75    p100     hist
    ##  143.9  440    5304    ▇▂▁▁▁▁▁▁
    ##  159    467    5280    ▇▂▁▁▁▁▁▁
    ##   39.3   49.9    83.65 ▁▁▂▂▂▆▇▁
    ##    6.77  61.57  179.75 ▁▆▆▂▇▃▃▂

# Figures

Visualise the corrected elevation values against the original elevation
values.

``` r
ggplot(data = isd_history,
       aes(x = ELEV_M,
           y = ELEV_M_SRTM_90m)) +
  geom_point(alpha = 0.4,
             size = 0.5) +
  geom_abline(slope = 1,
              colour = "blue",
              size = 1.5,
              alpha = 0.5) +
  ggtitle("Corrected elevation versus original elevation values") +
  theme_ipsum()
```

![GSOD Reported Elevation versus CGIAR - CSI SRTM Buffered
Elevation](fetch_isd-history_files/figure-gfm/Buffered%20SRTM%2090m%20vs%20Reported%20Elevation-1.png)

Buffered versus non-buffered elevation values were previously checked
and found not to be different while also not showing any discernible
geographic patterns. However, the buffered elevation data are higher
than the non-buffered data. To help avoid within cell and between cell
variation the buffered values are the values that are included in the
final data for distribution with the GSODR package following the
approach of Hijmans *et al.* (2005).

## Save final version to disk

The final data frame for distribution with *GSODR* includes the new
elevation values in the `ELEV_M_SRTM_90m` field along with the cleaned
“isd-history.csv” data that removes stations that do not have valid x,
y locations as a `data.table` object.

``` r
setDT(isd_history)
setkey(isd_history, "STNID")

# write rda file to disk for use with GSODR package
save(isd_history,
     file = "../inst/extdata/isd_history.rda",
     compress = "bzip2",
     version = 2)
```

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
    ##  version  R version 3.6.1 (2019-07-05)
    ##  os       macOS Mojave 10.14.6        
    ##  system   x86_64, darwin15.6.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2019-08-13                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package            * version date       lib source        
    ##  assertthat           0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
    ##  backports            1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
    ##  class                7.3-15  2019-01-01 [1] CRAN (R 3.6.1)
    ##  classInt             0.4-1   2019-08-06 [1] CRAN (R 3.6.0)
    ##  cli                  1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
    ##  codetools            0.2-16  2018-12-24 [1] CRAN (R 3.6.1)
    ##  colorspace           1.4-1   2019-03-18 [1] CRAN (R 3.6.0)
    ##  crayon               1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
    ##  curl                 4.0     2019-07-22 [1] CRAN (R 3.6.0)
    ##  data.table         * 1.12.2  2019-04-07 [1] CRAN (R 3.6.0)
    ##  DBI                  1.0.0   2018-05-02 [1] CRAN (R 3.6.0)
    ##  digest               0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
    ##  doParallel         * 1.0.15  2019-08-02 [1] CRAN (R 3.6.0)
    ##  dplyr              * 0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
    ##  e1071                1.7-2   2019-06-05 [1] CRAN (R 3.6.0)
    ##  evaluate             0.14    2019-05-28 [1] CRAN (R 3.6.0)
    ##  extrafont            0.17    2014-12-08 [1] CRAN (R 3.6.0)
    ##  extrafontdb          1.0     2012-06-11 [1] CRAN (R 3.6.0)
    ##  foreach            * 1.4.7   2019-07-27 [1] CRAN (R 3.6.0)
    ##  gdtools              0.1.9   2019-06-18 [1] CRAN (R 3.6.0)
    ##  ggplot2            * 3.2.1   2019-08-10 [1] CRAN (R 3.6.0)
    ##  glue                 1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
    ##  gtable               0.3.0   2019-03-25 [1] CRAN (R 3.6.0)
    ##  highr                0.8     2019-03-20 [1] CRAN (R 3.6.0)
    ##  hms                  0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
    ##  hrbrthemes         * 0.6.0   2019-01-21 [1] CRAN (R 3.6.0)
    ##  htmltools            0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
    ##  iterators          * 1.0.12  2019-07-26 [1] CRAN (R 3.6.0)
    ##  KernSmooth           2.23-15 2015-06-29 [1] CRAN (R 3.6.1)
    ##  knitr                1.24    2019-08-08 [1] CRAN (R 3.6.0)
    ##  labeling             0.3     2014-08-23 [1] CRAN (R 3.6.0)
    ##  lattice              0.20-38 2018-11-04 [1] CRAN (R 3.6.1)
    ##  lazyeval             0.2.2   2019-03-15 [1] CRAN (R 3.6.0)
    ##  magrittr           * 1.5     2014-11-22 [1] CRAN (R 3.6.0)
    ##  munsell              0.5.0   2018-06-12 [1] CRAN (R 3.6.0)
    ##  pillar               1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
    ##  pkgconfig            2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
    ##  purrr                0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
    ##  R6                   2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
    ##  raster             * 2.9-23  2019-07-11 [1] CRAN (R 3.6.0)
    ##  Rcpp                 1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
    ##  readr              * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
    ##  rgdal                1.4-4   2019-05-29 [1] CRAN (R 3.6.0)
    ##  rlang                0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
    ##  rmarkdown            1.14    2019-07-12 [1] CRAN (R 3.6.0)
    ##  rnaturalearth      * 0.1.0   2017-03-21 [1] CRAN (R 3.6.0)
    ##  rnaturalearthhires   0.2.0   2019-08-13 [1] local         
    ##  Rttf2pt1             1.3.7   2018-06-29 [1] CRAN (R 3.6.0)
    ##  scales               1.0.0   2018-08-09 [1] CRAN (R 3.6.0)
    ##  sessioninfo        * 1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
    ##  sf                   0.7-7   2019-07-24 [1] CRAN (R 3.6.0)
    ##  skimr              * 1.0.7   2019-06-20 [1] CRAN (R 3.6.0)
    ##  sp                 * 1.3-1   2018-06-05 [1] CRAN (R 3.6.0)
    ##  stringi              1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
    ##  stringr              1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
    ##  tibble               2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
    ##  tidyr                0.8.3   2019-03-01 [1] CRAN (R 3.6.0)
    ##  tidyselect           0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
    ##  units                0.6-3   2019-05-03 [1] CRAN (R 3.6.0)
    ##  vctrs                0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
    ##  withr                2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
    ##  xfun                 0.8     2019-06-25 [1] CRAN (R 3.6.0)
    ##  yaml                 2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
    ##  zeallot              0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
    ## 
    ## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library

# References

Hijmans, RJ, SJ Cameron, JL Parra, PG Jones, A Jarvis, 2005, Very High
Resolution Interpolated Climate Surfaces for Global Land Areas.
*International Journal of Climatology*. 25: 1965-1978.
[DOI:10.1002/joc.1276](http://dx.doi.org/10.1002/joc.1276)

Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled SRTM for
the globe Version 4, available from the CGIAR-CSI SRTM 90m Database
(<http://srtm.csi.cgiar.org>)
