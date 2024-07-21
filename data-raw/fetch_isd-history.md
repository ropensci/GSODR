Fetch and Clean ‘isd_history.csv’ File
================
Adam H. Sparks
2024-07-21

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

    ## Installing package into '/Users/adamsparks/Library/R/arm64/4.4/library'
    ## (as 'lib' is unspecified)

    ## 
    ## The downloaded binary packages are in
    ##  /var/folders/ch/8fqkzddj1kj_qb5ddfdd3p1w0000gn/T//Rtmpx7iKJ9/downloaded_packages

``` r
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

# select only the cols of interest
x <- names(isd_history)
new_isd_history <- new_isd_history[, ..x] 

(isd_diff <- diffobj::diffPrint(new_isd_history, isd_history))
```

<PRE class="fansi fansi-output"><CODE>## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>new_isd_history</span>                                                             
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>isd_history</span>                                                                 
## <span style='color: #00BBBB;'>@@ 8,22 / 8,22 @@                                                             </span>
## <span style='color: #555555;'>~               STNID                                              NAME    LAT</span>
## <span style='color: #555555;'>~              &lt;char&gt;                                            &lt;char&gt;  &lt;num&gt;</span>
##       5: 010016-99999                                       RORVIK/RYUM 64.850
##      ---                                                                      
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27921:</span> A07355-00241                         VIROQUA MUNICIPAL AIRPORT 43.579
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27930:</span> A07355-00241                         VIROQUA MUNICIPAL AIRPORT 43.579
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27922:</span> A07357-00182 ELBOW LAKE MUNICIPAL PRIDE OF THE PRAIRIE AIRPORT 45.986
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27931:</span> A07357-00182 ELBOW LAKE MUNICIPAL PRIDE OF THE PRAIRIE AIRPORT 45.986
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27923:</span> A07359-00240                              IONIA COUNTY AIRPORT 42.938
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27932:</span> A07359-00240                              IONIA COUNTY AIRPORT 42.938
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27924:</span> A51255-00445                       DEMOPOLIS MUNICIPAL AIRPORT 32.464
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27933:</span> A51255-00445                       DEMOPOLIS MUNICIPAL AIRPORT 32.464
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27925:</span> A51256-00451      BRANSON WEST MUNICIPAL EMERSON FIELD AIRPORT 36.699
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27934:</span> A51256-00451      BRANSON WEST MUNICIPAL EMERSON FIELD AIRPORT 36.699
##              LON ELEV(M)   CTRY  STATE    BEGIN      END  COUNTRY_NAME  ISO2C 
##            &lt;num&gt;   &lt;num&gt; &lt;char&gt; &lt;char&gt;    &lt;int&gt;    &lt;int&gt;        &lt;char&gt; &lt;char&gt; 
##       1:  65.567  1156.7     AF        20100519 20120323   AFGHANISTAN     AF 
## <span style='color: #BBBB00;'>&lt;</span>     2:  -8.667     9.0     NO        19310101 <span style='color: #BBBB00;'>20240718</span>        NORWAY     NO 
## <span style='color: #0000BB;'>&gt;</span>     2:  -8.667     9.0     NO        19310101 <span style='color: #0000BB;'>20240324</span>        NORWAY     NO 
## <span style='color: #BBBB00;'>&lt;</span>     3:   5.341    48.8     NO        19861120 <span style='color: #BBBB00;'>20240718</span>        NORWAY     NO 
## <span style='color: #0000BB;'>&gt;</span>     3:   5.341    48.8     NO        19861120 <span style='color: #0000BB;'>20240324</span>        NORWAY     NO 
##       4:   5.867   327.0     NO        19870117 19971231        NORWAY     NO 
##       5:  11.233    14.0     NO        19870116 19910806        NORWAY     NO 
##      ---                                                                      
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27921:</span> -90.913   394.1     US     WI 20140731 <span style='color: #BBBB00;'>20240719</span> UNITED STATES     US 
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27930:</span> -90.913   394.1     US     WI 20140731 <span style='color: #0000BB;'>20240325</span> UNITED STATES     US 
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27922:</span> -95.992   367.3     US     MN 20140731 <span style='color: #BBBB00;'>20240719</span> UNITED STATES     US 
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27931:</span> -95.992   367.3     US     MN 20140731 <span style='color: #0000BB;'>20240326</span> UNITED STATES     US 
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27923:</span> -85.061   249.0     US     MI 20140731 <span style='color: #BBBB00;'>20240719</span> UNITED STATES     US 
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27932:</span> -85.061   249.0     US     MI 20140731 <span style='color: #0000BB;'>20240325</span> UNITED STATES     US 
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27924:</span> -87.954    34.1     US     AL 20140731 <span style='color: #BBBB00;'>20240719</span> UNITED STATES     US 
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27933:</span> -87.954    34.1     US     AL 20140731 <span style='color: #0000BB;'>20240325</span> UNITED STATES     US 
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27925:</span> -93.402   411.2     US     MO 20140731 <span style='color: #BBBB00;'>20240719</span> UNITED STATES     US 
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27934:</span> -93.402   411.2     US     MO 20140731 <span style='color: #0000BB;'>20240326</span> UNITED STATES     US 
##           ISO3C                                                               
##          &lt;char&gt;                                                               
## <span style='color: #00BBBB;'>@@ 34,7 / 34,7 @@                                                             </span>
## <span style='color: #555555;'>~         ISO3C                                                               </span>
## <span style='color: #555555;'>~        &lt;char&gt;                                                               </span>
##       5:    NOR                                                               
##      ---                                                                      
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27921:</span>    USA                                                               
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27930:</span>    USA                                                               
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27922:</span>    USA                                                               
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27931:</span>    USA                                                               
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27923:</span>    USA                                                               
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27932:</span>    USA                                                               
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27924:</span>    USA                                                               
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27933:</span>    USA                                                               
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27925:</span>    USA                                                               
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>27934:</span>    USA
</CODE></PRE>

