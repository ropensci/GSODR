# Functions used in GSODR for validating data and formatting user entries ------

#' @noRd
.check_missing <- function(GSOD_list, max_missing, td) {
  records <- plyr::llply(.fun = R.utils::countLines,
                         .data = paste0(td, "/", GSOD_list),
                         .parallel = TRUE)
  names(records) <- GSOD_list
  year <- as.numeric(stringi::stri_extract_last(GSOD_list[1], regex = "\\d{4}"))
  if (.is_leapyear(year) == FALSE) {
    allow <- 365 - max_missing
    GSOD_list <- stats::na.omit(ifelse(records >= allow, paste0(GSOD_list), NA))
  } else {
    if (.is_leapyear(year) == TRUE) {
      allow <- 366 - max_missing
      GSOD_list <- stats::na.omit(ifelse(records >= allow, paste0(GSOD_list), NA))
    }
  }
  return(GSOD_list)
}


#' @noRd
.get_country <- function(country = "") {
  country <- toupper(trimws(country[1]))
  nc <- nchar(country)
  if (nc == 3) {
    if (country %in% GSODR::country_list$iso3c) {
      c <- which(country == GSODR::country_list$iso3c)
      return(GSODR::country_list[[c, 1]])
    } else {
      stop("\nPlease provide a valid name or 2 or 3 letter ISO country code; you
           can view the entire list of valid countries in this data by typing,
           'GSODR::country_list'.\n")
    }
  } else if (nc == 2) {
    if (country %in% GSODR::country_list$iso2c) {
      c <- which(country == GSODR::country_list$iso2c)
      return(GSODR::country_list[[c, 1]])
    } else {
      stop("\nPlease provide a valid name or 2 or 3 letter ISO country code; you
             can view the entire list of valid countries in this data by typing,
             'GSODR::country_list'.\n")
    }
  } else if (country %in% GSODR::country_list$COUNTRY_NAME) {
    c <- which(country == GSODR::country_list$COUNTRY_NAME)
    return(GSODR::country_list[[c, 1]])
  } else {
    stop("\nPlease provide a valid name or 2 or 3 letter ISO country code; you
             can view the entire list of valid countries in this data by typing,
             'GSODR::country_list'.\n")
  }
}


#' @noRd
# is.leapyear function originally from Quantitative Ecology blog,
# http://quantitative-ecology.blogspot.com.au/2009/10/leap-years.html
.is_leapyear <- function(year){
  #http://en.wikipedia.org/wiki/Leap_year
  return( ((year %% 4 == 0) & (year %% 100 != 0)) | (year %% 400 == 0))
}

#' @noRd
.validate_dsn <- function(dsn) {
  dsn <- trimws(dsn)
  if (dsn == "") {
    stop("\nYou must supply a valid file path for storing the resulting
         file(s).\n")
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
      stop("\nFile dsn does not exist: ", dsn, ".\n")
    }
  }
  if (substr(dsn, nchar(dsn), nchar(dsn)) != "/" &
      substr(dsn, nchar(dsn), nchar(dsn)) != "\\") {
    dsn <- paste0(dsn, "/")
  }
  return(dsn)
}


#' @noRd
.validate_station <- function(station, stations) {
  for (vs in station) {
    if (!vs %in% stations[[12]]) {
      stop("\nThis is not a valid station ID number, please check your entry.
           \nStation IDs are provided as a part of the GSODR package in the
           'stations' data\nin the STNID column.\n")
    }
  }
}


#' @noRd
.validate_station_years <- function(station, stations, years) {
  for (vsy in station) {
    BEGIN <- as.numeric(substr(stations[stations[[12]] == vsy]$BEGIN, 1, 4))
    END <- as.numeric(substr(stations[stations[[12]] == vsy]$END, 1, 4))
    if (min(years) < BEGIN | max(years) > END)
      message("This station, ", vsy, ", only provides data for years ", BEGIN,
              " to ", END, ".\n")
  }
}


#' @noRd
.validate_years <- function(years) {
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
      } else
        return(1)
    }
  }
}
