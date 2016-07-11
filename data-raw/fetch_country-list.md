Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks - Center for Crop Health, University of Southern Queensland
07-011-2016

Introduction
============

This script will fetch the country list provided by the NCDC for the GSOD stations from the ftp server and merge it with ISO codes from the [`countrycode`](https://github.com/vincentarelbundock/countrycode) package for inclusion in the GSODR package in /data/country-list.rda. These codes are used when a user selects a single country for a data query.

This inclusion decreases the time necessary to query the server when specifying a country for weather data downloading.

R Data Processing
=================

Read "country-list.txt"" file from NCDC FTP server and merge with`countrycode` data.

``` r
countries <- readr::read_table(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt")[-1, c(1, 3)]

country_list <- dplyr::left_join(countries, countrycode::countrycode_data,
                              by = c(FIPS = "fips104"))

print(country_list)
```

    ## # A tibble: 293 x 16
    ##     FIPS        COUNTRY NAME        country.name  cowc  cown   fao   imf
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
    ##     FIPS        COUNTRY NAME iso2c iso3c
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

Write .rda file to disk for inclusion in `GSODR` package.

``` r
devtools::use_data(country_list, overwrite = TRUE, compress = "bzip2")
```

    ## Saving country_list as country_list.rda to /Users/U8004755/Development/GSODR/data
