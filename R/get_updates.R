#' Get updates.txt With Information on Updates to the GSOD Data Set
#'
#' Gets and imports the 'updates.txt' file that has a change log of GSOD data.
#'   Changes are shown in order from most recent to oldest changes by the "DATE"
#'   field.  Column names follow \CRANpkg{GSODR} naming conventions.
#'
#'
#' @returns A [data.table::data.table()] object
#' @export
#' @autoglobal
#' @family metadata
#' @examplesIf interactive()
#' get_updates()
#'
get_updates <- function() {
  op <- options(timeout = 600L)
  on.exit(options(op))

  file_in <- file.path(tempdir(), "updates.txt")
  if (!file.exists(file_in)) {
    tryCatch(
      {
        utils::download.file(
          url = "https://www1.ncdc.noaa.gov/pub/data/noaa/updates.txt",
          destfile = file_in,
          mode = "wb",
          quiet = TRUE
        )
      },
      error = function(x) {
        stop(
          "The NCEI server with the update information is not responding. ",
          "Please retry again later.\n",
          call. = FALSE
        )
      }
    )
  }

  x <- data.table::setDT(
    utils::read.fwf(
      file = file_in,
      widths = c(7L, 5L, 5L, 11L, 25L),
      header = FALSE,
      comment.char = "",
      allowEscapes = TRUE,
      strip.white = TRUE,
      colClasses = "character",
      col.names = c("STATION", "WBAN", "YEAR", "DATE", "COMMENT")
    )
  )

  x[, STNID := sprintf("%s-%s", STATION, WBAN)]
  x[, c("STATION", "WBAN") := NULL]
  x[, YEAR := as.integer(YEAR)]
  x[, DATE := as.Date(DATE)]
  setorder(x, -DATE)
  setcolorder(x, c("STNID"))
  return(x[])
}
