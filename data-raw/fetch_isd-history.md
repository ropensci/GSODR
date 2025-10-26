---
title: "Fetch and Clean 'isd_history.csv' File"
author: "Adam H. Sparks"
date: "2025-10-26"
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

## Add country names based on FIPS or ISO2C


``` r
cclist <- as.data.table(codelist[, c("country.name.en", "iso2c", "fips")])
cclist <- melt(cclist, id.vars = "country.name.en")
cclist <- cclist[order(cclist$country.name.en)]
cclist <- unique(cclist, by = "value")

new_isd_history <-
  new_isd_history[cclist, on = c("CTRY" = "value")]

new_isd_history <-
  new_isd_history[as.data.table(countrycode::codelist), on = c("country.name.en")]

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
## Installing package into '/Users/283204f/Library/R/arm64/4.5/library'
## (as 'lib' is unspecified)
```

```
## 
## The downloaded binary packages are in
## 	/var/folders/r4/wwsd3hsn48j5gck6qv6npkpc0000gr/T//RtmpxS5O10/downloaded_packages
```

``` r
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

# select only the cols of interest
x <- names(isd_history)
new_isd_history <- new_isd_history[, ..x] 

(isd_diff <- diffobj::diffPrint(new_isd_history, isd_history))
```

```
## Warning in diffobj::diffPrint(target = new_isd_history, current = isd_history):
## `target` or `current` contained ANSI CSI SGR when rendered; these were
## stripped.  Use `strip.sgr=FALSE` to preserve them in the diffs.
```

