---
title: "Fetch and Clean 'isd_history.csv' File"
author: "Adam H. Sparks"
date: "2025-11-15"
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
library("countrycode")
library("data.table")
library("sf")
library("dplyr")
library("geodata")
library("diffobj")

new_isd_history <- fread("https://www.ncei.noaa.gov/pub/data/noaa/isd-history.csv")
```


## Add country names based on geographic location

Previously (prior to 2025-11-04) I used the FIPS code in the CSV file to determine the country.
This turned out to be [problematic](https://github.com/ropensci/GSODR/issues/133#issuecomment-3483206035).
So, I've gone to a brute-force method of determining which country the lat/lon values fall in using {rnaturalearth} and {sf}.


``` r
# isd_history
# pad WBAN where necessary
new_isd_history[, WBAN := sprintf("%05d", WBAN)]

# add STNID column
new_isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
setcolorder(new_isd_history, "STNID")

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

sf_use_s2(FALSE)

coords_sf <- 
  st_as_sf(
  new_isd_history,
  coords = c("LON", "LAT"),
  crs = 4326,
  remove = FALSE
 ) |> select(STNID, `STATION NAME`, STATE, `ELEV(M)`, BEGIN, END, LON, LAT)

world <- st_as_sf(world(resolution = 1L)) |>
  st_transform(crs = 4326)

within_dt <- st_join(
  x = coords_sf,
  y = world,
  join = st_within) |>
  as.data.table()

new_isd_history <-
  within_dt[as.data.table(codelist), on = c("NAME_0" = "country.name.en")]

# remove rows with no stations
new_isd_history <- new_isd_history[complete.cases(new_isd_history$STNID), ]

new_isd_history <- new_isd_history[, c(
  "STNID",
  "STATION NAME",
  "LAT",
  "LON",
  "ELEV(M)",
  "STATE",
  "BEGIN",
  "END",
  "NAME_0",
  "fips",
  "iso2c",
  "iso3c"
)]

setnames(
  new_isd_history,
  c(
    "STATION NAME",
    "NAME_0",
    "fips",
    "iso2c",
    "iso3c"
  ),
  c(
    "NAME",
    "COUNTRY_NAME",
    "CTRY",
    "ISO2C",
    "ISO3C"
  )
)
setcolorder(
  new_isd_history,
    c(
      "STNID",
      "NAME",
      "LAT",
      "LON",
      "ELEV(M)",
      "STATE",
      "BEGIN",
      "END",
      "COUNTRY_NAME",
      "ISO2C",
      "ISO3C",
      "CTRY"
))

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
## 	/var/folders/vz/txwj1tx51txgw7zv_b5c5_3m0000gn/T//Rtmp3Z9nvv/downloaded_packages
```

``` r
load(system.file("extdata", "isd_history.rda", package = "GSODR"))

# select only the cols of interest
x <- names(isd_history)
new_isd_history <- new_isd_history[, ..x] 
cat(                                 # output to screen
  as.character(                      # convert to diff to character vector
diffPrint(new_isd_history, isd_history,
      format = "html",                 # specify html output
      style =
      list(
        html.output = "diff.w.style"   # configure html style
      )
      )
    )
  )
