---
title: "Fetch and Clean 'isd_history.csv' File"
author: "Adam H. Sparks"
date: "2023-08-20"
output: github_document
---



<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>

# Introduction

The "isd_history.csv" file details GSOD station metadata.
These data include the start and stop years used by *GSODR* to pre-check requests before querying the server for download and the country code used by *GSODR* when sub-setting for requests by country.
The following checks are performed on the raw data file before inclusion in *GSODR*,

-   Check for valid lon and lat values;

    -   isd_history where latitude or longitude are `NA` or both 0 are removed leaving only properly georeferenced stations,

    -   isd_history where latitude is < -90˚ or > 90˚ are removed,

    -   isd_history where longitude is < -180˚ or > 180˚ are removed.

-   A new field, STNID, a concatenation of the USAF and WBAN fields, is added.

# Data Processing

## Set up workspace


```r
library("sessioninfo")
library("skimr")
```

```
## Error in library("skimr"): there is no package called 'skimr'
```

```r
library("countrycode")
library("data.table")
```

## Download and clean data


```r
# download data
new_isd_history <- fread("https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")
```

## Add/drop columns and save to disk


```r
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


```r
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
setkeyv(new_isd_history, "STNID")[]
```

```
##               STNID                                              NAME    LAT     LON ELEV(M) CTRY STATE    BEGIN      END  COUNTRY_NAME ISO2C ISO3C
##     1: 008268-99999                                         WXPOD8278 32.950  65.567  1156.7   AF       20100519 20120323   AFGHANISTAN    AF   AFG
##     2: 010010-99999                               JAN MAYEN(NOR-NAVY) 70.933  -8.667     9.0   NO       19310101 20230817        NORWAY    NO   NOR
##     3: 010014-99999                                        SORSTOKKEN 59.792   5.341    48.8   NO       19861120 20230817        NORWAY    NO   NOR
##     4: 010015-99999                                        BRINGELAND 61.383   5.867   327.0   NO       19870117 19971231        NORWAY    NO   NOR
##     5: 010016-99999                                       RORVIK/RYUM 64.850  11.233    14.0   NO       19870116 19910806        NORWAY    NO   NOR
##    ---                                                                                                                                             
## 27931: A07355-00241                         VIROQUA MUNICIPAL AIRPORT 43.579 -90.913   394.1   US    WI 20140731 20230818 UNITED STATES    US   USA
## 27932: A07357-00182 ELBOW LAKE MUNICIPAL PRIDE OF THE PRAIRIE AIRPORT 45.986 -95.992   367.3   US    MN 20140731 20230818 UNITED STATES    US   USA
## 27933: A07359-00240                              IONIA COUNTY AIRPORT 42.938 -85.061   249.0   US    MI 20140731 20230818 UNITED STATES    US   USA
## 27934: A51255-00445                       DEMOPOLIS MUNICIPAL AIRPORT 32.464 -87.954    34.1   US    AL 20140731 20230819 UNITED STATES    US   USA
## 27935: A51256-00451      BRANSON WEST MUNICIPAL EMERSON FIELD AIRPORT 36.699 -93.402   411.2   US    MO 20140731 20230818 UNITED STATES    US   USA
```

## Show changes from last release


```r
# ensure we aren't using a locally installed dev version
install.packages("GSODR", repos = "https://cloud.r-project.org/")
```

```
## Installing package into '/Users/adamsparks/Library/R/arm64/4.3/library'
## (as 'lib' is unspecified)
```

```
## 
## The downloaded binary packages are in
## 	/var/folders/ch/8fqkzddj1kj_qb5ddfdd3p1w0000gn/T//RtmpLczN2T/downloaded_packages
```

```r
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

# select only the cols of interest
x <- names(isd_history)
new_isd_history <- new_isd_history[, ..x] 

