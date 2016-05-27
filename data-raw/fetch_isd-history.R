
# title: fetch_isd-history.R
#
# description: This script will fetch station data from the ftp server and
# clean up for inclusion in package in /data/stations.rda for the GSODR package

# Users of these data should take into account the following (from the NCDC
# website): "The following data and products may have conditions placed on
# their international commercial use. They can be used within the U.S. or for
# non-commercial international activities without restriction. The non-U.S.
# data cannot be redistributed for commercial purposes. Re-distribution of
# these data by others must provide this same notification."

# Reference
# 90m hole filled SRTM files from Jarvis et al. (2008)
# http://www.ncdc.noaa.gov/cgi-bin/res40.pl?page=gsod.html
# Jarvis A., H.I. Reuter, A. Nelson, E. Guevara, 2008, Hole-filled seamless SRTM
# data V4, International Centre for Tropical Agriculture (CIAT), available from
# http://srtm.csi.cgiar.org.

# Correction for altitude methodology from Van Etten (2011)
# http://rpackages.ianhowson.com/rforge/gsod/man/stations.html

#### import data ---------------------------------------------------------------
stations <- as.data.frame(readr::read_csv(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
  col_types = "ccccccddddd",
  col_names = c("USAF", "WBAN", "STN.NAME", "CTRY", "STATE", "CALL",
                "LAT", "LON", "ELEV.M", "BEGIN", "END"), skip = 1,
  na = c("-999.9", "-999.0")))

dem_tiles <- list.files(path.expand("~/Data/Jarvis_SRTM"), full.names = TRUE)

#### format data
stations <- stations[!is.na(stations$LAT) & !is.na(stations$LON), ]
stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
stations <- stations[stations$LAT > -90 & stations$LAT < 90, ]
stations <- stations[stations$LON > -180 & stations$LON < 180, ]
stations$STNID <- paste(stations$USAF, stations$WBAN, sep = "-")

sp::coordinates(stations) <- ~ LON + LAT
sp::proj4string(stations) <- sp::CRS(" +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 ")

#### Loop to check and correct altitude for stations ---------------------------
for (i in dem_tiles) {
  # Load the DEM tile
  dem <- raster::raster(list.files(paste0(i, "/"), pattern = glob2rx("*.tif"),
                                   full.names = TRUE))
  sub_stations <- raster::crop(stations, dem)
  gI <- raster::extract(dem, sub_stations)

  sub_stations <- as.data.frame(sub_stations)
  sub_stations$ELEV.M.COR <- gI

  # if original elevation == 0 and DEM indicates difference >= 15m, use DEM
  sub_stations[, 13] <- ifelse(sub_stations[, 9] == 0 &
                                 sub_stations[, 13] >= sub_stations[, 9] + 15,
                               sub_stations[, 13],
                               sub_stations[, 9])

  # if original elevation > 0 and DEM indicates difference <= / >= 50m, use DEM
  sub_stations[, 13] <- ifelse(sub_stations[, 9] > 0 &
                                 sub_stations[, 13] >= sub_stations[, 9] + 50 |
                                 sub_stations[, 13] >= sub_stations[, 9] - 50,
                               sub_stations[, 13],
                               sub_stations[, 9])

  # if DEM elevation == NA, use original elevation
  sub_stations[, 13] <- ifelse(is.na(sub_stations[, 13]) & !is.na(sub_stations[, 9]),
                               sub_stations[, 9], sub_stations[, 13])

  # build data frame here
}

devtools::use_data(stations, overwrite = TRUE)