```

<PRE class="fansi fansi-output"><CODE>## &lt;style type=&#039;text/css&#039;&gt;
## /* Structural CSS ------------------------------------------------------------*/
## /*
##  * TBD whether we want a more fully table like structure; some of the visual
##  * cues provided by the current set-up are useful (line wraps, etc.)
##  */
## 
## DIV.diffobj-container PRE.diffobj-content {
##   white-space: pre-wrap;
##   margin: 0;
## }
## DIV.diffobj-container DIV.diffobj-row {
##   width: 100%;
##   font-family: monospace;
##   display: table;
##   table-layout: fixed;
## }
## DIV.diffobj-container DIV.diffobj-line {
##   width: auto;
##   display: table-cell;
##   overflow: hidden;
## }
## DIV.diffobj-container DIV.diffobj-line&gt;DIV {
##   width: 100%;
##   display: table;
##   table-layout: auto;
## }
## DIV.diffobj-container DIV.diffobj-line.banner&gt;DIV {
##   display: table;
##   table-layout: auto; /* set to fixed in JS */
## }
## DIV.diffobj-container DIV.diffobj-text {
##   display: table-cell;
##   width: 100%;
## }
## DIV.diffobj-container DIV.diffobj-gutter {
##   display: table-cell;
##   padding: 0 0.2em;
## }
## DIV.diffobj-container DIV.diffobj-gutter DIV {
##   display: table-cell;
## }
## #diffobj_content_meta DIV.diffobj-container DIV.diffobj-row {
##   width: auto;
## }
## #diffobj_banner_meta DIV.diffobj-container DIV.diffobj-line.banner&gt;DIV {
##   table-layout: auto;
## }
## #diffobj_outer {
##   overflow: hidden;
## }
## /* Summary -------------------------------------------------------------------*/ 
## 
## DIV.diffobj-container DIV.diffobj-summary DIV.map {
##   word-wrap: break-word;
##   padding-left: 1em;
## }
## DIV.diffobj-container DIV.diffobj-summary DIV.detail {
##   padding-left: 1em;
## }
## 
## /* Common elements -----------------------------------------------------------*/
## 
## DIV.diffobj-container DIV.diffobj-line.banner {
##   font-size: 1.2em;
##   font-weight: bold;
##   overflow: hidden;
## }
## /* truncate banners */
## DIV.diffobj-container DIV.diffobj-line.banner DIV.diffobj-text DIV{
##   white-space: nowrap;
##   overflow: hidden;
##   text-overflow: ellipsis;
##   width: 100%;             /* need to compute and set in JS */
## }
## DIV.diffobj-container DIV.diffobj-gutter,
## DIV.diffobj-container DIV.diffobj-guide,
## DIV.diffobj-container DIV.diffobj-fill,
## DIV.diffobj-container DIV.context_sep,
## DIV.diffobj-container SPAN.diffobj-trim {
##   color: #999;
## }
## DIV.diffobj-container DIV.diffobj-header {
##   font-size: 1.1em;
## }
## DIV.diffobj-container DIV.diffobj-text&gt;DIV.diffobj-match,
## DIV.diffobj-container DIV.diffobj-text&gt;DIV.diffobj-guide {
##   background-color: #ffffff;
## }
## DIV.diffobj-container DIV.diffobj-text&gt;DIV.diffobj-fill {
##   background-color: transparent;
## }
## DIV.diffobj-container DIV.diffobj-text&gt;DIV {
##   padding-right: 3px;
## }
## DIV.diffobj-container DIV.diffobj-text&gt;DIV {
##   border-left: 1px solid #888888;
## }
## DIV.diffobj-container DIV.diffobj-line {
##   background-color: #eeeeee;
## }
## DIV.diffobj-container DIV.diffobj-text&gt;DIV,
## DIV.diffobj-container DIV.diffobj-header {
##   padding-left: 0.5em;
## }
## DIV.diffobj-container DIV.diffobj-line&gt;DIV.diffobj-match,
## DIV.diffobj-container DIV.diffobj-line&gt;DIV.diffobj-fill,
## DIV.diffobj-container DIV.diffobj-line&gt;DIV.diffobj-guide {
##   border-left: 1px solid #888888;
## }
## /* github inspired color scheme - default ------------------------------------*/
## 
## DIV.diffobj-container.light.rgb SPAN.diffobj-word.insert,
## DIV.diffobj-container.light.rgb DIV.diffobj-line&gt;DIV.insert {
##   background-color: #a6f3a6;
## }
## DIV.diffobj-container.light.rgb SPAN.diffobj-word.delete,
## DIV.diffobj-container.light.rgb DIV.diffobj-line&gt;DIV.delete {
##   background-color: #f8c2c2;
## }
## DIV.diffobj-container.light.rgb DIV.diffobj-text&gt;DIV.insert {
##   background-color: #efffef;
## }
## DIV.diffobj-container.light.rgb DIV.diffobj-text&gt;DIV.insert,
## DIV.diffobj-container.light.rgb DIV.diffobj-line&gt;DIV.insert {
##   border-left: 1px solid #33bb33;
## }
## DIV.diffobj-container.light.rgb DIV.diffobj-text&gt;DIV.delete {
##   background-color: #ffefef;
## }
## DIV.diffobj-container.light.rgb DIV.diffobj-text&gt;DIV.delete,
## DIV.diffobj-container.light.rgb DIV.diffobj-line&gt;DIV.delete {
##   border-left: 1px solid #cc6666;
## }
## DIV.diffobj-container.light.rgb DIV.diffobj-header {
##   background-color: #e0e6fa;
##   border-left: 1px solid #9894b6;
## }
## /* Yellow Blue variation -----------------------------------------------------*/
## 
## DIV.diffobj-container.light.yb SPAN.diffobj-word.insert,
## DIV.diffobj-container.light.yb DIV.diffobj-line&gt;DIV.insert {
##   background-color: #c0cfff;
## }
## DIV.diffobj-container.light.yb SPAN.diffobj-word.delete,
## DIV.diffobj-container.light.yb DIV.diffobj-line&gt;DIV.delete {
##   background-color: #e7e780;
## }
## DIV.diffobj-container.light.yb DIV.diffobj-text&gt;DIV.insert {
##   background-color: #efefff;
## }
## DIV.diffobj-container.light.yb DIV.diffobj-text&gt;DIV.insert,
## DIV.diffobj-container.light.yb DIV.diffobj-line&gt;DIV.insert {
##   border-left: 1px solid #3333bb;
## }
## DIV.diffobj-container.light.yb DIV.diffobj-text&gt;DIV.delete {
##   background-color: #fefee5;
## }
## DIV.diffobj-container.light.yb DIV.diffobj-text&gt;DIV.delete,
## DIV.diffobj-container.light.yb DIV.diffobj-line&gt;DIV.delete {
##   border-left: 1px solid #aaaa55;
## }
## DIV.diffobj-container.light.yb DIV.diffobj-header {
##   background-color: #afafaf;
##   border-left: 1px solid #e3e3e3;
##   color: #e9e9e9;
## }
## DIV.diffobj-container.light.yb DIV.diffobj-line {
##   background-color: #eeeeee;
## }
## &lt;/style&gt;&lt;div class=&#039;diffobj-container light yb&#039;&gt;&lt;pre class=&#039;diffobj-content&#039;&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line banner&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;new_isd_history&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line banner&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;isd_history&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;diffobj-header&#039;&gt;@@ 1,25 / 1,25 @@&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'># Data table (class data.table) 12 x &lt;span class=&#039;diffobj-word delete&#039;&gt;24285:</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'># Data table (class data.table) 12 x &lt;span class=&#039;diffobj-word insert&#039;&gt;27963:</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'># (Showing rows 1 - 20 out of &lt;span class=&#039;diffobj-word delete&#039;&gt;24285)</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'># (Showing rows 1 - 20 out of &lt;span class=&#039;diffobj-word insert&#039;&gt;27963)</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&amp;nbsp;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #000000; background-color: #BBBBBB; font-weight: bold;'>  │STNID       │NAME               │LAT  │LON  │ELEV(M)│CTRY │STATE│BEGIN   </span>&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&amp;nbsp;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;  │<span style='font-style: italic;'>&amp;lt;chr&amp;gt;       </span>│<span style='font-style: italic;'>&amp;lt;chr&amp;gt;              </span>│<span style='font-style: italic;'>&amp;lt;dbl&amp;gt;</span>│<span style='font-style: italic;'>&amp;lt;dbl&amp;gt;</span>│<span style='font-style: italic;'>&amp;lt;dbl&amp;gt;  </span>│<span style='font-style: italic;'>&amp;lt;chr&amp;gt;</span>│<span style='font-style: italic;'>&amp;lt;chr&amp;gt;</span>│<span style='font-style: italic;'>&amp;lt;int&amp;gt;   </span>&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&amp;nbsp;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'> 1</span>│<span style='font-weight: bold;'>008268-99999</span>│<span style='font-style: italic;'>WXPOD8278          </span>│   33│ 65.6│ 1156.7│<span style='font-style: italic;'>AF   </span>│<span style='font-style: italic;'>     </span>│20100519&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'> &lt;span class=&#039;diffobj-word delete&#039;&gt;2</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010014-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>SORSTOKKEN&lt;/span&gt; / STORD </span><span style='background-color: #000000;'>│   60│  5.3│   48.8│</span><span style='background-color: #000000; font-style: italic;'>NO   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│19861120</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'> &lt;span class=&#039;diffobj-word insert&#039;&gt;2</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010010-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>JAN&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;MAYEN&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;(NOR-NAVY)</span><span style='background-color: #000000;'>│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;71│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;-8.7│&lt;/span&gt;    &lt;span class=&#039;diffobj-word insert&#039;&gt;9.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>&lt;/span&gt;     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19310101</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; font-style: italic;'>&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;3</span>│<span style='font-weight: bold;'>010014-99999</span>│<span style='font-style: italic;'>SORSTOKKEN&lt;/span&gt; / STORD </span>│   60│  5.3│   48.8│<span style='font-style: italic;'>NO   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span>│19861120&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; font-style: italic;'>&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;3</span>│<span style='font-weight: bold;'>010015-99999</span>│<span style='font-style: italic;'>BRINGELAND&lt;/span&gt;         </span>│   61│  5.9│  327.0│<span style='font-style: italic;'>NO   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│19870117&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;4</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010015-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>BRINGELAND&lt;/span&gt;         </span><span style='background-color: #000000;'>│   61│  5.9│  327.0│</span><span style='background-color: #000000; font-style: italic;'>NO   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19870117</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;4</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010016-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>RORVIK/RYUM&lt;/span&gt;        </span><span style='background-color: #000000;'>│   65│ 11.2│   14.0│</span><span style='background-color: #000000; font-style: italic;'>NO   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│19870116</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; font-style: italic;'>&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;5</span>│<span style='font-weight: bold;'>010016-99999</span>│<span style='font-style: italic;'>RORVIK/RYUM&lt;/span&gt;        </span>│   65│ 11.2│   14.0│<span style='font-style: italic;'>NO   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span>│19870116&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; font-style: italic;'>&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;5</span>│<span style='font-weight: bold;'>010100-99999</span>│<span style='font-style: italic;'>ANDOYA&lt;/span&gt;             &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│&lt;/span&gt;   &lt;span class=&#039;diffobj-word delete&#039;&gt;69│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;16.1│&lt;/span&gt;   &lt;span class=&#039;diffobj-word delete&#039;&gt;13.1│<span style='font-style: italic;'>NO&lt;/span&gt;   &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│<span style='font-style: italic;'>&lt;/span&gt;     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│19310103&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'> &lt;span class=&#039;diffobj-word delete&#039;&gt;6</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010230-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>BARDUFOSS&lt;/span&gt;          </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;69│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;18.5│&lt;/span&gt;   &lt;span class=&#039;diffobj-word delete&#039;&gt;76.8│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│19400713</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'> &lt;span class=&#039;diffobj-word insert&#039;&gt;6</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010017-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>FRIGG&lt;/span&gt;              </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;60│&lt;/span&gt;  &lt;span class=&#039;diffobj-word insert&#039;&gt;2.2│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;48.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19880320</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'> &lt;span class=&#039;diffobj-word delete&#039;&gt;7</span>│<span style='font-weight: bold;'>010250-99999</span>│<span style='font-style: italic;'>TROMSO&lt;/span&gt;             </span>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;70│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;18.9│&lt;/span&gt;    &lt;span class=&#039;diffobj-word delete&#039;&gt;9.4│<span style='font-style: italic;'>NO&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│19730101&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'> &lt;span class=&#039;diffobj-word insert&#039;&gt;7</span>│<span style='font-weight: bold;'>010020-99999</span>│<span style='font-style: italic;'>VERLEGENHUKEN&lt;/span&gt;      </span>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;80│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;16.2│&lt;/span&gt;    &lt;span class=&#039;diffobj-word insert&#039;&gt;8.0│<span style='font-style: italic;'>NO&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span>│19861109&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'> &lt;span class=&#039;diffobj-word delete&#039;&gt;8</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010260-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>TROMSO&lt;/span&gt;             </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;70│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;18.9│&lt;/span&gt;  &lt;span class=&#039;diffobj-word delete&#039;&gt;114.5│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│19970201</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'> &lt;span class=&#039;diffobj-word insert&#039;&gt;8</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010030-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>HORNSUND&lt;/span&gt;           </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;77│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;15.5│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;12.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19850601</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'> &lt;span class=&#039;diffobj-word delete&#039;&gt;9</span>│<span style='font-weight: bold;'>010270-99999</span>│<span style='font-style: italic;'>TROMSO-HOLT&lt;/span&gt;        </span>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;70│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;18.9│&lt;/span&gt;   &lt;span class=&#039;diffobj-word delete&#039;&gt;20.0│<span style='font-style: italic;'>NO&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│20110928&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'> &lt;span class=&#039;diffobj-word insert&#039;&gt;9</span>│<span style='font-weight: bold;'>010040-99999</span>│<span style='font-style: italic;'>NY-ALESUND&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;II&lt;/span&gt;      </span>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;79│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;11.9│&lt;/span&gt;    &lt;span class=&#039;diffobj-word insert&#039;&gt;8.0│<span style='font-style: italic;'>NO&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span>│19730101&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>10</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010300-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>KISTEFJELL&lt;/span&gt;         </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;69│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;18.1│&lt;/span&gt;  &lt;span class=&#039;diffobj-word delete&#039;&gt;982.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│19510101</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>10</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010050-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>ISFJORD&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;RADIO&lt;/span&gt;      </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;78│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;13.6│&lt;/span&gt;    &lt;span class=&#039;diffobj-word insert&#039;&gt;9.0│</span><span style='background-color: #000000; font-style: italic;'>SV&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19310103</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; font-style: italic;'>11</span>│<span style='font-weight: bold;'>010303-99999</span>│<span style='font-style: italic;'>TROMSO/SKATTURA&lt;/span&gt;    </span>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;70│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;19.0│&lt;/span&gt;   14.0│<span style='font-style: italic;'>NO   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│20140522&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; font-style: italic;'>11</span>│<span style='font-weight: bold;'>010060-99999</span>│<span style='font-style: italic;'>EDGEOYA&lt;/span&gt;            </span>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;78│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;22.8│&lt;/span&gt;   14.0│<span style='font-style: italic;'>NO   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span>│19730101&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>12</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010320-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>OVERBYGD&lt;/span&gt;           </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;69│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;19.3│&lt;/span&gt;   &lt;span class=&#039;diffobj-word delete&#039;&gt;78.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│19730101</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>12</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010070-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>NY-ALESUND&lt;/span&gt;         </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;79│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;11.9│&lt;/span&gt;    &lt;span class=&#039;diffobj-word insert&#039;&gt;7.7│</span><span style='background-color: #000000; font-style: italic;'>SV&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19730106</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; font-style: italic;'>13</span>│<span style='font-weight: bold;'>010350-99999</span>│<span style='font-style: italic;'>LYNGEN&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;GJERDVASSBU&lt;/span&gt; </span>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;70│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;20.1│&lt;/span&gt;  &lt;span class=&#039;diffobj-word delete&#039;&gt;710.0│<span style='font-style: italic;'>NO&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│19730101&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; font-style: italic;'>13</span>│<span style='font-weight: bold;'>010071-99999</span>│<span style='font-style: italic;'>LONGYEARBYEN&lt;/span&gt;       </span>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;78│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;15.6│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;37.0│<span style='font-style: italic;'>SV&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span>│20050210&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>14</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010360-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>NORDNESFJELLET&lt;/span&gt;     </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;70│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;20.4│&lt;/span&gt;  &lt;span class=&#039;diffobj-word delete&#039;&gt;710.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│20040510</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>14</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010080-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>LONGYEAR&lt;/span&gt;           </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;78│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;15.5│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;26.8│</span><span style='background-color: #000000; font-style: italic;'>SV&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19750929</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; font-style: italic;'>15</span>│<span style='font-weight: bold;'>010090-99999</span>│<span style='font-style: italic;'>KARL&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;XII&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;OYA&lt;/span&gt;       </span>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;81│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;25.0│&lt;/span&gt;    &lt;span class=&#039;diffobj-word insert&#039;&gt;5.0│<span style='font-style: italic;'>SV&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span>│19550101&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>16</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010100-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>ANDOYA&lt;/span&gt;             </span><span style='background-color: #000000;'>│   69│ &lt;span class=&#039;diffobj-word insert&#039;&gt;16.1│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;13.1│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19310103</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; font-style: italic;'>15</span>│<span style='font-weight: bold;'>010361-99999</span>│<span style='font-style: italic;'>SKIBOTIN&lt;/span&gt;           </span>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;69│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;20.3│&lt;/span&gt;    &lt;span class=&#039;diffobj-word delete&#039;&gt;5.0│<span style='font-style: italic;'>NO&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│20050916&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; font-style: italic;'>17</span>│<span style='font-weight: bold;'>010110-99999</span>│<span style='font-style: italic;'>KVITOYA&lt;/span&gt;            </span>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;80│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;31.5│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;10.0│<span style='font-style: italic;'>SV&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span>│19861118&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>16</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010370-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>SKIBOTN&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;2&lt;/span&gt;          </span><span style='background-color: #000000;'>│   69│ &lt;span class=&#039;diffobj-word delete&#039;&gt;20.3│&lt;/span&gt;   &lt;span class=&#039;diffobj-word delete&#039;&gt;20.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│19730101</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>18</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010140-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>SENJA-LAUKHELLA&lt;/span&gt;    &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;69│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;17.9│&lt;/span&gt;    &lt;span class=&#039;diffobj-word insert&#039;&gt;9.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19730101</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; font-style: italic;'>19</span>│<span style='font-weight: bold;'>010150-99999</span>│<span style='font-style: italic;'>HEKKINGEN&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;FYR&lt;/span&gt;      </span>│   70│ &lt;span class=&#039;diffobj-word insert&#039;&gt;17.8│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;14.0│<span style='font-style: italic;'>NO&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span>│19800314&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; font-style: italic;'>17</span>│<span style='font-weight: bold;'>010410-99999</span>│<span style='font-style: italic;'>NORDREISA-OYENG&lt;/span&gt;    </span>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;70│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;21.0│&lt;/span&gt;    &lt;span class=&#039;diffobj-word delete&#039;&gt;5.0│<span style='font-style: italic;'>NO&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│19730101&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&amp;gt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;insert&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word insert&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>20</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010160-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>KONGSOYA&lt;/span&gt;           </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word insert&#039;&gt;79│&lt;/span&gt; &lt;span class=&#039;diffobj-word insert&#039;&gt;28.9│&lt;/span&gt;   &lt;span class=&#039;diffobj-word insert&#039;&gt;20.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word insert&#039;&gt;</span><span style='background-color: #000000;'>│19930501</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>18</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010420-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>HASVIK-SLUSKFJELLET</span><span style='background-color: #000000;'>│&lt;/span&gt;   &lt;span class=&#039;diffobj-word delete&#039;&gt;71│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;22.4│&lt;/span&gt;  &lt;span class=&#039;diffobj-word delete&#039;&gt;438.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│20080917</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; font-style: italic;'>19</span>│<span style='font-weight: bold;'>010440-99999</span>│<span style='font-style: italic;'>HASVIK&lt;/span&gt;             </span>│   70│ &lt;span class=&#039;diffobj-word delete&#039;&gt;22.1│&lt;/span&gt;    &lt;span class=&#039;diffobj-word delete&#039;&gt;6.4│<span style='font-style: italic;'>NO&lt;/span&gt;   </span>│<span style='font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span>│20050102&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&amp;lt;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;delete&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;span class=&#039;diffobj-word delete&#039;&gt;<span style='color: #555555; background-color: #000000; font-style: italic;'>20</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-weight: bold;'>010470-99999</span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>KAUTOKEINO&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;II&lt;/span&gt;      </span><span style='background-color: #000000;'>│   &lt;span class=&#039;diffobj-word delete&#039;&gt;69│&lt;/span&gt; &lt;span class=&#039;diffobj-word delete&#039;&gt;23.1│&lt;/span&gt;  &lt;span class=&#039;diffobj-word delete&#039;&gt;307.0│</span><span style='background-color: #000000; font-style: italic;'>NO&lt;/span&gt;   </span><span style='background-color: #000000;'>│</span><span style='background-color: #000000; font-style: italic;'>     &lt;span class=&#039;diffobj-word delete&#039;&gt;</span><span style='background-color: #000000;'>│19730101</span>&lt;/span&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-row&#039;&gt;&lt;div class=&#039;diffobj-line&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&lt;div class=&#039;diffobj-gutter&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&amp;nbsp;&lt;/div&gt;&lt;div class=&#039;pad&#039;&gt; &lt;/div&gt;&lt;/div&gt;&lt;div class=&#039;diffobj-text&#039;&gt;&lt;div class=&#039;diffobj-match&#039;&gt;&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;<span style='color: #555555; font-style: italic;'># 4 more columns: END (&amp;lt;int&amp;gt;), COUNTRY_NAME (&amp;lt;chr&amp;gt;), ISO2C (&amp;lt;chr&amp;gt;), ISO3C (&amp;lt;chr&amp;gt;)</span>&lt;span class=&#039;diffobj-trim&#039;&gt;&lt;/span&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/div&gt;&lt;/pre&gt;&lt;/div&gt;
</CODE></PRE>

## View and save the data


``` r
rm(isd_history)
isd_history <- new_isd_history

