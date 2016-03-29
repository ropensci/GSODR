#' @title Download, Clean and Generate New Variables From GSOD Weather Data
#'
#'@description This function automates downloading and cleaning data from the
#'Global Summary of the Day (GSOD) data provided by the US National Climatic
#'Data Center (NCDC). Stations are individually checked for number of missing
#'days to assure data quality, stations with too many missing observations are
#'omitted. All units are converted to metric, e.g. feet to metres and
#'Fahrenheit to Celcius. Due to the size of the resulting data,
#'output is saved as a .csv file in a directory specified by the user,
#'the .csv file summarizes each year by station, which includes vapor pressure
#'and relative humidity variables calculated from existing data in GSOD.
#'
#'All missing values in resulting csv files are represented as -9999 regardless
#'of which column they occur in.
#'
#'Be sure to have disk space free and allocate the proper time for this to run.
#'This is a time, processor and disk input/output/space intensive process.
#'
#'For more information see the description of the data provided by NCDC,
#'\url{http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt}
#' @param years Year(s) of weather data to download (mandatory).
#' @param country Specify a country of interest for which to retrieve weather
#' data, full name or 3 letter ISO code work. Use raster::getData('ISO3') to
#' for a list of ISO country codes (optional).
#' @param  path Path entered by user indicating where to store resulting
#' csv file(s). Defaults to the current working directory (optional).
#' @param max_missing The maximum number of days allowed to be missing from a
#' station's data before it is excluded from .csv file output. Defaults to 5
#' days (optional).
#' @param agroclimatology Only clean data for stations between latitudes 60 and
#' -60 for agroclimatology work, defaults to TRUE. Set to FALSE to override and
#' include stations outside these latitudes (optional).
#'
#' @details This function generates a .csv file in the respective year directory
#' containing the following variables:
#' STNID - Station number (WMO/DATSAV3 number) for the location;
#' WBAN - number where applicable--this is the historical "Weather Bureau Air
#' Force Navy" number - with WBAN being the acronym;
#' STATION NAME
#' CTRY - Country
#' LAT - Latitude;
#' LON - Longitude;
#' ELEV.M - Elevation converted to metres;
#' YEARMODA - Date in YYYY-MM-DD format;
#' YEAR - The year;
#' MONTH - The month;
#' DAY - The day;
#' YDAY - Sequential day of year (not in original GSOD);
#' TEMP - Mean daily temperature converted to degrees C to tenths. Missing =
#' -9999;
#' COUNT.TEMP - Number of observations used in calculating mean daily
#' temperature
#' DEWP-  Mean daily dewpoint convrted to degrees C to tenths. Missing = -9999;
#' COUNT.DEWP - Number of observations used in calculating mean daily dew point;
#' SLP - Mean sea level pressure in millibars to tenths. Missing = -9999;
#' COUNT.SLP - Number of observations used in calculating mean sea level
#' pressure;
#' STP - Mean station pressure for the day in millibars to tenths.
#' Missing = -9999.9;
#' COUNT.STP - Number of observations used in calculating mean station pressure;
#' VISIB - Mean visibility for the day converted to kilometers to tenths.
#' Missing = -9999;
#' COUNT.VISIB - Number of observations used in calculating mean daily
#' visibility;
#' WDSPC - Mean daily wind speed value converted to metres/second to tenths.
#' Missing = -9999;
#' COUNT.WDSP - Number of observations used in calculating mean daily windspeed;
#' MXSPD - Maximum sustained wind speed reported for the day converted to
#' metres/second to tenths. Missing = -9999;
#' GUST = Maximum wind gust reported for the day converted to metres/second to
#' tenths. Missing = -9999;
#' MAX - Maximum temperature reported during the day converted to Celcious to
#' tenths--time of max temp report varies by country and region, so this will
#' sometimes not be the max for the calendar day.  Missing = -9999;
#' MIN- Minimum temperature reported during the day converted to Celcious to
#' tenths--time of min temp report varies by country and region, so this will
#' sometimes not be the max for the calendar day.  Missing = -9999;
#' PRCP - Total precipitation (rain and/or melted snow) reported during the day
#' converted to millimetres to hundredths; will usually not end with the
#' midnight observation--i.e., may include latter part of previous day. .00
#' indicates no measurable precipitation (includes a trace). Missing = -9999.
#' Note:  Many stations do not report '0' on days with no precipitation--
#' therefore, '-9999' will often appear on these days. Also, for example,
#' a station may only report a 6-hour amount for the period during which rain
#' fell. See FLAGS.PRCP column for source of data;
#' FLAGS.PRCP -  A = 1 report of 6-hour precipitation amount.
#' B = Summation of 2 reports of 6-hour precipitation amount.
#' C = Summation of 3 reports of 6-hour precipitation amount.
#' D = Summation of 4 reports of 6-hour precipitation amount.
#' E = 1 report of 12-hour precipitation amount.
#' F = Summation of 2 reports of 12-hour precipitation amount.
#' G = 1 report of 24-hour precipitation amount.
#' H = Station reported '0' as the amount for the day (eg, from 6-hour reports),
#' but also reported at least one occurrence of precipitation in hourly
#' observations--this could indicate a trace occurred, but should be considered
#' as incomplete data for the day.
#' I = Station did not report any precip data for the day and did not report any
#' occurrences of precipitation in its hourly observations--it's still possible
#' that precip occurred but was not reported;
#' SNDP - Snow depth in milimetres to tenths. Missing = -9999;
#' INDICATOR.* (1 = yes, 0 = no/not reported) for the occurrence during the day
#' of:
#' FOG,
#' RAIN or drizzle,
#' SNOW or ice pellets,
#' HAIL,
#' THUNDER,
#' TORNADO or funnel cloud.
#'
#' Values calculated by this package:
#' ea - Mean daily actual vapor pressure,
#' es - Mean daily saturation vapor pressure,
#' RH - Mean daily relative humidity.
#'
#' @examples
#' \dontrun{
#'  # Download global GSOD data for agroclimatology work for years 2009 and 2010
#' # and generate yearly summary files, GSOD_2009_XY and GSOD_2010_XY in folders
#' # named 2009 and 2010 in the specified working directory with a maximum of
#' # five missing days per weather station allowed.
#'
#' # Examples not run due to lengthy time required to run.
#'
#' get_GSOD(years = c(2009:2010), path = '~/tmp', agroclimatology = TRUE)
#' }
#'
#'\dontrun{
#' # Download data for Australia for year 2010 and generate a yearly
#' # summary file, GSOD_2010_XY files in a folder named 2010 in the current
#' # working directory with a maximum of five missing days per station allowed.
#'
#' get_GSOD(years = 2010, country = 'Australia')
#' }
#' @export

