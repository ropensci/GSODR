#' Download the Latest Station List From the NCDC Server
#'
#' This function downloads the latest station list from the NCDC FTP server.
#' This list includes metadata for all stations including unique identifiers,
#' country, state (if in US), latitude, longitude, elevation and when weather
#' observations begin and end. Stations with invalid latitude and longitude
#' values will not be included.
#'
#' @examples
#' \dontrun{
#' GSOD_stations <- get_station_list()
#' }
#' @return \code{\link[data.table]{data.table}} object of station metadata.
#' @author Adam H Sparks \email{adamhsparks@gmail.com}
#' @export
#'
get_station_list <- function() {
  STNID <- NULL
  stations <- readr::read_csv(
    "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
    col_types = "ccccccddddd",
    col_names = c(
      "USAF",
      "WBAN",
      "STN_NAME",
      "CTRY",
      "STATE",
      "CALL",
      "LAT",
      "LON",
      "ELEV_M",
      "BEGIN",
      "END"
    ),
    skip = 1
  )
  stations[stations == -999.9] <- NA
  stations[stations == -999] <- NA
  stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
  stations <- stations[stations$LAT > -90 & stations$LAT < 90, ]
  stations <- stations[stations$LON > -180 & stations$LON < 180, ]
  stations$STNID <-
    as.character(paste(stations$USAF, stations$WBAN, sep = "-"))
  SRTM_GSOD_elevation <-
    data.table::setkey(GSODR::SRTM_GSOD_elevation, STNID)
  data.table::setDT(stations)
  data.table::setkey(stations, STNID)
  stations <- stations[SRTM_GSOD_elevation, on = "STNID"]
  stations <- stations[!is.na(stations$LAT), ]
  stations <- stations[!is.na(stations$LON), ]
  return(stations)
}
