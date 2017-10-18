## ----check_packages, echo=FALSE, messages=FALSE, warning=FALSE-----------
required <- c("ggplot2", "tidyr", "lubridate")

if (!all(unlist(lapply(required, function(pkg) requireNamespace(pkg, quietly = TRUE)))))
  knitr::opts_chunk$set(eval = FALSE)

## ---- eval=FALSE---------------------------------------------------------
#  library(dplyr)
#  load(system.file("extdata", "country_list.rda", package = "GSODR"))
#  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
#  station_locations <- left_join(isd_history, country_list,
#                                 by = c("CTRY" = "FIPS"))
#  
#  # create data.frame for Australia only
#  Oz <- filter(station_locations, COUNTRY_NAME == "AUSTRALIA")
#  head(Oz)
#  
#  #>     USAF  WBAN                  STN_NAME CTRY STATE CALL     LAT     LON
#  #> 1 695023 99999       HORN ISLAND   (HID)   AS  <NA> KQXC -10.583 142.300
#  #> 2 749430 99999        AIDELAIDE RIVER SE   AS  <NA> <NA> -13.300 131.133
#  #> 3 749432 99999 BATCHELOR FIELD AUSTRALIA   AS  <NA> <NA> -13.049 131.066
#  #> 4 749438 99999      IRON RANGE AUSTRALIA   AS  <NA> <NA> -12.700 143.300
#  #> 5 749439 99999  MAREEBA AS/HOEVETT FIELD   AS  <NA> <NA> -17.050 145.400
#  #> 6 749440 99999                 REID EAST   AS  <NA> <NA> -19.767 146.850
#  #>   ELEV_M    BEGIN      END        STNID ELEV_M_SRTM_90m COUNTRY_NAME iso2c
#  #> 1     NA 19420804 20030816 695023-99999              24    AUSTRALIA    AU
#  #> 2    131 19430228 19440821 749430-99999              96    AUSTRALIA    AU
#  #> 3    107 19421231 19430610 749432-99999              83    AUSTRALIA    AU
#  #> 4     18 19420917 19440930 749438-99999              63    AUSTRALIA    AU
#  #> 5    443 19420630 19440630 749439-99999             449    AUSTRALIA    AU
#  #> 6    122 19421012 19430405 749440-99999              75    AUSTRALIA    AU
#  #>   iso3c
#  #> 1   AUS
#  #> 2   AUS
#  #> 3   AUS
#  #> 4   AUS
#  #> 5   AUS
#  #> 6   AUS
#  
#  filter(Oz, STN_NAME == "TOOWOOMBA")
#  #>     USAF  WBAN  STN_NAME CTRY STATE CALL     LAT     LON ELEV_M    BEGIN
#  #> 1 945510 99999 TOOWOOMBA   AS  <NA> <NA> -27.583 151.933    676 19561231
#  #>        END        STNID ELEV_M_SRTM_90m COUNTRY_NAME iso2c iso3c
#  #> 1 20120503 945510-99999             670    AUSTRALIA    AU   AUS

## ---- eval=FALSE---------------------------------------------------------
#  library(GSODR)
#  Tbar <- get_GSOD(years = 2010, station = "955510-99999")
#  
#  #> Downloading the station file(s) now.
#  
#  #> Finished downloading file. Parsing the station file(s) now.
#  
#  head(Tbar)

## ---- eval=FALSE---------------------------------------------------------
#  tbar_stations <- nearest_stations(LAT = -27.5598,
#                                    LON = 151.9507,
#                                    distance = 50)
#  
#    tbar <- get_GSOD(years = 2010, station = tbar_stations)

## ---- eval=FALSE---------------------------------------------------------
#  remove <- c("949999-00170", "949999-00183")
#  
#  tbar_stations <- tbar_stations[!tbar_stations %in% remove]
#  
#  tbar <- get_GSOD(years = 2010,
#                   station = tbar_stations,
#                   dsn = "~/")

## ---- eval=FALSE---------------------------------------------------------
#  library(ggplot2)
#  library(lubridate)
#  library(tidyr)
#  
#  # Create a dataframe of just the date and temperature values that we want to
#  # plot
#  tbar_temps <- tbar[, c("YEARMODA", "TEMP", "MAX", "MIN")]
#  
#  # Gather the data from wide to long
#  tbar_temps <- gather(tbar_temps, Measurement, gather_cols = TEMP:MIN)
#  
#  ggplot(data = tbar_temps, aes(x = ymd(YEARMODA), y = value,
#                                colour = Measurement)) +
#    geom_line() +
#    scale_color_brewer(type = "qual", na.value = "black") +
#    scale_y_continuous(name = "Temperature") +
#    scale_x_date(name = "Date") +
#    theme_bw()

