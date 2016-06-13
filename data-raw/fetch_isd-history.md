Fetch, clean and correct altitude in GSOD isd\_history.csv Data
================
Adam H. Sparks - Center for Crop Health, University of Southern Queensland
06-02-2016

Introduction
============

This script will fetch station data from the ftp server and clean up for inclusion in package in /data/stations.rda for the GSODR package.

The following changes are made:

-   Stations where latitude or longitude are NA or both 0 were removed

-   Stations where latitude is &lt; -90˚ or &gt; 90˚ were removed

-   Stations where longitude is &lt; -180˚ or &gt; 180˚ were removed

-   A new field, STNID, a concatenation of the USAF and WBAN fields, was added

-   Stations were checked against Natural Earth 1:10 ADM0 Cultural data, stations not mapping in the isd-history reported country were dropped

-   90m hole-filled SRTM digital elevation (Jarvis *et al.* 2008) was used to identify and correct/remove elevation errors in data for station locations between -60˚ and 60˚ latitude. This applies to cases here where elevation was missing in the reported values as well. In case the station reported an elevation and the DEM does not, the station reported value is taken. For stations beyond -60˚ and 60˚ latitude, the values are station reported values in every instance for the 90m column.

R Data Processing
=================

Set up workspace
----------------

``` r
dem_tiles <- list.files(path.expand("~/Data/CGIAR-CSI SRTM"), 
                        pattern = glob2rx("*.tif"), full.names = TRUE)
crs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
cor_stations <- list()
tf <- tempfile()
```

Download from Natural Earth and NCDC
------------------------------------

``` r
# import Natural Earth cultural 1:10m data (last download 31/05/2016)
curl::curl_download("http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip",
                    destfile = tf)
NE <- unzip(tf)
NE <- raster::shapefile("./ne_10m_admin_0_countries.shp")
unlink(tf)

# download data
stations <- readr::read_csv(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
  col_types = "ccccccddddd",
  col_names = c("USAF", "WBAN", "STN.NAME", "CTRY", "STATE", "CALL",
                "LAT", "LON", "ELEV.M", "BEGIN", "END"), skip = 1)

stations[stations == -999.9] <- NA
stations[stations == -999] <- NA

countries <- readr::read_table(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt")[-1, c(1, 3)]

# join with countrycode data (do we need this?)
countries <- dplyr::left_join(countries, countrycode::countrycode_data,
                              by = c(FIPS = "fips104"))
```

Reformat and clean station data file from NCDC
----------------------------------------------

``` r
# clean data
stations <- stations[!is.na(stations$LAT) & !is.na(stations$LON), ]
stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
stations <- stations[stations$LAT > -90 & stations$LAT < 90, ]
stations <- stations[stations$LON > -180 & stations$LON < 180, ]
stations$STNID <- paste(stations$USAF, stations$WBAN, sep = "-")

xy <- dplyr::left_join(stations, countries, by = c("CTRY" = "FIPS"))
```

Check data for inconsistencies
------------------------------

