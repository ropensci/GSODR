Fetch and Clean ‘isd_history.csv’ File
================
Adam H. Sparks
2025-02-05

<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>

# Introduction

The “isd_history.csv” file details GSOD station metadata. These data
include the start and stop years used by {GSODR} to pre-check requests
before querying the server for download and the country code used by
{GSODR} when sub-setting for requests by country. The following checks
are performed on the raw data file before inclusion in {GSODR},

- Check for valid lon and lat values;

  - isd_history where latitude or longitude are `NA` or both 0 are
    removed leaving only properly georeferenced stations,

  - isd_history where latitude is \< -90˚ or \> 90˚ are removed,

  - isd_history where longitude is \< -180˚ or \> 180˚ are removed.

- A new field, STNID, a concatenation of the USAF and WBAN fields, is
  added.

# Data Processing

## Set up workspace

``` r
library("sessioninfo")
library("skimr")
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

    ## Installing package into '/Users/283204f/Library/R/arm64/4.4/library'
    ## (as 'lib' is unspecified)

    ## 
    ## The downloaded binary packages are in
    ##  /var/folders/r4/wwsd3hsn48j5gck6qv6npkpc0000gr/T//RtmpwvAIs1/downloaded_packages

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
## <span style='color: #00BBBB;'>@@ 1,40 / 1,40 @@                                                      </span>
##   Key: &lt;STNID&gt;                                                         
##                 STNID                                              NAME
##                &lt;char&gt;                                            &lt;char&gt;
##       1: 008268-99999                                         WXPOD8278
##       2: 010010-99999                               JAN MAYEN(NOR-NAVY)
##       3: 010014-99999                                        SORSTOKKEN
##       4: 010015-99999                                        BRINGELAND
##       5: 010016-99999                                       RORVIK/RYUM
##      ---                                                               
##   27932: A07355-00241                         VIROQUA MUNICIPAL AIRPORT
##   27933: A07357-00182 ELBOW LAKE MUNICIPAL PRIDE OF THE PRAIRIE AIRPORT
##   27934: A07359-00240                              IONIA COUNTY AIRPORT
##   27935: A51255-00445                       DEMOPOLIS MUNICIPAL AIRPORT
##   27936: A51256-00451      BRANSON WEST MUNICIPAL EMERSON FIELD AIRPORT
##             LAT     LON ELEV(M)   CTRY  STATE    BEGIN      END        
##           &lt;num&gt;   &lt;num&gt;   &lt;num&gt; &lt;char&gt; &lt;char&gt;    &lt;int&gt;    &lt;int&gt;        
##       1: 32.950  65.567  1156.7     AF        20100519 20120323        
##       2: 70.933  -8.667     9.0     NO        19310101 20250202        
##       3: 59.792   5.341    48.8     NO        19861120 20250202        
##       4: 61.383   5.867   327.0     NO        19870117 19971231        
##       5: 64.850  11.233    14.0     NO        19870116 19910806        
##      ---                                                               
##   27932: 43.579 -90.913   394.1     US     WI 20140731 20250203        
##   27933: 45.986 -95.992   367.3     US     MN 20140731 20250204        
##   27934: 42.938 -85.061   249.0     US     MI 20140731 20250204        
##   27935: 32.464 -87.954    34.1     US     AL 20140731 20250203        
##   27936: 36.699 -93.402   411.2     US     MO 20140731 20250203        
##           COUNTRY_NAME  ISO2C  ISO3C                                   
##                 &lt;char&gt; &lt;char&gt; &lt;char&gt;                                   
##       1:   AFGHANISTAN     AF    AFG                                   
##       2:        NORWAY     NO    NOR                                   
##       3:        NORWAY     NO    NOR                                   
##       4:        NORWAY     NO    NOR                                   
##       5:        NORWAY     NO    NOR                                   
##      ---                                                               
##   27932: UNITED STATES     US    USA                                   
##   27933: UNITED STATES     US    USA                                   
##   27934: UNITED STATES     US    USA                                   
##   27935: UNITED STATES     US    USA                                   
##   27936: UNITED STATES     US    USA
</CODE></PRE>

``` r
rm(isd_history)

