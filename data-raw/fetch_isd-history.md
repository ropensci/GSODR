Fetch and Clean ‘isd\_history.csv’ File
================
Adam H. Sparks
2020-09-06

Introduction
============

The isd\_history.csv file details GSOD station metadata. These data
include the start and stop years used by *GSODR* to pre-check requests
before querying the server for download and the country code used by
*GSODR* when subsetting for requests by country. The following checks
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

Data Processing
===============

Set up workspace
----------------

    if (!require("pacman")) {
      install.packages("pacman", repos = "https://cran.rstudio.com/")
    }
    pacman::p_load("sessioninfo", "skimr", "countrycode", "data.table")

Download and clean data
-----------------------

    # download data
    isd_history <- fread("https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")

Add/drop columns and save to disk
---------------------------------

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

Add country names based on FIPS
-------------------------------

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

View and save the data
----------------------

    str(isd_history)

    ## Classes 'data.table' and 'data.frame':   26691 obs. of  11 variables:
    ##  $ STNID       : chr  "008268-99999" "409000-99999" "409010-99999" "409030-99999" ...
    ##  $ NAME        : chr  "WXPOD8278" "DARWAZ" "KHWAHAN" "KHWAJA-GHAR" ...
    ##  $ LAT         : num  33 38.4 37.9 37.1 37.1 ...
    ##  $ LON         : num  65.6 70.8 70.2 69.4 70.5 ...
    ##  $ CTRY        : chr  "AF" "AF" "AF" "AF" ...
    ##  $ STATE       : chr  "" "" "" "" ...
    ##  $ BEGIN       : int  20100519 19730304 19730629 20010925 19730304 20171229 19730701 19730101 19800316 19730101 ...
    ##  $ END         : int  20120323 20070905 20070608 20010925 20130703 20171229 20090511 20130313 20010828 20200902 ...
    ##  $ COUNTRY_NAME: chr  "AFGHANISTAN" "AFGHANISTAN" "AFGHANISTAN" "AFGHANISTAN" ...
    ##  $ ISO2C       : chr  "AF" "AF" "AF" "AF" ...
    ##  $ ISO3C       : chr  "AFG" "AFG" "AFG" "AFG" ...
    ##  - attr(*, ".internal.selfref")=<externalptr>

    # write rda file to disk for use with GSODR package
    save(isd_history,
         file = "../inst/extdata/isd_history.rda",
         compress = "bzip2")

Notes
=====

NOAA policy
-----------

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

R System Information
--------------------

    ## ─ Session info ───────────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 4.0.2 (2020-06-22)
    ##  os       macOS Catalina 10.15.6      
    ##  system   x86_64, darwin17.0          
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2020-09-06                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version date       lib source        
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.2)
    ##  base64enc     0.1-3   2015-07-28 [1] CRAN (R 4.0.2)
    ##  cli           2.0.2   2020-02-28 [1] CRAN (R 4.0.2)
    ##  countrycode * 1.2.0   2020-05-22 [1] CRAN (R 4.0.2)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 4.0.2)
    ##  curl          4.3     2019-12-02 [1] CRAN (R 4.0.1)
    ##  data.table  * 1.13.1  2020-08-19 [1] local         
    ##  digest        0.6.25  2020-02-23 [1] CRAN (R 4.0.2)
    ##  dplyr         1.0.2   2020-08-18 [1] CRAN (R 4.0.2)
    ##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.2)
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.1)
    ##  fansi         0.4.1   2020-01-08 [1] CRAN (R 4.0.2)
    ##  generics      0.0.2   2018-11-29 [1] CRAN (R 4.0.2)
    ##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)
    ##  htmltools     0.5.0   2020-06-16 [1] CRAN (R 4.0.2)
    ##  jsonlite      1.7.0   2020-06-25 [1] CRAN (R 4.0.2)
    ##  knitr         1.29    2020-06-23 [1] CRAN (R 4.0.2)
    ##  lifecycle     0.2.0   2020-03-06 [1] CRAN (R 4.0.2)
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 4.0.2)
    ##  pacman      * 0.5.1   2019-03-11 [1] CRAN (R 4.0.2)
    ##  pillar        1.4.6   2020-07-10 [1] CRAN (R 4.0.2)
    ##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.2)
    ##  purrr         0.3.4   2020-04-17 [1] CRAN (R 4.0.2)
    ##  R6            2.4.1   2019-11-12 [1] CRAN (R 4.0.2)
    ##  repr          1.1.0   2020-01-28 [1] CRAN (R 4.0.2)
    ##  rlang         0.4.7   2020-07-09 [1] CRAN (R 4.0.2)
    ##  rmarkdown     2.3     2020-06-18 [1] CRAN (R 4.0.2)
    ##  sessioninfo * 1.1.1   2018-11-05 [1] CRAN (R 4.0.2)
    ##  skimr       * 2.1.2   2020-07-06 [1] CRAN (R 4.0.2)
    ##  stringi       1.4.6   2020-02-17 [1] CRAN (R 4.0.2)
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.0.2)
    ##  tibble        3.0.3   2020-07-10 [1] CRAN (R 4.0.2)
    ##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.2)
    ##  vctrs         0.3.4   2020-08-29 [1] CRAN (R 4.0.2)
    ##  withr         2.2.0   2020-04-20 [1] CRAN (R 4.0.2)
    ##  xfun          0.16    2020-07-24 [1] CRAN (R 4.0.2)
    ##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.2)
    ## 
    ## [1] /Users/adamsparks/.R/library
    ## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
