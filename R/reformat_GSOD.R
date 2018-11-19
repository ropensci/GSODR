
#' Tidy and Return a Data Frame of \acronym{GSOD} Weather from Local Data
#'
#' This function automates cleaning and reformatting of \acronym{GSOD} station
#' files in\cr "WMO-WBAN-YYYY.op.gz" format that have been downloaded from the
#' United States National Center for Environmental Information's
#' (\acronym{NCEI}) \acronym{FTP} server. Three new elements; saturation vapour
#' pressure (es), actual vapour pressure (ea) and relative humidity are
#' calculated and returned in the final data as well.  All units are converted
#' to International System of Units (SI), \emph{e.g.} Fahrenheit to Celsius and
#' inches to millimetres.  Alternative elevation measurements are supplied for
#' missing values or values found to be questionable based on the Consultative
#' Group for International Agricultural Research's Consortium for Spatial
#' Information group's (\acronym{CGIAR-CSI}) Shuttle Radar Topography Mission 90
#' metre (\acronym{SRTM} 90m) digital elevation data based on \acronym{NASA}'s
#' original \acronym{SRTM} 90m data.
#'
#' Parallel processing can be enabled using \code{\link[future]{plan}} to set
#' up a parallel backend of your choice, e.g.,
#' \code{future::plan(multisession)}.  See examples for more.
#'
#' @param dsn User supplied file path to location of data files on local disk
#' for tidying.
#' @param file_list User supplied list of files of data on local disk for
#' tidying.
#'
#' @details
#' If multiple stations are given, data are summarised for each year by station,
#' which include vapour pressure and relative humidity elements calculated from
#' existing data in \acronym{GSOD}. Else, single stations are tidied and a data
#' frame is returned.
#'
#' All missing values in resulting files are represented as \code{NA} regardless
#' of which field they occur in.
#'
#' Only station files in the original ".op.gz" file format are supported by this
#' function.  If you have downloaded the full annual "gsod_YYYY.tar" file you
#' will need to extract the individual station files from the tar file first to
#' use this function.
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
#' download.file(url =
#'	  "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/2010/955510-99999-2010.op.gz",
#'      	destfile = file.path(tempdir(), "955510-99999-2010.op.gz"),
#'      	mode = "wb")
#'
#' # Reformat station data files in R's tempdir() directory
#' tbar <- reformat_GSOD(dsn = tempdir())
#'
#' tbar
#' }
#'
#' @author Adam H Sparks, \email{adamhsparks@@gmail.com}
#'
#' @references {Jarvis, A., Reuter, H.I, Nelson, A., Guevara, E. (2008)
#' Hole-filled SRTM for the globe Version 4, available from the CGIAR-CSI SRTM
#' 90m Database \url{http://srtm.csi.cgiar.org}}
#'
#' @return A data frame as a \code{\link[tibble]{tibble}} object of weather
#' data.
#'
#' @seealso \code{\link{get_GSOD}}
#'
#' @importFrom magrittr %>%
#'
#' @export reformat_GSOD

reformat_GSOD <- function(dsn = NULL, file_list = NULL) {
  isd_history <- NULL # nocov
  load(system.file("extdata", "isd_history.rda", package = "GSODR")) # nocov

  # If dsn !NULL, create a list of files to reformat
  if (!is.null(dsn)) {
    file_list <- list.files(path = dsn,
                            pattern = "^.*\\.op.gz$",
                            full.names = TRUE)
    if (length(file_list) == 0)
      stop("No files were found, please check your file location.")
  }
  GSOD_XY <- apply_process_gz(file_list, isd_history)
}
