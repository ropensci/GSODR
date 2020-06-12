Fetch and Clean ‘isd\_history.csv’ File
================
Adam H. Sparks
2020-06-12

# Introduction

The isd\_history.csv file details GSOD station metadata. These data
include the start and stop years used by *GSODR* to pre-check requests
before querying the server for download and the country code used by
*GSODR* when subsetting for requests by country. The following checks
are performed on the raw data file before inclusion in *GSODR*,

  - Check for valid lon and lat values;
    
      - isd\_history where latitude or longitude are `NA` or both 0 are
        removed leaving only properly georeferenced stations,
    
      - isd\_history where latitude is \< -90˚ or \> 90˚ are removed,
    
      - isd\_history where longitude is \< -180˚ or \> 180˚ are removed.

  - A new field, STNID, a concatenation of the USAF and WBAN fields, is
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
```

## View and save the data

``` r
str(isd_history)
```

    ## Classes 'data.table' and 'data.frame':   26680 obs. of  11 variables:
    ##  $ STNID       : chr  "008268-99999" "409000-99999" "409010-99999" "409030-99999" ...
    ##  $ NAME        : chr  "WXPOD8278" "DARWAZ" "KHWAHAN" "KHWAJA-GHAR" ...
    ##  $ LAT         : num  33 38.4 37.9 37.1 37.1 ...
    ##  $ LON         : num  65.6 70.8 70.2 69.4 70.5 ...
    ##  $ CTRY        : chr  "AF" "AF" "AF" "AF" ...
    ##  $ STATE       : chr  "" "" "" "" ...
    ##  $ BEGIN       : int  20100519 19730304 19730629 20010925 19730304 20171229 19730701 19730101 19800316 19730101 ...
    ##  $ END         : int  20120323 20070905 20070608 20010925 20130703 20171229 20090511 20130313 20010828 20200609 ...
    ##  $ COUNTRY_NAME: chr  "AFGHANISTAN" "AFGHANISTAN" "AFGHANISTAN" "AFGHANISTAN" ...
    ##  $ ISO2C       : chr  "AF" "AF" "AF" "AF" ...
    ##  $ ISO3C       : chr  "AFG" "AFG" "AFG" "AFG" ...
    ##  - attr(*, ".internal.selfref")=<externalptr>

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
website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

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
    ##  version  R version 4.0.1 (2020-06-06)
    ##  os       macOS Catalina 10.15.5      
    ##  system   x86_64, darwin17.0          
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2020-06-12                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version date       lib source                             
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.0)                     
    ##  base64enc     0.1-3   2015-07-28 [1] CRAN (R 4.0.0)                     
    ##  cli           2.0.2   2020-02-28 [1] CRAN (R 4.0.0)                     
    ##  clisymbols    1.2.0   2017-05-21 [1] CRAN (R 4.0.0)                     
    ##  countrycode * 1.2.0   2020-05-22 [1] CRAN (R 4.0.0)                     
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.0)                     
    ##  curl          4.3     2019-12-02 [1] CRAN (R 4.0.0)                     
    ##  data.table  * 1.12.8  2019-12-09 [1] CRAN (R 4.0.0)                     
    ##  digest        0.6.25  2020-02-23 [1] CRAN (R 4.0.0)                     
    ##  dplyr         1.0.0   2020-05-29 [1] CRAN (R 4.0.0)                     
    ##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.0)                     
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.0)                     
    ##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.0)                     
    ##  generics      0.0.2   2018-11-29 [1] CRAN (R 4.0.0)                     
    ##  glue          1.4.1   2020-05-13 [1] CRAN (R 4.0.0)                     
    ##  htmltools     0.4.0   2019-10-04 [1] CRAN (R 4.0.0)                     
    ##  jsonlite      1.6.1   2020-02-02 [1] CRAN (R 4.0.0)                     
    ##  knitr         1.28    2020-02-06 [1] CRAN (R 4.0.0)                     
    ##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.0)                     
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 4.0.0)                     
    ##  pacman      * 0.5.1   2019-03-11 [1] CRAN (R 4.0.0)                     
    ##  pillar        1.4.4   2020-05-05 [1] CRAN (R 4.0.0)                     
    ##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.0)                     
    ##  prompt        1.0.0   2020-04-25 [1] Github (gaborcsardi/prompt@b332c42)
    ##  purrr         0.3.4   2020-04-17 [1] CRAN (R 4.0.0)                     
    ##  R6            2.4.1   2019-11-12 [1] CRAN (R 4.0.0)                     
    ##  Rcpp          1.0.4.6 2020-04-09 [1] CRAN (R 4.0.0)                     
    ##  repr          1.1.0   2020-01-28 [1] CRAN (R 4.0.0)                     
    ##  rlang         0.4.6   2020-05-02 [1] CRAN (R 4.0.0)                     
    ##  rmarkdown     2.2     2020-05-31 [1] CRAN (R 4.0.0)                     
    ##  rstudioapi    0.11    2020-02-07 [1] CRAN (R 4.0.0)                     
    ##  sessioninfo * 1.1.1   2018-11-05 [1] CRAN (R 4.0.0)                     
    ##  skimr       * 2.1.1   2020-04-16 [1] CRAN (R 4.0.0)                     
    ##  stringi       1.4.6   2020-02-17 [1] CRAN (R 4.0.0)                     
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.0.0)                     
    ##  tibble        3.0.1   2020-04-20 [1] CRAN (R 4.0.0)                     
    ##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.0)                     
    ##  vctrs         0.3.1   2020-06-05 [1] CRAN (R 4.0.0)                     
    ##  withr         2.2.0   2020-04-20 [1] CRAN (R 4.0.0)                     
    ##  xfun          0.14    2020-05-20 [1] CRAN (R 4.0.0)                     
    ##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.0)                     
    ## 
    ## [1] /Users/adamsparks/.R/library
    ## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
