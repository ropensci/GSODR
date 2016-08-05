Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks - Center for Crop Health, University of Southern Queensland
2016-08-05

Introduction
============

This script will fetch the country list provided by the NCDC for the GSOD stations from the ftp server and merge it with ISO codes from the [`countrycode`](https://github.com/vincentarelbundock/countrycode) package for inclusion in the GSODR package in /data/country-list.rda. These codes are used when a user selects a single country for a data query.

This inclusion decreases the time necessary to query the server when specifying a country for weather data downloading.

R Data Processing
=================

Read "country-list.txt" file from NCDC FTP server and merge with `countrycode` data.

``` r
countries <- readr::read_table(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt")[-1, c(1, 3)]
names(countries)[2] <- "COUNTRY_NAME"

country_list <- dplyr::left_join(countries, countrycode::countrycode_data,
                              by = c(FIPS = "fips104"))

print(country_list)
```

    ## # A tibble: 293 x 16
    ##     FIPS        COUNTRY_NAME        country.name  cowc  cown   fao   imf
    ##    <chr>               <chr>               <chr> <chr> <int> <int> <int>
    ## 1     AA               ARUBA               Aruba  <NA>    NA    NA   314
    ## 2     AC ANTIGUA AND BARBUDA Antigua and Barbuda   AAB    58     8   311
    ## 3     AF         AFGHANISTAN         Afghanistan   AFG   700     2   512
    ## 4     AG             ALGERIA             Algeria   ALG   615     4   612
    ## 5     AI    ASCENSION ISLAND                <NA>  <NA>    NA    NA    NA
    ## 6     AJ          AZERBAIJAN          Azerbaijan   AZE   373    52   912
    ## 7     AL             ALBANIA             Albania   ALB   339     3   914
    ## 8     AM             ARMENIA             Armenia   ARM   371     1   911
    ## 9     AN             ANDORRA             Andorra   AND   232     6    NA
    ## 10    AO              ANGOLA              Angola   ANG   540     7   614
    ## # ... with 283 more rows, and 9 more variables: ioc <chr>, iso2c <chr>,
    ## #   iso3c <chr>, iso3n <int>, un <int>, wb <chr>, regex <chr>,
    ## #   continent <chr>, region <chr>

There are unecessary data in several columns. `GSODR` only requires FIPS, name, and ISO codes to function.

``` r
country_list <- country_list[, -c(3, 4:8, 11:16)]

print(country_list)
```

    ## # A tibble: 293 x 4
    ##     FIPS        COUNTRY_NAME iso2c iso3c
    ##    <chr>               <chr> <chr> <chr>
    ## 1     AA               ARUBA    AW   ABW
    ## 2     AC ANTIGUA AND BARBUDA    AG   ATG
    ## 3     AF         AFGHANISTAN    AF   AFG
    ## 4     AG             ALGERIA    DZ   DZA
    ## 5     AI    ASCENSION ISLAND  <NA>  <NA>
    ## 6     AJ          AZERBAIJAN    AZ   AZE
    ## 7     AL             ALBANIA    AL   ALB
    ## 8     AM             ARMENIA    AM   ARM
    ## 9     AN             ANDORRA    AD   AND
    ## 10    AO              ANGOLA    AO   AGO
    ## # ... with 283 more rows

Convert to regular `data.frame` object and write .rda file to disk.

``` r
country_list <- data.frame(country_list)
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

    ## R version 3.3.1 (2016-06-21)
    ## Platform: x86_64-apple-darwin15.5.0 (64-bit)
    ## Running under: OS X 10.11.6 (El Capitan)
    ## 
    ## locale:
    ## [1] en_AU.UTF-8/en_AU.UTF-8/en_AU.UTF-8/C/en_AU.UTF-8/en_AU.UTF-8
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_0.12.6      countrycode_0.18 withr_1.0.2      digest_0.6.10   
    ##  [5] dplyr_0.5.0      assertthat_0.1   R6_2.1.2         DBI_0.4-1       
    ##  [9] formatR_1.4      magrittr_1.5     evaluate_0.9     stringi_1.1.1   
    ## [13] curl_1.1         rmarkdown_1.0    devtools_1.12.0  tools_3.3.1     
    ## [17] stringr_1.0.0    readr_1.0.0      yaml_2.1.13      memoise_1.0.0   
    ## [21] htmltools_0.3.5  knitr_1.13       tibble_1.1