## ---- eval=FALSE---------------------------------------------------------
#  get_GSOD(years = 2015, country = "Australia", dsn = "~/", filename = "AUS",
#           CSV = FALSE, GPKG = TRUE)
#  #> trying URL 'ftp://ftp.ncdc.noaa.gov/pub/data/gsod/2015/gsod_2015.tar'
#  #> Content type 'unknown' length 106352640 bytes (101.4 MB)
#  #> ==================================================
#  #> downloaded 101.4 MB
#  
#  
#  #> Finished downloading file.
#  
#  #> Starting data file processing.
#  
#  
#  #> Writing GeoPackage file to disk.

## ---- eval=FALSE---------------------------------------------------------
#  library(rgdal)
#  #> Loading required package: sp
#  #> rgdal: version: 1.1-10, (SVN revision 622)
#  #>  Geospatial Data Abstraction Library extensions to R successfully loaded
#  #>  Loaded GDAL runtime: GDAL 1.11.5, released 2016/07/01
#  #>  Path to GDAL shared files: /usr/local/Cellar/gdal/1.11.5_1/share/gdal
#  #>  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
#  #>  Path to PROJ.4 shared files: (autodetected)
#  #>  Linking to sp version: 1.2-3
#  
#  AUS_stations <- readOGR(dsn = path.expand("~/AUS.gpkg"), layer = "GSOD")
#  #> OGR data source with driver: GPKG
#  #> Source: "/Users/asparks/AUS-2015.gpkg", layer: "GSOD"
#  #> with 186977 features
#  #> It has 46 fields
#  
#  class(AUS_stations)
#  #> [1] "SpatialPointsDataFrame"
#  #> attr(,"package")
#  #> [1] "sp"

## ---- eval=FALSE---------------------------------------------------------
#  AUS_sqlite <- tbl(src_sqlite(path.expand("~/AUS.gpkg")), "GSOD")
#  class(AUS_sqlite)
#  #> [1] "tbl_dbi"  "tbl_sql"  "tbl_lazy" "tbl"
#  
#  print(AUS_sqlite, n = 5)
#  #> Source:   table<GSOD> [?? x 48]
#  #> Database: sqlite 3.19.3 [/Users/U8004755/AUS.gpkg]
#  #>    fid         geom   USAF  WBAN        STNID  STN_NAME  CTRY STATE  CALL ELEV_M ELEV_M_SRTM_90m    BEGIN      END YEARMODA
#  #>  <int>       <blob>  <chr> <chr>        <chr>     <chr> <chr> <chr> <chr>  <dbl>           <dbl>    <dbl>    <dbl>    <chr>
#  #> 1     1 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150101
#  #> 2     2 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150102
#  #> 3     3 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150103
#  #> 4      4 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150104
#  #> 5     5 <blob[29 B]> 941000 99999 941000-99999 KALUMBURU    AS  <NA>  <NA>     24              17 20010912 20170916 20150105
#  #> ... with more rows, and 34 more variables: YEAR <chr>, MONTH <chr>, DAY <chr>, YDAY <dbl>, TEMP <dbl>, TEMP_CNT <int>,
#  #>   DEWP <dbl>, DEWP_CNT <int>, SLP <dbl>, SLP_CNT <int>, STP <dbl>, STP_CNT <int>, VISIB <dbl>, VISIB_CNT <int>, WDSP <dbl>,
#  #>   WDSP_CNT <int>, MXSPD <dbl>, GUST <dbl>, MAX <dbl>, MAX_FLAG <chr>, MIN <dbl>, MIN_FLAG <chr>, PRCP <dbl>, PRCP_FLAG <chr>,
#  #>   SNDP <dbl>, I_FOG <int>, I_RAIN_DRIZZLE <int>, I_SNOW_ICE <int>, I_HAIL <int>, I_THUNDER <int>, I_TORNADO_FUNNEL <int>,
#  #>   EA <dbl>, ES <dbl>, RH <dbl>

## ---- eval=FALSE---------------------------------------------------------
#  y <- c("~/GSOD/gsod_1960/200490-99999-1960.op.gz",
#         "~/GSOD/gsod_1961/200490-99999-1961.op.gz")
#  x <- reformat_GSOD(file_list = y)

## ---- eval=FALSE---------------------------------------------------------
#  x <- reformat_GSOD(dsn = "~/GSOD/gsod_1960")

