
#' Download latest station list information and update internal database
#'
#' This function downloads the latest station list (isd-history.csv) from the
#' \acronym{NCEI} \acronym{FTP} server and updates the data distributed with
#' \pkg{GSODR} to the latest stations available.  These data provide unique
#' identifiers, country, state (if in U.S.) and when weather observations begin
#'  and end.
#'
#' Care should be taken when using this function if reproducibility is necessary
#' as different machines with the same version of \pkg{GSODR} can end up with
#' different versions of the isd_history.csv file internally.
#'
#' There is no need to use this unless you know that a station exists in the
#' \pkg{GSODR} data that is not available in the self-contained database.
#'
#' To directly access these data, use: \cr
#' \code{load(system.file("extdata", "isd_history.rda", package = "GSODR"))}
#'
#' @examples
#' \dontrun{
#' update_station_list()
#' }
#'
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @export update_station_list

update_station_list <- function() {
  message(
    "This will overwrite GSODR's current internal list of GSOD stations.\n",
    "If reproducibility is necessary, you may not wish to proceed.\n",
    "Do you understand and wish to proceed (Y/n)?\n"
  )

  answer <-
    readLines(con = getOption("GSODR_connection"), n = 1)

  answer <- toupper(answer)

  if (answer != "Y" & answer != "YES") {
    stop("Station list was not updated.",
         call. = FALSE)
  }

  original_timeout <- options("timeout")[[1]]
  options(timeout = 300)
  on.exit(options(timeout = original_timeout))

  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  old_isd_history <- isd_history

  # fetch new isd_history from NCEI server
  new_isd_history <- fread(
    "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
    col.names = c(
      "STN_NAME",
      "CTRY",
      "STATE",
      "CALL",
      "LAT",
      "LON",
      "BEGIN",
      "END"
    ),
    skip = 1
  )

  # Replace -999.9 with NA
  for (col in names(new_isd_history)[names(new_isd_history) %in% c("ELEV_M")]) {
    set(
      new_isd_history,
      i = which(new_isd_history[[col]] == -999.9),
      j = col,
      value = NA
    )
  }

  # Replace -999 with NA
  for (col in names(new_isd_history)[names(new_isd_history) %in% c("ELEV_M")]) {
    set(
      new_isd_history,
      i = which(new_isd_history[[col]] == -999),
      j = col,
      value = NA
    )
  }

  new_isd_history <-
    new_isd_history[new_isd_history$LAT != 0 &
                      new_isd_history$LON != 0,]
  new_isd_history <-
    new_isd_history[new_isd_history$LAT > -90 &
                      new_isd_history$LAT < 90,]
  new_isd_history <-
    new_isd_history[new_isd_history$LON > -180 &
                      new_isd_history$LON < 180,]
  new_isd_history$STNID <-
    as.character(paste(new_isd_history$USAF, new_isd_history$WBAN, sep = "-"))
  new_isd_history <- new_isd_history[!is.na(new_isd_history$LAT),]
  new_isd_history <- new_isd_history[!is.na(new_isd_history$LON),]

  # left join the old and new data
  isd_history <- old_isd_history[new_isd_history,
                                 on = c(
                                   "NAME" = "STN_NAME",
                                   "CTRY" = "CTRY",
                                   "STATE" = "STATE",
                                   "CALL" = "CALL",
                                   "LAT" = "LAT",
                                   "LON" = "LON",
                                   "BEGIN" = "BEGIN",
                                   "END" = "END",
                                   "STNID" = "STNID"
                                 )]

  # overwrite the existing isd_history.rda file on disk
  fname <-
    system.file("extdata", "isd_history.rda", package = "GSODR")
  save(isd_history, file = fname, compress = "bzip2")
}
