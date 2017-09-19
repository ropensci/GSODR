Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks
2017-09-19

Introduction
============

This document details how to fetch the country list provided by the NCEI for the GSOD stations from the FTP server and merge it with ISO codes from the [*countrycode*](https://cran.r-project.org/package=countrycode) package for inclusion in the *GSODR* package in /data/country-list.rda. These codes are used when a user selects a single country for a data query.

R Data Processing
=================

Read "country-list.txt" file from NCEI FTP server and merge with *countrycode* data.

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
country_list <- data.table::setDT(country_list)

print(country_list)
```

    ##      FIPS                         COUNTRY_NAME  ar5 continent cowc cown
    ##   1:   AA                                ARUBA  LAM  Americas   NA   NA
    ##   2:   AC                  ANTIGUA AND BARBUDA  LAM  Americas  AAB   58
    ##   3:   AF                          AFGHANISTAN ASIA      Asia  AFG  700
    ##   4:   AG                              ALGERIA  MAF    Africa  ALG  615
    ##   5:   AI                     ASCENSION ISLAND   NA        NA   NA   NA
    ##  ---                                                                   
    ## 289:   YY ST. MARTEEN, ST. EUSTATIUS, AND SABA   NA        NA   NA   NA
    ## 290:   ZA                               ZAMBIA  MAF    Africa  ZAM  551
    ## 291:   ZI                             ZIMBABWE  MAF    Africa  ZIM  552
    ## 292:   ZM                                SAMOA   NA        NA   NA   NA
    ## 293:   ZZ       ST. MARTIN AND ST. BARTHOLOMEW   NA        NA   NA   NA
    ##      eu28  eurocontrol_pru eurocontrol_statfor fao icao icao_region imf
    ##   1:   NA Southern America        Mid-Atlantic  NA   TN           T 314
    ##   2:   NA Southern America        Mid-Atlantic   8   TA           T 311
    ##   3:   NA             Asia        Asia/Pacific   2   OA           O 512
    ##   4:   NA           Africa        North-Africa   4   DA           D 612
    ##   5:   NA               NA                  NA  NA   NA          NA  NA
    ##  ---                                                                   
    ## 289:   NA               NA                  NA  NA   NA          NA  NA
    ## 290:   NA           Africa     Southern Africa 251   FL           F 754
    ## 291:   NA           Africa     Southern Africa 181   FV           F 698
    ## 292:   NA               NA                  NA  NA   NA          NA  NA
    ## 293:   NA               NA                  NA  NA   NA          NA  NA
    ##      ioc iso2c iso3c iso3n          region  un  wb country.name.ar
    ##   1: ARU    AW   ABW   533       Caribbean 533 ABW              NA
    ##   2: ANT    AG   ATG    28       Caribbean  28 ATG أنتيغوا وبربودا
    ##   3: AFG    AF   AFG     4   Southern Asia   4 AFG       أفغانستان
    ##   4: ALG    DZ   DZA    12 Northern Africa  12 DZA         الجزائر
    ##   5:  NA    NA    NA    NA              NA  NA  NA              NA
    ##  ---                                                              
    ## 289:  NA    NA    NA    NA              NA  NA  NA              NA
    ## 290: ZAM    ZM   ZMB   894  Eastern Africa 894 ZMB          زامبيا
    ## 291: ZIM    ZW   ZWE   716  Eastern Africa 716 ZWE         زمبابوي
    ## 292:  NA    NA    NA    NA              NA  NA  NA              NA
    ## 293:  NA    NA    NA    NA              NA  NA  NA              NA
    ##          country.name.de               country.name.de.regex
    ##   1:               Aruba            ^(?!.*bonaire).*\\baruba
    ##   2: Antigua und Barbuda                             antigua
    ##   3:         Afghanistan                              afghan
    ##   4:            Algerien                            algerien
    ##   5:                  NA                                  NA
    ##  ---                                                        
    ## 289:                  NA                                  NA
    ## 290:              Sambia              sambia|nord.?rhodesien
    ## 291:            Simbabwe (z|s)imbabwe|^(?!.*nord).*rhodesien
    ## 292:                  NA                                  NA
    ## 293:                  NA                                  NA
    ##          country.name.en              country.name.en.regex
    ##   1:               Aruba           ^(?!.*bonaire).*\\baruba
    ##   2: Antigua and Barbuda                            antigua
    ##   3:         Afghanistan                             afghan
    ##   4:             Algeria                            algeria
    ##   5:                  NA                                 NA
    ##  ---                                                       
    ## 289:                  NA                                 NA
    ## 290:              Zambia          zambia|northern.?rhodesia
    ## 291:            Zimbabwe zimbabwe|^(?!.*northern).*rhodesia
    ## 292:                  NA                                 NA
    ## 293:                  NA                                 NA
    ##        country.name.es    country.name.fr   country.name.ru
    ##   1:                NA                 NA                NA
    ##   2: Antigua y Barbuda Antigua-et-Barbuda Антигуа и Барбуда
    ##   3:        Afganistán        Afghanistan        Афганистан
    ##   4:           Argelia            Algérie             Алжир
    ##   5:                NA                 NA                NA
    ##  ---                                                       
    ## 289:                NA                 NA                NA
    ## 290:            Zambia             Zambie            Замбия
    ## 291:          Zimbabwe           Zimbabwe          Зимбабве
    ## 292:                NA                 NA                NA
    ## 293:                NA                 NA                NA
    ##      country.name.zh eurostat wb_api2c wb_api3c p4_scode p4_ccode wvs
    ##   1:              NA       AW       AW      ABW       NA       NA  NA
    ##   2:  安提瓜和巴布达       AG       AG      ATG       NA       NA  28
    ##   3:          阿富汗       AF       AF      AFG      AFG      700   4
    ##   4:      阿尔及利亚       DZ       DZ      DZA      ALG      615  12
    ##   5:              NA       NA       NA       NA       NA       NA  NA
    ##  ---                                                                 
    ## 289:              NA       NA       NA       NA       NA       NA  NA
    ## 290:          赞比亚       ZM       ZM      ZMB      ZAM      551 894
    ## 291:        津巴布韦       ZW       ZW      ZWE      ZIM      552 716
    ## 292:              NA       NA       NA       NA       NA       NA  NA
    ## 293:              NA       NA       NA       NA       NA       NA  NA

There are unnecessary data in several columns. *GSODR* only requires FIPS, name, and ISO codes to function.

``` r
country_list[, c(3:14, 17:35) := NULL]

print(country_list)
```

    ##      FIPS                         COUNTRY_NAME iso2c iso3c
    ##   1:   AA                                ARUBA    AW   ABW
    ##   2:   AC                  ANTIGUA AND BARBUDA    AG   ATG
    ##   3:   AF                          AFGHANISTAN    AF   AFG
    ##   4:   AG                              ALGERIA    DZ   DZA
    ##   5:   AI                     ASCENSION ISLAND    NA    NA
    ##  ---                                                      
    ## 289:   YY ST. MARTEEN, ST. EUSTATIUS, AND SABA    NA    NA
    ## 290:   ZA                               ZAMBIA    ZM   ZMB
    ## 291:   ZI                             ZIMBABWE    ZW   ZWE
    ## 292:   ZM                                SAMOA    NA    NA
    ## 293:   ZZ       ST. MARTIN AND ST. BARTHOLOMEW    NA    NA

Write .rda file to disk.

``` r
save(country_list, file = "../inst/extdata/country_list.rda",
     compress = "bzip2")
```

Notes
=====

NOAA Policy
-----------

Users of these data should take into account the following (from the [NCEI website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

> "The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification." [WMO Resolution 40. NOAA Policy](http://www.wmo.int/pages/about/Resolution40.html)

R System Information
--------------------

    ## Session info -------------------------------------------------------------

    ##  setting  value                       
    ##  version  R version 3.4.1 (2017-06-30)
    ##  system   x86_64, darwin16.7.0        
    ##  ui       unknown                     
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2017-09-19

    ## Packages -----------------------------------------------------------------

    ##  package     * version    date       source                          
    ##  assertthat    0.2.0      2017-04-11 CRAN (R 3.4.1)                  
    ##  backports     1.1.0      2017-05-22 CRAN (R 3.4.1)                  
    ##  base        * 3.4.1      2017-08-20 local                           
    ##  bindr         0.1        2016-11-13 CRAN (R 3.4.1)                  
    ##  bindrcpp      0.2        2017-06-17 CRAN (R 3.4.1)                  
    ##  compiler      3.4.1      2017-08-20 local                           
    ##  countrycode * 0.19       2017-02-06 CRAN (R 3.4.1)                  
    ##  curl          2.8.1      2017-07-21 CRAN (R 3.4.1)                  
    ##  data.table    1.10.4     2017-02-01 CRAN (R 3.4.1)                  
    ##  datasets    * 3.4.1      2017-08-20 local                           
    ##  devtools      1.13.3     2017-08-02 CRAN (R 3.4.1)                  
    ##  digest        0.6.12     2017-01-27 CRAN (R 3.4.1)                  
    ##  dplyr         0.7.3      2017-09-09 cran (@0.7.3)                   
    ##  evaluate      0.10.1     2017-06-24 CRAN (R 3.4.1)                  
    ##  glue          1.1.1      2017-06-21 CRAN (R 3.4.1)                  
    ##  graphics    * 3.4.1      2017-08-20 local                           
    ##  grDevices   * 3.4.1      2017-08-20 local                           
    ##  hms           0.3        2016-11-22 CRAN (R 3.4.1)                  
    ##  htmltools     0.3.6      2017-04-28 CRAN (R 3.4.1)                  
    ##  knitr         1.17       2017-08-10 CRAN (R 3.4.1)                  
    ##  magrittr      1.5        2014-11-22 CRAN (R 3.4.1)                  
    ##  memoise       1.1.0      2017-04-21 CRAN (R 3.4.1)                  
    ##  methods     * 3.4.1      2017-08-20 local                           
    ##  pkgconfig     2.0.1      2017-03-21 CRAN (R 3.4.1)                  
    ##  R6            2.2.2      2017-06-17 CRAN (R 3.4.1)                  
    ##  Rcpp          0.12.12    2017-07-15 CRAN (R 3.4.1)                  
    ##  readr         1.1.1      2017-05-16 CRAN (R 3.4.1)                  
    ##  rlang         0.1.2.9000 2017-09-13 Github (tidyverse/rlang@ff02f2a)
    ##  rmarkdown     1.6        2017-06-15 CRAN (R 3.4.1)                  
    ##  rprojroot     1.2        2017-01-16 CRAN (R 3.4.1)                  
    ##  stats       * 3.4.1      2017-08-20 local                           
    ##  stringi       1.1.5      2017-04-07 CRAN (R 3.4.1)                  
    ##  stringr       1.2.0      2017-02-18 CRAN (R 3.4.1)                  
    ##  tibble        1.3.4      2017-08-22 cran (@1.3.4)                   
    ##  tools         3.4.1      2017-08-20 local                           
    ##  utils       * 3.4.1      2017-08-20 local                           
    ##  withr         2.0.0      2017-09-17 Github (jimhester/withr@d1f0957)
    ##  yaml          2.1.14     2016-11-12 CRAN (R 3.4.1)