(isd_diff <- diffobj::diffPrint(new_isd_history, isd_history))
```

<PRE class="fansi fansi-output"><CODE>## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>new_isd_history</span>                                                                                                                                    
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>isd_history</span>                                                                                                                                        
## <span style='color: #00BBBB;'>@@ 1,12 / 1,12 @@                                                                                                                                    </span>
##                 STNID                                              NAME    LAT     LON ELEV(M) CTRY STATE    BEGIN      END  COUNTRY_NAME ISO2C ISO3C
##       1: 008268-99999                                         WXPOD8278 32.950  65.567  1156.7   AF       20100519 20120323   AFGHANISTAN    AF   AFG
## <span style='color: #BBBB00;'>&lt;</span>     2: 010010-99999                               JAN MAYEN(NOR-NAVY) 70.933  -8.667     9.0   NO       19310101 <span style='color: #BBBB00;'>20230817</span>        NORWAY    NO   NOR
## <span style='color: #0000BB;'>&gt;</span>     2: 010010-99999                               JAN MAYEN(NOR-NAVY) 70.933  -8.667     9.0   NO       19310101 <span style='color: #0000BB;'>20230222</span>        NORWAY    NO   NOR
## <span style='color: #BBBB00;'>&lt;</span>     3: 010014-99999                                        SORSTOKKEN 59.792   5.341    48.8   NO       19861120 <span style='color: #BBBB00;'>20230817</span>        NORWAY    NO   NOR
## <span style='color: #0000BB;'>&gt;</span>     3: 010014-99999                                        SORSTOKKEN 59.792   5.341    48.8   NO       19861120 <span style='color: #0000BB;'>20230222</span>        NORWAY    NO   NOR
##       4: 010015-99999                                        BRINGELAND 61.383   5.867   327.0   NO       19870117 19971231        NORWAY    NO   NOR
##       5: 010016-99999                                       RORVIK/RYUM 64.850  11.233    14.0   NO       19870116 19910806        NORWAY    NO   NOR
##      ---                                                                                                                                             
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27931:</span> A07355-00241                         VIROQUA MUNICIPAL AIRPORT 43.579 -90.913   394.1   US    WI 20140731 <span style='color: #BBBB00;'>20230818</span> UNITED STATES    US   USA
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27925:</span> A07355-00241                         VIROQUA MUNICIPAL AIRPORT 43.579 -90.913   394.1   US    WI 20140731 <span style='color: #0000BB;'>20230224</span> UNITED STATES    US   USA
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27932:</span> A07357-00182 ELBOW LAKE MUNICIPAL PRIDE OF THE PRAIRIE AIRPORT 45.986 -95.992   367.3   US    MN 20140731 <span style='color: #BBBB00;'>20230818</span> UNITED STATES    US   USA
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27926:</span> A07357-00182 ELBOW LAKE MUNICIPAL PRIDE OF THE PRAIRIE AIRPORT 45.986 -95.992   367.3   US    MN 20140731 <span style='color: #0000BB;'>20230225</span> UNITED STATES    US   USA
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27933:</span> A07359-00240                              IONIA COUNTY AIRPORT 42.938 -85.061   249.0   US    MI 20140731 <span style='color: #BBBB00;'>20230818</span> UNITED STATES    US   USA
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27927:</span> A07359-00240                              IONIA COUNTY AIRPORT 42.938 -85.061   249.0   US    MI 20140731 <span style='color: #0000BB;'>20230225</span> UNITED STATES    US   USA
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27934:</span> A51255-00445                       DEMOPOLIS MUNICIPAL AIRPORT 32.464 -87.954    34.1   US    AL 20140731 <span style='color: #BBBB00;'>20230819</span> UNITED STATES    US   USA
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27928:</span> A51255-00445                       DEMOPOLIS MUNICIPAL AIRPORT 32.464 -87.954    34.1   US    AL 20140731 <span style='color: #0000BB;'>20230107</span> UNITED STATES    US   USA
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27935:</span> A51256-00451      BRANSON WEST MUNICIPAL EMERSON FIELD AIRPORT 36.699 -93.402   411.2   US    MO 20140731 <span style='color: #BBBB00;'>20230818</span> UNITED STATES    US   USA
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27929:</span> A51256-00451      BRANSON WEST MUNICIPAL EMERSON FIELD AIRPORT 36.699 -93.402   411.2   US    MO 20140731 <span style='color: #0000BB;'>20230224</span> UNITED STATES    US   USA
</CODE></PRE>

```r
rm(isd_history)

isd_history <- new_isd_history
```

## View and save the data


```r
str(isd_history)
```

```
## Classes 'data.table' and 'data.frame':	27935 obs. of  12 variables:
##  $ STNID       : chr  "008268-99999" "010010-99999" "010014-99999" "010015-99999" ...
##  $ NAME        : chr  "WXPOD8278" "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN" "BRINGELAND" ...
##  $ LAT         : num  33 70.9 59.8 61.4 64.8 ...
##  $ LON         : num  65.57 -8.67 5.34 5.87 11.23 ...
##  $ ELEV(M)     : num  1156.7 9 48.8 327 14 ...
##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
##  $ STATE       : chr  "" "" "" "" ...
##  $ BEGIN       : int  20100519 19310101 19861120 19870117 19870116 19880320 19861109 19850601 19730101 19310103 ...
##  $ END         : int  20120323 20230817 20230817 19971231 19910806 19971226 20230816 20230815 19970801 20041030 ...
##  $ COUNTRY_NAME: chr  "AFGHANISTAN" "NORWAY" "NORWAY" "NORWAY" ...
##  $ ISO2C       : chr  "AF" "NO" "NO" "NO" ...
##  $ ISO3C       : chr  "AFG" "NOR" "NOR" "NOR" ...
##  - attr(*, ".internal.selfref")=<externalptr> 
##  - attr(*, "sorted")= chr "STNID"
```

```r
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

