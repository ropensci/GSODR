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
if (!require("readr")) {
  install.packages("readr", repos = "https://cran.rstudio.com/")
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
```

## Download data from Natural Earth and NCEI

``` r
# download data
isd_history <- read_csv(
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

## Add/drop columns and save to disk

``` r
# add STNID column
setDT(isd_history)
isd_history[, STNID := paste(USAF, WBAN, sep = "-")]

# clean data
isd_history[, c("USAF", "WBAN", "ELEV_M") := NULL]

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
    ##  date     2019-08-15                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       lib source        
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
    ##  backports     1.1.4   2019-04-10 [1] CRAN (R 3.6.0)
    ##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
    ##  curl          4.0     2019-07-22 [1] CRAN (R 3.6.0)
    ##  data.table  * 1.12.2  2019-04-07 [1] CRAN (R 3.6.0)
    ##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
    ##  dplyr         0.8.3   2019-07-04 [1] CRAN (R 3.6.0)
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
    ##  glue          1.3.1   2019-03-12 [1] CRAN (R 3.6.0)
    ##  hms           0.5.0   2019-07-09 [1] CRAN (R 3.6.0)
    ##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
    ##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.0)
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
    ##  pillar        1.4.2   2019-06-29 [1] CRAN (R 3.6.0)
    ##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.6.0)
    ##  purrr         0.3.2   2019-03-15 [1] CRAN (R 3.6.0)
    ##  R6            2.4.0   2019-02-14 [1] CRAN (R 3.6.0)
    ##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
    ##  readr       * 1.3.1   2018-12-21 [1] CRAN (R 3.6.0)
    ##  rlang         0.4.0   2019-06-25 [1] CRAN (R 3.6.0)
    ##  rmarkdown     1.14    2019-07-12 [1] CRAN (R 3.6.0)
    ##  sessioninfo * 1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
    ##  skimr       * 1.0.7   2019-06-20 [1] CRAN (R 3.6.0)
    ##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
    ##  tibble        2.1.3   2019-06-06 [1] CRAN (R 3.6.0)
    ##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.6.0)
    ##  vctrs         0.2.0   2019-07-05 [1] CRAN (R 3.6.0)
    ##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
    ##  xfun          0.8     2019-06-25 [1] CRAN (R 3.6.0)
    ##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
    ##  zeallot       0.1.0   2018-01-28 [1] CRAN (R 3.6.0)
    ## 
    ## [1] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
