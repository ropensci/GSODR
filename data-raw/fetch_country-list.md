Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks
2016-11-25

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
                   by = c(FIPS = "fips104"))
country_list <- data.table::setDT(country_list)

print(country_list)
```

    ##      FIPS                         COUNTRY_NAME        country.name cowc
    ##   1:   AA                                ARUBA               Aruba   NA
    ##   2:   AC                  ANTIGUA AND BARBUDA Antigua and Barbuda  AAB
    ##   3:   AF                          AFGHANISTAN         Afghanistan  AFG
    ##   4:   AG                              ALGERIA             Algeria  ALG
    ##   5:   AI                     ASCENSION ISLAND                  NA   NA
    ##  ---                                                                   
    ## 289:   YY ST. MARTEEN, ST. EUSTATIUS, AND SABA                  NA   NA
    ## 290:   ZA                               ZAMBIA              Zambia  ZAM
    ## 291:   ZI                             ZIMBABWE            Zimbabwe  ZIM
    ## 292:   ZM                                SAMOA                  NA   NA
    ## 293:   ZZ       ST. MARTIN AND ST. BARTHOLOMEW                  NA   NA
    ##      cown fao imf ioc iso2c iso3c iso3n  un  wb
    ##   1:   NA  NA 314 ARU    AW   ABW   533 533 ABW
    ##   2:   58   8 311 ANT    AG   ATG    28  28 ATG
    ##   3:  700   2 512 AFG    AF   AFG     4   4 AFG
    ##   4:  615   4 612 ALG    DZ   DZA    12  12 DZA
    ##   5:   NA  NA  NA  NA    NA    NA    NA  NA  NA
    ##  ---                                           
    ## 289:   NA  NA  NA  NA    NA    NA    NA  NA  NA
    ## 290:  551 251 754 ZAM    ZM   ZMB   894 894 ZMB
    ## 291:  552 181 698 ZIM    ZW   ZWE   716 716 ZWE
    ## 292:   NA  NA  NA  NA    NA    NA    NA  NA  NA
    ## 293:   NA  NA  NA  NA    NA    NA    NA  NA  NA
    ##                                   regex continent          region
    ##   1:           ^(?!.*bonaire).*\\baruba  Americas       Caribbean
    ##   2:                            antigua  Americas       Caribbean
    ##   3:                             afghan      Asia   Southern Asia
    ##   4:                            algeria    Africa Northern Africa
    ##   5:                                 NA        NA              NA
    ##  ---                                                             
    ## 289:                                 NA        NA              NA
    ## 290:          zambia|northern.?rhodesia    Africa  Eastern Africa
    ## 291: zimbabwe|^(?!.*northern).*rhodesia    Africa  Eastern Africa
    ## 292:                                 NA        NA              NA
    ## 293:                                 NA        NA              NA

There are unnecessary data in several columns. `GSODR` only requires FIPS, name, and ISO codes to function.

``` r
country_list[, c(3, 4:8, 11:16) := NULL]
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

``` r
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

    ## R version 3.3.2 (2016-10-31)
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
    ## [1] countrycode_0.18
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_0.12.8      withr_1.0.2      dplyr_0.5.0      digest_0.6.10   
    ##  [5] rprojroot_1.1    assertthat_0.1   chron_2.3-47     R6_2.2.0        
    ##  [9] DBI_0.5-1        backports_1.0.4  magrittr_1.5     evaluate_0.10   
    ## [13] stringi_1.1.2    curl_2.2         data.table_1.9.6 rmarkdown_1.2   
    ## [17] devtools_1.12.0  tools_3.3.2      stringr_1.1.0    readr_1.0.0     
    ## [21] yaml_2.1.14      memoise_1.0.0    htmltools_0.3.5  knitr_1.15.1    
    ## [25] tibble_1.2