str(isd_history)
```

```
## Classes 'data.table' and 'data.frame':	24285 obs. of  12 variables:
##  $ STNID       : chr  "008268-99999" "010014-99999" "010015-99999" "010016-99999" ...
##  $ NAME        : chr  "WXPOD8278" "SORSTOKKEN / STORD" "BRINGELAND" "RORVIK/RYUM" ...
##  $ LAT         : num  33 59.8 61.4 64.8 69.3 ...
##  $ LON         : num  65.57 5.34 5.87 11.23 16.14 ...
##  $ ELEV(M)     : num  1156.7 48.8 327 14 13.1 ...
##  $ CTRY        : chr  "AF" "NO" "NO" "NO" ...
##  $ STATE       : chr  "" "" "" "" ...
##  $ BEGIN       : int  20100519 19861120 19870117 19870116 19310103 19400713 19730101 19970201 20110928 19510101 ...
##  $ END         : int  20120323 20250824 19971231 19910806 20250824 20250824 20250824 20250824 20250824 20250824 ...
##  $ COUNTRY_NAME: chr  "Afghanistan" "Norway" "Norway" "Norway" ...
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

```
## Error in save(isd_diff, file = "../inst/extdata/isd_diff.rda", compress = "bzip2"): object 'isd_diff' not found
```

