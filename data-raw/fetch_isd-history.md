Fetch and Clean ‘isd\_history.csv’ File
================
Adam H. Sparks
2021-01-19

# Introduction

The isd\_history.csv file details GSOD station metadata. These data
include the start and stop years used by *GSODR* to pre-check requests
before querying the server for download and the country code used by
*GSODR* when sub-setting for requests by country. The following checks
are performed on the raw data file before inclusion in *GSODR*,

-   Check for valid lon and lat values;

    -   isd\_history where latitude or longitude are `NA` or both 0 are
        removed leaving only properly georeferenced stations,

    -   isd\_history where latitude is &lt; -90˚ or &gt; 90˚ are
        removed,

    -   isd\_history where longitude is &lt; -180˚ or &gt; 180˚ are
        removed.

-   A new field, STNID, a concatenation of the USAF and WBAN fields, is
    added.

# Data Processing

## Set up workspace

``` r
if (!require("pacman")) {
  install.packages("pacman", repos = "https://cran.rstudio.com/")
}
pacman::p_load("sessioninfo", "skimr", "countrycode", "data.table")
```

## Download and clean data

``` r
# download data
isd_history <- fread("https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")
```

## Add/drop columns and save to disk

``` r
# add STNID column
isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
setcolorder(isd_history, "STNID")
setnames(isd_history, "STATION NAME", "NAME")

# drop stations not in GSOD data
isd_history[, STNID_len := nchar(STNID)]
isd_history <- subset(isd_history, STNID_len == 12)

# remove stations where LAT or LON is NA
isd_history <- na.omit(isd_history, cols = c("LAT", "LON"))

# remove extra columns
isd_history[, c("USAF", "WBAN", "ICAO", "ELEV(M)", "STNID_len") := NULL]
```

## Add country names based on FIPS

``` r
isd_history <-
  isd_history[setDT(countrycode::codelist), on = c("CTRY" = "fips")]

isd_history <- isd_history[, c(
  "STNID",
  "NAME",
  "LAT",
  "LON",
  "CTRY",
  "STATE",
  "BEGIN",
  "END",
  "country.name.en",
  "iso2c",
  "iso3c"
)]

# clean data
isd_history[isd_history == -999] <- NA
isd_history[isd_history == -999.9] <- NA
isd_history <- isd_history[!is.na(isd_history$LAT) & !is.na(isd_history$LON), ]
isd_history <- isd_history[isd_history$LAT != 0 & isd_history$LON != 0, ]
isd_history <- isd_history[isd_history$LAT > -90 & isd_history$LAT < 90, ]
isd_history <- isd_history[isd_history$LON > -180 & isd_history$LON < 180, ]

# set colnames to upper case
names(isd_history) <- toupper(names(isd_history))
setnames(
  isd_history,
  old = "COUNTRY.NAME.EN",
  new = "COUNTRY_NAME"
)

# set country names to be upper case for easier internal verifications
isd_history[, COUNTRY_NAME := toupper(COUNTRY_NAME)]

# set key for joins when processing CSV files
setkeyv(isd_history, "STNID")
```

## View and save the data

``` r
str(isd_history)
```

    ## Classes 'data.table' and 'data.frame':   26531 obs. of  11 variables:
    ##  $ STNID       : chr  "008268-99999" "010010-99999" "010014-99999" "010015-99999" ...
    ##  $ NAME        : chr  "WXPOD8278" "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN" "BRINGELAND" ...
    ##  $ LAT         : num  33 70.9 59.8 61.4 64.8 ...
    ##  $ LON         : num  65.57 -8.67 5.34 5.87 11.23 ...
    ##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
    ##  $ STATE       : chr  "" "" "" "" ...
    ##  $ BEGIN       : int  20100519 19310101 19861120 19870117 19870116 19880320 19861109 19850601 19730101 19310103 ...
    ##  $ END         : int  20120323 20210116 20210116 20081231 19910806 20050228 20210114 20210116 20140523 20041030 ...
    ##  $ COUNTRY_NAME: chr  "AFGHANISTAN" "NORWAY" "NORWAY" "NORWAY" ...
    ##  $ ISO2C       : chr  "AF" "NO" "NO" "NO" ...
    ##  $ ISO3C       : chr  "AFG" "NOR" "NOR" "NOR" ...
    ##  - attr(*, ".internal.selfref")=<externalptr> 
    ##  - attr(*, "sorted")= chr "STNID"

``` r
# write rda file to disk for use with GSODR package
save(isd_history,
     file = "../inst/extdata/isd_history.rda",
     compress = "bzip2")
```

# Notes

## NOAA policy