<PRE class="fansi fansi-output"><CODE>## <span style='color: #555555;'>No visible differences between objects, but objects are *not* `all.equal`:</span>
## <span style='color: #555555;'>- Column &#039;NAME&#039;: 1 string mismatch</span>
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>new_isd_history</span>                                                               
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>isd_history</span>                                                                   
## <span style='color: #00BBBB;'>@@ 1,25 / 1,25 @@                                                               </span>
##   # Data table (class data.table) 12 x 27963:                                   
##   # (Showing rows 1 - 20 out of 27963)                                          
##     │STNID       │NAME               │LAT  │LON  │ELEV(M)│CTRY │STATE│BEGIN     
##     │&lt;chr&gt;       │&lt;chr&gt;              │&lt;dbl&gt;│&lt;dbl&gt;│&lt;dbl&gt;  │&lt;chr&gt;│&lt;chr&gt;│&lt;int&gt;     
##    1│008268-99999│WXPOD8278          │   33│ 65.6│ 1156.7│AF   │     │20100519  
##    2│010010-99999│JAN MAYEN(NOR-NAVY)│   71│ -8.7│    9.0│NO   │     │19310101  
##    3│010014-99999│SORSTOKKEN / STORD │   60│  5.3│   48.8│NO   │     │19861120  
##    4│010015-99999│BRINGELAND         │   61│  5.9│  327.0│NO   │     │19870117  
##    5│010016-99999│RORVIK/RYUM        │   65│ 11.2│   14.0│NO   │     │19870116  
##    6│010017-99999│FRIGG              │   60│  2.2│   48.0│NO   │     │19880320  
##    7│010020-99999│VERLEGENHUKEN      │   80│ 16.2│    8.0│NO   │     │19861109  
##    8│010030-99999│HORNSUND           │   77│ 15.5│   12.0│NO   │     │19850601  
##    9│010040-99999│NY-ALESUND II      │   79│ 11.9│    8.0│NO   │     │19730101  
##   10│010050-99999│ISFJORD RADIO      │   78│ 13.6│    9.0│SV   │     │19310103  
##   11│010060-99999│EDGEOYA            │   78│ 22.8│   14.0│NO   │     │19730101  
##   12│010070-99999│NY-ALESUND         │   79│ 11.9│    7.7│SV   │     │19730106  
##   13│010071-99999│LONGYEARBYEN       │   78│ 15.6│   37.0│SV   │     │20050210  
##   14│010080-99999│LONGYEAR           │   78│ 15.5│   26.8│SV   │     │19750929  
##   15│010090-99999│KARL XII OYA       │   81│ 25.0│    5.0│SV   │     │19550101  
##   16│010100-99999│ANDOYA             │   69│ 16.1│   13.1│NO   │     │19310103  
##   17│010110-99999│KVITOYA            │   80│ 31.5│   10.0│SV   │     │19861118  
##   18│010140-99999│SENJA-LAUKHELLA    │   69│ 17.9│    9.0│NO   │     │19730101  
##   19│010150-99999│HEKKINGEN FYR      │   70│ 17.8│   14.0│NO   │     │19800314  
##   20│010160-99999│KONGSOYA           │   79│ 28.9│   20.0│NO   │     │19930501  
##   # 4 more columns: END (&lt;int&gt;), COUNTRY_NAME (&lt;chr&gt;), ISO2C (&lt;chr&gt;), ISO3C (&lt;ch
##   r&gt;)
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
## Classes 'data.table' and 'data.frame':	27963 obs. of  12 variables:
##  $ STNID       : chr  "008268-99999" "010010-99999" "010014-99999" "010015-99999" ...
##  $ NAME        : chr  "WXPOD8278" "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN / STORD" "BRINGELAND" ...
##  $ LAT         : num  33 70.9 59.8 61.4 64.8 ...
##  $ LON         : num  65.57 -8.67 5.34 5.87 11.23 ...
##  $ ELEV(M)     : num  1156.7 9 48.8 327 14 ...
##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
##  $ STATE       : chr  "" "" "" "" ...
##  $ BEGIN       : int  20100519 19310101 19861120 19870117 19870116 19880320 19861109 19850601 19730101 19310103 ...
##  $ END         : int  20120323 20250824 20250824 19971231 19910806 19971226 20250824 20250824 19970801 20041030 ...
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
##  version  R version 4.5.1 (2025-06-13)
##  os       macOS Sequoia 15.7.1
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_AU.UTF-8
##  ctype    en_AU.UTF-8
##  tz       Australia/Perth
##  date     2025-10-26
##  pandoc   3.8.2.1 @ /opt/homebrew/bin/pandoc
##  quarto   1.8.25 @ /usr/local/bin/quarto
## 
## <span style='color: #00BBBB; font-weight: bold;'>─ Packages ───────────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>package    </span> <span style='color: #555555; font-style: italic;'>*</span> <span style='color: #555555; font-style: italic;'>version</span> <span style='color: #555555; font-style: italic;'>date (UTC)</span> <span style='color: #555555; font-style: italic;'>lib</span> <span style='color: #555555; font-style: italic;'>source</span>
##  askpass       1.2.1   <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  base64enc     0.1-3   <span style='color: #555555;'>2015-07-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  cli           3.6.5   <span style='color: #555555;'>2025-04-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  colorDF       0.1.7   <span style='color: #555555;'>2022-09-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  colorout      1.3-3   <span style='color: #555555;'>2025-06-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>https://r-multiverse.r-universe.dev (R 4.5.1)</span>
##  countrycode * 1.6.1   <span style='color: #555555;'>2025-03-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  crayon        1.5.3   <span style='color: #555555;'>2024-06-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  credentials   2.0.3   <span style='color: #555555;'>2025-09-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  curl          7.0.0   <span style='color: #555555;'>2025-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  data.table  * 1.17.8  <span style='color: #555555;'>2025-07-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  diffobj       0.3.6   <span style='color: #555555;'>2025-04-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  digest        0.6.37  <span style='color: #555555;'>2024-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  dplyr         1.1.4   <span style='color: #555555;'>2023-11-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  evaluate      1.0.5   <span style='color: #555555;'>2025-08-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  fansi         1.0.6   <span style='color: #555555;'>2023-12-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  fastmap       1.2.0   <span style='color: #555555;'>2024-05-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  fs            1.6.6   <span style='color: #555555;'>2025-04-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  generics      0.1.4   <span style='color: #555555;'>2025-05-09</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  glue          1.8.0   <span style='color: #555555;'>2024-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  htmltools     0.5.8.1 <span style='color: #555555;'>2024-04-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  jsonlite      2.0.0   <span style='color: #555555;'>2025-03-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  knitr       * 1.50    <span style='color: #555555;'>2025-03-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  lifecycle     1.0.4   <span style='color: #555555;'>2023-11-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  magrittr      2.0.4   <span style='color: #555555;'>2025-09-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  nvimcom     * 0.9.76  <span style='color: #555555;'>2025-10-14</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>local</span>
##  openssl       2.3.4   <span style='color: #555555;'>2025-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  pillar        1.11.1  <span style='color: #555555;'>2025-09-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  pkgconfig     2.0.3   <span style='color: #555555;'>2019-09-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  pkgdown       2.1.3   <span style='color: #555555;'>2025-05-25</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  purrr         1.1.0   <span style='color: #555555;'>2025-07-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  R6            2.6.1   <span style='color: #555555;'>2025-02-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  repr          1.1.7   <span style='color: #555555;'>2024-03-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  rlang         1.1.6   <span style='color: #555555;'>2025-04-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  sessioninfo * 1.2.3   <span style='color: #555555;'>2025-02-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  skimr       * 2.2.1   <span style='color: #555555;'>2025-07-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  sys           3.4.3   <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  tibble        3.3.0   <span style='color: #555555;'>2025-06-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  tidyselect    1.2.1   <span style='color: #555555;'>2024-03-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  vctrs         0.6.5   <span style='color: #555555;'>2023-12-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  xfun          0.53    <span style='color: #555555;'>2025-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
## 
## <span style='color: #555555;'> [1] /Users/283204f/Library/R/arm64/4.5/library</span>
## <span style='color: #555555;'> [2] /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/library</span>
##  <span style='color: #BBBBBB; background-color: #BB0000;'>*</span> ── Packages attached to the search path.
## 
## <span style='color: #00BBBB; font-weight: bold;'>──────────────────────────────────────────────────────────────────────────────</span>
</CODE></PRE>
