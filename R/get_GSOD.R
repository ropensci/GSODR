#' Download, Clean, Reformat and Generate New Variables From GSOD Weather Data
#'
#'This function automates downloading, cleaning, reformatting of data from
#'the Global Surface Summary of the Day (GSOD) data provided by the US National
#'Climatic Data Center (NCDC),
#'\url{https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod},
#'and calculates three new variables; Saturation Vapor Pressure (ES) – Actual
#'Vapor Pressure (EA) and relative humidity (RH). Stations are individually
#'checked for number of missing days to assure data quality, stations with too
#'many missing observations are omitted. Additionally, stations reporting a
#'latitude of < -90 or > 90 or longitude of < -180 or > 180 are removed. All
#'units are converted to International System of Units (SI), e.g., Fahrenheit to
#'Celsius and inches to millimetres. Alternative elevation measurements are
#'supplied for missing values or values found to be questionable based on the
#'Consultative Group for International Agricultural Research's Consortium for
#'Spatial Information group's (CGIAR-CSI) Shuttle Radar Topography Mission 90
#'metre (SRTM 90m) digital elevation data based on NASA's original SRTM 90m
#'data. Further information on these data and methods can be found on GSODR's
#'GitHub repository here:
#'\url{https://github.com/adamhsparks/GSODR/blob/master/data-raw/fetch_isd-history.md}
#'
#' @param years Year(s) of weather data to download.
#' @param station Specify a station or multiple stations for which to retrieve,
#' check and clean weather data. The NCDC reports years for which the data are
#' available. This function checks against these years. However, not all cases
#' are properly documented and in some cases files may not exist on the ftp
#' server even though it is indicated that data was recorded for the station for
#' a particular year. If a station is specified that does not have an
#' existing file on the server, this function will silently fail and move on
#' to existing files for download and cleaning from the ftp server.
#' @param country Specify a country of interest for which to retrieve weather
#' data; full name. For stations located in locales
#' having an ISO code 2 or 3 letter ISO code can also be used if known. See
#' \code{\link{country_list}} for a full list of country names and ISO
#' codes available.
#' @param dsn Path to file write to. (Optional)
#' @param filename The filename for resulting file(s) to be written with no
#' file extension. Year and file extension will be automatically appended to
#' file outputs. Defaults to "GSOD-year". (Optional)
#' @param max_missing The maximum number of days allowed to be missing from a
#' station's data before it is excluded from final file output. Defaults to five
#' days. If a single station is specified, this option is ignored and any data
#' available, even an empty file, from NCDC will be returned.
#' @param agroclimatology Logical. Only clean data for stations between
#' latitudes 60 and -60 for agroclimatology work, defaults to FALSE. Set to
#' TRUE to include only stations within the confines of these
#' latitudes.
#' @param CSV Logical. If set to TRUE, create a comma separated value (CSV)
#' file ile and save it locally in a user specified location. Depends on
#' \code{dsn} being specified.
#' @param GPKG Logical. If set to TRUE, create a GeoPackage file and save it
#' locally in a user specified location. Depends on \code{dsn} being specified.
#'
#' @details
#' Data summarize each year by station, which include vapour pressure and
#' relative humidity variables calculated from existing data in GSOD.
#'
#' If the option to save locally is selected. Output may be saved as comma-
#' separated, CSV, files or GeoPackage files in a directory specified by the
#' user, defaulting to the current working directory.
#'
#' When querying selected stations and electing to write files to disk, all
#' years queried and stations queried will be merged into one final ouptut file.
#'
#' All missing values in resulting files are represented as NA regardless of
#' which field they occur in.
#'
#'For more information see the description of the data provided by NCDC,
#'\url{http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt}.
#'
#' The CSV or GeoPackage in the respective year-directory will contain the
#' following fields/values:
#' \describe{
#' \item{STNID}{Station number (WMO/DATSAV3 number) for the location}
#' \item{WBAN}{number where applicable--this is the historical "Weather Bureau
#' Air Force Navy" number - with WBAN being the acronym}
#' \item{STN_NAME}{Unique text identifier}
#' \item{CTRY}{Country in which the station is located}
#' \item{LAT}{Latitude. *Station dropped in cases where values are < -90 or
#'> 90 degrees or Lat = 0 and Lon = 0* (WGS84)}
#' \item{LON}{Longitude. *Station dropped in cases where values are < -180 or
#'> 180 degrees or Lat = 0 and Lon = 0* (WGS84)}
#' \item{ELEV_M}{Elevation in metres}
#' \item{ELEV_M_SRTM_90m}{Elevation in metres corrected for possible errors,
#' derived from the CGIAR-CSI SRTM 90m database (Jarvis et al. 2008)}
#' \item{YEARMODA}{Date in YYYY-mm-dd format}
#' \item{YEAR}{The year (YYYY)}
#' \item{MONTH}{The month (mm)}
#' \item{DAY}{The day (dd)}
#' \item{YDAY}{Sequential day of year (not in original GSOD)}
#' \item{TEMP}{Mean daily temperature converted to degrees C to tenths.
#' Missing = NA}
#' \item{TEMP_CNT}{Number of observations used in calculating mean daily
#' temperature}
#' \item{DEWP}{Mean daily dew point converted to degrees C to tenths. Missing
#' = NA}
#' \item{DEWP_CNT}{Number of observations used in calculating mean daily dew
#' point}
#' \item{SLP}{Mean sea level pressure in millibars to tenths. Missing =   NA}
#' \item{SLP_CNT}{Number of observations used in calculating mean sea level
#' pressure}
#' \item{STP}{Mean station pressure for the day in millibars to tenths.
#' Missing = NA}
#' \item{STP_CNT}{Number of observations used in calculating mean station
#' pressure}
#' \item{VISIB}{Mean visibility for the day converted to kilometres to
#' tenths Missing = NA}
#' \item{VISIB_CNT}{Number of observations used in calculating mean daily
#' visibility}
#' \item{WDSP}{Mean daily wind speed value converted to metres/second to
#' tenths Missing = NA}
#' \item{WDSP_CNT}{Number of observations used in calculating mean daily
#' wind speed}
#' \item{MXSPD}{Maximum sustained wind speed reported for the day converted
#' to metres/second to tenths. Missing = NA}
#' \item{GUST}{Maximum wind gust reported for the day converted to
#' metres/second to tenths. Missing = NA}
#' \item{MAX}{Maximum temperature reported during the day converted to
#' Celsius to tenths--time of max temp report varies by country and region,
#' so this will sometimes not be the max for the calendar day. Missing =
#' NA}
#' \item{MAX_FLAG}{Blank indicates max temp was taken from the explicit max
#' temp report and not from the 'hourly' data. An "\*" indicates max temp was
#' derived from the hourly data (i.e., highest hourly or synoptic-reported
#' temperature)}
#' \item{MIN}{Minimum temperature reported during the day converted to
#' Celsius to tenths--time of min temp report varies by country and region,
#' so this will sometimes not be the max for the calendar day. Missing =
#' NA}
#' \item{MIN_FLAG}{Blank indicates max temp was taken from the explicit max
#' temp report and not from the 'hourly' data. An "\*" indicates min temp was
#' derived from the hourly data (i.e., highest hourly or synoptic-reported
#' temperature)}
#' \item{PRCP}{Total precipitation (rain and/or melted snow) reported during
#' the day converted to millimetres to hundredths; will usually not end
#' with the midnight observation, i.e., may include latter part of previous
#' day. A ".00" value indicates no measurable precipitation (includes a trace).
#' Missing = NA; *Note: Many stations do not report '0' on days with no
#' precipitation-- therefore, 'NA' will often appear on these days. For
#' example, a station may only report a 6-hour amount for the period during
#' which rain fell.* See FLAGS_PRCP column for source of data}
#' \item{PRCP_FLAG}{
#'   \describe{
#'    \item{A}{1 report of 6-hour precipitation amount}
#'    \item{B}{Summation of 2 reports of 6-hour precipitation amount}
#'    \item{C}{Summation of 3 reports of 6-hour precipitation amount}
#'    \item{D}{Summation of 4 reports of 6-hour precipitation amount}
#'    \item{E}{1 report of 12-hour precipitation amount}
#'    \item{F}{Summation of 2 reports of 12-hour precipitation amount}
#'    \item{G}{1 report of 24-hour precipitation amount}
#'    \item{H}{Station reported '0' as the amount for the day (e.g., from
#'    6-hour reports), but also reported at least one occurrence of
#'    precipitation in hourly observations--this could indicate a trace
#'    occurred, but should be considered as incomplete data for the day}
#'    \item{I}{Station did not report any precip data for the day and did not
#'    report any occurrences of precipitation in its hourly observations--it's
#'    still possible that precipitation occurred but was not reported}
#'   }
#' }
#' \item{SNDP}{Snow depth in millimetres to tenths. Missing = NA}
#' \item{I_FOG}{Indicator for fog, (1 = yes, 0 = no/not reported) for the
#' occurrence during the day}
#' \item{I_RAIN_DRIZZLE}{Indicator for rain or drizzle, (1 = yes, 0 = no/not
#' reported) for the occurrence during the day}
#' \item{I_SNOW_ICE}{Indicator for snow or ice pellets, (1 = yes, 0 = no/not
#' reported) for the occurrence during the day}
#' \item{I_HAIL}{Indicator for hail, (1 = yes, 0 = no/not reported) for the
#' occurrence during the day}
#' \item{I_THUNDER}{Indicator for thunder, (1 = yes, 0 = no/not reported)
#' for the occurrence during the day}
#' \item{I_TORNADO_FUNNEL}{Indicator for tornado or funnel cloud, (1 = yes, 0 =
#' no/not reported) for the occurrence during the day}
#'\item{ea}{Mean daily actual vapour pressure}
#' \item{es}{Mean daily saturation vapour pressure}
#' \item{RH}{Mean daily relative humidity}
#' }
#'
#' @note Some of these data are redistributed with this R package. Originally
#' from these data come from the US NCDC which states that users of these data
#' should take into account the following: \dQuote{The following data and
#' products may have conditions placed on their international commercial use.
#' They can be used within the U.S. or for non-commercial international
#' activities without restriction. The non-U.S. data cannot be redistributed for
#' commercial purposes. Re-distribution of these data by others must provide
#' this same notification.}
#'
#' @examples
#' \dontrun{
#' # Download weather station for Toowoomba, Queensland for 2010
#' t <- get_GSOD(years = 2010, station = "955510-99999")
#'
#' # Download data for Philippines for year 2010 and generate a yearly
#' # summary GeoPackage file, GSOD-RP-2010.gpkg, file in the user's home
#' directory with a maximum of five missing days per station allowed.
#'
#' get_GSOD(years = 2010, country = "Philippines", dsn = "~/",
#' filename = "Philippines_GSOD", GPKG = TRUE, CSV = FALSE)
#'
#' # Download global GSOD data for agroclimatology work for years 2009 and 2010
#' # and generate yearly summary files, GSOD-agroclimatology-2010.csv and
#' # GSOD-agroclimatology-2011.csv in the user's home directory with a maximum
#' # of five missing days per weather station allowed.
#'
#' get_GSOD(years = 2010:2011, dsn = "~/",
#' filename = "GSOD_agroclimatology_2010-2011", agroclimatology = TRUE)
#'
#' }
#'
#' @references {Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled
#' SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m Database
#' \url{http://srtm.csi.cgiar.org}}
#'
#' @importFrom data.table :=
#'
#' @export
get_GSOD <- function(years = NULL, station = NULL, country = NULL,
                     dsn = NULL, filename = "GSOD", max_missing = 5,
                     agroclimatology = FALSE, CSV = FALSE, GPKG = FALSE) {

  # Set up options, create objects, fetch most recent station metadata ---------
  original_options <- options()
  options(warn = 2)
  options(timeout = 300)

  td <- tempdir()

  ftp <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/"

  # Validate -------------------------------------------------------------------
  # Check data path given by user, does it exist? Is it properly formatted?
  if (!is.null(dsn)) {
    dsn <- .validate_dsn(dsn)
  }

  # fetch most recent station history file
  if (!exists("stations")) {
    stations <- .fetch_station_list()
  }

  # Check years given by the user, are they valid?
  .validate_years(years)

  # Check station given by user and check that years for this station are valid
  if (!is.null(station)) {
    .validate_station(station, stations)
    .validate_station_years(station, stations, years)
  }

  # Check country given by user and format for use in function
  if (!is.null(country)) {
    country <- .get_country(country)
  }

  # By default, if a single station is selected, then we will report even just
  # one day of data if that's all that is recorded
  if (!is.null(station)) {
    max_missing <- 366
  }

  # Download and process data --------------------------------------------------
  # Agroclimatology, Country or Global
  if (is.null(station)) {
    message("\nDownloading the data file(s) now.")
    file_list <- paste0(ftp, years, "/", "gsod_", years, ".tar")
    GSOD_XY <- plyr::ldply(.data = file_list, .fun = .dl_global_files,
                            agroclimatology = agroclimatology,
                            country = country, stations = stations,
                            td = td, years = years, .progress = "text")
  } else {
    # Individual stations
    message("\nDownloading the station file(s) now.")
    file_list <- paste0(ftp, years, "/")
    file_list <- do.call(paste0, c(expand.grid(file_list, station)))
    file_list <- paste0(file_list, "-", years, ".op.gz")
    GSOD_XY <- plyr::ldply(.data = file_list, .fun = .dl_specified_stations,
                           stations = stations, td = td, .progress = "text")
  }

  return(GSOD_XY)

  # cleanup and reset to default state
  unlink(td)
  options(original_options)
}
