Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks
2019-01-18

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
if (!require("dplyr"))
{
  install.packages("dplyr",
                   repos = c(CRAN = "https://cran.rstudio.com"))
}
```

    ## Loading required package: dplyr

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
countries <- readr::read_table(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt")[-1, c(1, 3)]
names(countries)[2] <- "COUNTRY_NAME"

country_list <- dplyr::left_join(countries, countrycode::codelist,
                   by = c("FIPS" = "fips"))

print(country_list)
```

    ## # A tibble: 292 x 682
    ##    FIPS  COUNTRY_NAME ar5   continent country.name.de country.name.de…
    ##    <chr> <chr>        <chr> <chr>     <chr>           <chr>           
    ##  1 AC    ANTIGUA AND… LAM   Americas  Antigua und Ba… antigua         
    ##  2 AF    AFGHANISTAN  ASIA  Asia      Afghanistan     afghan          
    ##  3 AG    ALGERIA      MAF   Africa    Algerien        algerien        
    ##  4 AI    ASCENSION I… <NA>  <NA>      <NA>            <NA>            
    ##  5 AJ    AZERBAIJAN   EIT   Asia      Aserbaidschan   aserbaidsch     
    ##  6 AL    ALBANIA      EIT   Europe    Albanien        albanien        
    ##  7 AM    ARMENIA      EIT   Asia      Armenien        armenien        
    ##  8 AN    ANDORRA      OECD… Europe    Andorra         andorra         
    ##  9 AO    ANGOLA       MAF   Africa    Angola          angola          
    ## 10 AQ    AMERICAN SA… ASIA  Oceania   Amerikanisch-S… ^(?=.*amerik).*…
    ## # … with 282 more rows, and 676 more variables: country.name.en <chr>,
    ## #   country.name.en.regex <chr>, cow.name <chr>, cowc <chr>, cown <int>,
    ## #   ecb <chr>, ecb.name <chr>, eu28 <chr>, eurocontrol_pru <chr>,
    ## #   eurocontrol_statfor <chr>, eurostat <chr>, eurostat.name <chr>,
    ## #   fao <int>, fao.name <chr>, fips.name <chr>, gaul <int>,
    ## #   genc.name <chr>, genc2c <chr>, genc3c <chr>, genc3n <chr>, gwc <chr>,
    ## #   gwn <int>, icao <chr>, icao_region <chr>, imf <int>, ioc <chr>,
    ## #   ioc.name <chr>, iso.name.en <chr>, iso.name.fr <chr>, iso2c <chr>,
    ## #   iso3c <chr>, iso3n <int>, p4.name <chr>, p4c <chr>, p4n <int>,
    ## #   region <chr>, un <int>, un.name.ar <chr>, un.name.en <chr>,
    ## #   un.name.es <chr>, un.name.fr <chr>, un.name.ru <chr>,
    ## #   un.name.zh <chr>, unpd <int>, unpd.name <chr>, vdem <int>,
    ## #   vdem.name <chr>, wb <chr>, wb_api.name <chr>, wb_api2c <chr>,
    ## #   wb_api3c <chr>, wb.name <chr>, wvs <int>, wvs.name <chr>,
    ## #   cldr.name.af <chr>, cldr.name.agq <chr>, cldr.name.ak <chr>,
    ## #   cldr.name.am <chr>, cldr.name.ar <chr>, cldr.name.ar_ly <chr>,
    ## #   cldr.name.ar_sa <chr>, cldr.name.as <chr>, cldr.name.asa <chr>,
    ## #   cldr.name.ast <chr>, cldr.name.az <chr>, cldr.name.az_cyrl <chr>,
    ## #   cldr.name.bas <chr>, cldr.name.be <chr>, cldr.name.bem <chr>,
    ## #   cldr.name.bez <chr>, cldr.name.bg <chr>, cldr.name.bm <chr>,
    ## #   cldr.name.bn <chr>, cldr.name.bn_in <chr>, cldr.name.bo <chr>,
    ## #   cldr.name.br <chr>, cldr.name.brx <chr>, cldr.name.bs <chr>,
    ## #   cldr.name.bs_cyrl <chr>, cldr.name.ca <chr>, cldr.name.ce <chr>,
    ## #   cldr.name.cgg <chr>, cldr.name.chr <chr>, cldr.name.ckb <chr>,
    ## #   cldr.name.cs <chr>, cldr.name.cu <chr>, cldr.name.cy <chr>,
    ## #   cldr.name.da <chr>, cldr.name.dav <chr>, cldr.name.de <chr>,
    ## #   cldr.name.de_at <chr>, cldr.name.de_ch <chr>, cldr.name.dje <chr>,
    ## #   cldr.name.dsb <chr>, cldr.name.dua <chr>, cldr.name.dyo <chr>,
    ## #   cldr.name.dz <chr>, cldr.name.ee <chr>, cldr.name.el <chr>,
    ## #   cldr.name.en <chr>, …

There are unnecessary data in several columns. *GSODR* only requires
FIPS, name, and ISO codes to function.

