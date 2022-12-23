Fetch and Clean ‘isd_history.csv’ File
================
Adam H. Sparks
2022-12-23

<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>

# Introduction

The “isd_history.csv” file details GSOD station metadata. These data
include the start and stop years used by *GSODR* to pre-check requests
before querying the server for download and the country code used by
*GSODR* when sub-setting for requests by country. The following checks
are performed on the raw data file before inclusion in *GSODR*,

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
setkeyv(new_isd_history, "STNID")[]
```

    ##               STNID                                              NAME    LAT
    ##     1: 008268-99999                                         WXPOD8278 32.950
    ##     2: 010010-99999                               JAN MAYEN(NOR-NAVY) 70.933
    ##     3: 010014-99999                                        SORSTOKKEN 59.792
    ##     4: 010015-99999                                        BRINGELAND 61.383
    ##     5: 010016-99999                                       RORVIK/RYUM 64.850
    ##    ---                                                                      
    ## 27921: A07355-00241                         VIROQUA MUNICIPAL AIRPORT 43.579
    ## 27922: A07357-00182 ELBOW LAKE MUNICIPAL PRIDE OF THE PRAIRIE AIRPORT 45.986
    ## 27923: A07359-00240                              IONIA COUNTY AIRPORT 42.938
    ## 27924: A51255-00445                       DEMOPOLIS MUNICIPAL AIRPORT 32.464
    ## 27925: A51256-00451      BRANSON WEST MUNICIPAL EMERSON FIELD AIRPORT 36.699
    ##            LON ELEV(M) CTRY STATE    BEGIN      END  COUNTRY_NAME ISO2C ISO3C
    ##     1:  65.567  1156.7   AF       20100519 20120323   AFGHANISTAN    AF   AFG
    ##     2:  -8.667     9.0   NO       19310101 20221220        NORWAY    NO   NOR
    ##     3:   5.341    48.8   NO       19861120 20221220        NORWAY    NO   NOR
    ##     4:   5.867   327.0   NO       19870117 19971231        NORWAY    NO   NOR
    ##     5:  11.233    14.0   NO       19870116 19910806        NORWAY    NO   NOR
    ##    ---                                                                       
    ## 27921: -90.913   394.1   US    WI 20140731 20221220 UNITED STATES    US   USA
    ## 27922: -95.992   367.3   US    MN 20140731 20221220 UNITED STATES    US   USA
    ## 27923: -85.061   249.0   US    MI 20140731 20221220 UNITED STATES    US   USA
    ## 27924: -87.954    34.1   US    AL 20140731 20221221 UNITED STATES    US   USA
    ## 27925: -93.402   411.2   US    MO 20140731 20221220 UNITED STATES    US   USA

## Show changes from last release

``` r
# ensure we aren't using a locally installed dev version
install.packages("GSODR", repos = "https://cloud.r-project.org/")
```

    ## Installing package into '/Users/adamsparks/Library/R/arm64/4.2/library'
    ## (as 'lib' is unspecified)

    ## 
    ## The downloaded binary packages are in
    ##  /var/folders/hc/tft3s5bn48gb81cs99mycyf00000gn/T//Rtmpm3cAoW/downloaded_packages

``` r
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

# select only the cols of interest
x <- names(isd_history)
new_isd_history <- new_isd_history[, ..x] 

