# Validate years -------------------------------------------------------------
#' @noRd
.validate_years <- function(years) {
  this_year <- 1900 + as.POSIXlt(Sys.Date())$year
  if (is.null(years) & is.character(years)) {
    stop("\nYou must provide at least one year of data to download in a numeric
         format.\n")
  } else {
    for (i in years) {
      if (i <= 0) {
        stop("\nThis is not a valid year.\n")
      } else if (i < 1929) {
        stop("\nThe GSOD data files start at 1929, you have entered a year prior
             to 1929.\n")
      } else if (i > this_year) {
        stop("\nThe year cannot be greater than current year.\n")
      }
    }
  }
}


# If file outs are specified, check that everything is in place ----------------
#' @noRd
.validate_fileout <- function(CSV, dsn, filename, GPKG) {
  if (isTRUE(CSV) | isTRUE(GPKG)) {

    if (is.null(dsn)) {
      dsn <- getwd()
    } else {

      dsn <- trimws(dsn)
      if (substr(dsn, nchar(dsn) - 1, nchar(dsn)) == "//") {
        p <- substr(dsn, 1, nchar(dsn) - 2)
      } else if (substr(dsn, nchar(dsn), nchar(dsn)) == "/" |
                 substr(dsn, nchar(dsn), nchar(dsn)) == "\\") {
        p <- substr(dsn, 1, nchar(dsn) - 1)
      } else {
        p <- dsn
      }
      if (!file.exists(p) & !file.exists(dsn)) {
        stop("\nFile path does not exist: ", dsn, ".\n")
      }
      if (substr(dsn, nchar(dsn), nchar(dsn)) != "/" &
          substr(dsn, nchar(dsn), nchar(dsn)) != "\\") {
        dsn <- paste0(dsn, "/")
      }
      if (is.null(filename)) {
        filename <- "GSOD"
      }
    }

    outfile <- paste0(dsn, filename)
  }
}