``` r
country_list <- dplyr::select(country_list, c("FIPS",
                                              "COUNTRY_NAME",
                                              "iso2c",
                                              "iso3c"))
country_list
```

    ## # A tibble: 292 x 4
    ##    FIPS  COUNTRY_NAME        iso2c iso3c
    ##    <chr> <chr>               <chr> <chr>
    ##  1 AC    ANTIGUA AND BARBUDA AG    ATG  
    ##  2 AF    AFGHANISTAN         AF    AFG  
    ##  3 AG    ALGERIA             DZ    DZA  
    ##  4 AI    ASCENSION ISLAND    <NA>  <NA> 
    ##  5 AJ    AZERBAIJAN          AZ    AZE  
    ##  6 AL    ALBANIA             AL    ALB  
    ##  7 AM    ARMENIA             AM    ARM  
    ##  8 AN    ANDORRA             AD    AND  
    ##  9 AO    ANGOLA              AO    AGO  
    ## 10 AQ    AMERICAN SAMOA      AS    ASM  
    ## # … with 282 more rows

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
\> “The following data and products may have conditions placed on their
international commercial use. They can be used within the U.S. or for \>
non-commercial international activities without restriction. The
non-U.S. \> data cannot be redistributed for commercial purposes.
Re-distribution of these \> data by others must provide this same
notification.” [WMO Resolution 40. NOAA
Policy](http://www.wmo.int/pages/about/Resolution40.html)

## R System Information

    ## ─ Session info ──────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 3.5.2 (2018-12-20)
    ##  os       macOS Mojave 10.14.2        
    ##  system   x86_64, darwin18.2.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2019-01-18                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version date       lib source        
    ##  assertthat    0.2.0   2017-04-11 [1] CRAN (R 3.5.2)
    ##  bindr         0.1.1   2018-03-13 [1] CRAN (R 3.5.2)
    ##  bindrcpp      0.2.2   2018-03-29 [1] CRAN (R 3.5.2)
    ##  cli           1.0.1   2018-09-25 [1] CRAN (R 3.5.2)
    ##  countrycode * 1.1.0   2018-10-27 [1] CRAN (R 3.5.2)
    ##  crayon        1.3.4   2017-09-16 [1] CRAN (R 3.5.2)
    ##  curl          3.3     2019-01-10 [1] CRAN (R 3.5.2)
    ##  digest        0.6.18  2018-10-10 [1] CRAN (R 3.5.2)
    ##  dplyr       * 0.7.8   2018-11-10 [1] CRAN (R 3.5.2)
    ##  evaluate      0.12    2018-10-09 [1] CRAN (R 3.5.2)
    ##  fansi         0.4.0   2018-10-05 [1] CRAN (R 3.5.2)
    ##  glue          1.3.0   2018-07-17 [1] CRAN (R 3.5.2)
    ##  hms           0.4.2   2018-03-10 [1] CRAN (R 3.5.2)
    ##  htmltools     0.3.6   2017-04-28 [1] CRAN (R 3.5.2)
    ##  knitr         1.21    2018-12-10 [1] CRAN (R 3.5.2)
    ##  magrittr      1.5     2014-11-22 [1] CRAN (R 3.5.2)
    ##  pillar        1.3.1   2018-12-15 [1] CRAN (R 3.5.2)
    ##  pkgconfig     2.0.2   2018-08-16 [1] CRAN (R 3.5.2)
    ##  purrr         0.2.5   2018-05-29 [1] CRAN (R 3.5.2)
    ##  R6            2.3.0   2018-10-04 [1] CRAN (R 3.5.2)
    ##  Rcpp          1.0.0   2018-11-07 [1] CRAN (R 3.5.2)
    ##  readr         1.3.1   2018-12-21 [1] CRAN (R 3.5.2)
    ##  rlang         0.3.1   2019-01-08 [1] CRAN (R 3.5.2)
    ##  rmarkdown     1.11    2018-12-08 [1] CRAN (R 3.5.2)
    ##  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 3.5.2)
    ##  stringi       1.2.4   2018-07-20 [1] CRAN (R 3.5.2)
    ##  stringr       1.3.1   2018-05-10 [1] CRAN (R 3.5.2)
    ##  tibble        2.0.1   2019-01-12 [1] CRAN (R 3.5.2)
    ##  tidyselect    0.2.5   2018-10-11 [1] CRAN (R 3.5.2)
    ##  utf8          1.1.4   2018-05-24 [1] CRAN (R 3.5.2)
    ##  withr         2.1.2   2018-03-15 [1] CRAN (R 3.5.2)
    ##  xfun          0.4     2018-10-23 [1] CRAN (R 3.5.2)
    ##  yaml          2.2.0   2018-07-25 [1] CRAN (R 3.5.2)
    ## 
    ## [1] /Users/U8004755/Library/R/3.x/library
    ## [2] /usr/local/lib/R/3.5/site-library
    ## [3] /usr/local/Cellar/r/3.5.2/lib/R/library
