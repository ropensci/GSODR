Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks
2018-03-07

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

country_list <- dplyr::left_join(countries, countrycode::codelist,
                   by = c("FIPS" = "fips"))

print(country_list)
```

    ## # A tibble: 293 x 678
    ##    FIPS  COUNTRY_NAME   ar5    continent country.name.de country.name.de.…
    ##    <chr> <chr>          <chr>  <chr>     <chr>           <chr>            
    ##  1 AA    ARUBA          LAM    Americas  Aruba           "^(?!.*bonaire).…
    ##  2 AC    ANTIGUA AND B… LAM    Americas  Antigua und Ba… antigua          
    ##  3 AF    AFGHANISTAN    ASIA   Asia      Afghanistan     afghan           
    ##  4 AG    ALGERIA        MAF    Africa    Algerien        algerien         
    ##  5 AI    ASCENSION ISL… <NA>   <NA>      <NA>            <NA>             
    ##  6 AJ    AZERBAIJAN     EIT    Asia      Aserbaidschan   aserbaidsch      
    ##  7 AL    ALBANIA        EIT    Europe    Albanien        albanien         
    ##  8 AM    ARMENIA        EIT    Asia      Armenien        armenien         
    ##  9 AN    ANDORRA        OECD1… Europe    Andorra         andorra          
    ## 10 AO    ANGOLA         MAF    Africa    Angola          angola           
    ## # ... with 283 more rows, and 672 more variables: country.name.en <chr>,
    ## #   country.name.en.regex <chr>, cow.name <chr>, cowc <chr>, cown <int>,
    ## #   ecb <chr>, ecb.name <chr>, eu28 <chr>, eurocontrol_pru <chr>,
    ## #   eurocontrol_statfor <chr>, eurostat <chr>, eurostat.name <chr>,
    ## #   fao <int>, fao.name <chr>, fips.name <chr>, gaul <int>,
    ## #   genc.name <chr>, genc2c <chr>, genc3c <chr>, genc3n <chr>, icao <chr>,
    ## #   icao_region <chr>, imf <int>, ioc <chr>, ioc.name <chr>,
    ## #   iso.name.en <chr>, iso.name.fr <chr>, iso2c <chr>, iso3c <chr>,
    ## #   iso3n <int>, p4.name <chr>, p4c <chr>, p4n <int>, region <chr>,
    ## #   un <int>, un.name.ar <chr>, un.name.en <chr>, un.name.es <chr>,
    ## #   un.name.fr <chr>, un.name.ru <chr>, un.name.zh <chr>, unpd <int>,
    ## #   unpd.name <chr>, wb <chr>, wb_api.name <chr>, wb_api2c <chr>,
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
    ## #   cldr.name.en <chr>, cldr.name.eo <chr>, cldr.name.es <chr>,
    ## #   cldr.name.es_419 <chr>, cldr.name.es_ar <chr>, …

There are unnecessary data in several columns. *GSODR* only requires
FIPS, name, and ISO codes to function.

``` r
country_list <- (country_list[, -c(3:14, 17:35)])

