#' Download and Return a data.table Object of GSOD Weather Station Data Inventories
#'
#' The \acronym{NCEI} maintains a document,
#' <https://www1.ncdc.noaa.gov/pub/data/noaa/isd-inventory.txt>, which lists
#' the number of weather observations by station-year-month from the beginning
#' of the stations' records.  This function retrieves that document and prints
#' an information header displaying the last update time with a data frame of
#' the inventory information for each station-year-month.
#'
#' @note While \CRANpkg{GSODR} does not distribute GSOD weather data, users of
#' the data should note the conditions that the U.S. \acronym{NCEI} places upon
#' the \acronym{GSOD} data.
#' \dQuote{The following data and products may have conditions placed on their
#'  international commercial use.  They can be used within the U.S. or for non-
#'  commercial international activities without restriction.  The non-U.S. data
#'  cannot be redistributed for commercial purposes.  Re-distribution of these
#'  data by others must provide this same notification.  A log of IP addresses
#'  accessing these data and products will be maintained and may be made
#'  available to data providers.}
#'
#' @examplesIf interactive()
#' inventory <- get_inventory()
#' inventory
#'
#' @return A `GSODR.info` object, which inherits from [data.table::data.table].
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @family metadata
#' @autoglobal
#' @export get_inventory

get_inventory <- function() {
  load(system.file("extdata", "isd_history.rda", package = "GSODR")) # nocov
  setkeyv(isd_history, "STNID")

  tryCatch(
    {
      curl::curl_download(
        "https://www1.ncdc.noaa.gov/pub/data/noaa/isd-inventory.txt.z",
        destfile = file.path(tempdir(), "inventory.txt"),
        quiet = TRUE
      )

      main_body <-
        fread(
          file.path(tempdir(), "inventory.txt"),
          skip = 8,
          col.names = c(
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
        )

      main_body[, STNID := paste(main_body$USAF, main_body$WBAN, sep = "-")]
      setkeyv(main_body, "STNID")

      main_body[, c("USAF", "WBAN") := NULL]

      setcolorder(main_body, "STNID")

      header <-
        readLines(file.path(tempdir(), "inventory.txt"), n = 6)

      # sift out the year and month
      year_month <- grep("[0-9]{4}", header)

      year_month <-
        tools::toTitleCase(tolower(gsub(
          "^([^\\D]*\\d+).*", "\\1",
          header[[year_month]]
        )))
      year_month <- gsub("Through ", "", year_month)
      year_month <- gsub("\\..*", "", year_month)

      main_body <- isd_history[main_body, on = "STNID"]

      class(main_body) <- c("GSODR.Info", class(main_body))

      # add attributes for printing df
      attr(main_body, "GSODR.Inventory") <- c(
        "  *** FEDERAL CLIMATE COMPLEX INTEGRATED SURFACE DATA INVENTORY ***  \n",
        "  This inventory provides the number of weather observations by  \n",
        "  STATION-YEAR-MONTH for beginning of record through", year_month, " \n"
      )
    },
    error = function(cond) {
      stop(
        "There was a problem retrieving the inventory file. Perhaps \n",
        "the server is not responding currently or there is no \n",
        "Internet connection. Please try again later.",
        call. = FALSE
      )
    }
  )

  unlink(file.path(tempdir(), "inventory.txt"))
  return(main_body)
}

#' Prints GSODR.info object
#'
#' @param x GSODR.Info object
#' @param ... ignored
#' @export
print.GSODR.Info <- function(x, ...) {
  cat(attr(x, "GSODR.Inventory"))
  NextMethod(x)
  invisible(x)
}
