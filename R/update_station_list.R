
#' Download the latest station list from the NCEI server and update internal database
#'
#' This function downloads the latest station list (isd-history.csv) from the
#' NCEI FTP server and updates the data distributed with \code{GSODR} so that
#' you have the latest list of stations available.  These data provide unique
#' identifiers, country, state (if in US), latitude, longitude, elevation and
#' when weather observations begin and end.  Stations with invalid latitude and
#' longitude values will not be included.
#'
#' There is no need to use this unless you know that a station exists in the
#' GSODR data that is not available in the database distributed with
#' \code{\link{GSODR}} in the \code{\link{isd_history}} data distributed with
#' \code{\link{GSODR}}.
#'
#' @examples
#' \dontrun{
#' update_station_list()
#' }
#' @return \code{\link[data.table]{data.table}} object of station metadata.
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#' @export
#'
update_station_list <- function() {
  original_timeout <- options("timeout")[[1]]
  options(timeout = 300)
  on.exit(options(timeout = original_timeout))

  old_isd_history <- isd_history

  # fetch new isd_history from NCEI server
  stations <- readr::read_csv(
    "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
    col_types = "ccccccddddd",
    col_names = c("USAF", "WBAN", "STN_NAME", "CTRY", "STATE", "CALL",
                  "LAT", "LON", "ELEV_M", "BEGIN", "END"), skip = 1)

  stations[stations == -999.9] <- NA
  stations[stations == -999] <- NA

  # clean data
  stations <- stations[!is.na(stations$LAT) & !is.na(stations$LON), ]
  stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
  stations <- stations[stations$LAT > -90 & stations$LAT < 90, ]
  stations <- stations[stations$LON > -180 & stations$LON < 180, ]
  stations$STNID <- as.character(paste(stations$USAF, stations$WBAN, sep = "-"))

  # left join the old and new data
  isd_history <- dplyr::left_join(
    old_isd_history,
    stations,
    by = c(
      "USAF" = "USAF",
      "WBAN" = "WBAN",
      "STN_NAME" = "STN_NAME",
      "CTRY" = "CTRY",
      "STATE" = "STATE",
      "CALL" = "CALL",
      "LAT" = "LAT",
      "LON" = "LON",
      "ELEV_M" = "ELEV_M",
      "BEGIN" = "BEGIN",
      "END" = "END",
      "STNID" = "STNID"
    )
  )

  isd_history <- data.table::setDT(isd_history)

  # overwrite the existing isd_history.rda file on disk
  pkg <- system.file(package = "GSODR")
  path <-
    file.path(file.path(pkg, "data"), paste0("isd_history.rda"))
  save(isd_history, file = path, compress = "bzip2")
  return(isd_history)
}
