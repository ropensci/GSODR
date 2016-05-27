
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

# import data ------------------------------------------------------------------
stations <- readr::read_csv(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
  col_types = "ccccccddddd",
  col_names = c("USAF", "WBAN", "STN.NAME", "CTRY", "STATE", "CALL",
                "LAT", "LON", "ELEV.M", "BEGIN", "END"), skip = 1,
  na = c("-999.9", "-999.0"))

stations <- stations[!is.na(stations$LAT) & !is.na(stations$LON), ]
stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
stations <- stations[stations$LAT > -90 & stations$LAT < 90, ]
stations <- stations[stations$LON > -180 & stations$LON < 180, ]
stations$STNID <- paste(stations$USAF, stations$WBAN, sep = "-")

devtools::use_data(stations, overwrite = TRUE)
