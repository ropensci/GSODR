Fetch, Clean and Correct Altitude in GSOD ‘isd\_history.csv’ Data
================
Adam H. Sparks
2019-08-15

# Introduction

The isd\_history file details station metadata including the start and
stop years used by GSODR to pre-check requests before querying the
server for download and the country code used by GSODR when subsetting
for requests by country.

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

## Download data from Natural Earth and NCEI

``` r
# download data
isd_history <- fread("ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")
```

## Add/drop columns and save to disk

``` r
# add STNID column
isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
setcolorder(isd_history, "STNID")
setnames(isd_history, "STATION NAME", "NAME")
setkey(isd_history, "STNID")

# remove extra columns
isd_history[, c("USAF", "WBAN", "ICAO", "ELEV(M)") := NULL]
```

## View and save the data

``` r
isd_history
```

    ##               STNID                                              NAME CTRY
    ##     1: 007018-99999                                        WXPOD 7018     
    ##     2: 007026-99999                                        WXPOD 7026   AF
    ##     3: 007070-99999                                        WXPOD 7070   AF
    ##     4: 008260-99999                                         WXPOD8270     
    ##     5: 008268-99999                                         WXPOD8278   AF
    ##    ---                                                                    
    ## 29724:   A07355-241                         VIROQUA MUNICIPAL AIRPORT   US
    ## 29725:   A07357-182 ELBOW LAKE MUNICIPAL PRIDE OF THE PRAIRIE AIRPORT   US
    ## 29726:   A07359-240                              IONIA COUNTY AIRPORT   US
    ## 29727:   A51255-445                       DEMOPOLIS MUNICIPAL AIRPORT   US
    ## 29728:   A51256-451      BRANSON WEST MUNICIPAL EMERSON FIELD AIRPORT   US
    ##        STATE    LAT     LON    BEGIN      END
    ##     1:        0.000   0.000 20110309 20130730
    ##     2:        0.000   0.000 20120713 20170822
    ##     3:        0.000   0.000 20140923 20150926
    ##     4:        0.000   0.000 20050101 20100731
    ##     5:       32.950  65.567 20100519 20120323
    ##    ---                                       
    ## 29724:    WI 43.579 -90.913 20140731 20190811
    ## 29725:    MN 45.986 -95.992 20140731 20190811
    ## 29726:    MI 42.938 -85.061 20140731 20190811
    ## 29727:    AL 32.464 -87.954 20140731 20190812
    ## 29728:    MO 36.699 -93.402 20140731 20190811

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
    ##  date     2019-08-15                  
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
