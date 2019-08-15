Fetch, Clean and Correct Altitude in GSOD ‘isd\_history.csv’ Data
================
Adam H. Sparks
2019-08-16

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

if (!require("data.table")) {
  install.packages("data.table", repos = "https://cran.rstudio.com/")
}
```

## Download and clean data

``` r
# download data
isd_history <- fread("ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")

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

## View and save the data

``` r
isd_history
```

    ##               STNID                            NAME CTRY STATE    LAT
    ##     1: 008268-99999                       WXPOD8278   AF       32.950
    ##     2: 010010-99999             JAN MAYEN(NOR-NAVY)   NO       70.933
    ##     3: 010014-99999                      SORSTOKKEN   NO       59.792
    ##     4: 010015-99999                      BRINGELAND   NO       61.383
    ##     5: 010016-99999                     RORVIK/RYUM   NO       64.850
    ##    ---                                                               
    ## 26800: A00023-63890 WHITEHOUSE NAVAL OUTLYING FIELD   US    FL 30.350
    ## 26801: A00024-53848    CHOCTAW NAVAL OUTLYING FIELD   US    FL 30.507
    ## 26802: A00026-94297                 COUPEVILLE/NOLF   US    WA 48.217
    ## 26803: A00029-63820         EVERETT-STEWART AIRPORT   US    TN 36.380
    ## 26804: A00032-25715                    ATKA AIRPORT   US    AK 52.220
    ##             LON    BEGIN      END
    ##     1:   65.567 20100519 20120323
    ##     2:   -8.667 19310101 20190810
    ##     3:    5.341 19861120 20190809
    ##     4:    5.867 19870117 20081231
    ##     5:   11.233 19870116 19910806
    ##    ---                           
    ## 26800:  -81.883 20070601 20190810
    ## 26801:  -86.960 20070601 20190810
    ## 26802: -122.633 20060324 20150514
    ## 26803:  -88.985 20130627 20190811
    ## 26804: -174.206 20060101 20190811

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
    ##  date     2019-08-16                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       lib source        
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
    ##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
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
    ##  rmarkdown     1.14    2019-07-12 [1] CRAN (R 3.6.0)
    ##  sessioninfo * 1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
    ##  skimr       * 1.0.7   2019-06-20 [1] CRAN (R 3.6.0)
    ##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
    ##  tibble        2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
    ##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
    ##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
    ##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
    ##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
    ## 
    ## [1] /Users/adamsparks/Library/R/3.x/library
    ## [2] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
