#' Download, Clean, Reformat and Generate New Variables From GSOD Weather Data
#'
#'This function automates downloading, cleaning, reformatting of data from
#'the Global Surface Summary of the Day (GSOD) data provided by the US National
#'Climatic Data Center (NCDC),
#'\url{https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod},
#'and calculates three new variables; Saturation Vapor Pressure (ES) – Actual
#'Vapor Pressure (EA) and relative humidity (RH). Stations reporting a latitude
#'of < -90 or > 90 or longitude of < -180 or > 180 are removed. Stations may be
#'individually checked for number of missing days to assure data quality and
#'omitting stations with too many missing observations. All units are converted
#'to International System of Units (SI), e.g., Fahrenheit to Celsius and inches
#'to millimetres. Alternative elevation measurements are supplied for missing
#'values or values found to be questionable based on the Consultative Group for
#'International Agricultural Research's Consortium for Spatial Information
#'group's (CGIAR-CSI) Shuttle Radar Topography Mission 90 metre (SRTM 90m)
#'digital elevation data based on NASA's original SRTM 90m data. Further
#'information on these data and methods can be found on GSODR's GitHub
#'repository here:
#'\url{https://github.com/adamhsparks/GSODR/blob/master/data-raw/fetch_isd-history.md}
#'
#' @param years Year(s) of weather data to download.
#' @param station Optional. Specify a station or multiple stations for which to
#' retrieve, check and clean weather data. The NCDC reports years for which the
#' data are available. This function checks against these years. However, not
#' all cases are properly documented and in some cases files may not exist on
#' the ftp server even though it is indicated that data was recorded for the
#' station for a particular year. If a station is specified that does not have
#' an existing file on the server, this function will silently fail and move on
#' to existing files for download and cleaning from the ftp server.
#' @param country Optional. Specify a country for which to retrieve weather
#' data; full name or ISO codes can be used. See
#' \code{\link{country_list}} for a full list of country names and ISO
#' codes available.
#' @param CSV Optional. Logical. If set to TRUE, create a comma separated value
#' (CSV) file and save it locally in a user specified location. Depends on
#' \code{dsn} and \code{filename} being specified.
#' @param GPKG Optional. Logical. If set to TRUE, create a GeoPackage file and
#' save it locally in a user specified location. Depends on
#' \code{dsn} and \code{filename} being specified.
#' @param dsn Optional. Local file path to write file out to. Must be specified
#' if CSV or GPKG parameters are selected. Depends on \code{CSV} and/or
#' \code{GPKG} being set to TRUE and \code{filename} being specified.
#' @param filename Optional. The filename for resulting file(s) to be written
#' with no file extension. File extension will be automatically appended to file
#' outputs. Depends on \code{CSV} and/or \code{GPKG} set to TRUE and
#' \code{filename} being specified.
#' @param max_missing Optional. The maximum number of days allowed to be missing
#' from a station's data before it is excluded from final file output.
#' @param agroclimatology Optional. Logical. Only clean data for stations
#' between latitudes 60 and -60 for agroclimatology work, defaults to FALSE.
#' Set to TRUE to include only stations within the confines of these
#' latitudes.
#'
#' @details
#' Data summarise each year by station, which include vapour pressure and
#' relative humidity variables calculated from existing data in GSOD.
#'
#' If the option to save locally is selected. Output may be saved as comma-
#' separated, CSV, files or GeoPackage, GPKG, files in a directory specified by
#' the user, defaulting to the current working directory.
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
#' The data returned either in a data.frame object or a file written to local
#' disk include the followig fields:
#' \describe{
#' \item{STNID}{Station number (WMO/DATSAV3 number) for the location}
#' \item{WBAN}{Number where applicable--this is the historical "Weather Bureau
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
#' \item{SLP}{Mean sea level pressure in millibars to tenths. Missing = NA}
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
#' # summary GeoPackage file, Philippines_GSOD-2010.gpkg, file in the user's
#' home directory with a maximum of five missing days per station allowed.
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
#'
#' @export
get_GSOD <- function(years = NULL, station = NULL, country = NULL,
                     dsn = NULL, filename = NULL, max_missing = NULL,
                     agroclimatology = FALSE, CSV = FALSE, GPKG = FALSE) {
  
  # set up options, create objects, fetch most recent station metadata ---------
  original_options <- options()
  options(warn = 2)
  options(timeout = 300)
  td <- tempdir()
  
  LON <- LAT <- NULL
  ftp <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/"
  
  # validate years -------------------------------------------------------------
  this_year <- 1900 + as.POSIXlt(Sys.Date())$year
  if (is.null(years) | is.character(years)) {
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
  
  # if file outs are specified, check that everything is in place --------------
  if (isTRUE(CSV) | isTRUE(GPKG)) {
    if (is.null(dsn)) {
      stop("\nYou must supply a valid file path (dsn) for storing the resulting
           file(s).\n")
    } else {
        dsn <- trimws(dsn)
    }
    
    if (is.null(CSV) | is.null(GPKG)) {
      stop("\nYou must supply a valid file format (CSV or GPKG) for storing the
           resulting file(s).\n")
    } else {
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
    }
    if (substr(dsn, nchar(dsn), nchar(dsn)) != "/" &
        substr(dsn, nchar(dsn), nchar(dsn)) != "\\") {
      dsn <- paste0(dsn, "/")
    }
    outfile <- paste0(dsn, filename)
  }
  
  
  # fetch latest station metadata from NCDC server -----------------------------
  if (!exists("stations")) {
    stations <- .fetch_stations()
  }
  
  # check station integrity ----------------------------------------------------
  if (!is.null(station)) {
    if (!station %in% stations[[12]]) {
      stop("\nThis is not a valid station ID number, please check your entry.
         \nStation IDs are provided as a part of the GSODR package in the
         'stations' data\nin the STNID column.\n")
    }
    # check station years in station listing
    for (vsy in station) {
      BEGIN <- as.numeric(substr(stations[stations[[12]] == vsy]$BEGIN, 1, 4))
      END <- as.numeric(substr(stations[stations[[12]] == vsy]$END, 1, 4))
      if (min(years) < BEGIN | max(years) > END)
        message("This station, ", vsy, ", only provides data for years ", BEGIN,
                " to ", END, ".\n")
    }
  }
  
  
  # if country supplied, check and return letter code for filtering data ------
  if (!is.null(country)) {
    country <- toupper(trimws(country[1]))
    nc <- nchar(country)
    if (nc == 3) {
      if (country %in% GSODR::country_list$iso3c) {
        c <- which(country == GSODR::country_list$iso3c)
        country <- GSODR::country_list[[c, 1]]
      } else {
        stop("\nPlease provide a valid name or 2 or 3 letter ISO country code; you
           can view the entire list of valid countries in this data by typing,
           'country_list'.\n")
      }
    } else if (nc == 2) {
      if (country %in% GSODR::country_list$iso2c) {
        c <- which(country == GSODR::country_list$iso2c)
        country <- GSODR::country_list[[c, 1]]
      } else {
        stop("\nPlease provide a valid name or 2 or 3 letter ISO country code;
              you can view the entire list of valid countries in this data by
              typing, 'country_list'.\n")
      }
    } else if (country %in% GSODR::country_list$COUNTRY_NAME) {
      c <- which(country == GSODR::country_list$COUNTRY_NAME)
      country <- GSODR::country_list[[c, 1]]
    } else {
      stop("\nPlease provide a valid name or 2 or 3 letter ISO country code;
              you can view the entire list of valid countries in this data by
              typing, 'country_list'.\n")
    }
  }
  
  
  # download complete tar files ------------------------------------------------
  if (is.null(station)) {
    file_list <- paste0(ftp, years, "/", "gsod_", years, ".tar")
    tryCatch(Map(function(ftp, dest)
      utils::download.file(url = ftp, destfile = dest),
      file_list, file.path(td, basename(file_list))), error = function(x) stop(
        "\nThe file downloads have failed. Please restart.\n"))
    
    tar_files <- list.files(td, pattern = "^gsod.*\\.tar$", full.names = TRUE)
    
    plyr::ldply(.data = tar_files, .fun = utils::untar, exdir = td)
    
    GSOD_list <- list.files(td, pattern = "^.*\\.op.gz$", full.names = TRUE)
  }
  
  # download specific station files --------------------------------------------
  if (!is.null(station)) {
    message("\nDownloading the station file(s) now.")
    file_list <- paste0(ftp, years, "/")
    file_list <- do.call(paste0, c(expand.grid(file_list, station)))
    file_list <- paste0(file_list, "-", years, ".op.gz")
    
    tryCatch(Map(function(ftp, dest)
      utils::download.file(url = ftp, destfile = dest),
      file_list, file.path(td, basename(file_list))),
      error = function(x) message(paste0(
        "\nThe file downloads have failed. Please restart.\n")))
    
    GSOD_list <- list.files(path = td, pattern = "^.*\\.op.gz$",
                            full.names = TRUE)
  }
  
  # check for max_missing ------------------------------------------------------
  if (!is.null(max_missing)) {
    records <- lapply(data = paste0(td, "/", GSOD_list), R.utils::countLines)
    names(records) <- GSOD_list
    year <- as.numeric(gsub("[^0-9]", "", GSOD_list[1]))
    
    ifelse(format(as.POSIXct(paste0(year, "-03-01")) - 1, "%d") != "29",
           allow <- 365 - max_missing,
           allow <- 366 - max_missing)
    
    GSOD_list <- stats::na.omit(ifelse(records >= allow, paste0(GSOD_list),
                                       NA))
  }
  
  # if agroclimatology is set TRUE, subset list of stations to process--------------
  if (agroclimatology == TRUE) {
    station_list <- stations[stations$LAT >= -60 &
                               stations$LAT <= 60, ]$STNID
    station_list <- do.call(paste0,
                            c(expand.grid(td, "/", station_list, "-", years,
                                          ".op.gz")))
    GSOD_list <- GSOD_list[GSOD_list %in% station_list == TRUE]
    rm(station_list)
  }
  
  # if country is set, subset list of stations to process ----------------------
  if (!is.null(country)) {
    country_FIPS <- unlist(as.character(stats::na.omit(
      GSODR::country_list[GSODR::country_list$FIPS == country, ][[1]]),
      use.names = FALSE))
    station_list <- stations[stations$CTRY == country_FIPS, ]$STNID
    station_list <- do.call(paste0,
                            c(expand.grid(td, "/", station_list, "-", years,
                                          ".op.gz")))
    GSOD_list <- GSOD_list[GSOD_list %in% station_list == TRUE]
    rm(station_list)
  }
  
  # clean and reformat list of station files from local disk in tempdir --------
  
  message("Starting data file processing")
  GSOD_XY <- as.data.frame(
        try(
          plyr::ldply(.data = GSOD_list, .fun = .process_gz,
                      stations = stations, .progress = "text")
        )
    )
  
  
  # Write files to disk --------------------------------------------------------
  
  # CSV file------------------------------------------------------------------
  if (CSV == TRUE) {
    outfile <- paste0(outfile, ".csv")
    readr::write_csv(GSOD_XY, path = paste0(outfile))
  }
  
  # GPKG file ----------------------------------------------------------------
  if (GPKG == TRUE) {
    outfile <- paste0(outfile, ".gpkg")
    # Convert object to standard df and then spatial object
    GSOD_XY <- as.data.frame(GSOD_XY)
    sp::coordinates(GSOD_XY) <- ~LON + LAT
    sp::proj4string(GSOD_XY) <- sp::CRS("+proj=longlat +datum=WGS84")
    
    # If the filename specified exists, remove it and create new
    if (file.exists(path.expand(outfile))) {
      file.remove(outfile)
    }
    # Create new .gpkg file
    rgdal::writeOGR(GSOD_XY, dsn = path.expand(outfile), layer = "GSOD",
                    driver = "GPKG")
  }
  
  return(GSOD_XY)
  
  # cleanup and reset to default state
  
  unlink(td)
  options(original_options)
}

