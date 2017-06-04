
#' Clean, reformat and generate new variables from GSOD weather data
#'
#'This function automates cleaning and reformatting of GSOD,
#'\url{https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod},
#'station files in "WMO-WBAN-YYYY.op.gz" format that have been downloaded from
#' the United States National Center for Environmental Information's (NCEI)
#' FTP server.
#'
#'For automated downloading and processing see the \code{\link{get_GSOD}}
#'function which provides expanded functionality for automatically downloading
#'and expanding annual GSOD files and cleaning station files.
#'
#'This function reformats the data into a more usable form and calculates three
#'new elements; saturation vapour pressure (es), actual vapour pressure (ea) and
#'relative humidity (RH).  All units are converted to International System of
#'Units (SI), e.g., Fahrenheit to Celsius and inches to millimetres.
#'Alternative elevation measurements are supplied for missing values or values
#'found to be questionable based on the Consultative Group for International
#'Agricultural Research's Consortium for Spatial Information group's (CGIAR-CSI)
#'Shuttle Radar Topography Mission 90 metre (SRTM 90m) digital elevation data
#'based on NASA's original SRTM 90m data.
#'
#'@param dsn User supplied file path to location of station file data on
#'local disk for reformatting.
#'@param file_list User supplied list of files of station data on local disk for
#'reformatting.
#'
#' @details
#' Data summarise each year by station, which include vapour pressure and
#' relative humidity elements calculated from existing data in GSOD.
#'
#' All missing values in resulting files are represented as NA regardless of
#' which field they occur in.
#'
#' Only station files in ".op.gz" file format are supported by this function. If
#' you have downloaded the full annual "gsod_YYYY.tar" file you will need to
#' extract the individual station files first to use this function.
#'
#' For a complete list of the fields and desciption of the contents and units,
#' please refer to the \code{vignette("GSODR_output_fields", package = "GSODR")}.
#'
#' @note Some of these data are redistributed with this R package. Originally
#' from these data come from the US NCEI which states that users of these data
#' should take into account the following: \dQuote{The following data and
#' products may have conditions placed on their international commercial use.
#' They can be used within the U.S. or for non-commercial international
#' activities without restriction. The non-U.S. data cannot be redistributed for
#' commercial purposes. Re-distribution of these data by others must provide
#' this same notification.}
#'
#' @examples
#' \dontrun{
#'
#' # Reformat station data files in local directory
#' x <- reformat_GSOD(dsn = "~/tmp")
#'
#' # Reformat a list of data files
#' y <- c("~/GSOD/gsod_1960/200490-99999-1960.op.gz",
#'        "~/GSOD/gsod_1961/200490-99999-1961.op.gz")
#' x <- reformat_GSOD(file_list = y)
#' }
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#'
#' @references {Jarvis, A., Reuter, H.I, Nelson, A., Guevara, E. (2008)
#' Hole-filled SRTM for the globe Version 4, available from the CGIAR-CSI SRTM
#' 90m Database \url{http://srtm.csi.cgiar.org}}
#'
#' @return A \code{\link[base]{data.frame}} object of weather data or a
#' comma-separated value (CSV) or GeoPackage (GPKG) file saved to local disk.
#'
#' @seealso \code{\link{get_GSOD}}
#' 
#' @importFrom magrittr %>%
#' 
#' @export
#' 
reformat_GSOD <- function(dsn = NULL, file_list = NULL) {

  stations <- isd_history
  stations <- data.table::setDT(stations)

  # If dsn !NULL, create a list of files to reformat
  if (!is.null(dsn)) {
    file_list <- list.files(path = dsn,
                            pattern = "^.*\\.op.gz$",
                            full.names = TRUE)
  }
  purrr::map(
    .x = file_list,
    .f = .process_gz,
    stations = stations
  ) %>% 
    dplyr::bind_rows() %>% 
    as.data.frame()
}
