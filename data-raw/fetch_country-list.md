Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks
2018-01-24

# Introduction

This document details how to fetch the country list provided by the NCEI
for the GSOD stations from the FTP server and merge it with ISO codes
from the [*countrycode*](https://cran.r-project.org/package=countrycode)
package for inclusion in the *GSODR* package in /data/country-list.rda.
These codes are used when a user selects a single country for a data
query.

# R Data Processing

Read “country-list.txt” file from NCEI FTP server and merge with
*countrycode* data.

``` r
if (!require("countrycode"))
{
  install.packages("countrycode")
}
```

    ## Loading required package: countrycode

``` r
countries <- readr::read_table(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt")[-1, c(1, 3)]
```

    ## Parsed with column specification:
    ## cols(
    ##   FIPS = col_character(),
    ##   ID = col_character(),
    ##   `COUNTRY NAME` = col_character()
    ## )

``` r
names(countries)[2] <- "COUNTRY_NAME"

country_list <- dplyr::left_join(countries, countrycode::countrycode_data,
                   by = c(FIPS = "fips105"))

print(country_list)
```

    ## # A tibble: 293 x 35
    ##    FIPS  COUNTRY_NAME   ar5    continent cowc   cown eu28  eurocontrol_pru
    ##    <chr> <chr>          <chr>  <chr>     <chr> <int> <chr> <chr>          
    ##  1 AA    ARUBA          LAM    Americas  <NA>     NA <NA>  Southern Ameri…
    ##  2 AC    ANTIGUA AND B… LAM    Americas  AAB      58 <NA>  Southern Ameri…
    ##  3 AF    AFGHANISTAN    ASIA   Asia      AFG     700 <NA>  Asia           
    ##  4 AG    ALGERIA        MAF    Africa    ALG     615 <NA>  Africa         
    ##  5 AI    ASCENSION ISL… <NA>   <NA>      <NA>     NA <NA>  <NA>           
    ##  6 AJ    AZERBAIJAN     EIT    Asia      AZE     373 <NA>  Asia           
    ##  7 AL    ALBANIA        EIT    Europe    ALB     339 <NA>  Eurocontrol    
    ##  8 AM    ARMENIA        EIT    Asia      ARM     371 <NA>  Eurocontrol    
    ##  9 AN    ANDORRA        OECD1… Europe    AND     232 <NA>  <NA>           
    ## 10 AO    ANGOLA         MAF    Africa    ANG     540 <NA>  Africa         
    ## # ... with 283 more rows, and 27 more variables:
    ## #   eurocontrol_statfor <chr>, fao <int>, icao <chr>, icao_region <chr>,
    ## #   imf <int>, ioc <chr>, iso2c <chr>, iso3c <chr>, iso3n <int>,
    ## #   region <chr>, un <int>, wb <chr>, country.name.ar <chr>,
    ## #   country.name.de <chr>, country.name.de.regex <chr>,
    ## #   country.name.en <chr>, country.name.en.regex <chr>,
    ## #   country.name.es <chr>, country.name.fr <chr>, country.name.ru <chr>,
    ## #   country.name.zh <chr>, eurostat <chr>, wb_api2c <chr>, wb_api3c <chr>,
    ## #   p4_scode <chr>, p4_ccode <dbl>, wvs <int>

There are unnecessary data in several columns. *GSODR* only requires
FIPS, name, and ISO codes to function.

``` r
country_list <- (country_list[, -c(3:14, 17:35)])

country_list
```

    ## # A tibble: 293 x 4
    ##    FIPS  COUNTRY_NAME        iso2c iso3c
    ##    <chr> <chr>               <chr> <chr>
    ##  1 AA    ARUBA               AW    ABW  
    ##  2 AC    ANTIGUA AND BARBUDA AG    ATG  
    ##  3 AF    AFGHANISTAN         AF    AFG  
    ##  4 AG    ALGERIA             DZ    DZA  
    ##  5 AI    ASCENSION ISLAND    <NA>  <NA> 
    ##  6 AJ    AZERBAIJAN          AZ    AZE  
    ##  7 AL    ALBANIA             AL    ALB  
    ##  8 AM    ARMENIA             AM    ARM  
    ##  9 AN    ANDORRA             AD    AND  
    ## 10 AO    ANGOLA              AO    AGO  
    ## # ... with 283 more rows

Write .rda file to disk.

``` r
save(country_list, file = "../inst/extdata/country_list.rda",
     compress = "bzip2")
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
    ##  version  R version 3.4.3 (2017-11-30)
    ##  os       macOS Sierra 10.12.6        
    ##  system   x86_64, darwin16.7.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2018-01-24                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version    date       source                          
    ##  assertthat    0.2.0      2017-04-11 CRAN (R 3.4.3)                  
    ##  backports     1.1.2      2017-12-13 CRAN (R 3.4.3)                  
    ##  bindr         0.1        2016-11-13 CRAN (R 3.4.3)                  
    ##  bindrcpp      0.2        2017-06-17 CRAN (R 3.4.3)                  
    ##  cli           1.0.0      2017-11-05 CRAN (R 3.4.3)                  
    ##  clisymbols    1.2.0      2017-05-21 CRAN (R 3.4.3)                  
    ##  countrycode * 0.19       2017-02-06 CRAN (R 3.4.3)                  
    ##  crayon        1.3.4      2017-09-16 CRAN (R 3.4.3)                  
    ##  curl          3.1        2017-12-12 CRAN (R 3.4.3)                  
    ##  digest        0.6.14     2018-01-14 CRAN (R 3.4.3)                  
    ##  dplyr         0.7.4      2017-09-28 CRAN (R 3.4.3)                  
    ##  evaluate      0.10.1     2017-06-24 CRAN (R 3.4.3)                  
    ##  glue          1.2.0      2017-10-29 CRAN (R 3.4.3)                  
    ##  hms           0.4.0      2017-11-23 CRAN (R 3.4.3)                  
    ##  htmltools     0.3.6      2017-04-28 CRAN (R 3.4.3)                  
    ##  knitr         1.18       2017-12-27 CRAN (R 3.4.3)                  
    ##  magrittr      1.5        2014-11-22 CRAN (R 3.4.3)                  
    ##  pillar        1.1.0      2018-01-14 CRAN (R 3.4.3)                  
    ##  pkgconfig     2.0.1      2017-03-21 CRAN (R 3.4.3)                  
    ##  R6            2.2.2      2017-06-17 CRAN (R 3.4.3)                  
    ##  Rcpp          0.12.15    2018-01-20 cran (@0.12.15)                 
    ##  readr         1.1.1      2017-05-16 CRAN (R 3.4.3)                  
    ##  rlang         0.1.6.9003 2018-01-23 Github (tidyverse/rlang@4b4483a)
    ##  rmarkdown     1.8        2017-11-17 CRAN (R 3.4.3)                  
    ##  rprojroot     1.3-2      2018-01-03 CRAN (R 3.4.3)                  
    ##  sessioninfo   1.0.0      2017-06-21 CRAN (R 3.4.3)                  
    ##  stringi       1.1.6      2017-11-17 CRAN (R 3.4.3)                  
    ##  stringr       1.2.0      2017-02-18 CRAN (R 3.4.3)                  
    ##  tibble        1.4.2      2018-01-22 cran (@1.4.2)                   
    ##  utf8          1.1.3      2018-01-03 CRAN (R 3.4.3)                  
    ##  withr         2.1.1.9000 2018-01-16 Github (jimhester/withr@df18523)
    ##  yaml          2.1.16     2017-12-12 CRAN (R 3.4.3)
