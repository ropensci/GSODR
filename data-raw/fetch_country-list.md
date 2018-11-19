Fetch GSOD Country List and Merge with ISO Country Codes
================
Adam H. Sparks
2018-11-19

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

    ## Warning in library(package, lib.loc = lib.loc, character.only = TRUE,
    ## logical.return = TRUE, : there is no package called 'countrycode'

    ## Installing package into '/Users/U8004755/Library/R/3.x/library'
    ## (as 'lib' is unspecified)

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

    ## # A tibble: 293 x 682
    ##    FIPS  COUNTRY_NAME ar5   continent country.name.de country.name.de…
    ##    <chr> <chr>        <chr> <chr>     <chr>           <chr>           
    ##  1 AA    ARUBA        LAM   Americas  Aruba           "^(?!.*bonaire)…
    ##  2 AC    ANTIGUA AND… LAM   Americas  Antigua und Ba… antigua         
    ##  3 AF    AFGHANISTAN  ASIA  Asia      Afghanistan     afghan          
    ##  4 AG    ALGERIA      MAF   Africa    Algerien        algerien        
    ##  5 AI    ASCENSION I… <NA>  <NA>      <NA>            <NA>            
    ##  6 AJ    AZERBAIJAN   EIT   Asia      Aserbaidschan   aserbaidsch     
    ##  7 AL    ALBANIA      EIT   Europe    Albanien        albanien        
    ##  8 AM    ARMENIA      EIT   Asia      Armenien        armenien        
    ##  9 AN    ANDORRA      OECD… Europe    Andorra         andorra         
    ## 10 AO    ANGOLA       MAF   Africa    Angola          angola          
    ## # ... with 283 more rows, and 676 more variables: country.name.en <chr>,
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
country_list <- country_list[, c(1:2, 34:35)]