<PRE class="fansi fansi-output"><CODE>## <span style='color: #00BBBB; font-weight: bold;'>─ Session info ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>setting </span> <span style='color: #555555; font-style: italic;'>value</span>
##  version  R version 4.3.1 (2023-06-16)
##  os       macOS Ventura 13.5.1
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       Australia/Perth
##  date     2023-08-20
##  pandoc   3.1.6.1 @ /opt/homebrew/bin//pandoc
## 
## <span style='color: #00BBBB; font-weight: bold;'>─ Packages ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>! </span> <span style='color: #555555; font-style: italic;'>package    </span> <span style='color: #555555; font-style: italic;'>*</span> <span style='color: #555555; font-style: italic;'>version   </span> <span style='color: #555555; font-style: italic;'>date (UTC)</span> <span style='color: #555555; font-style: italic;'>lib</span> <span style='color: #555555; font-style: italic;'>source</span>
##     askpass       1.1        <span style='color: #555555;'>2019-01-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     bit           4.0.5      <span style='color: #555555;'>2022-11-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     bit64         4.0.5      <span style='color: #555555;'>2020-08-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     blob          1.2.4      <span style='color: #555555;'>2023-03-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     brio          1.1.3      <span style='color: #555555;'>2021-11-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     bslib         0.5.1      <span style='color: #555555;'>2023-08-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     cachem        1.0.8      <span style='color: #555555;'>2023-05-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     callr         3.7.3      <span style='color: #555555;'>2022-11-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     cli           3.6.1      <span style='color: #555555;'>2023-03-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     countrycode * 1.5.0      <span style='color: #555555;'>2023-05-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     covr          3.6.2      <span style='color: #555555;'>2023-03-25</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     crancache     <span style='color: #BB00BB; font-weight: bold;'>0.0.0.9001</span> <span style='color: #555555;'>2023-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (r-lib/crancache@fc51e31)</span>
##     cranlike      1.0.2      <span style='color: #555555;'>2018-11-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     crayon        1.5.2      <span style='color: #555555;'>2022-09-29</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     credentials   1.3.2      <span style='color: #555555;'>2021-11-29</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     crosstalk     1.2.0      <span style='color: #555555;'>2021-11-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     curl          5.0.2      <span style='color: #555555;'>2023-08-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     data.table  * 1.14.8     <span style='color: #555555;'>2023-02-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.1)</span>
##     DBI           1.1.3      <span style='color: #555555;'>2022-06-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     debugme       1.1.0      <span style='color: #555555;'>2017-10-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     desc          1.4.2      <span style='color: #555555;'>2022-09-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     devtools      2.4.5      <span style='color: #555555;'>2022-10-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     diffobj       0.3.5      <span style='color: #555555;'>2021-10-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     digest        0.6.33     <span style='color: #555555;'>2023-07-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     DT            0.28       <span style='color: #555555;'>2023-05-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     ellipsis      0.3.2      <span style='color: #555555;'>2021-04-29</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     evaluate      0.21       <span style='color: #555555;'>2023-05-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     fansi         1.0.4      <span style='color: #555555;'>2023-01-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     fastmap       1.1.1      <span style='color: #555555;'>2023-02-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     fs            1.6.3      <span style='color: #555555;'>2023-07-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     glue          1.6.2      <span style='color: #555555;'>2022-02-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##  <span style='color: #BBBBBB; background-color: #BB0000;'>VP</span> GSODR       * <span style='color: #BB00BB; font-weight: bold;'>3.1.8.9000</span> <span style='color: #555555;'>2023-02-25</span> <span style='color: #555555;'>[?]</span> <span style='color: #555555;'>CRAN (R 4.3.0) (on disk 3.1.8)</span>
##     htmltools     0.5.6      <span style='color: #555555;'>2023-08-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     htmlwidgets   1.6.2      <span style='color: #555555;'>2023-03-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     httpuv        1.6.11     <span style='color: #555555;'>2023-05-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     httr          1.4.7      <span style='color: #555555;'>2023-08-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     jquerylib     0.1.4      <span style='color: #555555;'>2021-04-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     jsonlite      1.8.7      <span style='color: #555555;'>2023-06-29</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     knitr         1.43       <span style='color: #555555;'>2023-05-25</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     later         1.3.1      <span style='color: #555555;'>2023-05-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     lazyeval      0.2.2      <span style='color: #555555;'>2019-03-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     lifecycle     1.0.3      <span style='color: #555555;'>2022-10-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     magrittr      2.0.3      <span style='color: #555555;'>2022-03-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     memoise       2.0.1      <span style='color: #555555;'>2021-11-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     mime          0.12       <span style='color: #555555;'>2021-09-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     miniUI        0.1.1.1    <span style='color: #555555;'>2018-05-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     openssl       2.1.0      <span style='color: #555555;'>2023-07-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     parsedate     1.3.1      <span style='color: #555555;'>2022-10-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     pillar        1.9.0      <span style='color: #555555;'>2023-03-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     pkgbuild      1.4.2      <span style='color: #555555;'>2023-06-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     pkgconfig     2.0.3      <span style='color: #555555;'>2019-09-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     pkgload       1.3.2.1    <span style='color: #555555;'>2023-07-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     prettyunits   1.1.1      <span style='color: #555555;'>2020-01-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     processx      3.8.2      <span style='color: #555555;'>2023-06-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     profvis       0.3.8      <span style='color: #555555;'>2023-05-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     promises      1.2.1      <span style='color: #555555;'>2023-08-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     ps            1.7.5      <span style='color: #555555;'>2023-04-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     purrr         1.0.2      <span style='color: #555555;'>2023-08-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     R.methodsS3   1.8.2      <span style='color: #555555;'>2022-06-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     R.oo          1.25.0     <span style='color: #555555;'>2022-06-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     R.utils       2.12.2     <span style='color: #555555;'>2022-11-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     R6            2.5.1      <span style='color: #555555;'>2021-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     rappdirs      0.3.3      <span style='color: #555555;'>2021-01-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     rcmdcheck     1.4.0      <span style='color: #555555;'>2021-09-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     Rcpp          1.0.11     <span style='color: #555555;'>2023-07-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     rematch2      2.1.2      <span style='color: #555555;'>2020-05-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     remotes       2.4.2.1    <span style='color: #555555;'>2023-07-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     rex           1.2.1      <span style='color: #555555;'>2021-11-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     rlang         1.1.1      <span style='color: #555555;'>2023-04-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     roxygen2      7.2.3      <span style='color: #555555;'>2022-12-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     rprojroot     2.0.3      <span style='color: #555555;'>2022-04-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     RSQLite       2.3.1      <span style='color: #555555;'>2023-04-03</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     rsthemes      0.4.0      <span style='color: #555555;'>2023-07-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (gadenbuie/rsthemes@34a55a4)</span>
##     rstudioapi    0.15.0     <span style='color: #555555;'>2023-07-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     sass          0.4.7      <span style='color: #555555;'>2023-07-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     sessioninfo * 1.2.2      <span style='color: #555555;'>2021-12-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     shiny         1.7.5      <span style='color: #555555;'>2023-08-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     stringi       1.7.12     <span style='color: #555555;'>2023-01-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     stringr       1.5.0      <span style='color: #555555;'>2022-12-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     sys           3.4.2      <span style='color: #555555;'>2023-05-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     testthat      3.1.10     <span style='color: #555555;'>2023-07-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     tibble        3.2.1      <span style='color: #555555;'>2023-03-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     urlchecker    1.0.1      <span style='color: #555555;'>2021-11-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     usethis       2.2.2      <span style='color: #555555;'>2023-07-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     utf8          1.2.3      <span style='color: #555555;'>2023-01-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     vctrs         0.6.3      <span style='color: #555555;'>2023-06-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     withr         2.5.0      <span style='color: #555555;'>2022-03-03</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     xfun          0.40       <span style='color: #555555;'>2023-08-09</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     xml2          1.3.5      <span style='color: #555555;'>2023-07-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     xopen         1.0.0      <span style='color: #555555;'>2018-09-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     xtable        1.8-4      <span style='color: #555555;'>2019-04-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
##     yaml          2.3.7      <span style='color: #555555;'>2023-01-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.3.0)</span>
## 
## <span style='color: #555555;'> [1] /Users/adamsparks/Library/R/arm64/4.3/library</span>
## <span style='color: #555555;'> [2] /Library/Frameworks/R.framework/Versions/4.3-arm64/Resources/library</span>
## 
##  <span style='color: #BBBBBB; background-color: #BB0000;'>V</span> ── Loaded and on-disk version mismatch.
##  <span style='color: #BBBBBB; background-color: #BB0000;'>P</span> ── Loaded and on-disk path mismatch.
## 
## <span style='color: #00BBBB; font-weight: bold;'>───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────</span>
</CODE></PRE>
