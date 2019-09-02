
#' Tidy and return a data frame of \acronym{GSOD} weather from local storage
#'
#' This function automates cleaning and reformatting of \acronym{GSOD} station
#' files in\cr "YEAR.tar.gz", provided that they have been untarred or
#' "STATION.csv" format that have been downloaded from the #' United States
#' National Center for Environmental Information's (\acronym{NCEI})
#' download page. Three new elements; saturation vapour pressure (es), actual
#' vapour pressure (ea) and relative humidity are calculated and returned in the
#' final data.  All units are converted to International System of Units (SI),
#' \emph{e.g.}, Fahrenheit to Celsius and inches to millimetres.
#'
#' Parallel processing can be enabled using \code{\link[future]{plan}} to set
#' up a parallel backend of your choice, \emph{e.g.},
#' \code{future::plan("multisession")}.  See examples for more.
#'
#' @param dsn User supplied file path to location of data files on local disk
#' for tidying.
#' @param file_list User supplied list of files of data on local disk for
#' tidying.
#'
#' @details
#' If multiple stations are given, data are summarised for each year by station,
#' which include vapour pressure and relative humidity elements calculated from
#' existing data in \acronym{GSOD}.  Else, single stations are tidied and a data
#' frame is returned.
#'
#' All missing values in resulting files are represented as \code{NA} regardless
#' of which field they occur in.
#'
#' Only station files in the original "csv" file format are supported by this
#' function.  If you have downloaded the full annual "YYYY.tar.gz" file you
#' will need to extract the individual station files from the tar file first to
#' use this function.
#'
#' Note that \code{reformat_GSOD()} will attempt to reformat any ".csv" files
#' found in the \code{dsn} that you provide.  If there are non-GSOD files present
#' this will lead to errors.
#'
#' For a complete list of the fields and description of the contents and units,
#' please refer to Appendix 1 in the \pkg{GSODR} vignette,
#' \code{vignette("GSODR", package = "GSODR")}.
#'
#' @note While \pkg{GSODR} does not distribute \acronym{GSOD} weather data,
#' users of the data should note the conditions that the U.S. \acronym{NCEI}
#' places upon the \acronym{GSOD} data.
#' \dQuote{The following data and products may have conditions placed on
#' their international commercial use.  They can be used within the U.S. or for
#' non-commercial international activities without restriction. The non-U.S.
#' data cannot be redistributed for commercial purposes. Re-distribution of
#' these data by others must provide this same notification.}
#'
#' @seealso
#' For automated downloading and tidying see the \code{\link{get_GSOD}}
#' function which provides expanded functionality for automatically downloading
#' and expanding annual \acronym{GSOD} files and cleaning station files.
#'
#' @examples
#' \donttest{
#'
#' # Download data to 'tempdir()'
#' download.file(
#'   url =
#'     "https://www.ncei.noaa.gov/data/global-summary-of-the-day/access/2010/95551099999.csv",
#'   destfile = file.path(tempdir(), "95551099999.csv"),
#'   mode = "wb"
#' )
#'
#' # Reformat station data files in R's tempdir() directory
#' tbar <- reformat_GSOD(dsn = tempdir())
#'
#' tbar
#' }
#'
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#'
#' @return A data frame as a \code{\link[data.table]{data.table}} object of
#' \acronym{GSOD} data.
#'
#' @seealso \code{\link{get_GSOD}}
#'
#' @export reformat_GSOD

reformat_GSOD <- function(dsn = NULL, file_list = NULL) {
  isd_history <- NULL # nocov
  load(system.file("extdata", "isd_history.rda", package = "GSODR")) # nocov
  setkeyv(isd_history, "STNID")

  # If dsn !NULL, create a list of files to reformat
  if (!is.null(dsn)) {
    file_list <- list.files(path = dsn,
                            pattern = "^.*\\.csv$",
                            full.names = TRUE)
    if (length(file_list) == 0)
      stop("No files were found, please check your file location.")
  }
  GSOD_XY <- .apply_process_csv(file_list, isd_history)
  return(GSOD_XY)
}
