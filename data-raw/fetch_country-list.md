Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks
2017-03-13

Introduction
============

This script will fetch the country list provided by the NCDC for the GSOD stations from the ftp server and merge it with ISO codes from the [`countrycode`](https://cran.r-project.org/package=countrycode) package for inclusion in the GSODR package in /data/country-list.rda. These codes are used when a user selects a single country for a data query.

R Data Processing
=================

Read "country-list.txt" file from NCDC FTP server and merge with `countrycode` data.

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

There are unnecessary data in several columns. `GSODR` only requires FIPS, name, and ISO codes to function.

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
devtools::use_data(country_list, overwrite = TRUE, compress = "bzip2")
```

    ## Saving country_list as country_list.rda to /Users/U8004755/Development/GSODR/data

Notes
=====

NOAA Policy
-----------

Users of these data should take into account the following (from the [NCDC website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

> "The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification." [WMO Resolution 40. NOAA Policy](http://www.wmo.int/pages/about/Resolution40.html)

R System Information
--------------------

    ## R version 3.3.3 (2017-03-06)
    ## Platform: x86_64-apple-darwin15.6.0 (64-bit)
    ## Running under: OS X El Capitan 10.11.6
    ## 
    ## locale:
    ## [1] en_AU.UTF-8/en_AU.UTF-8/en_AU.UTF-8/C/en_AU.UTF-8/en_AU.UTF-8
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] countrycode_0.19
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_0.12.9          withr_1.0.2          dplyr_0.5.0         
    ##  [4] digest_0.6.12        rprojroot_1.2        assertthat_0.1      
    ##  [7] R6_2.2.0             DBI_0.6              backports_1.0.5     
    ## [10] magrittr_1.5         evaluate_0.10        stringi_1.1.2       
    ## [13] curl_2.3             data.table_1.10.4    rmarkdown_1.3.9004  
    ## [16] devtools_1.12.0.9000 tools_3.3.3          stringr_1.2.0       
    ## [19] readr_1.0.0          pkgload_0.0.0.9000   yaml_2.1.14         
    ## [22] pkgbuild_0.0.0.9000  memoise_1.0.0        htmltools_0.3.5     
    ## [25] knitr_1.15.1         tibble_1.2
