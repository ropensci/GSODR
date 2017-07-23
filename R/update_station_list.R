
#' Download the latest station list from the NCEI server and update internal database
#'
#' This function downloads the latest station list (isd-history.csv) from the
#' NCEI FTP server and updates the data distributed with \code{GSODR} so that
#' you have the latest list of stations available.  These data provide unique
#' identifiers, country, state (if in US), latitude, longitude, elevation and
#' when weather observations begin and end.  Stations with invalid latitude and
#' longitude values will not be included.
#'
#' Care should be taken when using this function if reproducibility is necessary
#' as different machines with the same version of \code{GSODR} can end up with
#' different versions of the isd_history.csv file internally.
#'
#' There is no need to use this unless you know that a station exists in the
#' GSODR data that is not available in the database distributed with
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

  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  old_isd_history <- isd_history

  # fetch new isd_history from NCEI server
  new_isd_history <- readr::read_csv(
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
  new_isd_history[new_isd_history == -999.9] <- NA
  new_isd_history[new_isd_history == -999] <- NA
  new_isd_history <-
    new_isd_history[new_isd_history$LAT != 0 &
                      new_isd_history$LON != 0, ]
  new_isd_history <-
    new_isd_history[new_isd_history$LAT > -90 &
                      new_isd_history$LAT < 90, ]
  new_isd_history <-
    new_isd_history[new_isd_history$LON > -180 &
                      new_isd_history$LON < 180, ]
  new_isd_history$STNID <-
    as.character(paste(new_isd_history$USAF, new_isd_history$WBAN, sep = "-"))
  new_isd_history <- new_isd_history[!is.na(new_isd_history$LAT), ]
  new_isd_history <- new_isd_history[!is.na(new_isd_history$LON), ]

  # left join the old and new data

  isd_history <- dplyr::left_join(
    old_isd_history,
    new_isd_history,
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
  fname <- system.file("extdata", "isd_history.rda", package = "GSODR")
  save(isd_history, file = fname, compress = "bzip2")
}
