#' Download, Clean, Reformat and Generate New Variables From GSOD Weather Data
#'
#'This function automates downloading, cleaning, reformatting of data from
#'the Global Surface Summary of the Day (GSOD) data provided by the US National
#'Climatic Data Center (NCDC),
#'\url{https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod},
#'and calculates three new variables; Saturation Vapor Pressure (ES) – Actual
#'Vapor Pressure (EA) and relative humidity (RH). Stations are individually
#'checked for number of missing days to assure data quality, stations with too
#'many missing observations are omitted, stations with a latitude of < -90 or >
#'90 or longitude of < -180 or > 180 are removed. All units are converted to
#'International System of Units (SI), e.g., Fahrenheit to Celsius and inches to
#'millimetres. Alternative elevation measurements are supplied for missing
#'values or values found to be questionable based on the Consulatative Group
#'for International Agricultural Research's Consortium for Spatial Information
#'group's (CGIAR-CSI) Shuttle Radar Topography Mission 90 metre (SRTM 90m)
#'digital elevation data based on NASA's original SRTM 90m data. Further
#'information on these data and methods can be found on GSODR's GitHub
#'repository here: \url{https://github.com/adamhsparks/GSODR/blob/master/data-raw/fetch_isd-history.md}
#'
#' @param years Year(s) of weather data to download.
#' @param station Specify single station for which to retrieve, check and clean
#' weather data.
#' @param country Specify a country of interest for which to retrieve weather
#' data; full name. For stations located in locales
#' having an ISO code 2 or 3 letter ISO code can also be used if known. See
#' \code{\link{country_list}} for a full list of country names and ISO codes
#' available.
#' @param  path Path entered by user indicating where to store resulting
#' output file. Defaults to the current working directory.
#' @param max_missing The maximum number of days allowed to be missing from a
#' station's data before it is excluded from final file output. Defaults to five
#' days. If a single station is specified, this option is ignored and any data
#' available, even an empty file,from NCDC will be returned.
#' @param agroclimatology Only clean data for stations between latitudes 60 and
#' -60 for agroclimatology work, defaults to FALSE. Set to FALSE to override and
#' include only stations within the confines of these latitudes.
#' @param shapefile If set to TRUE, create an ESRI shapefile of vector type,
#' points, of the data for use in a GIS. Defaults to FALSE, no shapefile
#' created.
#' @param CSV If set to TRUE, create a comma separated value (CSV) file of data,
#' defaults to TRUE, a CSV file is created.
#' @param merge_station_years If set to TRUE, merge output files into one output
#' file for all years when selecting a single station, defaults to FALSE.
#'
#'
#' @details
#'Due to the size of the resulting data, output is saved as a comma-separated,
#'csv, file (default) or ESRI shapefile in a directory specified by the user or
#'defaults to the current working directory. The files summarize each year by
#'station, which includes vapour pressure and relative humidity variables
#'calculated from existing data in GSOD. Optionally, because the file sizes are
#'much smaller, when selecting a single station, all years queried may be
#'merged into one final ouptut file (CSV or shapefile) using the \code{
#'merge_station_years} option.
#'
#'All missing values in resulting files are represented as -9999
#'regardless of which field they occur in.
#'
#'Be sure to have disk space free and allocate the proper time for this to run.
#'This is a time, processor and disk input/output/space intensive process.
#'This function was largely based on T. Hengl's "getGSOD.R" script, available
#'from \url{http://spatial-analyst.net/book/system/files/getGSOD.R} with
#'enhancements to be cross-platform, faster and more flexible.
#'For more information see the description of the data provided by NCDC,
#'\url{http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt}.
#'
#' The CSV or ESRI format shapefile in the respective year-directory
#' will contain the following fields/values:
#' \describe{
#' \item{STNID}{Station number (WMO/DATSAV3 number) for the location}
#' \item{WBAN}{Number where applicable--this is the historical "Weather Bureau
#' Air Force Navy" number - with WBAN being the acronym}
#' \item{STN.NAME}{Unique text string identifier}
#' \item{CTRY}{Country}
#' \item{LAT}{Latitude}
#' \item{LON}{Longitude}
#' \item{ELEV.M}{Station reported elevation (metres to tenths)}
#' \item{ELEV.M.SRTM.90m}{Corrected elevation data in whole metres for stations
#' derived from Jarvis et al. (2008), extracted from DEM using reported LAT/LON
#' values in metres}
#' \item{YEARMODA}{Date in YYYY-MM-DD format}
#' \item{YEAR}{The year}
#' \item{MONTH}{The month}
#' \item{DAY}{The day}
#' \item{YDAY}{Sequential day of year (not in original GSOD)}
#' \item{TEMP}{Mean daily temperature converted to degrees C to tenths.
#' Missing = -9999}
#' \item{TEMP.CNT}{Number of observations used in calculating mean daily
#' temperature}
#' \item{DEWP}{Mean daily dew point converted to degrees C to tenths. Missing =
#' -9999}
#' \item{DEWP.CNT}{Number of observations used in calculating mean daily
#' dew point}
#' \item{SLP}{Mean sea level pressure in millibars to tenths. Missing =
#' -9999}
#' \item{SLP.CNT}{Number of observations used in calculating mean sea level
#' pressure}
#' \item{STP}{Mean station pressure for the day in millibars to tenths
#' Missing = -9999}
#' \item{STP.CNT}{Number of observations used in calculating mean station
#' pressure}
#' \item{VISIB}{Mean visibility for the day converted to kilometers to tenths
#' Missing = -9999}
#' \item{VISIB.CNT}{Number of observations used in calculating mean daily
#' visibility}
#' \item{WDSP}{Mean daily wind speed value converted to metres/second to tenths
#' Missing = -9999}
#' \item{WDSP.CNT}{Number of observations used in calculating mean daily
#' windspeed}
#' \item{MXSPD}{Maximum sustained wind speed reported for the day converted to
#' metres/second to tenths. Missing = -9999}
#' \item{GUST}{Maximum wind gust reported for the day converted to
#' metres/second to tenths. Missing = -9999}
#' \item{MAX}{Maximum temperature reported during the day converted to Celsius
#' to tenths--time of maximum temperature report varies by country and region,
#' so this will sometimes not be the maximum for the calendar day. Missing =
#' -9999}
#' \item{MAX.FLAG}{Blank indicates maximum temperature was taken from the
#' explicit maximum temperature report and not from the 'hourly' data. " * "
#' indicates maximum temperature was derived from the hourly data (i.e., highest
#' hourly or synoptic-reported temperature)}
#' \item{MIN}{Minimum temperature reported during the day converted to Celsius
#' to tenths--time of minimum temperature report varies by country and region,
#' so this will sometimes not be the minimum for the calendar day. Missing =
#' -9999}
#' \item{MIN.FLAG}{Blank indicates minimum temperature was taken from the
#' explicit minimum temperature report and not from the 'hourly' data. " * "
#' indicates minimum temperature was derived from the hourly data (i.e., lowest
#' hourly or synoptic-reported temperature)}
#' \item{PRCP}{Total precipitation (rain and/or melted snow) reported during
#' the day converted to millimetres to hundredths will usually not end with the
#' midnight observation--i.e., may include latter part of previous day. ".00"
#' indicates no measurable precipitation (includes a trace). Missing = -9999.
#' \emph{Note}: Many stations do not report '0' on days with no precipitation--
#' therefore, '-9999' will often appear on these days. For example, a
#' station may only report a 6-hour amount for the period during which rain
#' fell. See PRCP.FLAG column for source of data}
#' \item{PRCP.FLAG}{
#'  \describe{
#'    \item{A}{= 1 report of 6-hour precipitation amount}
#'    \item{B}{= Summation of 2 reports of 6-hour precipitation amount}
#'    \item{C}{= Summation of 3 reports of 6-hour precipitation amount}
#'    \item{D}{= Summation of 4 reports of 6-hour precipitation amount}
#'    \item{E}{= 1 report of 12-hour precipitation amount}
#'    \item{F}{= Summation of 2 reports of 12-hour precipitation amount}
#'    \item{G}{= 1 report of 24-hour precipitation amount}
#'    \item{H}{= Station reported '0' as the amount for the day (eg, from
#'    6-hour reports), but also reported at least one occurrence of
#'    precipitation in hourly observations--this could indicate a trace
#'    occurred, but should be considered as incomplete data for the day}
#'    \item{I}{= Station did not report any precipitation data for the day and
#'    did not report any occurrences of precipitation in its hourly
#'    observations. It's still possible that precipitation occurred but was not
#'    reported}
#'    }
#'  }
#' \item{SNDP}{Snow depth in millimetres to tenths. Missing = -9999}
#' \item{I.FOG}{Fog, (1 = yes, 0 = no/not reported) for the occurrence during
#' the day}
#' \item{I.RAIN_DZL}{Rain or drizzle, (1 = yes, 0 = no/not reported) for the
#' occurrence during the day}
#' \item{I.SNW_ICE}{Snow or ice pellets, (1 = yes, 0 = no/not reported) for the
#' occurrence during the day}
#' \item{I.HAIL}{Hail, (1 = yes, 0 = no/not reported) for the occurrence during
#' the day}
#' \item{I.THUNDER}{Thunder, (1 = yes, 0 = no/not reported) for the occurrence
#' during the #' day}
#' \item{I.TDO_FNL}{Tornado or funnel cloud, (1 = yes, 0 = no/not reported) for
#' the occurrence during the day}
#'}
#'
#' \emph{Values calculated by this package and included in final output:}
#' \describe{
#' \item{ea}{Mean daily actual vapour pressure}
#' \item{es}{Mean daily saturation vapour pressure}
#' \item{RH}{Mean daily relative humidity}
#'}
#'
#'@note Users of these data should take into account the following (from the
#' NCDC website): \dQuote{The following data and products may have conditions
#' placed on their international commercial use. They can be used within the
#' U.S. or for non-commercial international activities without restriction. The
#' non-U.S. data cannot be redistributed for commercial purposes.
#' Re-distribution of these data by others must provide this same
#' notification.}
#'
#' @examples
#' \dontrun{
#' # Download weather station for Toowoomba, Queensland for 2010, save resulting
#' # file, GSOD-955510-99999-2010.csv, in the user's home directory.
#'
#' get_GSOD(years = 2010, station = "955510-99999", path = "~/")
#'
#' # Download data for Philippines for year 2010 and generate a yearly
#' # summary file, GSOD-PHL-2010.csv, file in the user's home directory with a
#' # maximum of five missing days per station allowed.
#'
#' get_GSOD(years = 2010, country = "Philippines", path = "~/")
#'
#' # Download global GSOD data for agroclimatology work for years 2009 and 2010
#' # and generate yearly summary files, GSOD-agroclimatology-2010.csv and
#' # GSOD-agroclimatology-2011.csv in the user's home directory with a maximum
#' # of five missing days per weather station allowed.
#'
#' get_GSOD(years = 2010:2011, path = "~/", agroclimatology = TRUE)
#' }
#'
#'
#' @references {Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled
#' SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m Database
#' \url{http://srtm.csi.cgiar.org}}
#'
#' @importFrom foreach %dopar%
#' @importFrom foreach %do%
#'
#' @export
get_GSOD <- function(years = NULL, station = NULL, country = NULL, path = "",
                     max_missing = 5, agroclimatology = FALSE,
                     shapefile = FALSE, CSV = TRUE,
                     merge_station_years = FALSE) {

  # Set up options, creating objects, check variables entered by user-----------
  opt <- settings::options_manager(warn = 2, timeout = 300)

  utils::data("stations", package = "GSODR", envir = environment())
  stations <- get("stations", envir = environment())
  stations[, 12] <- as.character(stations[, 12])

  utils::data("country_list", package = "GSODR", envir = environment())
  country_list <- get("country_list", envir = environment())

  # Set up tempfile and directory for downloading data from server
  tf <- tempfile()
  td <- tempdir()

  # Create objects for use later
  yr <- NULL
  j <- NULL
  GSOD_objects <- list()

  # Check data path given by user, does it exist? Is it properly formatted?
  path <- .get_data_path(path)

  # Check years given by the user, are they valid?
  .validate_years(years)

  # Check station given by user, is it valid?
  if (!is.null(station)) {
    .validate_station(station)
  }

  # Check if user set merge to TRUE,
  # is there more than one year selected for the station?
  if (merge_station_years == TRUE) {
    .validate_merge(years, station)
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

  ftp_site <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/"

  # Loop if there are more than one year being queried ---------------------
  ity <- iterators::iter(years)
  foreach::foreach(yr = ity) %do% {
    if (is.null(station)) {

      tryCatch(curl::curl_download(url = paste0(ftp_site, yr, "/gsod_", yr, ".tar"),
                                   destfile = tf, quiet = FALSE, mode = "wb"),
               error = function(x) cat(paste0("\nThe download stoped at year ", yr,
                                              ".\nPlease restart the 'get_GSOD()' function starting at this point.\n")))
      utils::untar(tarfile = tf, exdir  = paste0(td, "/", yr, "/"))

      GSOD_list <- list.files(paste0(td, "/", yr, "/"),
                              pattern = utils::glob2rx("*.gz"),
                              full.names = FALSE)

      # If agroclimatology == TRUE, subset list of stations to clean
      if (agroclimatology == TRUE) {
        station_list <- stations[stations$LAT >= -60 &
                                   stations$LAT <= 60, ]$STNID
        station_list <- sapply(station_list,
                               function(x) rep(paste0(x, "-", yr, ".op.gz")))
        GSOD_list <- GSOD_list[GSOD_list %in% station_list == TRUE]
        rm(station_list)
      }

      # If country is set, subset list of stations to clean
      if (!is.null(country)) {
        country_FIPS <- unlist(as.character(stats::na.omit(
          country_list[country_list$iso3c == country, ][1])))
        station_list <- stations[stations$CTRY == country_FIPS, ]$STNID
        station_list <- sapply(station_list,
                               function(x) rep(paste0(x, "-", yr, ".op.gz")))

        GSOD_list <- GSOD_list[GSOD_list %in% station_list == TRUE]
        rm(station_list)
      }
    }

    # If a single station is selected---------------------- --------------------
    if (!is.null(station)) {
      tmp <- tryCatch(
        .read_gz(paste0(ftp_site, yr, "/", station, "-", yr, ".op.gz")),
        error = function(x) cat(paste0("\nThe download stoped at year ", yr,
                                       ".\nPlease restart the 'get_GSOD()' function starting at this point.\n")))
      if (merge_station_years == TRUE) {
        GSOD_objects[[yr]] <- .reformat(tmp, stations)
      } else {
        GSOD_XY <- .reformat(tmp, stations)
      }
      if (merge_station_years == FALSE) {
        GSOD_XY <- GSOD_XY
      }
    } else {
      cl <- parallel::makeCluster(parallel::detectCores() - 2)
      doParallel::registerDoParallel(cl)

      itx <- iterators::iter(GSOD_list)
      # For a country, the entire set or agroclimatology -----------------------
      GSOD_XY <- as.data.frame(
        data.table::rbindlist(
          foreach::foreach(j = itx) %dopar% {
            tmp <- try(.read_gz(paste0(td, "/", yr, "/", j)))
            if (.check(tmp, yr, max_missing) == FALSE) {
              .reformat(tmp, stations)
            }
          }
        )
      )
      parallel::stopCluster(cl)
    }

    #### Write to disk ---------------------------------------------------------
    if (!is.null(station)) {
      if (length(years) == 1) {
        outfile <- paste0("GSOD-", station, "-", yr)
      } else {
        outfile <- paste0("GSOD-", station, "-", min(years), "-to-",
                          max(years))
      }
    } else if (!is.null(country)) {
      outfile <- paste0("GSOD-", country, "-", yr)
    } else if (agroclimatology == TRUE) {
      outfile <- paste0("GSOD-agroclimatology-", yr)
    } else {
      outfile <- paste0("GSOD-", yr)
    }

    #### csv file---------------------------------------------------------------
    if (CSV == TRUE) {
      cat(noquote(paste0(paste0(names(GSOD_XY), collapse = ","), "\n")),
          file = paste0(path.expand(path), outfile, ".csv"))
      iotools::write.csv.raw(as.data.frame(GSOD_XY),
                             file = paste0(path.expand(path), outfile, ".csv"),
                             append = TRUE)
    }

    #### shapefile--------------------------------------------------------------
    if (shapefile == TRUE) {
      GSOD_XY <- as.data.frame(GSOD_XY) # convert tbl.df to dataframe for sp
      sp::coordinates(GSOD_XY) <- ~LON + LAT
      sp::proj4string(GSOD_XY) <- sp::CRS("+proj=longlat +datum=WGS84")
      rgdal::writeOGR(GSOD_XY, dsn = path.expand(path), layer = outfile,
                      driver = "ESRI Shapefile", overwrite_layer = TRUE)
    }
  }

  # cleanup and reset to default state
  unlink(tf)
  unlink(td)
  settings::reset(opt)
}

# Functions used within this package -------------------------------------------
# Check against maximum permissible missing days
.check <- function(tmp, yr, max_missing) {
  records <- nrow(tmp)
  if (lubridate::leap_year(yr) == FALSE) {
    allow <- 365 - max_missing
    !is.null(records) && length(records) == 1 && !is.na(records) &&
      records < allow
  } else {
    if (lubridate::leap_year(yr) == TRUE) {
      allow <- 366 - max_missing
      !is.null(records) && length(records) == 1 && !is.na(records) &&
        records < allow
    }
  }
}

# Reformat and generate new variables
.reformat <- function(tmp, stations) {
  GSOD_df <- NULL

  # add names to columns in data frame
  names(tmp) <- c("STN", "WBAN", "YEAR", "MODA", "TEMP", "TEMP.CNT",
                  "DEWP", "DEWP.CNT", "SLP", "SLP.CNT", "STP",
                  "STP.CNT", "VISIB", "VISIB.CNT", "WDSP", "WDSP.CNT",
                  "MXSPD", "GUST", "MAX", "MAX.FLAG", "MIN", "MIN.FLAG",
                  "PRCP", "PRCP.FLAG", "SNDP", "I.FOG", "I.RAIN_DZL",
                  "I.SNW_ICE", "I.HAIL", "I.THUNDER", "I.TDO_FNL")

  # Clean up and convert the station and weather data to metric
  tmp <- dplyr::mutate(tmp, STNID = paste(tmp$STN, tmp$WBAN, sep = "-"))
  tmp <- tmp[, -2]

  tmp <- dplyr::mutate(tmp, YEARMODA = paste(tmp$YEAR, tmp$MODA, sep = ""))
  tmp$MONTH <- stringr::str_sub(tmp$YEARMODA, 5, 6)
  tmp$DAY <- stringr::str_sub(tmp$YEARMODA, 7, 8)
  tmp$YDAY <- lubridate::yday(as.Date(paste(tmp$YEAR, tmp$MONTH, tmp$DAY,
                                            sep = "-")))

  tmp$TEMP <- ifelse(!is.na(tmp$TEMP), round( ( (5 / 9) * (tmp$TEMP - 32)), 1),
                     NA_integer_)
  tmp$DEWP <- ifelse(!is.na(tmp$DEWP), round( ( (5 / 9) * (tmp$DEWP - 32)), 1),
                     NA_integer_)
  tmp$WDSP <- ifelse(!is.na(tmp$WDSP), round(tmp$WDSP * 0.514444444, 1),
                     NA_integer_)
  tmp$MXSPD <- ifelse(!is.na(tmp$MXSPD), round(tmp$MXSPD * 0.514444444, 1),
                      NA_integer_)
  tmp$VISIB <- ifelse(!is.na(tmp$VISIB), round(tmp$VISIB * 1.60934, 1),
                      NA_integer_)
  tmp$WDSP <- ifelse(!is.na(tmp$WDSP), round(tmp$WDSP * 0.514444444, 1),
                     NA_integer_)
  tmp$GUST <- ifelse(!is.na(tmp$GUST), round(tmp$GUST * 0.514444444, 1),
                     NA_integer_)
  tmp$MAX <- ifelse(!is.na(tmp$MAX), round( (tmp$MAX - 32) * (5 / 9), 2),
                    NA_integer_)
  tmp$MIN <- ifelse(!is.na(tmp$MIN), round( (tmp$MIN - 32) * (5 / 9), 2),
                    NA_integer_)
  tmp$PRCP <- ifelse(!is.na(tmp$PRCP), round( (tmp$PRCP * 25.4), 1),
                     NA_integer_)
  tmp$SNDP <- ifelse(!is.na(tmp$SNDP), round( (tmp$SNDP * 25.4), 1),
                     NA_integer_)

  # Compute other weather vars--------------------------------------------------
  # Mean actual (EA) and mean saturation vapour pressure (ES)
  # Monteith JL (1973) Principles of environmental physics.
  #   Edward Arnold, London

  # EA derived from dew point
  tmp$EA <- round(0.61078 * exp( (17.2694 * tmp$DEWP) / (tmp$DEWP + 237.3)), 1)
  # ES derived from average temperature
  tmp$ES <- round(0.61078 * exp( (17.2694 * tmp$TEMP) / (tmp$TEMP + 237.3)), 1)

  # Calculate relative humidity
  tmp$RH <- round(tmp$EA / tmp$ES * 100, 1)

  # Join to the station data----------------------------------------------------
  GSOD_df <- suppressWarnings(suppressMessages(
    dplyr::inner_join(tmp, stations, by = "STNID")))

  GSOD_df <- GSOD_df[c("USAF", "WBAN", "STNID", "STN.NAME", "CTRY",
                       "LAT", "LON", "ELEV.M", "ELEV.M.SRTM.90m",
                       "YEARMODA", "YEAR", "MONTH", "DAY", "YDAY",
                       "TEMP", "TEMP.CNT", "DEWP", "DEWP.CNT",
                       "SLP", "SLP.CNT", "STP", "STP.CNT",
                       "VISIB", "VISIB.CNT",
                       "WDSP", "WDSP.CNT", "MXSPD", "GUST",
                       "MAX", "MIN",
                       "PRCP", "PRCP.FLAG",
                       "I.FOG", "I.RAIN_DZL", "I.SNW_ICE", "I.HAIL",
                       "I.THUNDER", "I.TDO_FNL",
                       "EA", "ES", "RH")]
  GSOD_df[is.na(GSOD_df)] <- -9999
  return(GSOD_df)
}

.read_gz <- function(gz_file) {
  readr::read_fwf(file = gz_file,
                  readr::fwf_positions(c(1, 8, 15, 19, 25, 32, 36, 43, 47, 54,
                                         58, 65, 69, 75, 79, 85, 89, 96, 103,
                                         109, 111, 117, 119, 124, 126, 133, 134,
                                         135, 136, 137, 138),
                                       c(6, 12, 18, 22, 30, 33, 41, 44, 52, 55,
                                         63, 66, 73, 76, 83, 86, 93, 100, 108,
                                         109, 116, 117, 123, 124, 130, 133, 134,
                                         135, 136, 137, 138)),
                  skip = 1,
                  na = c("9999.9", "999.9", "99.99"))
}

# The following 2 functions are shamelessly borrowed from RJ Hijmans raster pkg
# Download geographic data and return as R object
# Author: Robert J. Hijmans
# License GPL3
# Version 0.9
# October 2008

.get_data_path <- function(path) {
  path <- stringr::str_trim(path, side = "both")
  if (path == "") {
    stop("\nYou must supply a valid file path for storing the .csv file.\n")
  } else {
    if (substr(path, nchar(path) - 1, nchar(path)) == "//") {
      p <- substr(path, 1, nchar(path) - 2)
    } else if (substr(path, nchar(path), nchar(path)) == "/" |
               substr(path, nchar(path), nchar(path)) == "\\") {
      p <- substr(path, 1, nchar(path) - 1)
    } else {
      p <- path
    }
    if (!file.exists(p) & !file.exists(path)) {
      stop("\nFile path does not exist: ", path, ".\n")
      return(0)
    }
  }
  if (substr(path, nchar(path), nchar(path)) != "/" &
      substr(path, nchar(path), nchar(path)) != "\\") {
    path <- paste0(path, "/")
  }
  return(path)
}

# Original version as above from R J Hijmans.
# Bug fixes by A H Sparks for 2 letter ISO code
.get_country <- function(country = "") {
  country <- toupper(stringr::str_trim(country[1], side = "both"))
  cs <- raster::ccodes()
  # from Stack Overflow user juba, goo.gl/S31jyk
  cs <- data.frame(lapply(cs, function(x) {
    if (is.character(x)) return(toupper(x))
    else return(x)
  }))
  # end juba
  nc <- nchar(country)

  if (nc == 3) {
    if (country %in% cs[, 2]) {
      return(country)
    } else {
      stop("\nUnknown ISO code. Please provide a valid name or 2 or 3 letter ISO country code; you can get a list by using: raster::getData('ISO3').\n")
    }
  } else if (nc == 2) {
    if (country %in% cs[, 3]) {
      i <- which(country == cs[, 3])
      return(cs[i, 2])
    } else {
      stop("\nUnknown ISO code. Please provide a valid name or 2 or 3 letter ISO country code; you can get a list by using: raster::getData('ISO3').\n")
    }
  } else if (country %in% cs[, 1]) {
    i <- which(country == cs[, 1])
    return(cs[i, 2])
  } else if (country %in% cs[, 4]) {
    i <- which(country == cs[, 4])
    return(cs[i, 2] )
  } else if (country %in% cs[, 5]) {
    i <- which(country == cs[, 5])
    return(cs[i, 2])
  } else {
    stop("\nPlease provide a valid name or 2 or 3 letter ISO country code; you can get a list by using: raster::getData('ISO3').\n")
    return(0)
  }
}

# Ram Narasimhan
# Version 0.4
# License: GPL
# https://github.com/Ram-N/weatherData/blob/master/R/validity_checks.R
.validate_years <- function(years) {
  this_year <- 1900 + as.POSIXlt(Sys.Date())$year
  if (is.null(years)) {
    stop("\nYou must provide at least one year of data to download.\n")
  } else {
    for (i in years) {
      if (i <= 0) {
        stop("\nThis is not a valid year")
        return(0)
      }
      if (i > this_year) {
        stop("\nThe year cannot be greater than current year.\n")
        return(0)
      }
      return(1)
    }
  }
}

.validate_station <- function(station) {
  utils::data("stations", package = "GSODR", envir = environment())
  stations <- get("stations", envir = environment())
  stations[, 12] <- as.character(stations[, 12])

  if (station %in% stations[, 12] == FALSE) {
    stop("\nThis is not a valid station ID number, please check.\n
         Station IDs are provided as a part of the GSODR package in the  'stations' data frame in the STNID column.\n")
    return(0)
  }
}

.validate_merge <- function(years, station) {
  if (is.null(station)) {
    stop("\nThe option to merge multiple years into one file is only possible when selecting a single station.\n")
  }
  if (length(years) == 1)
    stop("\nYou have set 'merge = TRUE'' but have only one year to fetch and clean. Did you intend to query more than one year?\n")
}
