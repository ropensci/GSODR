---
title: "Fetch and Clean 'isd_history.csv' File"
author: "Adam H. Sparks"
date: "2025-05-03"
output: github_document
---



<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>

# Introduction

The "isd_history.csv" file details GSOD station metadata.
These data include the start and stop years used by {GSODR} to pre-check requests before querying the server for download and the country code used by {GSODR} when sub-setting for requests by country.
The following checks are performed on the raw data file before inclusion in {GSODR},

-   Check for valid lon and lat values;

    -   isd_history where latitude or longitude are `NA` or both 0 are removed leaving only properly georeferenced stations,

    -   isd_history where latitude is < -90˚ or > 90˚ are removed,

    -   isd_history where longitude is < -180˚ or > 180˚ are removed.

-   A new field, STNID, a concatenation of the USAF and WBAN fields, is added.

# Data Processing

## Set up workspace


``` r
library("sessioninfo")
library("skimr")
```

```
## Error in library("skimr"): there is no package called 'skimr'
```

``` r
library("countrycode")
library("data.table")
```

## Download and clean data


``` r
# download data
new_isd_history <- fread("https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")
```

## Add/drop columns and save to disk


``` r
# pad WBAN where necessary
new_isd_history[, WBAN := sprintf("%05d", WBAN)]

# add STNID column
new_isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
setcolorder(new_isd_history, "STNID")
setnames(new_isd_history, "STATION NAME", "NAME")

# remove stations where LAT or LON is NA
new_isd_history <- na.omit(new_isd_history, cols = c("LAT", "LON"))

# remove extra columns
new_isd_history[, c("USAF", "WBAN", "ICAO") := NULL]
```

## Add country names based on FIPS


``` r
new_isd_history <-
  new_isd_history[setDT(countrycode::codelist), on = c("CTRY" = "fips")]

new_isd_history <- new_isd_history[, c(
  "STNID",
  "NAME",
  "LAT",
  "LON",
  "ELEV(M)",
  "CTRY",
  "STATE",
  "BEGIN",
  "END",
  "country.name.en",
  "iso2c",
  "iso3c"
)]

# clean data
new_isd_history[new_isd_history == -999] <- NA
new_isd_history[new_isd_history == -999.9] <- NA
new_isd_history <-
  new_isd_history[!is.na(new_isd_history$LAT) &
                    !is.na(new_isd_history$LON),]
new_isd_history <-
  new_isd_history[new_isd_history$LAT != 0 &
                    new_isd_history$LON != 0,]
new_isd_history <-
  new_isd_history[new_isd_history$LAT > -90 &
                    new_isd_history$LAT < 90,]
new_isd_history <-
  new_isd_history[new_isd_history$LON > -180 &
                    new_isd_history$LON < 180,]

# set colnames to upper case
names(new_isd_history) <- toupper(names(new_isd_history))
setnames(new_isd_history,
         old = "COUNTRY.NAME.EN",
         new = "COUNTRY_NAME")

# set country names to be upper case for easier internal verifications
new_isd_history[, COUNTRY_NAME := toupper(COUNTRY_NAME)]

# set key for joins when processing CSV files
setkeyv(new_isd_history, "STNID")
```

## Show changes from last release


``` r
# ensure we aren't using a locally installed dev version
install.packages("GSODR", repos = "https://cloud.r-project.org/")
```

```
## Installing package into '/Users/adamsparks/Library/R/arm64/4.5/library'
## (as 'lib' is unspecified)
```

```
## 
## The downloaded binary packages are in
## 	/var/folders/vz/txwj1tx51txgw7zv_b5c5_3m0000gn/T//Rtmp96xxfr/downloaded_packages
```

``` r
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

# select only the cols of interest
x <- names(isd_history)
new_isd_history <- new_isd_history[, ..x] 

(isd_diff <- diffobj::diffPrint(new_isd_history, isd_history))
```

