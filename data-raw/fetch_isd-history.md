---
title: "Fetch and Clean 'isd_history.csv' File"
author: "Adam H. Sparks"
date: "2025-11-15"
output: github_document
---



<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>

# Introduction

The "isd_history.csv" file details GSOD station metadata.
These data include the start and stop years used by {GSODR} to pre-check requests before querying the server for download and the country code used by {GSODR} when sub-setting for requests by country.
The following checks are performed on the raw data file before inclusion in {GSODR},

-   Check for valid lon and lat values;

    -   isd_history where latitude or longitude are `NA` or both 0 are removed leaving only properly georeferenced stations,

    -   isd_history where latitude is < -90˚ or > 90˚ are removed,

    -   isd_history where longitude is < -180˚ or > 180˚ are removed.

-   A new field, STNID, a concatenation of the USAF and WBAN fields, is added.

# Data Processing

## Set up workspace


``` r
library("sessioninfo")
library("countrycode")
library("data.table")
library("sf")
library("dplyr")
library("geodata")
library("diffobj")

new_isd_history <- fread("https://www.ncei.noaa.gov/pub/data/noaa/isd-history.csv")
```


## Add country names based on geographic location

Previously (prior to 2025-11-04) I used the FIPS code in the CSV file to determine the country.
This turned out to be [problematic](https://github.com/ropensci/GSODR/issues/133#issuecomment-3483206035).
So, I've gone to a brute-force method of determining which country the lat/lon values fall in using {rnaturalearth} and {sf}.


``` r
# isd_history
# pad WBAN where necessary
new_isd_history[, WBAN := sprintf("%05d", WBAN)]

# add STNID column
new_isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
setcolorder(new_isd_history, "STNID")

# clean data
new_isd_history[new_isd_history == -999] <- NA
new_isd_history[new_isd_history == -999.9] <- NA
new_isd_history <-
  new_isd_history[!is.na(new_isd_history$LAT) &
                    !is.na(new_isd_history$LON),]
new_isd_history <-
  new_isd_history[new_isd_history$LAT != 0 &
                    new_isd_history$LON != 0,]
new_isd_history <-
  new_isd_history[new_isd_history$LAT > -90 &
                    new_isd_history$LAT < 90,]
new_isd_history <-
  new_isd_history[new_isd_history$LON > -180 &
                    new_isd_history$LON < 180,]

sf_use_s2(FALSE)

coords_sf <- 
  st_as_sf(
  new_isd_history,
  coords = c("LON", "LAT"),
  crs = 4326,
  remove = FALSE
 ) |> select(STNID, `STATION NAME`, STATE, `ELEV(M)`, BEGIN, END, LON, LAT)

world <- st_as_sf(world(resolution = 1L)) |>
  st_transform(crs = 4326)

within_dt <- st_join(
  x = coords_sf,
  y = world,
  join = st_within) |>
  as.data.table()

new_isd_history <-
  within_dt[as.data.table(codelist), on = c("NAME_0" = "country.name.en")]

# remove rows with no stations
new_isd_history <- new_isd_history[complete.cases(new_isd_history$STNID), ]

new_isd_history <- new_isd_history[, c(
  "STNID",
  "STATION NAME",
  "LAT",
  "LON",
  "ELEV(M)",
  "STATE",
  "BEGIN",
  "END",
  "NAME_0",
  "fips",
  "iso2c",
  "iso3c"
)]

setnames(
  new_isd_history,
  c(
    "STATION NAME",
    "NAME_0",
    "fips",
    "iso2c",
    "iso3c"
  ),
  c(
    "NAME",
    "COUNTRY_NAME",
    "CTRY",
    "ISO2C",
    "ISO3C"
  )
)
setcolorder(
  new_isd_history,
    c(
      "STNID",
      "NAME",
      "LAT",
      "LON",
      "ELEV(M)",
      "STATE",
      "BEGIN",
      "END",
      "COUNTRY_NAME",
      "ISO2C",
      "ISO3C",
      "CTRY"
))

new_isd_history[, COUNTRY_NAME := toupper(new_isd_history$COUNTRY_NAME)]

# set key for joins when processing CSV files
setkeyv(new_isd_history, "STNID")
```

## Show changes from last release


``` r
# ensure we aren't using a locally installed dev version
install.packages("GSODR", repos = "https://cloud.r-project.org/")
```

```
## Installing package into '/Users/adamsparks/Library/R/arm64/4.5/library'
## (as 'lib' is unspecified)
```

```
## 
## The downloaded binary packages are in
## 	/var/folders/vz/txwj1tx51txgw7zv_b5c5_3m0000gn/T//Rtmpg7jS2O/downloaded_packages
```

``` r
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

# select only the cols of interest
x <- names(isd_history)
new_isd_history <- new_isd_history[, ..x]

isd_diff <- diffObj(new_isd_history, isd_history, strip.sgr = FALSE)
```

## View and save the data


``` r
rm(isd_history)
isd_history <- new_isd_history

str(isd_history)
```

```
## Classes 'data.table' and 'data.frame':	24285 obs. of  12 variables:
##  $ STNID       : chr  "008268-99999" "010014-99999" "010015-99999" "010016-99999" ...
##  $ NAME        : chr  "WXPOD8278" "SORSTOKKEN / STORD" "BRINGELAND" "RORVIK/RYUM" ...
##  $ LAT         : num  33 59.8 61.4 64.8 69.3 ...
##  $ LON         : num  65.57 5.34 5.87 11.23 16.14 ...
##  $ ELEV(M)     : num  1156.7 48.8 327 14 13.1 ...
##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
##  $ STATE       : chr  "" "" "" "" ...
##  $ BEGIN       : int  20100519 19861120 19870117 19870116 19310103 19400713 19730101 19970201 20110928 19510101 ...
##  $ END         : int  20120323 20250824 19971231 19910806 20250824 20250824 20250824 20250824 20250824 20250824 ...
##  $ COUNTRY_NAME: chr  "AFGHANISTAN" "NORWAY" "NORWAY" "NORWAY" ...
##  $ ISO2C       : chr  "AF" "NO" "NO" "NO" ...
##  $ ISO3C       : chr  "AFG" "NOR" "NOR" "NOR" ...
##  - attr(*, ".internal.selfref")=<externalptr> 
##  - attr(*, "sorted")= chr "STNID"
```

``` r
# write rda file to disk for use with GSODR package
save(isd_history,
     file = "../inst/extdata/isd_history.rda",
     compress = "bzip2")

save(isd_diff,
     file = "../inst/extdata/isd_diff.rda",
     compress = "bzip2")
```

# Notes

## NOAA policy

Users of these data should take into account the following (from the [NCEI website](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00516)):

> The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification. A log of IP addresses accessing these data and products will be maintained and may be made available to data providers.  
> For details, please consult: [WMO Resolution 40. NOAA Policy](https://community.wmo.int/resolution-40)

## R System Information

<PRE class="fansi fansi-output"><CODE>## <span style='color: #00BBBB; font-weight: bold;'>─ Session info ───────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>setting </span> <span style='color: #555555; font-style: italic;'>value</span>
##  version  R version 4.5.2 (2025-10-31)
##  os       macOS Tahoe 26.1
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_AU.UTF-8
##  ctype    en_AU.UTF-8
##  tz       Australia/Perth
##  date     2025-11-15
##  pandoc   3.8.2.1 @ /opt/homebrew/bin/pandoc
##  quarto   1.8.26 @ /usr/local/bin/quarto
## 
## <span style='color: #00BBBB; font-weight: bold;'>─ Packages ───────────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>! </span> <span style='color: #555555; font-style: italic;'>package    </span> <span style='color: #555555; font-style: italic;'>*</span> <span style='color: #555555; font-style: italic;'>version   </span> <span style='color: #555555; font-style: italic;'>date (UTC)</span> <span style='color: #555555; font-style: italic;'>lib</span> <span style='color: #555555; font-style: italic;'>source</span>
##     askpass       1.2.1      <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     astgrepr      0.1.1      <span style='color: #555555;'>2025-06-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     brio          1.1.5      <span style='color: #555555;'>2024-04-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     cachem        1.1.0      <span style='color: #555555;'>2024-05-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     callr         3.7.6      <span style='color: #555555;'>2024-03-25</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     class         7.3-23     <span style='color: #555555;'>2025-01-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     classInt      0.4-11     <span style='color: #555555;'>2025-01-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     cli           3.6.5      <span style='color: #555555;'>2025-04-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     codetools     0.2-20     <span style='color: #555555;'>2024-03-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     colorDF       0.1.7      <span style='color: #555555;'>2022-09-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     colorout      1.3-3      <span style='color: #555555;'>2025-08-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (jalvesaq/colorout@64863bb)</span>
##     commonmark    2.0.0      <span style='color: #555555;'>2025-07-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     countrycode * 1.6.1      <span style='color: #555555;'>2025-03-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     crayon        1.5.3      <span style='color: #555555;'>2024-06-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     credentials   2.0.3      <span style='color: #555555;'>2025-09-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     curl          7.0.0      <span style='color: #555555;'>2025-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     data.table  * 1.17.8     <span style='color: #555555;'>2025-07-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     DBI           1.2.3      <span style='color: #555555;'>2024-06-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     desc          1.4.3      <span style='color: #555555;'>2023-12-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     devtag        <span style='color: #BB00BB; font-weight: bold;'>0.0.0.9000</span> <span style='color: #555555;'>2025-04-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (moodymudskipper/devtag@24f9b21)</span>
##     devtools      2.4.6      <span style='color: #555555;'>2025-10-03</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     diffobj     * 0.3.6      <span style='color: #555555;'>2025-04-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     digest        0.6.37     <span style='color: #555555;'>2024-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     dplyr       * 1.1.4      <span style='color: #555555;'>2023-11-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     e1071         1.7-16     <span style='color: #555555;'>2024-09-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     ellipsis      0.3.2      <span style='color: #555555;'>2021-04-29</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     evaluate      1.0.5      <span style='color: #555555;'>2025-08-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     fansi         1.0.6      <span style='color: #555555;'>2023-12-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     fastmap       1.2.0      <span style='color: #555555;'>2024-05-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     flir          0.5.0      <span style='color: #555555;'>2025-06-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     fs            1.6.6      <span style='color: #555555;'>2025-04-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     generics      0.1.4      <span style='color: #555555;'>2025-05-09</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     geodata     * 0.6-6      <span style='color: #555555;'>2025-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     glue          1.8.0      <span style='color: #555555;'>2024-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  <span style='color: #BBBBBB; background-color: #BB0000;'>VP</span> GSODR       * 5.0.0      <span style='color: #555555;'>2025-07-31</span> <span style='color: #555555;'>[?]</span> <span style='color: #555555;'>CRAN (R 4.5.0) (on disk 4.1.4)</span>
##     jsonlite      2.0.0      <span style='color: #555555;'>2025-03-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     KernSmooth    2.23-26    <span style='color: #555555;'>2025-01-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     knitr       * 1.50       <span style='color: #555555;'>2025-03-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     lifecycle     1.0.4      <span style='color: #555555;'>2023-11-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     magrittr      2.0.4      <span style='color: #555555;'>2025-09-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     memoise       2.0.1      <span style='color: #555555;'>2021-11-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     nvimcom     * 0.9.76     <span style='color: #555555;'>2025-11-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>local</span>
##     openssl       2.3.4      <span style='color: #555555;'>2025-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     pillar        1.11.1     <span style='color: #555555;'>2025-09-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     pkgbuild      1.4.8      <span style='color: #555555;'>2025-05-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     pkgconfig     2.0.3      <span style='color: #555555;'>2019-09-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     pkgdown       2.2.0      <span style='color: #555555;'>2025-11-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     pkgload       1.4.1      <span style='color: #555555;'>2025-09-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     prettyunits   1.2.0      <span style='color: #555555;'>2023-09-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     processx      3.8.6      <span style='color: #555555;'>2025-02-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     proxy         0.4-27     <span style='color: #555555;'>2022-06-09</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     ps            1.9.1      <span style='color: #555555;'>2025-04-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     purrr         1.2.0      <span style='color: #555555;'>2025-11-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     R.methodsS3   1.8.2      <span style='color: #555555;'>2022-06-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     R.oo          1.27.1     <span style='color: #555555;'>2025-05-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     R.utils       2.13.0     <span style='color: #555555;'>2025-02-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     R6            2.6.1      <span style='color: #555555;'>2025-02-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     rappdirs      0.3.3      <span style='color: #555555;'>2021-01-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     rcmdcheck     1.4.0      <span style='color: #555555;'>2021-09-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     Rcpp          1.1.0      <span style='color: #555555;'>2025-07-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     remotes       2.5.0      <span style='color: #555555;'>2024-03-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     rlang         1.1.6      <span style='color: #555555;'>2025-04-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     roxygen2      7.3.3      <span style='color: #555555;'>2025-09-03</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     roxyglobals   1.0.0      <span style='color: #555555;'>2023-08-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     rprojroot     2.1.1      <span style='color: #555555;'>2025-08-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     rrapply       1.2.7      <span style='color: #555555;'>2024-06-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     rstudioapi    0.17.1     <span style='color: #555555;'>2024-10-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     sessioninfo * 1.2.3      <span style='color: #555555;'>2025-02-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     sf          * 1.0-22     <span style='color: #555555;'>2025-11-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     stringi       1.8.7      <span style='color: #555555;'>2025-03-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     stringr       1.6.0      <span style='color: #555555;'>2025-11-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     sys           3.4.3      <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     terra       * 1.8-80     <span style='color: #555555;'>2025-11-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     testthat    * 3.2.3      <span style='color: #555555;'>2025-01-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     tibble        3.3.0      <span style='color: #555555;'>2025-06-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     tidyselect    1.2.1      <span style='color: #555555;'>2024-03-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     units         1.0-0      <span style='color: #555555;'>2025-10-09</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     usethis       3.2.1      <span style='color: #555555;'>2025-09-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     vctrs         0.6.5      <span style='color: #555555;'>2023-12-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     withr         3.0.2      <span style='color: #555555;'>2024-10-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     xfun          0.54       <span style='color: #555555;'>2025-10-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     xml2          1.4.1      <span style='color: #555555;'>2025-10-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     xopen         1.0.1      <span style='color: #555555;'>2024-04-25</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##     yaml          2.3.10     <span style='color: #555555;'>2024-07-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
## 
## <span style='color: #555555;'> [1] /Users/adamsparks/Library/R/arm64/4.5/library</span>
## <span style='color: #555555;'> [2] /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/library</span>
## 
##  <span style='color: #BBBBBB; background-color: #BB0000;'>*</span> ── Packages attached to the search path.
##  <span style='color: #BBBBBB; background-color: #BB0000;'>V</span> ── Loaded and on-disk version mismatch.
##  <span style='color: #BBBBBB; background-color: #BB0000;'>P</span> ── Loaded and on-disk path mismatch.
## 
## <span style='color: #00BBBB; font-weight: bold;'>──────────────────────────────────────────────────────────────────────────────</span>
</CODE></PRE>