Users of these data should take into account the following (from the
[NCEI
website](https://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

> “The following data and products may have conditions placed on their
> international commercial use. They can be used within the U.S. or for
> non-commercial international activities without restriction. The
> non-U.S. data cannot be redistributed for commercial purposes.
> Re-distribution of these data by others must provide this same
> notification.” [WMO Resolution 40. NOAA
> Policy](http://www.wmo.int/pages/about/Resolution40.html)

## R System Information

    ## ─ Session info ───────────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 4.0.3 (2020-10-10)
    ##  os       macOS Big Sur 10.16         
    ##  system   x86_64, darwin17.0          
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Perth             
    ##  date     2021-01-19                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version    date       lib source                             
    ##  assertthat    0.2.1      2019-03-21 [1] CRAN (R 4.0.2)                     
    ##  base64enc     0.1-3      2015-07-28 [1] CRAN (R 4.0.2)                     
    ##  cli           2.2.0      2020-11-20 [1] CRAN (R 4.0.2)                     
    ##  clisymbols    1.2.0      2017-05-21 [1] CRAN (R 4.0.2)                     
    ##  countrycode * 1.2.0      2020-05-22 [1] CRAN (R 4.0.2)                     
    ##  crayon        1.3.4      2017-09-16 [1] CRAN (R 4.0.2)                     
    ##  curl          4.3        2019-12-02 [1] CRAN (R 4.0.1)                     
    ##  data.table  * 1.13.6     2020-12-30 [1] CRAN (R 4.0.2)                     
    ##  digest        0.6.27     2020-10-24 [1] CRAN (R 4.0.2)                     
    ##  dplyr         1.0.3      2021-01-15 [1] CRAN (R 4.0.2)                     
    ##  ellipsis      0.3.1      2020-05-15 [1] CRAN (R 4.0.2)                     
    ##  evaluate      0.14       2019-05-28 [1] CRAN (R 4.0.1)                     
    ##  fansi         0.4.2      2021-01-15 [1] CRAN (R 4.0.2)                     
    ##  generics      0.1.0      2020-10-31 [1] CRAN (R 4.0.2)                     
    ##  glue          1.4.1.9000 2021-01-08 [1] Github (tidyverse/glue@f0a7b2a)    
    ##  htmltools     0.5.1      2021-01-12 [1] CRAN (R 4.0.3)                     
    ##  jsonlite      1.7.2      2020-12-09 [1] CRAN (R 4.0.2)                     
    ##  knitr         1.30       2020-09-22 [1] CRAN (R 4.0.2)                     
    ##  lifecycle     0.2.0      2020-03-06 [1] CRAN (R 4.0.2)                     
    ##  magrittr      2.0.1      2020-11-17 [1] CRAN (R 4.0.2)                     
    ##  memuse        4.1-0      2020-02-17 [1] CRAN (R 4.0.2)                     
    ##  pacman      * 0.5.1      2019-03-11 [1] CRAN (R 4.0.2)                     
    ##  pillar        1.4.7      2020-11-20 [1] CRAN (R 4.0.2)                     
    ##  pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 4.0.2)                     
    ##  prompt        1.0.0      2021-01-01 [1] Github (gaborcsardi/prompt@b332c42)
    ##  purrr         0.3.4      2020-04-17 [1] CRAN (R 4.0.2)                     
    ##  R6            2.5.0      2020-10-28 [1] CRAN (R 4.0.2)                     
    ##  repr          1.1.0      2020-01-28 [1] CRAN (R 4.0.2)                     
    ##  rlang         0.4.10     2020-12-30 [1] CRAN (R 4.0.3)                     
    ##  rmarkdown     2.6        2020-12-14 [1] CRAN (R 4.0.2)                     
    ##  rstudioapi    0.13       2020-11-12 [1] CRAN (R 4.0.2)                     
    ##  sessioninfo * 1.1.1      2018-11-05 [1] CRAN (R 4.0.2)                     
    ##  skimr       * 2.1.2      2020-07-06 [1] CRAN (R 4.0.2)                     
    ##  stringi       1.5.3      2020-09-09 [1] CRAN (R 4.0.2)                     
    ##  stringr       1.4.0      2019-02-10 [1] CRAN (R 4.0.2)                     
    ##  tibble        3.0.5      2021-01-15 [1] CRAN (R 4.0.2)                     
    ##  tidyselect    1.1.0      2020-05-11 [1] CRAN (R 4.0.2)                     
    ##  vctrs         0.3.6      2020-12-17 [1] CRAN (R 4.0.2)                     
    ##  withr         2.4.0      2021-01-16 [1] CRAN (R 4.0.2)                     
    ##  xfun          0.20       2021-01-06 [1] CRAN (R 4.0.2)                     
    ##  yaml          2.2.1      2020-02-01 [1] CRAN (R 4.0.2)                     
    ## 
    ## [1] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