(isd_diff <- diffobj::diffPrint(new_isd_history, isd_history))
```

<PRE class="fansi fansi-output"><CODE>## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>new_isd_history</span>                                                             
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>isd_history</span>                                                                 
## <span style='color: #00BBBB;'>@@ 1,24 / 1,24 @@                                                             </span>
## <span style='color: #BBBB00;'>&lt;</span>               STNID                                              NAME    LAT
## <span style='color: #0000BB;'>&gt;</span>               STNID                         NAME    LAT      <span style='color: #0000BB;'>LON</span> <span style='color: #0000BB;'>CTRY</span> <span style='color: #0000BB;'>STATE</span> 
## <span style='color: #BBBB00;'>&lt;</span>     1: 008268-99999                                         WXPOD8278 32.950
## <span style='color: #0000BB;'>&gt;</span>     1: 008268-99999                    WXPOD8278 32.950   <span style='color: #0000BB;'>65.567</span>   <span style='color: #0000BB;'>AF</span>       
## <span style='color: #BBBB00;'>&lt;</span>     2: 010010-99999                               JAN MAYEN(NOR-NAVY) 70.933
## <span style='color: #0000BB;'>&gt;</span>     2: 010010-99999          JAN MAYEN(NOR-NAVY) 70.933   <span style='color: #0000BB;'>-8.667</span>   <span style='color: #0000BB;'>NO</span>       
## <span style='color: #BBBB00;'>&lt;</span>     3: 010014-99999                                        SORSTOKKEN 59.792
## <span style='color: #0000BB;'>&gt;</span>     3: 010014-99999                   SORSTOKKEN 59.792    <span style='color: #0000BB;'>5.341</span>   <span style='color: #0000BB;'>NO</span>       
## <span style='color: #BBBB00;'>&lt;</span>     4: 010015-99999                                        BRINGELAND 61.383
## <span style='color: #0000BB;'>&gt;</span>     4: 010015-99999                   BRINGELAND 61.383    <span style='color: #0000BB;'>5.867</span>   <span style='color: #0000BB;'>NO</span>       
## <span style='color: #BBBB00;'>&lt;</span>     5: 010016-99999                                       RORVIK/RYUM 64.850
## <span style='color: #0000BB;'>&gt;</span>     5: 010016-99999                  RORVIK/RYUM 64.850   <span style='color: #0000BB;'>11.233</span>   <span style='color: #0000BB;'>NO</span>       
##      ---                                                                      
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27921:</span> <span style='color: #BBBB00;'>A07355-00241</span>                         <span style='color: #BBBB00;'>VIROQUA</span> <span style='color: #BBBB00;'>MUNICIPAL</span> <span style='color: #BBBB00;'>AIRPORT</span> <span style='color: #BBBB00;'>43.579</span>
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27922:</span> <span style='color: #BBBB00;'>A07357-00182</span> <span style='color: #BBBB00;'>ELBOW</span> <span style='color: #BBBB00;'>LAKE</span> <span style='color: #BBBB00;'>MUNICIPAL</span> <span style='color: #BBBB00;'>PRIDE</span> <span style='color: #BBBB00;'>OF</span> <span style='color: #BBBB00;'>THE</span> <span style='color: #BBBB00;'>PRAIRIE</span> <span style='color: #BBBB00;'>AIRPORT</span> <span style='color: #BBBB00;'>45.986</span>
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27923:</span> <span style='color: #BBBB00;'>A07359-00240</span>                              <span style='color: #BBBB00;'>IONIA</span> <span style='color: #BBBB00;'>COUNTY</span> AIRPORT <span style='color: #BBBB00;'>42.938</span>
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27924:</span> <span style='color: #BBBB00;'>A51255-00445</span>                       <span style='color: #BBBB00;'>DEMOPOLIS</span> <span style='color: #BBBB00;'>MUNICIPAL</span> AIRPORT <span style='color: #BBBB00;'>32.464</span>
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27925:</span> <span style='color: #BBBB00;'>A51256-00451</span>      <span style='color: #BBBB00;'>BRANSON</span> <span style='color: #BBBB00;'>WEST</span> <span style='color: #BBBB00;'>MUNICIPAL</span> <span style='color: #BBBB00;'>EMERSON</span> <span style='color: #BBBB00;'>FIELD</span> AIRPORT <span style='color: #BBBB00;'>36.699</span>
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26587:</span> <span style='color: #0000BB;'>A00024-53848</span> <span style='color: #0000BB;'>CHOCTAW</span> <span style='color: #0000BB;'>NAVAL</span> <span style='color: #0000BB;'>OUTLYING</span> <span style='color: #0000BB;'>FIELD</span> <span style='color: #0000BB;'>30.512</span>  <span style='color: #0000BB;'>-86.954</span>   <span style='color: #0000BB;'>US</span>    <span style='color: #0000BB;'>FL</span> 
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26588:</span> <span style='color: #0000BB;'>A00026-94297</span>              <span style='color: #0000BB;'>COUPEVILLE/NOLF</span> <span style='color: #0000BB;'>48.217</span> <span style='color: #0000BB;'>-122.633</span>   <span style='color: #0000BB;'>US</span>    <span style='color: #0000BB;'>WA</span> 
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26589:</span> <span style='color: #0000BB;'>A00029-63820</span>      <span style='color: #0000BB;'>EVERETT-STEWART</span> AIRPORT <span style='color: #0000BB;'>36.380</span>  <span style='color: #0000BB;'>-88.985</span>   <span style='color: #0000BB;'>US</span>    <span style='color: #0000BB;'>TN</span> 
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26590:</span> <span style='color: #0000BB;'>A00030-93795</span>        <span style='color: #0000BB;'>CONNELLSVILLE</span> AIRPORT <span style='color: #0000BB;'>39.959</span>  <span style='color: #0000BB;'>-79.657</span>   <span style='color: #0000BB;'>US</span>    <span style='color: #0000BB;'>PA</span> 
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26591:</span> <span style='color: #0000BB;'>A00032-25715</span>                 <span style='color: #0000BB;'>ATKA</span> AIRPORT <span style='color: #0000BB;'>52.220</span> <span style='color: #0000BB;'>-174.206</span>   <span style='color: #0000BB;'>US</span>    <span style='color: #0000BB;'>AK</span> 
## <span style='color: #BBBB00;'>&lt;</span>            <span style='color: #BBBB00;'>LON</span> <span style='color: #BBBB00;'>CTRY</span> <span style='color: #BBBB00;'>STATE</span>    BEGIN      END  COUNTRY_NAME ISO2C ISO3C       
## <span style='color: #0000BB;'>&gt;</span>           BEGIN      END  COUNTRY_NAME ISO2C ISO3C                          
## <span style='color: #BBBB00;'>&lt;</span>     1:  <span style='color: #BBBB00;'>65.567</span>   <span style='color: #BBBB00;'>AF</span>       20100519 20120323   AFGHANISTAN    AF   AFG       
## <span style='color: #0000BB;'>&gt;</span>     1: 20100519 20120323   AFGHANISTAN    AF   AFG                          
## <span style='color: #BBBB00;'>&lt;</span>     2:  <span style='color: #BBBB00;'>-8.667</span>   <span style='color: #BBBB00;'>NO</span>       19310101 <span style='color: #BBBB00;'>20221220</span>        NORWAY    NO   NOR       
## <span style='color: #0000BB;'>&gt;</span>     2: 19310101 <span style='color: #0000BB;'>20220731</span>        NORWAY    NO   NOR                          
## <span style='color: #BBBB00;'>&lt;</span>     3:   <span style='color: #BBBB00;'>5.341</span>   <span style='color: #BBBB00;'>NO</span>       19861120 <span style='color: #BBBB00;'>20221220</span>        NORWAY    NO   NOR       
## <span style='color: #0000BB;'>&gt;</span>     3: 19861120 <span style='color: #0000BB;'>20220810</span>        NORWAY    NO   NOR                          
## <span style='color: #BBBB00;'>&lt;</span>     4:   <span style='color: #BBBB00;'>5.867</span>   <span style='color: #BBBB00;'>NO</span>       19870117 <span style='color: #BBBB00;'>19971231</span>        NORWAY    NO   NOR       
## <span style='color: #0000BB;'>&gt;</span>     4: 19870117 <span style='color: #0000BB;'>20081231</span>        NORWAY    NO   NOR                          
## <span style='color: #BBBB00;'>&lt;</span>     5:  <span style='color: #BBBB00;'>11.233</span>   <span style='color: #BBBB00;'>NO</span>       19870116 19910806        NORWAY    NO   NOR       
## <span style='color: #0000BB;'>&gt;</span>     5: 19870116 19910806        NORWAY    NO   NOR                          
##      ---                                                                      
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27921:</span> <span style='color: #BBBB00;'>-90.913</span>   <span style='color: #BBBB00;'>US</span>    <span style='color: #BBBB00;'>WI</span> <span style='color: #BBBB00;'>20140731</span> <span style='color: #BBBB00;'>20221220</span> UNITED STATES    US   USA       
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26587:</span> <span style='color: #0000BB;'>20070601</span> <span style='color: #0000BB;'>20220810</span> UNITED STATES    US   USA                          
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27922:</span> <span style='color: #BBBB00;'>-95.992</span>   <span style='color: #BBBB00;'>US</span>    <span style='color: #BBBB00;'>MN</span> <span style='color: #BBBB00;'>20140731</span> <span style='color: #BBBB00;'>20221220</span> UNITED STATES    US   USA       
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26588:</span> <span style='color: #0000BB;'>20060324</span> <span style='color: #0000BB;'>20150514</span> UNITED STATES    US   USA                          
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27923:</span> <span style='color: #BBBB00;'>-85.061</span>   <span style='color: #BBBB00;'>US</span>    <span style='color: #BBBB00;'>MI</span> <span style='color: #BBBB00;'>20140731</span> <span style='color: #BBBB00;'>20221220</span> UNITED STATES    US   USA       
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26589:</span> <span style='color: #0000BB;'>20130627</span> <span style='color: #0000BB;'>20220812</span> UNITED STATES    US   USA                          
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27924:</span> <span style='color: #BBBB00;'>-87.954</span>   <span style='color: #BBBB00;'>US</span>    <span style='color: #BBBB00;'>AL</span> <span style='color: #BBBB00;'>20140731</span> <span style='color: #BBBB00;'>20221221</span> UNITED STATES    US   USA       
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26590:</span> <span style='color: #0000BB;'>20210309</span> <span style='color: #0000BB;'>20220811</span> UNITED STATES    US   USA                          
## <span style='color: #BBBB00;'>&lt;</span> <span style='color: #BBBB00;'>27925:</span> <span style='color: #BBBB00;'>-93.402</span>   <span style='color: #BBBB00;'>US</span>    <span style='color: #BBBB00;'>MO</span> <span style='color: #BBBB00;'>20140731</span> <span style='color: #BBBB00;'>20221220</span> UNITED STATES    US   USA       
## <span style='color: #0000BB;'>&gt;</span> <span style='color: #0000BB;'>26591:</span> <span style='color: #0000BB;'>20060101</span> <span style='color: #0000BB;'>20220725</span> UNITED STATES    US   USA
</CODE></PRE>

``` r
rm(isd_history)