<PRE class="fansi fansi-output"><CODE>## <span style='color: #555555;'>No visible differences between objects.</span>
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>new_isd_history</span>                                                             
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>isd_history</span>                                                                 
## <span style='color: #00BBBB;'>@@ 1,40 / 1,40 @@                                                             </span>
##   Key: &lt;STNID&gt;                                                                
##                 STNID                                              NAME    LAT
##                &lt;char&gt;                                            &lt;char&gt;  &lt;num&gt;
##       1: 008268-99999                                         WXPOD8278 32.950
##       2: 010010-99999                               JAN MAYEN(NOR-NAVY) 70.933
##       3: 010014-99999                                        SORSTOKKEN 59.792
##       4: 010015-99999                                        BRINGELAND 61.383
##       5: 010016-99999                                       RORVIK/RYUM 64.850
##      ---                                                                      
##   27933: A07355-00241                         VIROQUA MUNICIPAL AIRPORT 43.579
##   27934: A07357-00182 ELBOW LAKE MUNICIPAL PRIDE OF THE PRAIRIE AIRPORT 45.986
##   27935: A07359-00240                              IONIA COUNTY AIRPORT 42.938
##   27936: A51255-00445                       DEMOPOLIS MUNICIPAL AIRPORT 32.464
##   27937: A51256-00451      BRANSON WEST MUNICIPAL EMERSON FIELD AIRPORT 36.699
##              LON ELEV(M)   CTRY  STATE    BEGIN      END  COUNTRY_NAME  ISO2C 
##            &lt;num&gt;   &lt;num&gt; &lt;char&gt; &lt;char&gt;    &lt;int&gt;    &lt;int&gt;        &lt;char&gt; &lt;char&gt; 
##       1:  65.567  1156.7     AF        20100519 20120323   AFGHANISTAN     AF 
##       2:  -8.667     9.0     NO        19310101 20250430        NORWAY     NO 
##       3:   5.341    48.8     NO        19861120 20250430        NORWAY     NO 
##       4:   5.867   327.0     NO        19870117 19971231        NORWAY     NO 
##       5:  11.233    14.0     NO        19870116 19910806        NORWAY     NO 
##      ---                                                                      
##   27933: -90.913   394.1     US     WI 20140731 20250430 UNITED STATES     US 
##   27934: -95.992   367.3     US     MN 20140731 20250430 UNITED STATES     US 
##   27935: -85.061   249.0     US     MI 20140731 20250501 UNITED STATES     US 
##   27936: -87.954    34.1     US     AL 20140731 20250501 UNITED STATES     US 
##   27937: -93.402   411.2     US     MO 20140731 20250501 UNITED STATES     US 
##           ISO3C                                                               
##          &lt;char&gt;                                                               
##       1:    AFG                                                               
##       2:    NOR                                                               
##       3:    NOR                                                               
##       4:    NOR                                                               
##       5:    NOR                                                               
##      ---                                                                      
##   27933:    USA                                                               
##   27934:    USA                                                               
##   27935:    USA                                                               
##   27936:    USA                                                               
##   27937:    USA
</CODE></PRE>

``` r
rm(isd_history)

isd_history <- new_isd_history
```

## View and save the data


``` r
str(isd_history)
```

```
## Classes 'data.table' and 'data.frame':	27937 obs. of  12 variables:
##  $ STNID       : chr  "008268-99999" "010010-99999" "010014-99999" "010015-99999" ...
##  $ NAME        : chr  "WXPOD8278" "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN" "BRINGELAND" ...
##  $ LAT         : num  33 70.9 59.8 61.4 64.8 ...
##  $ LON         : num  65.57 -8.67 5.34 5.87 11.23 ...
##  $ ELEV(M)     : num  1156.7 9 48.8 327 14 ...
##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
##  $ STATE       : chr  "" "" "" "" ...
##  $ BEGIN       : int  20100519 19310101 19861120 19870117 19870116 19880320 19861109 19850601 19730101 19310103 ...
##  $ END         : int  20120323 20250430 20250430 19971231 19910806 19971226 20250430 20250430 19970801 20041030 ...
##  $ COUNTRY_NAME: chr  "AFGHANISTAN" "NORWAY" "NORWAY" "NORWAY" ...
##  $ ISO2C       : chr  "AF" "NO" "NO" "NO" ...
##  $ ISO3C       : chr  "AFG" "NOR" "NOR" "NOR" ...
##  - attr(*, ".internal.selfref")=<externalptr> 
##  - attr(*, "sorted")= chr "STNID"
```