country_list
```

    ## # A tibble: 293 x 4
    ##    FIPS  COUNTRY_NAME        iso.name.en         iso.name.fr       
    ##    <chr> <chr>               <chr>               <chr>             
    ##  1 AA    ARUBA               Aruba               Aruba             
    ##  2 AC    ANTIGUA AND BARBUDA Antigua and Barbuda Antigua-et-Barbuda
    ##  3 AF    AFGHANISTAN         Afghanistan         Afghanistan (l')  
    ##  4 AG    ALGERIA             Algeria             Algérie (l')      
    ##  5 AI    ASCENSION ISLAND    <NA>                <NA>              
    ##  6 AJ    AZERBAIJAN          Azerbaijan          Azerbaïdjan (l')  
    ##  7 AL    ALBANIA             Albania             Albanie (l')      
    ##  8 AM    ARMENIA             Armenia             Arménie (l')      
    ##  9 AN    ANDORRA             Andorra             Andorre (l')      
    ## 10 AO    ANGOLA              Angola              Angola (l')       
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
    ##  version  R version 3.5.1 (2018-07-02)
    ##  os       macOS  10.14.1              
    ##  system   x86_64, darwin18.0.0        
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_US.UTF-8                 
    ##  ctype    en_US.UTF-8                 
    ##  tz       Australia/Brisbane          
    ##  date     2018-11-19                  
    ## 
    ## ─ Packages ──────────────────────────────────────────────────────────────
    ##  ! package      * version    date       lib source        
    ##  R .py            0.1.3      <NA>       [?] <NA>          
    ##    assertthat     0.2.0      2017-04-11 [1] CRAN (R 3.5.1)
    ##    backports      1.1.2      2017-12-13 [1] CRAN (R 3.5.1)
    ##    base64enc      0.1-3      2015-07-28 [1] CRAN (R 3.5.1)
    ##    bindr          0.1.1      2018-03-13 [1] CRAN (R 3.5.1)
    ##    bindrcpp       0.2.2      2018-03-29 [1] CRAN (R 3.5.1)
    ##    callr          3.0.0      2018-08-24 [1] CRAN (R 3.5.1)
    ##    cli            1.0.1      2018-09-25 [1] CRAN (R 3.5.1)
    ##    codetools      0.2-15     2016-10-05 [3] CRAN (R 3.5.1)
    ##    colorout     * 1.2-0      2018-11-06 [1] local         
    ##    commonmark     1.6        2018-09-30 [1] CRAN (R 3.5.1)
    ##    countrycode    1.1.0      2018-10-27 [1] CRAN (R 3.5.1)
    ##    crayon         1.3.4      2017-09-16 [1] CRAN (R 3.5.1)
    ##    curl           3.2        2018-03-28 [1] CRAN (R 3.5.1)
    ##    desc           1.2.0      2018-05-01 [1] CRAN (R 3.5.1)
    ##    devtools       2.0.1      2018-10-26 [1] CRAN (R 3.5.1)
    ##    digest         0.6.18     2018-10-10 [1] CRAN (R 3.5.1)
    ##    dplyr          0.7.8      2018-11-10 [1] CRAN (R 3.5.1)
    ##    evaluate       0.12       2018-10-09 [1] CRAN (R 3.5.1)
    ##    fansi          0.4.0      2018-10-05 [1] CRAN (R 3.5.1)
    ##    fs             1.2.6      2018-08-23 [1] CRAN (R 3.5.1)
    ##    future         1.10.0     2018-10-17 [1] CRAN (R 3.5.1)
    ##    future.apply   1.0.1      2018-08-26 [1] CRAN (R 3.5.1)
    ##    globals        0.12.4     2018-10-11 [1] CRAN (R 3.5.1)
    ##    glue           1.3.0      2018-07-17 [1] CRAN (R 3.5.1)
    ##    GSODR        * 1.2.3.9000 2018-11-19 [1] CRAN (R 3.5.1)
    ##    hms            0.4.2      2018-03-10 [1] CRAN (R 3.5.1)
    ##    htmltools      0.3.6      2017-04-28 [1] CRAN (R 3.5.1)
    ##    httr           1.3.1      2017-08-20 [1] CRAN (R 3.5.1)
    ##    jsonlite       1.5        2017-06-01 [1] CRAN (R 3.5.1)
    ##    knitr          1.20       2018-02-20 [1] CRAN (R 3.5.1)
    ##    listenv        0.7.0      2018-01-21 [1] CRAN (R 3.5.1)
    ##    magick         2.0        2018-10-05 [1] CRAN (R 3.5.1)
    ##    magrittr       1.5        2014-11-22 [1] CRAN (R 3.5.1)
    ##    MASS           7.3-51.1   2018-11-01 [3] CRAN (R 3.5.1)
    ##    memoise        1.1.0      2017-04-21 [1] CRAN (R 3.5.1)
    ##    pillar         1.3.0      2018-07-14 [1] CRAN (R 3.5.1)
    ##    pkgbuild       1.0.2      2018-10-16 [1] CRAN (R 3.5.1)
    ##    pkgconfig      2.0.2      2018-08-16 [1] CRAN (R 3.5.1)
    ##    pkgdown      * 1.1.0      2018-06-02 [1] CRAN (R 3.5.1)
    ##    pkgload        1.0.2      2018-10-29 [1] CRAN (R 3.5.1)
    ##    prettyunits    1.0.2      2015-07-13 [1] CRAN (R 3.5.1)
    ##    processx       3.2.0      2018-08-16 [1] CRAN (R 3.5.1)
    ##    ps             1.2.1      2018-11-06 [1] CRAN (R 3.5.1)
    ##    purrr          0.2.5      2018-05-29 [1] CRAN (R 3.5.1)
    ##    R.methodsS3    1.7.1      2016-02-16 [1] CRAN (R 3.5.1)
    ##    R.oo           1.22.0     2018-04-22 [1] CRAN (R 3.5.1)
    ##    R.utils        2.7.0      2018-08-27 [1] CRAN (R 3.5.1)
    ##    R6             2.3.0      2018-10-04 [1] CRAN (R 3.5.1)
    ##    Rcpp           1.0.0      2018-11-07 [1] CRAN (R 3.5.1)
    ##    readr          1.1.1      2017-05-16 [1] CRAN (R 3.5.1)
    ##    remotes        2.0.2      2018-10-30 [1] CRAN (R 3.5.1)
    ##    rlang          0.3.0.1    2018-10-25 [1] CRAN (R 3.5.1)
    ##    rmarkdown      1.10       2018-06-11 [1] CRAN (R 3.5.1)
    ##    roxygen2       6.1.1      2018-11-07 [1] CRAN (R 3.5.1)
    ##    rprojroot      1.3-2      2018-01-03 [1] CRAN (R 3.5.1)
    ##    rstudioapi     0.8        2018-10-02 [1] CRAN (R 3.5.1)
    ##    sessioninfo    1.1.1      2018-11-05 [1] CRAN (R 3.5.1)
    ##    stringi        1.2.4      2018-07-20 [1] CRAN (R 3.5.1)
    ##    stringr        1.3.1      2018-05-10 [1] CRAN (R 3.5.1)
    ##    testthat       2.0.1      2018-10-13 [1] CRAN (R 3.5.1)
    ##    tibble         1.4.2      2018-01-22 [1] CRAN (R 3.5.1)
    ##    tidyselect     0.2.5      2018-10-11 [1] CRAN (R 3.5.1)
    ##    usethis        1.4.0      2018-08-14 [1] CRAN (R 3.5.1)
    ##    utf8           1.1.4      2018-05-24 [1] CRAN (R 3.5.1)
    ##    whisker        0.3-2      2013-04-28 [1] CRAN (R 3.5.1)
    ##    withr          2.1.2      2018-03-15 [1] CRAN (R 3.5.1)
    ##    xml2           1.2.0      2018-01-24 [1] CRAN (R 3.5.1)
    ##    yaml           2.2.0      2018-07-25 [1] CRAN (R 3.5.1)
    ## 
    ## [1] /Users/U8004755/Library/R/3.x/library
    ## [2] /usr/local/lib/R/3.5/site-library
    ## [3] /usr/local/Cellar/r/3.5.1/lib/R/library
    ## 
    ##  R ── Package was removed from disk.
