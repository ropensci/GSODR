
#' Download and Return a Tidy Data Frame of GSOD Weather Station Data Inventories
#'
#' The NCEI maintains a document,
#' <ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-inventory.txt>, which shows the
#' number of weather observations by station-year-month from the beginning of
#' the stations' records.  This function retrieves that document, prints the
#' header to display the last update time and returns a data frame of the
#' inventory information for each station-year-month.
#'
#' @note The GSOD data, which are downloaded and manipulated by this R package,
#' stipulate that the following notice should be given.  \dQuote{The following
#' data and products may have conditions placed on their international
#' commercial use.  They can be used within the U.S. or for non-commercial
#' international activities without restriction.  The non-U.S. data cannot be
#' redistributed for commercial purposes.  Re-distribution of these data by
#' others must provide this same notification.}
#'
#' @examples
#' \dontrun{
#' inventory <- get_inventory()
#'}
#' @return A data frame as a tibble \code{\link[tibble]{tibble}} object of
#' station inventories
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#' @note The download process can take quite some time to complete.
#' @importFrom rlang .data
#' @export
#'
get_inventory <- function() {
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))

  file_in <-
    curl::curl_download(
      "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-inventory.txt",
      destfile = tempfile(),
      quiet = FALSE
    )

  header <- readLines(file_in, n = 5)

  message(paste0(header[3:5], collapse = " "))

  body <-
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

  body[, "STNID"] <- paste(body$USAF, body$WBAN, sep = "-")

  body <- body[, -c(1:2)]

  body <- dplyr::select(body, .data$STNID, dplyr::everything())
  return(body)
  unlink(tempfile())
}
