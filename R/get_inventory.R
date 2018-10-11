
#' Download and Return a Tidy Data Frame of \acronym{GSOD} Weather Station Data Inventories
#'
#' The \acronym{NCEI} maintains a document,
#' \url{ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-inventory.txt}, which lists
#' the number of weather observations by station-year-month from the beginning
#' of the stations' records.  This function retrieves that document and prints
#' an information header displaying the last update time with a data frame of
#' the inventory information for each station-year-month.
#'
#' @note The \acronym{GSOD} data, which are downloaded and manipulated by
#' \pkg{GSODR}, stipulate that the following notice should be given.
#' \dQuote{The following data and products may have conditions placed on their
#' international commercial use.  They can be used within the U.S. or for non-
#' commercial international activities without restriction.  The non-U.S. data
#' cannot be redistributed for commercial purposes.  Re-distribution of these
#' data by others must provide this same notification.}
#'
#' @examples
#' \donttest{
#' inventory <- get_inventory()
#' inventory
#'}
#' @return A data frame as a \code{\link[tibble]{tibble}} object of station
#' inventories
#' @author Adam H Sparks, \email{adamhsparks@@gmail.com}
#' @note The download process can take quite some time to complete.
#' @importFrom rlang .data
#' @export get_inventory
#'
get_inventory <- function() {

  load(system.file("extdata", "isd_history.rda", package = "GSODR"))

  ftp_handle <-
    curl::new_handle(
      ftp_use_epsv = FALSE,
      crlf = TRUE,
      ssl_verifypeer = FALSE,
      ftp_response_timeout = 30,
      ftp_skip_pasv_ip = TRUE
    )

  file_in <-
    curl::curl_download(
      "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-inventory.txt",
      destfile = tempfile(),
      quiet = TRUE,
      handle = ftp_handle
    )

  main_body <-
    readr::read_fwf(
      file_in,
      skip = 8,
      readr::fwf_positions(
        c(1, 8, 14, 20, 28, 36, 44, 52, 60, 68, 76, 84, 92, 100, 108),
        c(7, 13, 18, 27, 35, 43, 51, 59, 67, 75, 83, 91, 99, 107, 113),
        c(
          "USAF",
          "WBAN",
          "YEAR",
          "JAN",
          "FEB",
          "MAR",
          "APR",
          "MAY",
          "JUN",
          "JUL",
          "AUG",
          "SEP",
          "OCT",
          "NOV",
          "DEC"
        )
      ),
      col_types = c("ciiiiiiiiiiiiii")
    )

  main_body[, "STNID"] <- paste(main_body$USAF, main_body$WBAN, sep = "-")

  main_body <- main_body[, -c(1:2)]

  main_body <- dplyr::select(main_body, .data$STNID, dplyr::everything())

  header <- readLines(file_in, n = 5)

  # sift out the year and month
  year_month <- grep("[0-9]{4}", header)

  year_month <- tools::toTitleCase(
    tolower(
      gsub("^([^\\D]*\\d+).*", "\\1", header[[year_month]])
    )
  )
  year_month <- gsub("Through ", "", year_month)

  class(main_body) <- c("GSODR.Info", class(main_body))

  # add attributes for printing df
  attr(main_body, "GSODR.Inventory") <- c(
    "   *** FEDERAL CLIMATE COMPLEX INTEGRATED SURFACE DATA INVENTORY ***   \n",
    "   This inventory provides the number of weather observations by   \n",
    "   STATION-YEAR-MONTH for beginning of record through", year_month, "   \n"
  )

  return(main_body)
  unlink(tempfile())
}

#' Prints GSODR.info object.
#'
#' @param x GSODR.info object
#' @param ... ignored
#' @export
print.GSODR.Info <- function(x, ...) {
  cat(attr(x, "GSODR.Inventory"))
  NextMethod(x)
  invisible(x)
}
