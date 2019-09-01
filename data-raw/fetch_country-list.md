Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks
2019-09-01

# Introduction

This document details how to fetch the country list provided by the NCEI
for the GSOD stations from the FTP server and merge it with ISO codes
from the [*countrycode*](https://cran.r-project.org/package=countrycode)
package for inclusion in the *GSODR* package in
`/data/country-list.rda`. These codes are used when a user selects a
single country for a data query.

# R Data Processing

Read “country-list.txt” file from NCEI FTP server and merge with
*countrycode* data.

``` r
if (!require("countrycode"))
{
  install.packages("countrycode",
                   repos = c(CRAN = "https://cran.rstudio.com"))
}
```

    ## Loading required package: countrycode

``` r
if (!require("data.table"))
{
  install.packages("data.table",
                   repos = c(CRAN = "https://cran.rstudio.com"))
}
```

    ## Loading required package: data.table

``` r
countries <-
  readLines("https://www1.ncdc.noaa.gov/pub/data/igra/igra2-country-list.txt")[-2]

countries <- read.fwf(textConnection(countries), widths = c(8, 59))

names(countries) <- c("fips", "country_name")
countries <- countries[-1, ] # drop first row that contained colnames

countries <-
  data.frame(lapply(countries, as.character), stringsAsFactors = FALSE)
countries <-
  data.frame(lapply(countries, trimws), stringsAsFactors = FALSE)

country_list <- merge(x = countries,
                      y =  countrycode::codelist,
                      by = "fips")
```

There are unnecessary data in several columns. *GSODR* only requires the
FIPS code, country name, and ISO codes to function.

``` r
country_list <- country_list[, c("fips",
                                 "country_name",
                                 "iso2c",
                                 "iso3c")]
names(country_list) <- toupper(names(country_list))
data.table::setDT(country_list, key = "FIPS")

country_list
```

    ## Empty data.table (0 rows and 4 cols): FIPS,COUNTRY_NAME,ISO2C,ISO3C

Write .rda file to disk.

``` r
save(country_list, file = "../inst/extdata/country_list.rda",
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
> notification.”

[WMO Resolution 40. NOAA
Policy](http://www.wmo.int/pages/about/Resolution40.html)

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
    ##  date     2019-09-01                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       lib source        
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 3.6.0)
    ##  cli           1.1.0   2019-03-19 [1] CRAN (R 3.6.0)
    ##  countrycode * 1.1.0   2018-10-27 [1] CRAN (R 3.6.0)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.6.0)
    ##  data.table  * 1.12.2  2019-04-07 [1] CRAN (R 3.6.0)
    ##  digest        0.6.20  2019-07-04 [1] CRAN (R 3.6.0)
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 3.6.0)
    ##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.6.0)
    ##  knitr         1.24    2019-08-08 [1] CRAN (R 3.6.1)
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.6.0)
    ##  Rcpp          1.0.2   2019-07-25 [1] CRAN (R 3.6.0)
    ##  rmarkdown     1.15    2019-08-21 [1] CRAN (R 3.6.0)
    ##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.6.0)
    ##  stringi       1.4.3   2019-03-12 [1] CRAN (R 3.6.0)
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 3.6.0)
    ##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.6.0)
    ##  xfun          0.9     2019-08-21 [1] CRAN (R 3.6.0)
    ##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.6.0)
    ## 
    ## [1] /Users/adamsparks/Library/R/3.x/library
    ## [2] /Library/Frameworks/R.framework/Versions/3.6/Resources/library