GSOD data have some inconsistencies in them, some of this has been removed above with filtering. Further filtering is used remove stations reporting locations in countries that do not match the physical coordinates reported. Using [Natural Earth Data 1:10 Cultural Data](http://www.naturalearthdata.com/downloads/10m-cultural-vectors/), the stations reported countries are checked against the country in which the coordinates map.

Also, reported elevation may differ from actual. Hijmans *et al.* (2005) created their own digital elevation model using Jarvis *et al.* (2004) and [GTOPO30 data](https://lta.cr.usgs.gov/GTOPO30) for areas where there was no SRTM data available (&gt;+/-60˚ latitude). Here only the hole-filled SRTM data, V4 (Jarvis *et al.* 2008) was used for correction of agroclimatology data (-60˚ to 60˚ latitude). Any incorrect station elevations beyond these values were ignored in this data set. Stations with incorrect elevation were identified using `raster::extract(x, y, buffer = 200, fun = mean)` so that surrounding cells are also used to determine the elevation at that point, reducing the chances of over or underestimating in mountainous areas. See Hijmans *et al.* (2005) for more detailed information on this methodology.

The hole-filled SRTM data is large enough that it won't all fit in-memory on most desktop computers. Using tiles allows this process to run on a modest machine with minimal effort but does take some time to loop through all of the tiles.

Data can be downloaded from the [CGIAR-CSI's](http://csi.cgiar.org/WhtIsCGIAR_CSI.asp) ftp server, [srtm.csi.cgiar.org](ftp://srtm.csi.cgiar.org), using an FTP client to facilitate this next step.

``` r
# quality check station locations for reported country and lat/lon position
# agreement

# create spatial object to check for location
xy <- as.data.frame(xy)
sp::coordinates(xy) <- ~ LON + LAT
sp::proj4string(xy) <- sp::CRS(crs)

# check for location in country
point_check <- sp::over(xy, NE)
point_check <- as.data.frame(point_check)
stn_discard <- point_check[point_check$FIPS %in% point_check$FIPS_10_ == FALSE, ]
nrow(stn_discard)
```

    ## [1] 0

Zero observations (rows) in stations\_discard, the data look good, no need to remove any

``` r
# create a spatial object for extracting elevation values using spatial points
stations <- as.data.frame(stations)
sp::coordinates(stations) <- ~ LON + LAT
sp::proj4string(stations) <- sp::CRS(crs)

for (i in dem_tiles) {
  
  # Load the DEM tile
  dem <- raster::raster(i)
  sub_stations <- raster::crop(stations, dem)
  
  # in some cases the DEM represents areas where there is no station
  # check for that here and if no stations, go on to next iteration
  if (is.null(sub_stations)) next
  
  # use a 200m buffer to extract elevation from the DEM
  SRTM_buffered <- raster::extract(dem, sub_stations, buffer = 200, fun = mean)
  
  # extract without using the buffer, strictly using 90m data
  SRTM_90m <- raster::extract(dem, sub_stations)
  
  # convert spatial object back to normal data frame and add new fields
  sub_stations <- as.data.frame(sub_stations)
  sub_stations$ELEV.M.SRTM.90m.BUFFER <- SRTM_buffered
  sub_stations$ELEV.M.SRTM.90m.NO_BUFFER <- SRTM_90m
  
  cor_stations[[i]] <- sub_stations
  rm(sub_stations)
}

stations <- as.data.frame(data.table::rbindlist(cor_stations))

# some stations occur in areas where DEM has no data
# use original station elevation in these cells
stations[, 13] <- ifelse(is.na(stations[, 13]), stations[, 9], stations[, 13])
stations[, 14] <- ifelse(is.na(stations[, 14]), stations[, 9], stations[, 14])

summary(stations)
```

    ##       USAF            WBAN                     STN.NAME    
    ##  999999 : 1226   99999  :20979   APPROXIMATE LOCALE:   36  
    ##  949999 :  373   23176  :    5   MOORED BUOY       :   20  
    ##  722250 :    4   03849  :    5   ...               :   15  
    ##  746929 :    4   24255  :    4   BOGUS CHINESE     :   13  
    ##  992390 :    4   24135  :    4   PACIFIC BUOY      :    8  
    ##  997225 :    4   24027  :    4   DEASE LAKE        :    7  
    ##  (Other):23262   (Other): 3876   (Other)           :24778  
    ##       CTRY           STATE            CALL            LAT        
    ##  US     : 6739          :18583          :14948   Min.   :-56.50  
    ##  CA     : 1609   CA     :  505   KMLF   :    6   1st Qu.: 21.78  
    ##  RS     : 1471   TX     :  487   KLSF   :    6   Median : 37.74  
    ##  AS     : 1411   FL     :  319   PAMD   :    5   Mean   : 29.35  
    ##  CH     : 1042   MI     :  231   KONT   :    5   3rd Qu.: 47.17  
    ##  UK     :  675   NC     :  212   KLRD   :    5   Max.   : 60.00  
    ##  (Other):11930   (Other): 4540   (Other): 9902                   
    ##       LON               ELEV.M           BEGIN               END          
    ##  Min.   :-179.983   Min.   :-350.0   Min.   :19010101   Min.   :19301231  
    ##  1st Qu.: -83.738   1st Qu.:  25.0   1st Qu.:19570601   1st Qu.:20020208  
    ##  Median :   7.283   Median : 152.0   Median :19750618   Median :20150602  
    ##  Mean   :  -1.651   Mean   : 376.2   Mean   :19774291   Mean   :20040150  
    ##  3rd Qu.:  69.212   3rd Qu.: 454.9   3rd Qu.:20010816   3rd Qu.:20160529  
    ##  Max.   : 179.750   Max.   :5304.0   Max.   :20160526   Max.   :20160531  
    ##                     NA's   :194                                           
    ##           STNID       ELEV.M.SRTM.90m.BUFFER ELEV.M.SRTM.90m.NO_BUFFER
    ##  992390-99999:    4   Min.   :-360.94        Min.   :-361.0           
    ##  997225-99999:    4   1st Qu.:  24.52        1st Qu.:  25.0           
    ##  992570-99999:    2   Median : 153.24        Median : 154.0           
    ##  997242-99999:    2   Mean   : 379.36        Mean   : 379.6           
    ##  919450-99999:    2   3rd Qu.: 456.33        3rd Qu.: 457.0           
    ##  719584-99999:    2   Max.   :5273.35        Max.   :5269.0           
    ##  (Other)     :24861   NA's   :52             NA's   :54

Figures
=======

``` r
ggplot(data = stations, aes(x = ELEV.M, y = ELEV.M.SRTM.90m.NO_BUFFER)) +
  geom_point(alpha = 0.4, size = 0.5)
```

![GSOD Reported Elevation versus CGIAR-CSI SRTM Elevation](fetch_isd-history_files/figure-markdown_github/SRTM%2090m%20vs%20Reported%20Elevation-1.png)

``` r
ggplot(data = stations, aes(x = ELEV.M, y = ELEV.M.SRTM.90m.BUFFER)) +
  geom_point(alpha = 0.4, size = 0.5)
```

![GSOD Reported Elevation versus CGIAR-CSI SRTM Buffered Elevation](fetch_isd-history_files/figure-markdown_github/Buffered%20SRTM%2090m%20vs%20Reported%20Elevation-1.png)

``` r
stations <- dplyr::mutate(stations, DIFFERENCE =
                            ELEV.M.SRTM.90m.NO_BUFFER - ELEV.M.SRTM.90m.BUFFER)
stations$DIFFERENCE[stations$DIFFERENCE >= -10 & stations$DIFFERENCE <= 10] <- NA

ggplot(data = stations, aes(x = LON, y = LAT)) +
  geom_point(aes(alpha = (DIFFERENCE)), size = 0.08) +
  labs(alpha = "NB - B") +
  coord_proj()
```

![CGIAR-CSI SRTM Buffered Elevation versus CGIAR-CSI SRTM 90m](fetch_isd-history_files/figure-markdown_github/SRTM%2090m%20vs%20Buffered%20SRTM%2090m-1.png)

Assuming that a 10m difference in elevation between the buffered and unbuffered is not important. Setting any values with a difference of &gt;= -10 and &lt;=10 to `NA`; the results are still not geographically clustered in any one location or feature.

``` r
ggplot(data = stations) +
  geom_histogram(aes(ELEV.M.SRTM.90m.NO_BUFFER - ELEV.M.SRTM.90m.BUFFER))
```

![Histogram plot of CGIAR-CSI SRTM Buffered Elevation versus CGIAR-CSI SRTM 90m](fetch_isd-history_files/figure-markdown_github/Hist%20difference%20SRTM%2090m%20vs%20Buffered%20SRTM%2090m-1.png)

The differences between the buffered and unbuffered elevation checks are minor and appear to be normally distributed while also not showing any discernable geographic pattern. However, The buffered elevation data are higher than the unbuffered data. To help avoid within cell and between cell variation the buffered values are the values that are included in the final data for distribution with the GSODR package following the approach of Hijmans *et al.* (2005). The new field is simply called ELEV.M.SRTM.90m in the stations.rda file.

    ## [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE

Notes
=====

NOAA Policy
-----------

Users of these data should take into account the following (from the [NCDC website](http://www7.ncdc.noaa.gov/CDO/cdoselect.cmd?datasetabbv=GSOD&countryabbv=&georegionabbv=)):

> "The following data and products may have conditions placed on their international commercial use. They can be used within the U.S. or for non-commercial international activities without restriction. The non-U.S. data cannot be redistributed for commercial purposes. Re-distribution of these data by others must provide this same notification." [WMO Resolution 40. NOAA Policy](http://www.wmo.int/pages/about/Resolution40.html)

R System Information
--------------------

    ## R version 3.3.0 (2016-05-03)
    ## Platform: x86_64-apple-darwin15.5.0 (64-bit)
    ## Running under: OS X 10.11.5 (El Capitan)
    ## 
    ## locale:
    ## [1] en_AU.UTF-8/en_AU.UTF-8/en_AU.UTF-8/C/en_AU.UTF-8/en_AU.UTF-8
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] ggalt_0.1.1   ggplot2_2.1.0
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_0.12.5        formatR_1.4        RColorBrewer_1.1-2
    ##  [4] plyr_1.8.4         tools_3.3.0        digest_0.6.9      
    ##  [7] memoise_1.0.0      evaluate_0.9       gtable_0.2.0      
    ## [10] lattice_0.20-33    DBI_0.4-1          curl_0.9.7        
    ## [13] yaml_2.1.13        rgdal_1.1-10       parallel_3.3.0    
    ## [16] withr_1.0.1        dplyr_0.4.3        stringr_1.0.0     
    ## [19] raster_2.5-8       knitr_1.13         maps_3.1.0        
    ## [22] devtools_1.11.1    grid_3.3.0         R6_2.1.2          
    ## [25] rmarkdown_0.9.6    sp_1.2-3           readr_0.2.2       
    ## [28] magrittr_1.5       scales_0.4.0       htmltools_0.3.5   
    ## [31] MASS_7.3-45        assertthat_0.1     proj4_1.0-8       
    ## [34] countrycode_0.18   colorspace_1.2-6   labeling_0.3      
    ## [37] KernSmooth_2.23-15 ash_1.0-15         stringi_1.1.1     
    ## [40] lazyeval_0.2.0     munsell_0.4.3

References
==========

Hijmans, RJ, SJ Cameron, JL Parra, PG Jones, A Jarvis, 2005, Very High Resolution Interpolated Climate Surfaces for Global Land Areas. *International Journal of Climatology*. 25: 1965-1978. [DOI:10.1002/joc.1276](http://dx.doi.org/10.1002/joc.1276)

Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m Database (<http://srtm.csi.cgiar.org>)

Jarvis, A, J Rubiano, A Nelson, A Farrow and M Mulligan, 2004, Practical use of SRTM Data in the Tropics: Comparisons with Digital Elevation Models Generated From Cartographic Data. Working Document no. 198. Cali, CO. International Centre for Tropical Agriculture (CIAT): 32. [URL](http://srtm.csi.cgiar.org/PDF/Jarvis4.pdf)
