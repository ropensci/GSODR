Fetch and Clean ‘isd\_history.csv’ File
================
Adam H. Sparks
2021-03-18

<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>

# Introduction

The isd\_history.csv file details GSOD station metadata. These data
include the start and stop years used by *GSODR* to pre-check requests
before querying the server for download and the country code used by
*GSODR* when sub-setting for requests by country. The following checks
are performed on the raw data file before inclusion in *GSODR*,

-   Check for valid lon and lat values;

    -   isd\_history where latitude or longitude are `NA` or both 0 are
        removed leaving only properly georeferenced stations,

    -   isd\_history where latitude is &lt; -90˚ or &gt; 90˚ are
        removed,

    -   isd\_history where longitude is &lt; -180˚ or &gt; 180˚ are
        removed.

-   A new field, STNID, a concatenation of the USAF and WBAN fields, is
    added.

# Data Processing

## Set up workspace

``` r
if (!require("pacman")) {
  install.packages("pacman", repos = "https://cran.rstudio.com/")
}
pacman::p_load("sessioninfo", "skimr", "countrycode", "data.table")
```

## Download and clean data

``` r
# download data
new_isd_history <- fread("https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")
```

## Add/drop columns and save to disk

``` r
# add STNID column
new_isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
setcolorder(new_isd_history, "STNID")
setnames(new_isd_history, "STATION NAME", "NAME")

# drop stations not in GSOD data
new_isd_history[, STNID_len := nchar(STNID)]
new_isd_history <- subset(new_isd_history, STNID_len == 12)

# remove stations where LAT or LON is NA
new_isd_history <- na.omit(new_isd_history, cols = c("LAT", "LON"))

# remove extra columns
new_isd_history[, c("USAF", "WBAN", "ICAO", "ELEV(M)", "STNID_len") := NULL]
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

    ##               STNID                         NAME   LAT      LON CTRY STATE
    ##     1: 008268-99999                    WXPOD8278 32.95   65.567   AF      
    ##     2: 010010-99999          JAN MAYEN(NOR-NAVY) 70.93   -8.667   NO      
    ##     3: 010014-99999                   SORSTOKKEN 59.79    5.341   NO      
    ##     4: 010015-99999                   BRINGELAND 61.38    5.867   NO      
    ##     5: 010016-99999                  RORVIK/RYUM 64.85   11.233   NO      
    ##    ---                                                                    
    ## 26533: A00024-53848 CHOCTAW NAVAL OUTLYING FIELD 30.51  -86.960   US    FL
    ## 26534: A00026-94297              COUPEVILLE/NOLF 48.22 -122.633   US    WA
    ## 26535: A00029-63820      EVERETT-STEWART AIRPORT 36.38  -88.985   US    TN
    ## 26536: A00030-93795        CONNELLSVILLE AIRPORT 39.96  -79.657   US    PA
    ## 26537: A00032-25715                 ATKA AIRPORT 52.22 -174.206   US    AK
    ##           BEGIN      END  COUNTRY_NAME ISO2C ISO3C
    ##     1: 20100519 20120323   AFGHANISTAN    AF   AFG
    ##     2: 19310101 20210315        NORWAY    NO   NOR
    ##     3: 19861120 20210315        NORWAY    NO   NOR
    ##     4: 19870117 20081231        NORWAY    NO   NOR
    ##     5: 19870116 19910806        NORWAY    NO   NOR
    ##    ---                                            
    ## 26533: 20070601 20210315 UNITED STATES    US   USA
    ## 26534: 20060324 20150514 UNITED STATES    US   USA
    ## 26535: 20130627 20210316 UNITED STATES    US   USA
    ## 26536: 20210309 20210317 UNITED STATES    US   USA
    ## 26537: 20060101 20210121 UNITED STATES    US   USA

## Show changes from last release

``` r
install.packages("GSODR") # ensure we aren't using a locally installed dev version
```

    ## Installing package into '/Users/adamsparks/Library/R/4.0/library'
    ## (as 'lib' is unspecified)

    ## 
    ## The downloaded binary packages are in
    ##  /var/folders/hc/tft3s5bn48gb81cs99mycyf00000gn/T//RtmpY1AV8P/downloaded_packages

``` r
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

# select only the cols of interest
x <- names(isd_history)
new_isd_history <- new_isd_history[, ..x] 