# Notes

## NOAA policy

Users of these data should take into account the following (from the [NCEI website](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00516)):

> The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification. A log of IP addresses accessing these data and products will be maintained and may be made available to data providers.  
> For details, please consult: [WMO Resolution 40. NOAA Policy](https://community.wmo.int/resolution-40)

## R System Information

<PRE class="fansi fansi-output"><CODE>## <span style='color: #00BBBB; font-weight: bold;'>─ Session info ───────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>setting </span> <span style='color: #555555; font-style: italic;'>value</span>
##  version  R version 4.5.2 (2025-10-31)
##  os       macOS Tahoe 26.1
##  system   aarch64, darwin20
##  ui       X11
##  language (EN)
##  collate  en_AU.UTF-8
##  ctype    en_AU.UTF-8
##  tz       Australia/Perth
##  date     2025-11-15
##  pandoc   3.8.2.1 @ /opt/homebrew/bin/pandoc
##  quarto   1.8.26 @ /usr/local/bin/quarto
## 
## <span style='color: #00BBBB; font-weight: bold;'>─ Packages ───────────────────────────────────────────────────────────────────</span>
##  <span style='color: #555555; font-style: italic;'>package    </span> <span style='color: #555555; font-style: italic;'>*</span> <span style='color: #555555; font-style: italic;'>version</span> <span style='color: #555555; font-style: italic;'>date (UTC)</span> <span style='color: #555555; font-style: italic;'>lib</span> <span style='color: #555555; font-style: italic;'>source</span>
##  askpass       1.2.1   <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  class         7.3-23  <span style='color: #555555;'>2025-01-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  classInt      0.4-11  <span style='color: #555555;'>2025-01-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  cli           3.6.5   <span style='color: #555555;'>2025-04-23</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  codetools     0.2-20  <span style='color: #555555;'>2024-03-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  colorDF       0.1.7   <span style='color: #555555;'>2022-09-26</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  colorout      1.3-3   <span style='color: #555555;'>2025-08-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>Github (jalvesaq/colorout@64863bb)</span>
##  countrycode * 1.6.1   <span style='color: #555555;'>2025-03-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  crayon        1.5.3   <span style='color: #555555;'>2024-06-20</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  credentials   2.0.3   <span style='color: #555555;'>2025-09-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  curl          7.0.0   <span style='color: #555555;'>2025-08-19</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  data.table  * 1.17.8  <span style='color: #555555;'>2025-07-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  DBI           1.2.3   <span style='color: #555555;'>2024-06-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  diffobj     * 0.3.6   <span style='color: #555555;'>2025-04-21</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  dplyr       * 1.1.4   <span style='color: #555555;'>2023-11-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  e1071         1.7-16  <span style='color: #555555;'>2024-09-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  evaluate      1.0.5   <span style='color: #555555;'>2025-08-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  fansi         1.0.6   <span style='color: #555555;'>2023-12-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  fs            1.6.6   <span style='color: #555555;'>2025-04-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  generics      0.1.4   <span style='color: #555555;'>2025-05-09</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  geodata     * 0.6-6   <span style='color: #555555;'>2025-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  glue          1.8.0   <span style='color: #555555;'>2024-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  jsonlite      2.0.0   <span style='color: #555555;'>2025-03-27</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  KernSmooth    2.23-26 <span style='color: #555555;'>2025-01-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  knitr       * 1.50    <span style='color: #555555;'>2025-03-16</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  lifecycle     1.0.4   <span style='color: #555555;'>2023-11-07</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  magrittr      2.0.4   <span style='color: #555555;'>2025-09-12</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  nvimcom     * 0.9.76  <span style='color: #555555;'>2025-11-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #BB00BB; font-weight: bold;'>local</span>
##  openssl       2.3.4   <span style='color: #555555;'>2025-09-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  pillar        1.11.1  <span style='color: #555555;'>2025-09-17</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  pkgconfig     2.0.3   <span style='color: #555555;'>2019-09-22</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  pkgdown       2.2.0   <span style='color: #555555;'>2025-11-06</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  proxy         0.4-27  <span style='color: #555555;'>2022-06-09</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  purrr         1.2.0   <span style='color: #555555;'>2025-11-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  R6            2.6.1   <span style='color: #555555;'>2025-02-15</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  rappdirs      0.3.3   <span style='color: #555555;'>2021-01-31</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  Rcpp          1.1.0   <span style='color: #555555;'>2025-07-02</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  rlang         1.1.6   <span style='color: #555555;'>2025-04-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  sessioninfo * 1.2.3   <span style='color: #555555;'>2025-02-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  sf          * 1.0-22  <span style='color: #555555;'>2025-11-10</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  sys           3.4.3   <span style='color: #555555;'>2024-10-04</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  terra       * 1.8-80  <span style='color: #555555;'>2025-11-05</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  tibble        3.3.0   <span style='color: #555555;'>2025-06-08</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  tidyselect    1.2.1   <span style='color: #555555;'>2024-03-11</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  units         1.0-0   <span style='color: #555555;'>2025-10-09</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
##  vctrs         0.6.5   <span style='color: #555555;'>2023-12-01</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  withr         3.0.2   <span style='color: #555555;'>2024-10-28</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.1)</span>
##  xfun          0.54    <span style='color: #555555;'>2025-10-30</span> <span style='color: #555555;'>[1]</span> <span style='color: #555555;'>CRAN (R 4.5.0)</span>
## 
## <span style='color: #555555;'> [1] /Users/adamsparks/Library/R/arm64/4.5/library</span>
## <span style='color: #555555;'> [2] /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/library</span>
##  <span style='color: #BBBBBB; background-color: #BB0000;'>*</span> ── Packages attached to the search path.
## 
## <span style='color: #00BBBB; font-weight: bold;'>──────────────────────────────────────────────────────────────────────────────</span>
</CODE></PRE>
