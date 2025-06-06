#' Download and Return a data.table Object of GSOD Weather Data
#'
#' @description
#' Automates downloading, cleaning, reformatting of data from the Global Surface
#' Summary of the Day (\acronym{GSOD}) data provided by the
#' [US National Centers for Environmental Information (NCEI)(https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00516),
#' Three additional useful elements: saturation vapour pressure (es), actual
#' vapour pressure (ea) and relative humidity (RH) are calculated and returned
#' in the final data frame using the improved August-Roche-Magnus approximation
#' (Alduchov and Eskridge 1996).
#'
#'
#' @details
#' All units are converted to International System of Units (SI), *e.g*,
#' Fahrenheit to Celsius and inches to millimetres.
#'
#' Data summarise each year by station, which include vapour pressure and
#' relative humidity elements calculated from existing data in \acronym{GSOD}.
#'
#' All missing values in resulting files are represented as `NA` regardless of
#'   which field they occur in.
#'
#' For a complete list of the fields and description of the contents and units,
#' please refer to Appendix 1 in the \CRANpkg{GSODR} vignette,
#' `vignette("GSODR", package = "GSODR")`.
#'
#' For more information see the description of the data provided by
#' \acronym{NCEI}, <https://www.ncei.noaa.gov/data/global-summary-of-the-day/doc/readme.txt>.
#'
#' @param years Year(s) of weather data to download.
#' @param station Optional.  Specify a station or multiple stations for which to
#' retrieve, check and clean weather data using \var{STATION}.  The
#' \acronym{NCEI} reports years for which the data are available.  This function
#' checks against these years.  However, not all cases are properly documented
#' and in some cases files may not exist for download even though it is
#' indicated that data was recorded for the station for a particular year.  If a
#' station is specified that does not have an existing file on the server, this
#' function will silently fail and move on to existing files for download and
#' cleaning.
#' @param country Optional.  Specify a country for which to retrieve weather
#' data; full name, 2 or 3 letter \acronym{ISO} or 2 letter \acronym{FIPS} codes
#' can be used.  All stations within the specified country will be returned.
#' @param max_missing Optional.  The maximum number of days allowed to be
#' missing from a station's data before it is excluded from final file output.
#' @param agroclimatology Optional.  Logical.  Only clean data for stations
#' between latitudes 60 and -60 for agroclimatology work, defaults to `FALSE`.
#' Set to `TRUE` to include only stations within the confines of these
#' latitudes.
#'
#' @note \CRANpkg{GSODR} attempts to validate year and station combination
#' requests, however, in certain cases the start and end date may encompass
#' years where no data is available.  In these cases no data will be returned.
#' It is suggested that the user check the latest data availability for the
#' station(s) desired using [get_inventory()] as this list is frequently
#' updated by the \acronym{NCEI} and is not shipped with \CRANpkg{GSODR}.
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
#' # Download weather station data for Toowoomba, Queensland for 2010
#' tbar <- get_GSOD(years = 2010, station = "955510-99999")
#'
#' # Download weather data for the year 1929
#' w_1929 <- get_GSOD(years = 1929)
#'
#' # Download weather data for the year 1929 for Ireland
#' ie_1929 <- get_GSOD(years = 1929, country = "Ireland")
#'
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#'
#' @section References:
#'
#' Alduchov, O.A. and Eskridge, R.E., 1996. Improved Magnus form approximation
#' of saturation vapor pressure. Journal of Applied Meteorology and Climatology,
#' 35(4), pp.601-609. DOI:
#' <10.1175%2F1520-0450%281996%29035%3C0601%3AIMFAOS%3E2.0.CO%3B2>.
#'
#' @returns A [data.table::data.table()] object of \acronym{GSOD} weather data.
#'
#' @seealso [reformat_GSOD()]
#' @autoglobal
#' @export get_GSOD

get_GSOD <- function(
  years,
  station = NULL,
  country = NULL,
  max_missing = NULL,
  agroclimatology = FALSE
) {
  # Validate user inputs -------------------------------------------------------
  .validate_years(years)
  # Validate stations for missing days -----------------------------------------
  if (!is.null(max_missing) && (is.na(max_missing) || max_missing < 1L)) {
    stop(
      call. = FALSE,
      "The `max_missing` parameter must be a positive",
      "value larger than 1."
    )
  }

  if (!is.null(max_missing) && (format(Sys.Date(), "%Y") %in% years)) {
    stop(
      call. = FALSE,
      "You cannot use `max_missing` with the current, incomplete year."
    )
  }

  if (isTRUE(agroclimatology) && !is.null(station)) {
    stop(
      call. = FALSE,
      "You cannot specify a single station along with agroclimatology."
    )
  }

  # Load station list
  load(system.file("extdata", "isd_history.rda", package = "GSODR")) # nocov

  if (!is.null(station)) {
    # Validate user entered stations for existence in stations list from NCEI
    invisible(lapply(
      X = station,
      FUN = .validate_station_id,
      isd_history = isd_history
    ))

    # Validate station data against years available. If years are requested w/o
    # data, an Warning and an `NA` is returned and removed here before passing
    # the modified vector to `.download_files()`
    station <- lapply(
      X = station,
      FUN = .validate_station_data_years,
      isd_history = isd_history,
      years = years
    )
    station <- station[!is.na(station)]
  }

  # Download files from server -------------------------------------------------
  file_list <- .download_files(station, years)

  # Subset file_list for agroclimatology only stations -------------------------
  if (isTRUE(agroclimatology)) {
    file_list <-
      .agroclimatology_list(file_list, isd_history, years)
  }

  # Subset file_list for specified country -------------------------------------
  if (!is.null(country)) {
    # Load country list
    # CRAN NOTE avoidance

    country <- .validate_country(country, isd_history)

    file_list <-
      .subset_country_list(
        country = country,
        isd_history = isd_history,
        file_list = file_list,
        years = years
      )
  }

  # Validate stations for missing days -----------------------------------------
  if (!is.null(max_missing)) {
    file_list <-
      .validate_missing_days(max_missing, file_list)
    if (length(file_list) == 0L) {
      stop(
        call. = FALSE,
        "There were no stations that had a max of ",
        max_missing,
        " days."
      )
    }
  }

  GSOD <- .apply_process_csv(file_list, isd_history)

  # remove any leftover files from download to prevent polluting a new run
  file.remove(list.files(tempdir(), pattern = ".csv$", full.names = TRUE))

  return(GSOD)
}