isd_history <- new_isd_history
```

## View and save the data

``` r
str(isd_history)
```

    ## Classes 'data.table' and 'data.frame':   27925 obs. of  11 variables:
    ##  $ STNID       : chr  "008268-99999" "010010-99999" "010014-99999" "010015-99999" ...
    ##  $ NAME        : chr  "WXPOD8278" "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN" "BRINGELAND" ...
    ##  $ LAT         : num  33 70.9 59.8 61.4 64.8 ...
    ##  $ LON         : num  65.57 -8.67 5.34 5.87 11.23 ...
    ##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
    ##  $ STATE       : chr  "" "" "" "" ...
    ##  $ BEGIN       : int  20100519 19310101 19861120 19870117 19870116 19880320 19861109 19850601 19730101 19310103 ...
    ##  $ END         : int  20120323 20221220 20221220 19971231 19910806 19971226 20221219 20221220 19970801 20041030 ...
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
##  version  R version 4.2.2 (2022-10-31)
##  os       macOS Ventura 13.1
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_US.UTF-8
##  ctype    en_US.UTF-8
##  tz       Australia/Perth
##  date     2022-12-23
##  pandoc   2.19.2 @ /opt/homebrew/bin/ (via rmarkdown)
## 
## <span style='color: #00BBBB; font-weight: bold;'>─ Packages ───────────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>package    </span> <span style='color: #555555; font-style: italic;'>*</span> <span style='color: #555555; font-style: italic;'>version</span> <span style='color: #555555; font-style: italic;'>date (UTC)</span> <span style='color: #555555; font-style: italic;'>lib</span> <span style='color: #555555; font-style: italic;'>source</span>
##  askpass       1.1     <span style='color: #555555;'>2019-01-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  assertthat    0.2.1   <span style='color: #555555;'>2019-03-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  base64enc     0.1-3   <span style='color: #555555;'>2015-07-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  cli           3.5.0   <span style='color: #555555;'>2022-12-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.2)</span>
##  countrycode * 1.4.0   <span style='color: #555555;'>2022-05-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  crayon        1.5.2   <span style='color: #555555;'>2022-09-29</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  credentials   1.3.2   <span style='color: #555555;'>2021-11-29</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  curl          4.3.3   <span style='color: #555555;'>2022-10-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  data.table  * 1.14.6  <span style='color: #555555;'>2022-11-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  DBI           1.1.3   <span style='color: #555555;'>2022-06-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  diffobj       0.3.5   <span style='color: #555555;'>2021-10-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  digest        0.6.31  <span style='color: #555555;'>2022-12-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  dplyr         1.0.10  <span style='color: #555555;'>2022-09-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  evaluate      0.19    <span style='color: #555555;'>2022-12-13</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.2)</span>
##  fansi         1.0.3   <span style='color: #555555;'>2022-03-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  fastmap       1.1.0   <span style='color: #555555;'>2021-01-25</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  generics      0.1.3   <span style='color: #555555;'>2022-07-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  glue          1.6.2   <span style='color: #555555;'>2022-02-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  htmltools     0.5.4   <span style='color: #555555;'>2022-12-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  jsonlite      1.8.4   <span style='color: #555555;'>2022-12-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  knitr         1.41    <span style='color: #555555;'>2022-11-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  lifecycle     1.0.3   <span style='color: #555555;'>2022-10-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  magrittr      2.0.3   <span style='color: #555555;'>2022-03-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  openssl       2.0.5   <span style='color: #555555;'>2022-12-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  pillar        1.8.1   <span style='color: #555555;'>2022-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  pkgconfig     2.0.3   <span style='color: #555555;'>2019-09-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  R6            2.5.1   <span style='color: #555555;'>2021-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  repr          1.1.4   <span style='color: #555555;'>2022-01-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  rlang         1.0.6   <span style='color: #555555;'>2022-09-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  rmarkdown     2.19    <span style='color: #555555;'>2022-12-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.2)</span>
##  rstudioapi    0.14    <span style='color: #555555;'>2022-08-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  sessioninfo * 1.2.2   <span style='color: #555555;'>2021-12-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  skimr       * 2.1.4   <span style='color: #555555;'>2022-04-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  stringi       1.7.8   <span style='color: #555555;'>2022-07-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  stringr       1.5.0   <span style='color: #555555;'>2022-12-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  sys           3.4.1   <span style='color: #555555;'>2022-10-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  tibble        3.1.8   <span style='color: #555555;'>2022-07-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  tidyselect    1.2.0   <span style='color: #555555;'>2022-10-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  utf8          1.2.2   <span style='color: #555555;'>2021-07-24</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.1)</span>
##  vctrs         0.5.1   <span style='color: #555555;'>2022-11-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  xfun          0.35    <span style='color: #555555;'>2022-11-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
##  yaml          2.3.6   <span style='color: #555555;'>2022-10-18</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.2.0)</span>
## 
## <span style='color: #555555;'> [1] /Users/adamsparks/Library/R/arm64/4.2/library</span>
## <span style='color: #555555;'> [2] /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library</span>
## 
## <span style='color: #00BBBB; font-weight: bold;'>──────────────────────────────────────────────────────────────────────────────</span>
</CODE></PRE>