``` r
rm(isd_history)

isd_history <- new_isd_history
```

## View and save the data

``` r
str(isd_history)
```

    ## Classes 'data.table' and 'data.frame':   27925 obs. of  12 variables:
    ##  $ STNID       : chr  "008268-99999" "010010-99999" "010014-99999" "010015-99999" ...
    ##  $ NAME        : chr  "WXPOD8278" "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN" "BRINGELAND" ...
    ##  $ LAT         : num  33 70.9 59.8 61.4 64.8 ...
    ##  $ LON         : num  65.57 -8.67 5.34 5.87 11.23 ...
    ##  $ ELEV(M)     : num  1156.7 9 48.8 327 14 ...
    ##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
    ##  $ STATE       : chr  "" "" "" "" ...
    ##  $ BEGIN       : int  20100519 19310101 19861120 19870117 19870116 19880320 19861109 19850601 19730101 19310103 ...
    ##  $ END         : int  20120323 20240718 20240718 19971231 19910806 19971226 20240718 20240718 19970801 20041030 ...
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

<PRE class="fansi fansi-output"><CODE>## <span style='color: #00BBBB; font-weight: bold;'>─ Session info ───────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>setting </span> <span style='color: #555555; font-style: italic;'>value</span>
##  version  R version 4.4.1 (2024-06-14)
##  os       macOS Sonoma 14.5
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       Australia/Perth
##  date     2024-07-21
##  pandoc   3.2.1 @ /opt/homebrew/bin/ (via rmarkdown)
## 
## <span style='color: #00BBBB; font-weight: bold;'>─ Packages ───────────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>package    </span> <span style='color: #555555; font-style: italic;'>*</span> <span style='color: #555555; font-style: italic;'>version</span> <span style='color: #555555; font-style: italic;'>date (UTC)</span> <span style='color: #555555; font-style: italic;'>lib</span> <span style='color: #555555; font-style: italic;'>source</span>
##  askpass       1.2.0   <span style='color: #555555;'>2023-09-03</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  base64enc     0.1-3   <span style='color: #555555;'>2015-07-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  cli           3.6.3   <span style='color: #555555;'>2024-06-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  colorout      1.3-1   <span style='color: #555555;'>2024-07-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (jalvesaq/colorout@d783015)</span>
##  countrycode * 1.6.0   <span style='color: #555555;'>2024-03-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  crayon        1.5.3   <span style='color: #555555;'>2024-06-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  credentials   2.0.1   <span style='color: #555555;'>2023-09-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  data.table  * 1.15.4  <span style='color: #555555;'>2024-03-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  diffobj       0.3.5   <span style='color: #555555;'>2021-10-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  digest        0.6.36  <span style='color: #555555;'>2024-06-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  dplyr         1.1.4   <span style='color: #555555;'>2023-11-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  evaluate      0.24.0  <span style='color: #555555;'>2024-06-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  fansi         1.0.6   <span style='color: #555555;'>2023-12-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  fastmap       1.2.0   <span style='color: #555555;'>2024-05-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  generics      0.1.3   <span style='color: #555555;'>2022-07-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  glue          1.7.0   <span style='color: #555555;'>2024-01-09</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  htmltools     0.5.8.1 <span style='color: #555555;'>2024-04-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  jsonlite      1.8.8   <span style='color: #555555;'>2023-12-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  knitr         1.48    <span style='color: #555555;'>2024-07-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  lifecycle     1.0.4   <span style='color: #555555;'>2023-11-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  magrittr      2.0.3   <span style='color: #555555;'>2022-03-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  openssl       2.2.0   <span style='color: #555555;'>2024-05-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  pillar        1.9.0   <span style='color: #555555;'>2023-03-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  pkgconfig     2.0.3   <span style='color: #555555;'>2019-09-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  R6            2.5.1   <span style='color: #555555;'>2021-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  repr          1.1.7   <span style='color: #555555;'>2024-03-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  rlang         1.1.4   <span style='color: #555555;'>2024-06-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  rmarkdown     2.27    <span style='color: #555555;'>2024-05-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  rstudioapi    0.16.0  <span style='color: #555555;'>2024-03-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  sessioninfo * 1.2.2   <span style='color: #555555;'>2021-12-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  skimr       * 2.1.5   <span style='color: #555555;'>2022-12-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  sys           3.4.2   <span style='color: #555555;'>2023-05-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  tibble        3.2.1   <span style='color: #555555;'>2023-03-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  tidyselect    1.2.1   <span style='color: #555555;'>2024-03-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  utf8          1.2.4   <span style='color: #555555;'>2023-10-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  vctrs         0.6.5   <span style='color: #555555;'>2023-12-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  xfun          0.45    <span style='color: #555555;'>2024-06-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
##  yaml          2.3.9   <span style='color: #555555;'>2024-07-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.4.0)</span>
## 
## <span style='color: #555555;'> [1] /Users/adamsparks/Library/R/arm64/4.4/library</span>
## <span style='color: #555555;'> [2] /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library</span>
## 
## <span style='color: #00BBBB; font-weight: bold;'>──────────────────────────────────────────────────────────────────────────────</span>
</CODE></PRE>