(isd_diff <- diffobj::diffPrint(new_isd_history, isd_history))
```

<PRE class="fansi fansi-output"><CODE>## <span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>new_isd_history</span><span>                                                              
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>isd_history</span><span>                                                                  
## </span><span style='color: #00BBBB;'>@@ 6,19 / 6,19 @@                                                              </span><span>
## </span><span style='color: #555555;'>~               STNID                         NAME   LAT      LON CTRY STATE   </span><span>
##       5: 010016-99999                  RORVIK/RYUM 64.85   11.233   NO         
##      ---                                                                       
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26527:</span><span> </span><span style='color: #0000BB;'>A00023-63890</span><span> </span><span style='color: #0000BB;'>WHITEHOUSE</span><span> </span><span style='color: #0000BB;'>NAVAL</span><span> </span><span style='color: #0000BB;'>OUTLYING</span><span> </span><span style='color: #0000BB;'>FIELD</span><span> </span><span style='color: #0000BB;'>30.35</span><span>  </span><span style='color: #0000BB;'>-81.883</span><span>   </span><span style='color: #0000BB;'>US</span><span>    </span><span style='color: #0000BB;'>FL</span><span>
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26533:</span><span> A00024-53848 CHOCTAW NAVAL OUTLYING FIELD 30.51  -86.960   US    FL   
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26528:</span><span> A00024-53848    CHOCTAW NAVAL OUTLYING FIELD 30.51  -86.960   US    FL
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26534:</span><span> A00026-94297              COUPEVILLE/NOLF 48.22 -122.633   US    WA   
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26529:</span><span> A00026-94297                 COUPEVILLE/NOLF 48.22 -122.633   US    WA
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26535:</span><span> A00029-63820      EVERETT-STEWART AIRPORT 36.38  -88.985   US    TN   
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26530:</span><span> A00029-63820         EVERETT-STEWART AIRPORT 36.38  -88.985   US    TN
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26536:</span><span> </span><span style='color: #BBBB00;'>A00030-93795</span><span>        </span><span style='color: #BBBB00;'>CONNELLSVILLE</span><span> </span><span style='color: #BBBB00;'>AIRPORT</span><span> </span><span style='color: #BBBB00;'>39.96</span><span>  </span><span style='color: #BBBB00;'>-79.657</span><span>   </span><span style='color: #BBBB00;'>US</span><span>    </span><span style='color: #BBBB00;'>PA</span><span>   
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26537:</span><span> A00032-25715                 ATKA AIRPORT 52.22 -174.206   US    AK   
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26531:</span><span> A00032-25715                    ATKA AIRPORT 52.22 -174.206   US    AK
##             BEGIN      END  COUNTRY_NAME ISO2C ISO3C                           
##       1: 20100519 20120323   AFGHANISTAN    AF   AFG                           
## </span><span style='color: #BBBB00;'>&lt;</span><span>     2: 19310101 </span><span style='color: #BBBB00;'>20210315</span><span>        NORWAY    NO   NOR                           
## </span><span style='color: #0000BB;'>&gt;</span><span>     2: 19310101 </span><span style='color: #0000BB;'>20210116</span><span>        NORWAY    NO   NOR                           
## </span><span style='color: #BBBB00;'>&lt;</span><span>     3: 19861120 </span><span style='color: #BBBB00;'>20210315</span><span>        NORWAY    NO   NOR                           
## </span><span style='color: #0000BB;'>&gt;</span><span>     3: 19861120 </span><span style='color: #0000BB;'>20210116</span><span>        NORWAY    NO   NOR                           
##       4: 19870117 20081231        NORWAY    NO   NOR                           
##       5: 19870116 19910806        NORWAY    NO   NOR                           
##      ---                                                                       
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26533:</span><span> 20070601 </span><span style='color: #BBBB00;'>20210315</span><span> UNITED STATES    US   USA                           
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26527:</span><span> 20070601 </span><span style='color: #0000BB;'>20210116</span><span> UNITED STATES    US   USA                           
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26534:</span><span> </span><span style='color: #BBBB00;'>20060324</span><span> </span><span style='color: #BBBB00;'>20150514</span><span> UNITED STATES    US   USA                           
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26528:</span><span> </span><span style='color: #0000BB;'>20070601</span><span> </span><span style='color: #0000BB;'>20210116</span><span> UNITED STATES    US   USA                           
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26535:</span><span> </span><span style='color: #BBBB00;'>20130627</span><span> </span><span style='color: #BBBB00;'>20210316</span><span> UNITED STATES    US   USA                           
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26529:</span><span> </span><span style='color: #0000BB;'>20060324</span><span> </span><span style='color: #0000BB;'>20150514</span><span> UNITED STATES    US   USA                           
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26536:</span><span> </span><span style='color: #BBBB00;'>20210309</span><span> </span><span style='color: #BBBB00;'>20210317</span><span> UNITED STATES    US   USA                           
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26530:</span><span> </span><span style='color: #0000BB;'>20130627</span><span> </span><span style='color: #0000BB;'>20210117</span><span> UNITED STATES    US   USA                           
## </span><span style='color: #BBBB00;'>&lt;</span><span> </span><span style='color: #BBBB00;'>26537:</span><span> 20060101 </span><span style='color: #BBBB00;'>20210121</span><span> UNITED STATES    US   USA                           
## </span><span style='color: #0000BB;'>&gt;</span><span> </span><span style='color: #0000BB;'>26531:</span><span> 20060101 </span><span style='color: #0000BB;'>20210117</span><span> UNITED STATES    US   USA
</span></CODE></PRE>

## View and save the data

``` r
str(isd_history)
```

    ## Classes 'data.table' and 'data.frame':   26531 obs. of  11 variables:
    ##  $ STNID       : chr  "008268-99999" "010010-99999" "010014-99999" "010015-99999" ...
    ##  $ NAME        : chr  "WXPOD8278" "JAN MAYEN(NOR-NAVY)" "SORSTOKKEN" "BRINGELAND" ...
    ##  $ LAT         : num  33 70.9 59.8 61.4 64.8 ...
    ##  $ LON         : num  65.57 -8.67 5.34 5.87 11.23 ...
    ##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
    ##  $ STATE       : chr  "" "" "" "" ...
    ##  $ BEGIN       : int  20100519 19310101 19861120 19870117 19870116 19880320 19861109 19850601 19730101 19310103 ...
    ##  $ END         : int  20120323 20210116 20210116 20081231 19910806 20050228 20210114 20210116 20140523 20041030 ...
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
website](https://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

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

    ## ─ Session info ───────────────────────────────────────────────────────────────
    ##  setting  value                       
    ##  version  R version 4.0.4 (2021-02-15)
    ##  os       macOS Big Sur 10.16         
    ##  system   x86_64, darwin17.0          
    ##  ui       X11                         
    ##  language (EN)                        
    ##  collate  en_AU.UTF-8                 
    ##  ctype    en_AU.UTF-8                 
    ##  tz       Australia/Perth             
    ##  date     2021-03-18                  
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package     * version date       lib source                            
    ##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.2)                    
    ##  base64enc     0.1-3   2015-07-28 [1] CRAN (R 4.0.2)                    
    ##  cli           2.3.1   2021-02-23 [1] CRAN (R 4.0.4)                    
    ##  countrycode * 1.2.0   2020-05-22 [1] standard (@1.2.0)                 
    ##  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.0.2)                    
    ##  curl          4.3     2019-12-02 [1] CRAN (R 4.0.1)                    
    ##  data.table  * 1.14.0  2021-02-21 [1] CRAN (R 4.0.4)                    
    ##  DBI           1.1.1   2021-01-15 [1] CRAN (R 4.0.2)                    
    ##  diffobj       0.3.3   2021-01-07 [1] CRAN (R 4.0.2)                    
    ##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.2)                    
    ##  dplyr         1.0.5   2021-03-05 [1] CRAN (R 4.0.2)                    
    ##  ellipsis      0.3.1   2020-05-15 [1] CRAN (R 4.0.2)                    
    ##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.1)                    
    ##  fansi         0.4.2   2021-01-15 [1] CRAN (R 4.0.2)                    
    ##  generics      0.1.0   2020-10-31 [1] CRAN (R 4.0.2)                    
    ##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.2)                    
    ##  htmltools     0.5.1.1 2021-01-22 [1] CRAN (R 4.0.2)                    
    ##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.2)                    
    ##  knitr         1.31    2021-01-27 [1] CRAN (R 4.0.2)                    
    ##  lifecycle     1.0.0   2021-02-15 [1] CRAN (R 4.0.4)                    
    ##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.2)                    
    ##  pacman      * 0.5.1   2019-03-11 [1] CRAN (R 4.0.2)                    
    ##  pillar        1.5.1   2021-03-05 [1] CRAN (R 4.0.2)                    
    ##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.2)                    
    ##  purrr         0.3.4   2020-04-17 [1] CRAN (R 4.0.2)                    
    ##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.2)                    
    ##  repr          1.1.3   2021-01-21 [1] standard (@1.1.3)                 
    ##  rlang         0.4.10  2020-12-30 [1] CRAN (R 4.0.2)                    
    ##  rmarkdown     2.7.3   2021-03-15 [1] Github (rstudio/rmarkdown@61db7a9)
    ##  sessioninfo * 1.1.1   2018-11-05 [1] CRAN (R 4.0.2)                    
    ##  skimr       * 2.1.3   2021-03-07 [1] CRAN (R 4.0.4)                    
    ##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.2)                    
    ##  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.0.2)                    
    ##  tibble        3.1.0   2021-02-25 [1] CRAN (R 4.0.2)                    
    ##  tidyselect    1.1.0   2020-05-11 [1] CRAN (R 4.0.2)                    
    ##  utf8          1.2.1   2021-03-12 [1] CRAN (R 4.0.2)                    
    ##  vctrs         0.3.6   2020-12-17 [1] CRAN (R 4.0.2)                    
    ##  withr         2.4.1   2021-01-26 [1] CRAN (R 4.0.2)                    
    ##  xfun          0.22    2021-03-11 [1] CRAN (R 4.0.4)                    
    ##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.2)                    
    ## 
    ## [1] /Users/adamsparks/Library/R/4.0/library
    ## [2] /Library/Frameworks/R.framework/Versions/4.0/Resources/library
