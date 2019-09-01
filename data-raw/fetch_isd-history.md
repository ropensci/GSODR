Fetch, Clean and Correct Altitude in GSOD ‘isd\_history.csv’ Data
================
Adam H. Sparks
2019-09-02

# Introduction

The isd\_history file details station metadata including the start and
stop years used by GSODR to pre-check requests before querying the
server for download and the country code used by GSODR when subsetting
for requests by country. The following changes are made to the raw data
file for inclusion in *GSODR*:

  - isd\_history where latitude or longitude are `NA` or both 0 are
    removed

  - isd\_history where latitude is \< -90˚ or \> 90˚ are removed

  - isd\_history where longitude is \< -180˚ or \> 180˚ are removed

  - A new field, STNID, a concatenation of the USAF and WBAN fields, is
    added

# Data Processing

## Set up workspace

``` r
if (!require("sessioninfo")) {
  install.packages("sessioninfo", repos = "https://cran.rstudio.com/")
}

if (!require("skimr")) {
  install.packages("skimr", repos = "https://cran.rstudio.com/")
}

if (!require("countrycode"))
{
  install.packages("countrycode",
                   repos = c(CRAN = "https://cran.rstudio.com"))
}

if (!require("data.table")) {
  install.packages("data.table", repos = "https://cran.rstudio.com/")
}
```

## Download and clean data

``` r
# download data
isd_history <- fread("https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")

# clean data
isd_history[isd_history == -999] <- NA
isd_history[isd_history == -999.9] <- NA
isd_history <- isd_history[!is.na(isd_history$LAT) & !is.na(isd_history$LON), ]
isd_history <- isd_history[isd_history$LAT != 0 & isd_history$LON != 0, ]
isd_history <- isd_history[isd_history$LAT > -90 & isd_history$LAT < 90, ]
isd_history <- isd_history[isd_history$LON > -180 & isd_history$LON < 180, ]
```

## Add/drop columns and save to disk

``` r
# add STNID column
isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
setcolorder(isd_history, "STNID")
setnames(isd_history, "STATION NAME", "NAME")
setkey(isd_history, "STNID")

# drop stations not in GSOD data
isd_history[, STNID_len := nchar(STNID)]
isd_history <- subset(isd_history, STNID_len == 12)

# remove extra columns
isd_history[, c("USAF", "WBAN", "ICAO", "ELEV(M)", "STNID_len") := NULL]
```

## Add country names based on FIPS

``` r
isd_history <-
  isd_history[countrycode::codelist, on = c("CTRY" = "fips")]

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

names(isd_history) <- toupper(names(isd_history))
setnames(isd_history, "CTRY", "FIPS")
```

## View and save the data

``` r
isd_history
```

    ##               STNID          NAME     LAT    LON FIPS STATE    BEGIN
    ##     1: 008268-99999     WXPOD8278  32.950 65.567   AF       20100519
    ##     2: 409000-99999        DARWAZ  38.433 70.800   AF       19730304
    ##     3: 409010-99999       KHWAHAN  37.883 70.217   AF       19730629
    ##     4: 409030-99999   KHWAJA-GHAR  37.083 69.433   AF       20010925
    ##     5: 409040-99999      FAIZABAD  37.117 70.517   AF       19730304
    ##    ---                                                              
    ## 26689: 679770-99999 BUFFALO RANGE -21.008 31.579   ZI       19651201
    ## 26690: 679790-99999          ZAKA -20.333 31.467   ZI       19870307
    ## 26691: 679830-99999      CHIPINGE -20.200 32.617   ZI       19490103
    ## 26692: 679890-99999        RUPISI -20.417 32.317   ZI       19620701
    ## 26693: 679910-99999    BEITBRIDGE -22.217 30.000   ZI       19620701
    ##             END COUNTRY.NAME.EN ISO2C ISO3C
    ##     1: 20120323     Afghanistan    AF   AFG
    ##     2: 20070905     Afghanistan    AF   AFG
    ##     3: 20070608     Afghanistan    AF   AFG
    ##     4: 20010925     Afghanistan    AF   AFG
    ##     5: 20130703     Afghanistan    AF   AFG
    ##    ---                                     
    ## 26689: 20190829        Zimbabwe    ZW   ZWE
    ## 26690: 20190829        Zimbabwe    ZW   ZWE
    ## 26691: 20190829        Zimbabwe    ZW   ZWE
    ## 26692: 19680630        Zimbabwe    ZW   ZWE
    ## 26693: 20190829        Zimbabwe    ZW   ZWE

``` r
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
    ##  date     2019-09-02                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       lib source        
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
    ##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
    ##  countrycode * 1.1.0   2018-10-27 [1] CRAN (R 3.6.0)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
    ##  curl          4.0     2019-07-22 [1] CRAN (R 3.6.1)
    ##  data.table  * 1.12.2  2019-04-07 [1] CRAN (R 3.6.0)
    ##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
    ##  dplyr         0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
    ##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
    ##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
    ##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.1)
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
    ##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
    ##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
    ##  purrr         0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
    ##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
    ##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
    ##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
    ##  rmarkdown     1.15    2019-08-21 [1] CRAN (R 3.6.0)
    ##  sessioninfo * 1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
    ##  skimr       * 1.0.7   2019-06-20 [1] CRAN (R 3.6.0)
    ##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
    ##  tibble        2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
    ##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
    ##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
    ##  xfun          0.9     2019-08-21 [1] CRAN (R 3.6.0)
    ##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
    ## 
    ## [1] /Users/adamsparks/Library/R/3.x/library
    ## [2] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