get_GSOD <- function(years = NULL, country = NULL, path = "", max_missing = 5,
                     agroclimatology = TRUE) {

  yr <- STN <- WBAN <- YEARMODA <- TEMP <- DEWP <- WDSP <- MXSPD <- MAX <-
    MIN <- PRCP <- SNDP <- VISIB <- NULL

  .validate_years(years)

  if(!is.null(country)) {
    country <- .get_country(country)
  }

  ftp_site <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/"

  # STEP 1: Download metadata for weather stations and files--------------------
  # download and load country-lists file
  countries <- readr::read_table(
    "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt")[-1, c(1, 3)]
  countries <- dplyr::left_join(countries, countrycode::countrycode_data,
                                by = c(FIPS = "fips104"))

  # download and load isd-history file
  stations <- readr::read_csv(
    "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
    col_types = "cccc__nnn__",
    col_names = c("USAF", "WBAN", "STATION.NAME", "CTRY", "LAT", "LON",
                  "ELEV.M"), skip = 1, na = c("-999.9", "999"))
  stations <- stations[stats::complete.cases(stations), ]
  stations <- stations[stations$CTRY != "", ]
  stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
  stations$STNID <- paste(stations$USAF, stations$WBAN, sep = "-")

  if(agroclimatology == TRUE){
    stations <- stations[stations$LAT >= -60 & stations$LAT <= 60, ]
  }

  for (yr in years) {
    # If country specified, make list of only those stations
    if(!is.null(country)) {
      country_FIPS <- unlist(as.character(
        stats::na.omit(countries[countries$iso3c == country, ][1])))
      station_list <- stations[stations$CTRY == country_FIPS, ]$STNID
      station_list <- sapply(station_list,
                             function(x) rep(paste0(x, "-", yr, ".op.gz")))
    }

    # Download annual .gz file of .csv files
    tf <- tempfile()
    td <- tempdir()

    try(utils::download.file(paste0(ftp_site, yr, "/gsod_", yr, ".tar"),
                             destfile = tf, mode = "wb"))

    # Extract and remove files
    utils::untar(tarfile = tf, exdir  = paste0(td, "/", yr, "/"))

    # list all files
    GSOD_list <- list.files(paste0(td, "/", yr, "/"),
                            pattern = utils::glob2rx("*.gz"),
                            full.names = FALSE)

    # if a country is specified, only select files from that country to use
    if(!is.null(country)) {
      GSOD_list <- stats::na.omit(GSOD_list[GSOD_list %in% station_list])
    }

    # STEP 2: Reformat, tidy up and compute climate variables-------------------
    GSOD_objects <- list()

    for (j in 1:length(GSOD_list)) {

      tmp <- readr::read_table(paste0(td, "/", yr, "/", GSOD_list[j]),
                               col_names = c("STN", "WBAN", "YEARMODA", "TEMP",
                                             "COUNT.TEMP", "DEWP", "COUNT.DEWP",
                                             "SLP", "COUNT.SLP", "STP",
                                             "COUNT.STP", "VISIB",
                                             "COUNT.VISIB", "WDSP",
                                             "COUNT.WDSP", "MXSPD",
                                             "GUST", "MAX", "MIN", "PRCP",
                                             "SNDP", "FRSHTT"),
                               col_types = "iiidididididididdddddc",
                               skip = 1,
                               na = c("9999.9", "999.9", "99.99"))

      # STEP 2.1: Check against maximum permissible missing days----------------
      if (lubridate::leap_year(yr) == TRUE) {
      } else {
        s <- 365 - max_missing + 1
      }

      if (nrow(tmp) < s) {
        tmp[] <- NA
      } else {

        # STEP 2.2: Clean up the station and weather data---------------------

        tmp <- dplyr::mutate(tmp, STNID = (paste(STN, WBAN, sep = "-")))
        tmp <- dplyr::mutate(tmp, YEAR = stringr::str_sub(tmp$YEARMODA, 1, 4))
        tmp <- dplyr::mutate(tmp, MONTH = stringr::str_sub(tmp$YEARMODA, 5, 6))
        tmp <- dplyr::mutate(tmp, DAY = stringr::str_sub(tmp$YEARMODA, 7, 8))
        tmp <- dplyr::mutate(tmp, YDAY = 1 + as.POSIXlt(as.Date(
          as.character(YEARMODA), "%Y%m%d"), "GMT")$yday) # day of year

        tmp <- dplyr::mutate(tmp, TEMP = ifelse(!is.na(tmp$TEMP), round(
          (TEMP - 32) * (5 / 9), 1), NA_integer_))
        tmp <- dplyr::mutate(tmp, DEWP = ifelse(!is.na(tmp$DEWP), round(
          (DEWP - 32) * (5 / 9), 1), NA_integer_))
        tmp <- dplyr::mutate(tmp, WDSP = ifelse(!is.na(tmp$WDSP), round(
          WDSP * 0.514444444, 1), NA_integer_))
        tmp <- dplyr::mutate(tmp, MXSPD = ifelse(!is.na(tmp$MXSPD), round(
          MXSPD * 0.514444444, 1), NA_integer_))
        tmp <- dplyr::mutate(tmp, VISIB = ifelse(!is.na(tmp$VISIB), round(
          VISIB * 1.60934, 1), NA_integer_))
        tmp <- dplyr::mutate(tmp, GUST = ifelse(!is.na(tmp$GUST), round(
          WDSP * 0.514444444, 1), NA_integer_))
        tmp$MAX <- as.numeric(stringr::str_sub(tmp$MAX, 1, 4))
        tmp <- dplyr::mutate(tmp, MAX = ifelse(!is.na(tmp$MAX), round(
          (MAX - 32) * (5 / 9), 2), NA_integer_))
        tmp$MIN <- as.numeric(stringr::str_sub(tmp$MIN, 1, 4))
        tmp <- dplyr::mutate(tmp, MIN = ifelse(!is.na(tmp$MIN), round(
          (MIN - 32) * (5 / 9), 2), NA_integer_))
        tmp <- dplyr::mutate(tmp, PRCP = ifelse(!is.na(tmp$PRCP),
                                                round(PRCP * 25.4, 1) * 10,
                                                NA_integer_))
        tmp <- dplyr::mutate(tmp, SNDP = ifelse(!is.na(tmp$SNDP),
                                                round(SNDP * 25.4, 1) * 10,
                                                NA_integer_))
        tmp$FLAGS.PRCP <- stringr::str_sub(tmp$PRCP, 5)
        indicators <- matrix(as.numeric(unlist(stringr::str_split(tmp$FRSHTT,
                                                                  ""))),
                             byrow = TRUE, ncol = 6)
        colnames(indicators) <- c("INDICATOR.FOG", "INDICATOR.RAIN",
                                  "INDICATOR.SNOW", "INDICATOR.HAIL",
                                  "INDICATOR.THUNDER", "INDICATOR.TORNADO")
        tmp <- data.frame(tmp, indicators, stringsAsFactors = FALSE)

        # STEP 2.3: Compute other weather vars----------------------------------
        # Mean actual (EA) and mean saturation vapour pressure (ES)
        # http://www.apesimulator.it/help/models/evapotranspiration/

        # EA derived from dewpoint
        tmp <- dplyr::mutate(tmp, EA = round(
          0.61078 * exp( (17.2694 * tmp$DEWP) / (tmp$DEWP + 237.3)),
          1))
        # ES derived from average temperature
        tmp <- dplyr::mutate(tmp, ES = round(
          0.61078 * exp( (17.2694 * tmp$TEMP) / (tmp$TEMP + 237.3)),
          1))
        # Calculate relative humidity
        tmp <- dplyr::mutate(tmp, RH = round(
          tmp$EA / tmp$ES * 100, 1))

        # STEP 2.4: Join to the station data------------------------------------
        GSOD_df <- dplyr::inner_join(tmp, stations, by = "STNID")

        GSOD_df <- GSOD_df[c("STN", "WBAN", "STNID", "STATION.NAME", "CTRY",
                             "LAT", "LON", "ELEV.M",
                             "YEARMODA", "YEAR", "MONTH", "DAY", "YDAY",
                             "TEMP", "COUNT.TEMP", "DEWP", "COUNT.DEWP",
                             "SLP", "COUNT.SLP", "STP", "COUNT.STP",
                             "VISIB", "COUNT.VISIB",
                             "WDSP", "COUNT.WDSP", "MXSPD", "GUST",
                             "MAX", "MIN",
                             "PRCP", "FLAGS.PRCP",
                             "INDICATOR.FOG", "INDICATOR.RAIN",
                             "INDICATOR.SNOW", "INDICATOR.HAIL",
                             "INDICATOR.THUNDER", "INDICATOR.TORNADO",
                             "EA", "ES", "RH")]
        GSOD_objects[[j]] <- GSOD_df
      }
    }
    GSOD_XY <- data.table::rbindlist(GSOD_objects)

    # STEP 3: Write to csv file-------------------------------------------------
    if (!is.null(country)) {
      outfile <- paste0(path, yr, "/GSOD-", country, "-", yr, ".csv")
    } else {
      outfile <- paste0(path, yr, "/GSOD-", yr, ".csv")
    }
    readr::write_csv(GSOD_XY, outfile, na = "-9999")
    do.call(file.remove, list(list.files(paste0(td, "/", yr),
                                         pattern = utils::glob2rx("*.gz"),
                                         full.names = TRUE)))
  }
}