isd_history <- new_isd_history
```

## View and save the data

``` r
str(isd_history)
```

    ## Classes 'data.table' and 'data.frame':   27936 obs. of  12 variables:
    ##  $ STNID       : chr  "008268-99999" "010010-99999" "010014-99999" "010015-99999" ...
    ##  $ NAME        : chr  "WXPOD8278" "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN" "BRINGELAND" ...
    ##  $ LAT         : num  33 70.9 59.8 61.4 64.8 ...
    ##  $ LON         : num  65.57 -8.67 5.34 5.87 11.23 ...
    ##  $ ELEV(M)     : num  1156.7 9 48.8 327 14 ...
    ##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
    ##  $ STATE       : chr  "" "" "" "" ...
    ##  $ BEGIN       : int  20100519 19310101 19861120 19870117 19870116 19880320 19861109 19850601 19730101 19310103 ...
    ##  $ END         : int  20120323 20250202 20250202 19971231 19910806 19971226 20250202 20250202 19970801 20041030 ...
    ##  $ COUNTRY_NAME: chr  "AFGHANISTAN" "NORWAY" "NORWAY" "NORWAY" ...
    ##  $ ISO2C       : chr  "AF" "NO" "NO" "NO" ...
    ##  $ ISO3C       : chr  "AFG" "NOR" "NOR" "NOR" ...
    ##  - attr(*, ".internal.selfref")=<externalptr> 
    ##  - attr(*, "sorted")= chr "STNID"

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

Users of these data should take into account the following (from the
[NCEI
website](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00516)):

> The following data and products may have conditions placed on their
> international commercial use. They can be used within the U.S. or for
> non-commercial international activities without restriction. The
> non-U.S. data cannot be redistributed for commercial purposes.
> Re-distribution of these data by others must provide this same
> notification. A log of IP addresses accessing these data and products
> will be maintained and may be made available to data providers.  
> For details, please consult: [WMO Resolution 40. NOAA
> Policy](https://community.wmo.int/resolution-40)

## R System Information

<PRE class="fansi fansi-output"><CODE>## <span style='color: #00BBBB; font-weight: bold;'>─ Session info ─────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>setting </span> <span style='color: #555555; font-style: italic;'>value</span>
##  version  R version 4.4.2 (2024-10-31)
##  os       macOS Sequoia 15.3
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_AU.UTF-8
##  ctype    en_AU.UTF-8
##  tz       Australia/Perth
##  date     2025-02-05
##  pandoc   3.6.2 @ /opt/homebrew/bin/ (via rmarkdown)
## 
## <span style='color: #00BBBB; font-weight: bold;'>─ Packages ─────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>!</span> <span style='color: #555555; font-style: italic;'>package    </span> <span style='color: #555555; font-style: italic;'>*</span> <span style='color: #555555; font-style: italic;'>version   </span> <span style='color: #555555; font-style: italic;'>date (UTC)</span> <span style='color: #555555; font-style: italic;'>lib</span> <span style='color: #555555; font-style: italic;'>source</span>
##    askpass       1.2.1      <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    base64enc     0.1-3      <span style='color: #555555;'>2015-07-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    brio          1.1.5      <span style='color: #555555;'>2024-04-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    cachem        1.1.0      <span style='color: #555555;'>2024-05-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    callr         3.7.6      <span style='color: #555555;'>2024-03-25</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    cli           3.6.3      <span style='color: #555555;'>2024-06-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    codemeta      0.1.1      <span style='color: #555555;'>2021-12-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    codemetar     0.3.5      <span style='color: #555555;'>2022-09-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    codetools     0.2-20     <span style='color: #555555;'>2024-03-31</span> <span style='color: #555555;'>[2]</span> <span style='color: #555555;'>CRAN (R 4.4.2)</span>
##    colorout      1.3-2      <span style='color: #555555;'>2024-12-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (jalvesaq/colorout@2a5f214)</span>
##    commonmark    1.9.2      <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    countrycode * 1.6.0      <span style='color: #555555;'>2024-03-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    crayon        1.5.3      <span style='color: #555555;'>2024-06-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    credentials   2.0.2      <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    crul          1.5.0      <span style='color: #555555;'>2024-07-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    curl          6.2.0      <span style='color: #555555;'>2025-01-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    data.table  * 1.16.4     <span style='color: #555555;'>2024-12-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    desc          1.4.3      <span style='color: #555555;'>2023-12-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    devtag        <span style='color: #BB00BB; font-weight: bold;'>0.0.0.9000</span> <span style='color: #555555;'>2025-02-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (moodymudskipper/devtag@24f9b21)</span>
##    devtools      2.4.5      <span style='color: #555555;'>2022-10-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    diffobj       0.3.5      <span style='color: #555555;'>2021-10-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    digest        0.6.37     <span style='color: #555555;'>2024-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    dplyr         1.1.4      <span style='color: #555555;'>2023-11-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    ellipsis      0.3.2      <span style='color: #555555;'>2021-04-29</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    evaluate      1.0.3      <span style='color: #555555;'>2025-01-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    fansi         1.0.6      <span style='color: #555555;'>2023-12-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    fastmap       1.2.0      <span style='color: #555555;'>2024-05-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    fs            1.6.5      <span style='color: #555555;'>2024-10-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    generics      0.1.3      <span style='color: #555555;'>2022-07-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    gert          2.1.4      <span style='color: #555555;'>2024-10-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    gh            1.4.1      <span style='color: #555555;'>2024-03-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    gitcreds      0.1.2      <span style='color: #555555;'>2022-09-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    glue          1.8.0      <span style='color: #555555;'>2024-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##  <span style='color: #BBBBBB; background-color: #BB0000;'>P</span> GSODR       * 4.1.3      <span style='color: #555555;'>2024-10-16</span> <span style='color: #555555;'>[?]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    htmltools     0.5.8.1    <span style='color: #555555;'>2024-04-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    htmlwidgets   1.6.4      <span style='color: #555555;'>2023-12-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    httpcode      0.3.0      <span style='color: #555555;'>2020-04-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    httpuv        1.6.15     <span style='color: #555555;'>2024-03-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    httr2         1.1.0      <span style='color: #555555;'>2025-01-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    jsonlite      1.8.9      <span style='color: #555555;'>2024-09-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    knitr         1.49       <span style='color: #555555;'>2024-11-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    later         1.4.1      <span style='color: #555555;'>2024-11-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    lifecycle     1.0.4      <span style='color: #555555;'>2023-11-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    magrittr      2.0.3      <span style='color: #555555;'>2022-03-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    memoise       2.0.1      <span style='color: #555555;'>2021-11-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    mime          0.12       <span style='color: #555555;'>2021-09-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    miniUI        0.1.1.1    <span style='color: #555555;'>2018-05-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    nvimcom     * 0.9.60     <span style='color: #555555;'>2024-12-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>local</span>
##    openssl       2.3.2      <span style='color: #555555;'>2025-02-03</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    pillar        1.10.1     <span style='color: #555555;'>2025-01-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    pingr         2.0.5      <span style='color: #555555;'>2024-12-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    pkgbuild      1.4.6      <span style='color: #555555;'>2025-01-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    pkgconfig     2.0.3      <span style='color: #555555;'>2019-09-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    pkgload       1.4.0      <span style='color: #555555;'>2024-06-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    processx      3.8.5      <span style='color: #555555;'>2025-01-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    profvis       0.4.0      <span style='color: #555555;'>2024-09-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    promises      1.3.2      <span style='color: #555555;'>2024-11-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    ps            1.8.1      <span style='color: #555555;'>2024-10-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    purrr         1.0.2      <span style='color: #555555;'>2023-08-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    R.methodsS3   1.8.2      <span style='color: #555555;'>2022-06-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    R.oo          1.27.0     <span style='color: #555555;'>2024-11-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    R.utils       2.12.3     <span style='color: #555555;'>2023-11-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    R6            2.5.1      <span style='color: #555555;'>2021-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    rappdirs      0.3.3      <span style='color: #555555;'>2021-01-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    Rcpp          1.0.14     <span style='color: #555555;'>2025-01-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.2)</span>
##    remotes       2.5.0      <span style='color: #555555;'>2024-03-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    repr          1.1.7      <span style='color: #555555;'>2024-03-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    rlang         1.1.5      <span style='color: #555555;'>2025-01-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    rmarkdown   * 2.29       <span style='color: #555555;'>2024-11-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    roxygen2      7.3.2      <span style='color: #555555;'>2024-06-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    roxyglobals   1.0.0      <span style='color: #555555;'>2023-08-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    rprojroot     2.0.4      <span style='color: #555555;'>2023-11-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    rstudioapi    0.17.1     <span style='color: #555555;'>2024-10-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    sessioninfo * 1.2.2      <span style='color: #555555;'>2021-12-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    shiny         1.10.0     <span style='color: #555555;'>2024-12-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    skimr       * 2.1.5      <span style='color: #555555;'>2022-12-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    stringi       1.8.4      <span style='color: #555555;'>2024-05-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    stringr       1.5.1      <span style='color: #555555;'>2023-11-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    sys           3.4.3      <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    testthat      3.2.3      <span style='color: #555555;'>2025-01-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    tibble        3.2.1      <span style='color: #555555;'>2023-03-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    tidyselect    1.2.1      <span style='color: #555555;'>2024-03-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    triebeard     0.4.1      <span style='color: #555555;'>2023-03-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    urlchecker    1.0.1      <span style='color: #555555;'>2021-11-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    urltools      1.7.3      <span style='color: #555555;'>2019-04-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    usethis       3.1.0      <span style='color: #555555;'>2024-11-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    vctrs         0.6.5      <span style='color: #555555;'>2023-12-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    withr         3.0.2      <span style='color: #555555;'>2024-10-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    xfun          0.50       <span style='color: #555555;'>2025-01-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.1)</span>
##    xml2          1.3.6      <span style='color: #555555;'>2023-12-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    xtable        1.8-4      <span style='color: #555555;'>2019-04-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##    yaml          2.3.10     <span style='color: #555555;'>2024-07-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
## 
## <span style='color: #555555;'> [1] /Users/283204f/Library/R/arm64/4.4/library</span>
## <span style='color: #555555;'> [2] /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library</span>
## 
##  <span style='color: #BBBBBB; background-color: #BB0000;'>P</span> ── Loaded and on-disk path mismatch.
## 
## <span style='color: #00BBBB; font-weight: bold;'>────────────────────────────────────────────────────────────────────────</span>
</CODE></PRE>