``` r
# write rda file to disk for use with GSODR package
save(isd_history,
     file = "../inst/extdata/isd_history.rda",
     compress = "bzip2")

save(isd_diff,
     file = "../inst/extdata/isd_diff.rda",
     compress = "bzip2")
```

# Notes

## NOAA policy

Users of these data should take into account the following (from the [NCEI website](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00516)):

> The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification. A log of IP addresses accessing these data and products will be maintained and may be made available to data providers.  
> For details, please consult: [WMO Resolution 40. NOAA Policy](https://community.wmo.int/resolution-40)

## R System Information

<PRE class="fansi fansi-output"><CODE>## <span style='color: #00BBBB; font-weight: bold;'>─ Session info ───────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>setting </span> <span style='color: #555555; font-style: italic;'>value</span>
##  version  R version 4.5.0 (2025-04-11)
##  os       macOS Sequoia 15.4.1
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_AU.UTF-8
##  ctype    en_AU.UTF-8
##  tz       Australia/Perth
##  date     2025-05-03
##  pandoc   3.6.4 @ /opt/homebrew/bin/pandoc
##  quarto   1.7.29 @ /usr/local/bin/quarto
## 
## <span style='color: #00BBBB; font-weight: bold;'>─ Packages ───────────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>! </span> <span style='color: #555555; font-style: italic;'>package    </span> <span style='color: #555555; font-style: italic;'>*</span> <span style='color: #555555; font-style: italic;'>version   </span> <span style='color: #555555; font-style: italic;'>date (UTC)</span> <span style='color: #555555; font-style: italic;'>lib</span> <span style='color: #555555; font-style: italic;'>source</span>
##     askpass       1.2.1      <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     brio          1.1.5      <span style='color: #555555;'>2024-04-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     cachem        1.1.0      <span style='color: #555555;'>2024-05-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     callr         3.7.6      <span style='color: #555555;'>2024-03-25</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     cli           3.6.5      <span style='color: #555555;'>2025-04-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     codetools     0.2-20     <span style='color: #555555;'>2024-03-31</span> <span style='color: #555555;'>[2]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     colorout      1.3-2      <span style='color: #555555;'>2025-04-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (jalvesaq/colorout@572ab10)</span>
##     commonmark    1.9.5      <span style='color: #555555;'>2025-03-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     countrycode * 1.6.1      <span style='color: #555555;'>2025-03-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     crayon        1.5.3      <span style='color: #555555;'>2024-06-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     credentials   2.0.2      <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     curl          6.2.2      <span style='color: #555555;'>2025-03-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     data.table  * 1.17.0     <span style='color: #555555;'>2025-02-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     desc          1.4.3      <span style='color: #555555;'>2023-12-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     devtag        <span style='color: #BB00BB; font-weight: bold;'>0.0.0.9000</span> <span style='color: #555555;'>2025-04-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (moodymudskipper/devtag@24f9b21)</span>
##     devtools      2.4.5      <span style='color: #555555;'>2022-10-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     diffobj       0.3.6      <span style='color: #555555;'>2025-04-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     digest        0.6.37     <span style='color: #555555;'>2024-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     ellipsis      0.3.2      <span style='color: #555555;'>2021-04-29</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     evaluate      1.0.3      <span style='color: #555555;'>2025-01-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     fansi         1.0.6      <span style='color: #555555;'>2023-12-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     fastmap       1.2.0      <span style='color: #555555;'>2024-05-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     fs            1.6.6      <span style='color: #555555;'>2025-04-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     glue          1.8.0      <span style='color: #555555;'>2024-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  <span style='color: #BBBBBB; background-color: #BB0000;'>VP</span> GSODR       * <span style='color: #BB00BB; font-weight: bold;'>4.1.3.9000</span> <span style='color: #555555;'>2024-10-16</span> <span style='color: #555555;'>[?]</span> <span style='color: #555555;'>CRAN (R 4.5.0) (on disk 4.1.3)</span>
##     htmltools     0.5.8.1    <span style='color: #555555;'>2024-04-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     htmlwidgets   1.6.4      <span style='color: #555555;'>2023-12-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     httpuv        1.6.15     <span style='color: #555555;'>2024-03-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     jsonlite      2.0.0      <span style='color: #555555;'>2025-03-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     knitr       * 1.50       <span style='color: #555555;'>2025-03-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     later         1.4.2      <span style='color: #555555;'>2025-04-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     lifecycle     1.0.4      <span style='color: #555555;'>2023-11-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     magrittr      2.0.3      <span style='color: #555555;'>2022-03-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     memoise       2.0.1      <span style='color: #555555;'>2021-11-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     mime          0.13       <span style='color: #555555;'>2025-03-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     miniUI        0.1.1.1    <span style='color: #555555;'>2018-05-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     nvimcom     * 0.9.67     <span style='color: #555555;'>2025-04-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>local</span>
##     openssl       2.3.2      <span style='color: #555555;'>2025-02-03</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     pillar        1.10.2     <span style='color: #555555;'>2025-04-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     pkgbuild      1.4.7      <span style='color: #555555;'>2025-03-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     pkgconfig     2.0.3      <span style='color: #555555;'>2019-09-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     pkgload       1.4.0      <span style='color: #555555;'>2024-06-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     processx      3.8.6      <span style='color: #555555;'>2025-02-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     profvis       0.4.0      <span style='color: #555555;'>2024-09-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     promises      1.3.2      <span style='color: #555555;'>2024-11-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     ps            1.9.1      <span style='color: #555555;'>2025-04-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     purrr         1.0.4      <span style='color: #555555;'>2025-02-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     R.methodsS3   1.8.2      <span style='color: #555555;'>2022-06-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     R.oo          1.27.1     <span style='color: #555555;'>2025-05-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     R.utils       2.13.0     <span style='color: #555555;'>2025-02-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     R6            2.6.1      <span style='color: #555555;'>2025-02-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     Rcpp          1.0.14     <span style='color: #555555;'>2025-01-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     remotes       <span style='color: #BB00BB; font-weight: bold;'>2.5.0.9000</span> <span style='color: #555555;'>2025-04-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (r-lib/remotes@bcd35d5)</span>
##     rlang         1.1.6      <span style='color: #555555;'>2025-04-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     roxygen2      7.3.2      <span style='color: #555555;'>2024-06-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     roxyglobals   1.0.0      <span style='color: #555555;'>2023-08-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     rprojroot     2.0.4      <span style='color: #555555;'>2023-11-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     rstudioapi    0.17.1     <span style='color: #555555;'>2024-10-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     sessioninfo * 1.2.3      <span style='color: #555555;'>2025-02-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     shiny         1.10.0     <span style='color: #555555;'>2024-12-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     stringi       1.8.7      <span style='color: #555555;'>2025-03-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     stringr       1.5.1      <span style='color: #555555;'>2023-11-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     sys           3.4.3      <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     testthat      3.2.3      <span style='color: #555555;'>2025-01-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     tibble        3.2.1      <span style='color: #555555;'>2023-03-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     urlchecker    1.0.1      <span style='color: #555555;'>2021-11-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     usethis       3.1.0      <span style='color: #555555;'>2024-11-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     vctrs         0.6.5      <span style='color: #555555;'>2023-12-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     withr         3.0.2      <span style='color: #555555;'>2024-10-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     xfun          0.52       <span style='color: #555555;'>2025-04-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     xml2          1.3.8      <span style='color: #555555;'>2025-03-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##     xtable        1.8-4      <span style='color: #555555;'>2019-04-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
## 
## <span style='color: #555555;'> [1] /Users/adamsparks/Library/R/arm64/4.5/library</span>
## <span style='color: #555555;'> [2] /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/library</span>
## 
##  <span style='color: #BBBBBB; background-color: #BB0000;'>*</span> ── Packages attached to the search path.
##  <span style='color: #BBBBBB; background-color: #BB0000;'>V</span> ── Loaded and on-disk version mismatch.
##  <span style='color: #BBBBBB; background-color: #BB0000;'>P</span> ── Loaded and on-disk path mismatch.
## 
## <span style='color: #00BBBB; font-weight: bold;'>──────────────────────────────────────────────────────────────────────────────</span>
</CODE></PRE>
