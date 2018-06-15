
#' Download and Return a Tidy Data Frame of GSOD Weather Data
#'
#' @description
#' This function automates downloading, cleaning, reformatting of data from
#' the Global Surface Summary of the Day (GSOD) data provided by the
#' \href{https://data.noaa.gov/dataset/dataset/global-surface-summary-of-the-day-gsod/}{US National Centers for Environmental Information (NCEI)},
#' Three additional useful elements: saturation vapour pressure (es), actual
#' vapour pressure (ea) and relative humidity (RH) are calculated and returned
#' in the final data frame.
#'
#' @details
#' Stations reporting a latitude of < -90 or > 90 or longitude of < -180 or >
#' 180 are removed. Stations may be individually checked for number of
#' missing days to assure data quality and omitting stations with too many
#' missing observations.
#'
#' All units are converted to International System of Units (SI), \emph{e.g.}
#' Fahrenheit to Celsius and inches to millimetres.
#'
#' Alternative elevation measurements are supplied for missing values or values
#' found to be questionable based on the Consultative Group for International
#' Agricultural Research's Consortium for Spatial Information group's
#' (CGIAR-CSI) Shuttle Radar Topography Mission 90 metre (SRTM 90m) digital
#' elevation data based on NASA's original SRTM 90m data. Further information
#' on these data and methods can be found on GSODR's
#' \href{https://github.com/ropensci/GSODR/blob/master/data-raw/fetch_isd-history.md}{GitHub repository}.
#'
#' Data summarise each year by station, which include vapour pressure and
#' relative humidity elements calculated from existing data in GSOD.
#'
#' All missing values in resulting files are represented as \code{NA} regardless
#' of which field they occur in.
#'
#' For a complete list of the fields and description of the contents and units,
#' please refer to Appendix 1 in the GSODR vignette,
#' \code{vignette("GSODR", package = "GSODR")}.
#'
#' For more information see the description of the data provided by NCEI,
#'\url{http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt}.
#' @note While \pkg{GSODR} does not distribute GSOD weather data, users of
#' the data should note the conditions that the U.S. NCEI places upon the GSOD
#' data.  \dQuote{The following data and products may have conditions placed on
#' their international commercial use.  They can be used within the U.S. or for
#' non-commercial international activities without restriction. The non-U.S.
#' data cannot be redistributed for commercial purposes. Re-distribution of
#' these data by others must provide this same notification.}

#'
#' @param years Year(s) of weather data to download.
#' @param station Optional. Specify a station or multiple stations for which to
#' retrieve, check and clean weather data using \code{STNID}. The NCEI reports
#' years for which the data are available. This function checks against these
#' years. However, not all cases are properly documented and in some cases files
#' may not exist on the FTP server even though it is indicated that data was
#' recorded for the station for a particular year. If a station is specified
#' that does not have an existing file on the server, this function will
#' silently fail and move on to existing files for download and cleaning from
#' the FTP server.
#' @param country Optional. Specify a country for which to retrieve weather
#' data; full name or ISO codes can be used.
#' @param max_missing Optional. The maximum number of days allowed to be missing
#' from a station's data before it is excluded from final file output.
#' @param agroclimatology Optional. Logical. Only clean data for stations
#' between latitudes 60 and -60 for agroclimatology work, defaults to FALSE.
#' Set to TRUE to include only stations within the confines of these
#' latitudes.
#'
#' @examples
#' \dontrun{
#' # Download weather station for Toowoomba, Queensland for 2010
#' t <- get_GSOD(years = 2010, station = "955510-99999")
#'
#' # Download data for Philippines for year 2010 with a maximum of five missing
#' days per station allowed.
#'
#' get_GSOD(years = 2010, country = "Philippines", max_missing = 5)
#'
#' # Download global GSOD data for agroclimatology work for years 2009 and 2010
#'
#' get_GSOD(years = 2010:2011, agroclimatology = TRUE)
#' }
#'
#' @author Adam H Sparks, \email{adamhsparks@@gmail.com}
#'
#' @references {Jarvis, A., Reuter, H. I, Nelson, A., Guevara, E. (2008)
#' Hole-filled SRTM for the globe Version 4, available from the CGIAR-CSI SRTM
#' 90m Database \url{http://srtm.csi.cgiar.org}}
#'
#' @return A data frame as a \code{\link[tibble]{tibble}} object of weather
#' data.
#'
#' @seealso
#' \code{\link{reformat_GSOD}}
#'
#' @importFrom magrittr %>%
#' @export
get_GSOD <- function(years = NULL,
                     station = NULL,
                     country = NULL,
                     max_missing = NULL,
                     agroclimatology = FALSE) {
  # Create objects for use in retrieving files ---------------------------------
  original_timeout <- options("timeout")[[1]]
  options(timeout = 300)
  on.exit(options(timeout = original_timeout))
  cache_dir <- tempdir()
  ftp_base <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/%s/"
  # Validate user inputs -------------------------------------------------------
  .validate_years(years)
  # Validate stations for missing days -----------------------------------------
  if (!is.null(max_missing)) {
    if (is.na(max_missing) | max_missing < 1) {
      stop(call. = FALSE,
           "\nThe 'max_missing' parameter must be a positive",
           "value larger than 1\n")
    }
  }

  if (!is.null(max_missing))
  {
    if (format(Sys.Date(), "%Y") %in% years)
    {
      stop(call. = FALSE,
           "You cannot use `max_missing` with the current, incomplete year.")
    }
  }

  # CRAN NOTE avoidance
  isd_history <- NULL # nocov

  # Load station list
  load(system.file("extdata", "isd_history.rda", package = "GSODR")) # nocov

  # Load country list
  # CRAN NOTE avoidance
  country_list <- NULL # nocov
  load(system.file("extdata", "country_list.rda", package = "GSODR")) # nocov

  # Validate user entered stations for existence in stations list from NCEI
  purrr::walk(
    .x = station,
    .f = .validate_station,
    isd_history = isd_history,
    years = years
  )
  country <- .validate_country(country, country_list)

  # Download files from server -----------------------------------------------
  GSOD_list <- .download_files(ftp_base, station, years, cache_dir)

  # Subset GSOD_list for agroclimatology only stations -----------------------
  if (isTRUE(agroclimatology)) {
    GSOD_list <-
      .agroclimatology_list(GSOD_list, isd_history, cache_dir, years)
  }

  # Subset GSOD_list for specified country -------------------------------------
  if (!is.null(country)) {
    GSOD_list <-
      .subset_country_list(country,
                           country_list,
                           GSOD_list,
                           isd_history,
                           cache_dir,
                           years)
  }

  # Validate stations for missing days -----------------------------------------
  if (!is.null(max_missing)) {
    GSOD_list <-
      .validate_missing_days(max_missing, GSOD_list)
  }

  # Clean and reformat list of station files from local disk in tempdir --------
  GSOD_XY <- purrr::map(.x = GSOD_list,
                        .f = .process_gz,
                        isd_history = isd_history)  %>%
    dplyr::bind_rows()

  # Cleanup --------------------------------------------------------------------
  files <-
    list.files(
      cache_dir,
      ignore.case = TRUE,
      include.dirs = TRUE,
      full.names = TRUE,
      recursive = TRUE,
      pattern = ".gz$"
    )
  unlink(files, force = TRUE, recursive = TRUE)
  rm(cache_dir)
  gc()
  return(GSOD_XY)
}
