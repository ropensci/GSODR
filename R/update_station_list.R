

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
  "STNID" <- "USAF" <- "WBAN" <- NULL

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
  # download data
  isd_history <-
    fread("ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")

  # add STNID column
  isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
  setcolorder(isd_history, "STNID")
  setnames(isd_history, "STATION NAME", "NAME")
  setkey(isd_history, "STNID")

  # remove extra columns
  isd_history[, c("USAF", "WBAN", "ELEV_M") := NULL]

  # write rda file to disk for use with GSODR package
  fname <-
    system.file("extdata", "isd_history.rda", package = "GSODR")
  save(isd_history,
       file = fname,
       compress = "bzip2",
       version = 2)
}