# the following 2 functions are shamelessly borrowed from RJ Hijmans raster pkg
.get_data_path <- function(path) {
  path <- raster::trim(path)
  if (path == "") {
    path <- getwd()
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
      stop("\nFile path does not exist: ", path)
      return(0)
    }
  }
  if (substr(path, nchar(path), nchar(path)) != "/" &
      substr(path, nchar(path), nchar(path)) != "\\") {
    path <- paste0(path, "/")
  }
  return(path)
}

.get_country <- function(country = "") {
  country <- toupper(raster::trim(country[1]))
  cs <- raster::ccodes()
  cs <- toupper(cs)
  iso3 <- substr(country, 1, 3)
  if (iso3 %in% cs[, 2]) {
    return(iso3)
  } else {
    iso2 <- substr(country, 1, 2)
    if (iso2 %in% cs[, 3]) {
      i <- which(country == cs[, 3])
      return( cs[i, 2] )
    } else if (country %in% cs[, 1]) {
      i <- which(country == cs[, 1])
      return( cs[i, 2] )
    } else if (country %in% cs[, 4]) {
      i <- which(country == cs[, 4])
      return( cs[i, 2] )
    } else if (country %in% cs[, 5]) {
      i <- which(country == cs[, 5])
      return( cs[i, 2])
    } else {
      stop("\nPlease provide a valid name or 3 letter ISO country code;
           you can get a list with: getData('ISO3')")
      return(0)
    }
  }
}

# Adapted from weatherData package, validity_checks.R
# https://github.com/Ram-N/weatherData/blob/master/R/validity_checks.R----------
.validate_years <- function(years){
  this_year <- 1900 + as.POSIXlt(Sys.Date())$year
  if (is.null(years)) {
    stop("\nYou must provide at least one year of data to download")
  } else {
    for (i in years) {
      if (i <= 0){
        stop("\nThis is not a valid year")
        return(0)
      }
      if (i > this_year){
        stop ("\nThe year cannot be greater than current year.")
        return (0)
      }
      return (1)
    }
  }
}