country_list
```

    ## # A tibble: 293 x 647
    ##    FIPS  COUNTRY_NAME eurocontrol_pru eurocontrol_sta… iso3n p4.name p4c  
    ##    <chr> <chr>        <chr>           <chr>            <int> <chr>   <chr>
    ##  1 AA    ARUBA        Southern Ameri… Mid-Atlantic       533 <NA>    <NA> 
    ##  2 AC    ANTIGUA AND… Southern Ameri… Mid-Atlantic        28 <NA>    <NA> 
    ##  3 AF    AFGHANISTAN  Asia            Asia/Pacific         4 Afghan… AFG  
    ##  4 AG    ALGERIA      Africa          North-Africa        12 Algeria ALG  
    ##  5 AI    ASCENSION I… <NA>            <NA>                NA <NA>    <NA> 
    ##  6 AJ    AZERBAIJAN   Asia            Other Europe        31 Azerba… AZE  
    ##  7 AL    ALBANIA      Eurocontrol     ESRA East            8 Albania ALB  
    ##  8 AM    ARMENIA      Eurocontrol     Other Europe        51 Armenia ARM  
    ##  9 AN    ANDORRA      <NA>            <NA>                20 <NA>    <NA> 
    ## 10 AO    ANGOLA       Africa          Southern-Africa     24 Angola  ANG  
    ## # ... with 283 more rows, and 640 more variables: p4n <int>, region <chr>,
    ## #   un <int>, un.name.ar <chr>, un.name.en <chr>, un.name.es <chr>,
    ## #   un.name.fr <chr>, un.name.ru <chr>, un.name.zh <chr>, unpd <int>,
    ## #   unpd.name <chr>, wb <chr>, wb_api.name <chr>, wb_api2c <chr>,
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
    ## #   cldr.name.en <chr>, cldr.name.eo <chr>, cldr.name.es <chr>,
    ## #   cldr.name.es_419 <chr>, cldr.name.es_ar <chr>, cldr.name.es_cl <chr>,
    ## #   cldr.name.et <chr>, cldr.name.eu <chr>, cldr.name.ewo <chr>,
    ## #   cldr.name.fa <chr>, cldr.name.fa_af <chr>, cldr.name.ff <chr>,
    ## #   cldr.name.fi <chr>, cldr.name.fil <chr>, cldr.name.fo <chr>,
    ## #   cldr.name.fr <chr>, cldr.name.fr_be <chr>, cldr.name.fr_ca <chr>,
    ## #   cldr.name.fur <chr>, cldr.name.fy <chr>, cldr.name.ga <chr>,
    ## #   cldr.name.gd <chr>, cldr.name.gl <chr>, cldr.name.gsw <chr>,
    ## #   cldr.name.gu <chr>, cldr.name.gv <chr>, cldr.name.ha <chr>,
    ## #   cldr.name.haw <chr>, cldr.name.he <chr>, cldr.name.hi <chr>,
    ## #   cldr.name.hr <chr>, cldr.name.hsb <chr>, cldr.name.hu <chr>,
    ## #   cldr.name.hy <chr>, cldr.name.id <chr>, cldr.name.ig <chr>,
    ## #   cldr.name.ii <chr>, …

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
    ##  date     2018-03-07                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  package     * version    date       source                          
    ##  assertthat    0.2.0      2017-04-11 CRAN (R 3.4.3)                  
    ##  backports     1.1.2      2017-12-13 CRAN (R 3.4.3)                  
    ##  bindr         0.1        2016-11-13 CRAN (R 3.4.3)                  
    ##  bindrcpp      0.2        2017-06-17 CRAN (R 3.4.3)                  
    ##  cli           1.0.0      2017-11-05 CRAN (R 3.4.3)                  
    ##  clisymbols    1.2.0      2017-05-21 CRAN (R 3.4.3)                  
    ##  countrycode * 1.00.0     2018-02-11 CRAN (R 3.4.3)                  
    ##  crayon        1.3.4      2017-09-16 CRAN (R 3.4.3)                  
    ##  curl          3.1        2017-12-12 CRAN (R 3.4.3)                  
    ##  digest        0.6.15     2018-01-28 CRAN (R 3.4.3)                  
    ##  dplyr         0.7.4      2017-09-28 CRAN (R 3.4.3)                  
    ##  evaluate      0.10.1     2017-06-24 CRAN (R 3.4.3)                  
    ##  glue          1.2.0      2017-10-29 CRAN (R 3.4.3)                  
    ##  hms           0.4.1      2018-01-24 CRAN (R 3.4.3)                  
    ##  htmltools     0.3.6      2017-04-28 CRAN (R 3.4.3)                  
    ##  knitr         1.20       2018-02-20 CRAN (R 3.4.3)                  
    ##  magrittr      1.5        2014-11-22 CRAN (R 3.4.3)                  
    ##  pillar        1.2.1      2018-02-27 CRAN (R 3.4.3)                  
    ##  pkgconfig     2.0.1      2017-03-21 CRAN (R 3.4.3)                  
    ##  R6            2.2.2      2017-06-17 CRAN (R 3.4.3)                  
    ##  Rcpp          0.12.15    2018-01-20 CRAN (R 3.4.3)                  
    ##  readr         1.1.1      2017-05-16 CRAN (R 3.4.3)                  
    ##  rlang         0.2.0.9000 2018-03-06 Github (tidyverse/rlang@b5ea5fa)
    ##  rmarkdown     1.9        2018-03-01 CRAN (R 3.4.3)                  
    ##  rprojroot     1.3-2      2018-01-03 CRAN (R 3.4.3)                  
    ##  sessioninfo   1.0.0      2017-06-21 CRAN (R 3.4.3)                  
    ##  stringi       1.1.6      2017-11-17 CRAN (R 3.4.3)                  
    ##  stringr       1.3.0      2018-02-19 CRAN (R 3.4.3)                  
    ##  tibble        1.4.2      2018-01-22 CRAN (R 3.4.3)                  
    ##  utf8          1.1.3      2018-01-03 CRAN (R 3.4.3)                  
    ##  withr         2.1.1.9000 2018-03-05 Github (jimhester/withr@5d05571)
    ##  yaml          2.1.17     2018-02-27 CRAN (R 3.4.3)