## ---- eval=FALSE---------------------------------------------------------
#  inventory <- get_inventory()
#  
#  #> THIS INVENTORY SHOWS THE NUMBER OF WEATHER OBSERVATIONS BY STATION-YEAR-MONTH FOR BEGINNING OF RECORD THROUGH SEPTEMBER 2017.  THE DATABASE CONTINUES TO BE UPDATED AND ENHANCED, AND THIS INVENTORY WILL BE  UPDATED ON A REGULAR BASIS.
#  
#  head(inventory)
#  
#  #> # A tibble: 6 x 14
#  #>         STNID  YEAR   JAN   FEB   MAR   APR   MAY   JUN   JUL   AUG   SEP   OCT   NOV   DEC
#  #>         <chr> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> #><int> <int> <int>
#  #>1 007005-99999  2012    18     0     0     0     0     0     0     0     0     0     0     0
#  #>2 007011-99999  2012   771     0   183     0     0     0   142    13     9     0     4     0
#  #>3 007018-99999  2013     0     0     0     0     0     0   710     0     0     0     0     0
#  #>4 007025-99999  2012    21     0     0     0     0     0     0     0     0     0     0     0
#  #>5 007026-99999  2012     0     0     0     0     0     0   367     0     0     0     0     7
#  #>6 007026-99999  2014     0     0     0     0     0     0   180     0     4     0   552     0
#  
#  subset(inventory, STNID == "955510-99999")
#  
#  #> # A tibble: 20 x 14
#  #>          STNID  YEAR   JAN   FEB   MAR   APR   MAY   JUN   JUL   AUG   SEP   OCT   NOV   DEC
#  #>          <chr> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int> <int>
#  #> 1 955510-99999  1998     0     0   222   223   221   211   226   217   222   234   215   230
#  #> 2 955510-99999  1999   213   201   235   224   244   229   239   247   236   246   233   243
#  #> 3 955510-99999  2000   241   227   247   238   246   237   245   240   236   248   239   248
#  #> 4 955510-99999  2001   245   223   246   238   239   236   243   240   237   236   235   246
#  #> 5 955510-99999  2002   245   219   246   236   243   229   243   246   227   238   233   246
#  #> 6 955510-99999  2003   244   217   220   232   235   233   246   242   218   239   225   245
#  #> 7 955510-99999  2004   240   227   241   229   233   224   235   244   235   244   235   245
#  #> 8 955510-99999  2005   243   221   243   241   247   242   248   247   234   241   239   246
#  #> 9 955510-99999  2006   245   223   246   232   241   238   247   247   239   247   240   247
#  #>10 955510-99999  2007   247   222   244   240   248   240   244   244   239   247   237   246
#  #>11 955510-99999  2008   247   228   248   239   248   239   248   247   239   247   238   248
#  #>12 955510-99999  2009   245   222   246   235   244   237   248   248   239   248   239   248
#  #>13 955510-99999  2010   248   223   248   240   244   240   242   247   240   248   240   247
#  #>14 955510-99999  2011   247   224   247   240   247   240   248   247   239   248   239   248
#  #>15 955510-99999  2012   248   232   248   240   248   240   248   247   240   248   240   245
#  #>16 955510-99999  2013   236   220   247   233   248   239   252   246   230   248   239   246
#  #>17 955510-99999  2014   243   224   247   240   246   239   241   243   240   247   240   248
#  #>18 955510-99999  2015   248   222   248   239   247   240   247   246   239   247   237   247
#  #>19 955510-99999  2016   246   228   245   240   246   240   248   248   238   248   231   248
#  #>20 955510-99999  2017   240   224   248   240   248   237   248   247   190     0     0     0

## ---- eval=FALSE---------------------------------------------------------
#  #install.packages("devtools")
#  devtools::install_github("adamhsparks/GSODRdata")
#  library("GSODRdata")

## ---- eval=TRUE, message = FALSE, echo = FALSE, warning=FALSE------------
if (requireNamespace("ggplot2", quietly = TRUE) &&
    requireNamespace("ggthemes", quietly = TRUE) &&
    requireNamespace("maps", quietly = TRUE) &&
    requireNamespace("mapproj", quietly = TRUE) &&
    requireNamespace("gridExtra", quietly = TRUE) &&
    requireNamespace("grid", quietly = TRUE)) {
  library(ggplot2)
  library(mapproj)
  library(ggthemes)
  library(maps)
  library(grid)
  library(gridExtra)
  library(GSODR)
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  world_map <- map_data("world")

  GSOD_stations <- ggplot(isd_history, aes(x = LON, y = LAT)) +
    geom_polygon(data = world_map, aes(x = long, y = lat, group = group),
                 color = grey(0.7),
                 fill = NA) +
    geom_point(color = "red",
               size = 0.05) +
    coord_map(xlim = c(-180, 180)) +
    theme_map() +
    labs(title = "GSOD Station Locations",
         caption = "Data: US NCEI GSOD and CIA World DataBank II")

  # Using the gridExtra and grid packages add a neatline to the map
  grid.arrange(GSOD_stations, ncol = 1)
  grid.rect(width = 0.98,
            height = 0.98,
            gp = grid::gpar(lwd = 0.25,
                            col = "black",
                            fill = NA))
}

