
#' Validate Years
#'
#' @param years User entered years for request
#' @keywords internal
#' @return None unless error in years being requested by users
#' @noRd

.validate_years <- function(years) {
  this_year <- 1900 + as.POSIXlt(Sys.Date())$year
  for (i in years) {
    if (i <= 0) {
      stop("\nThis is not a valid year.\n")
    } else if (i < 1929) {
      stop(call. = FALSE,
           "\nThe GSOD data files start at 1929, you have entered a year prior
           to 1929.\n")
    } else if (i > this_year) {
      stop(call. = FALSE,
           "\nThe year cannot be greater than current year.\n")
    }
  }
}


#' Validate Station IDs
#'
#' @param station User entered station ID
#' @param isd_history isd_history.csv from NCEI provided by GSODR
#' @param years User entered years for query
#' @keywords internal
#' @return None unless an error with the years or invalid station ID
#' @noRd

.validate_station <- function(station, isd_history, years) {
  if (!station %in% isd_history[[12]]) {
    stop(
      call. = FALSE,
      "\n",
      paste0(station),
      " is not a valid station ID number, please check your entry.\n",
      "Valid Station IDs can be found in the isd-history.txt file\n",
      "available from the US NCEI FTP server by combining the USAF and\n",
      "WBAN columns, e.g. '007005' '99999' is '007005-99999' from this\n",
      "file <ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.txt>\n"
    )
  }
  BEGIN <-
    as.numeric(substr(isd_history[isd_history[[12]] == station,]$BEGIN, 1, 4))
  END <-
    as.numeric(substr(isd_history[isd_history[[12]] == station,]$END, 1, 4))
  if (min(years) < BEGIN | max(years) > END) {
    message("\nThis station, ",
            station,
            ", only provides data for years ",
            BEGIN,
            " to ",
            END,
            ".\n")
  }
}


#' Validate Country Requests
#'
#' @param country User requested country name
#' @param country_list country_list file from NCEI provided by GSODR
#' @keywords internal
#' @return A validated country name
#' @noRd

.validate_country <-
  function(country, country_list) {
    if (!is.null(country)) {
      country <- toupper(trimws(country[1]))
      nc <- nchar(country)
      if (nc == 3) {
        if (country %in% country_list$iso3c) {
          c <- which(country == country_list$iso3c)
          country <- country_list[[c, 1]]
        } else {
          stop(call. = FALSE,
               "\nPlease provide a valid name or 2 or 3",
               "letter ISO country code\n")
        }
      } else if (nc == 2) {
        if (country %in% country_list$iso2c) {
          c <- which(country == country_list$iso2c)
          country <- country_list[[c, 1]]
        } else {
          stop(call. = FALSE,
               "\nPlease provide a valid name or 2 or 3",
               "\nletter ISO country code")
        }
      } else if (country %in% country_list$COUNTRY_NAME) {
        c <- which(country == country_list$COUNTRY_NAME)
        country <- country_list[[c, 1]]
      } else {
        stop(call. = FALSE,
             "\nPlease provide a valid name or 2 or 3",
             "letter ISO country code\n")
      }
    }
  }


#' Validate Data for Missing Days
#'
#' @param max_missing User entered maximum permissible missing days
#' @param GSOD_list A list of GSOD files that have been downloaded from NCEI
#' @keywords internal
#' @return A validated `list()` of GSOD files that meet requirements for missing days
#' @noRd

.validate_missing_days <-
  function(max_missing, GSOD_list) {
    records <-
      lapply(X = paste0(GSOD_list),
             FUN = R.utils::countLines)
    names(records) <- GSOD_list
    year <- as.numeric(substr(
      basename(GSOD_list[1]),
      start = nchar(basename(GSOD_list[1])) - 10 + 1,
      stop  = nchar(basename(GSOD_list[1])) - 7 + 1
    ))
    ifelse(
      format(as.POSIXct(paste0(year, "-03-01")) - 1, "%d") != "29",
      allow <- 365 - max_missing,
      allow <- 366 - max_missing
    )
    GSOD_list <- stats::na.omit(ifelse(records >= allow,
                                       GSOD_list,
                                       NA))
  }


#' Download GSOD Files from NCEI Server
#'
#' @param station Station ID being requested. Optional
#' @param years Years being requested. Mandatory
#' @keywords internal
#' @return A list of data for processing before returning to user
#'
#' @noRd

.download_files <-
  function(station,
           years) {
    # download archive .tar.gz files
    if (is.null(station)) {
      url_list <-
        paste0(
          "https://www.ncei.noaa.gov/data/global-summary-of-the-day/archive/",
          years,
          ".tar.gz"
        )
      tryCatch(
        Map(
          function(url, dest)
            curl::curl_download(
              url = url,
              destfile = dest,
              mode = "wb"
            ),
          url_list,
          file.path(tempdir(), basename(url_list))
        ),
        error = function(x)
          stop(call. = FALSE,
               "\nThe file downloads have failed. Please retry.\n")
      )

      tar_files <-
        list.files(tempdir(), pattern = "*\\.tar.gz$", full.names = TRUE)
      lapply(X = tar_files,
             FUN = utils::untar,
             exdir = tempdir())
    }

    if (!is.null(station)) {
      url_list <-
        data.table::CJ(years, station, sorted = FALSE)[, paste0(
          "https://www.ncei.noaa.gov/data/global-summary-of-the-day/access/",
          years,
          "/",
          station,
          ".csv"
        )]
      tryCatch(
        Map(
          function(url, dest)
            curl::curl_download(
              url = url,
              destfile = dest,
              mode = "wb"
            ),
          url_list,
          file.path(tempdir(), basename(url_list))
        ),
        error = function(x)
          stop(call. = FALSE,
               "\nThe file downloads have failed. Please retry.\n")
      )
    }
    GSOD_list <-
      list.files(tempdir(), pattern = "*\\.csv$", full.names = TRUE)
    return(GSOD_list)
  }

#' Agroclimatology List
#'
#' @param x A `data.table` of GSOD data from .download_data
#' @param isd_history isd_history file from NCEI
#' @param years Years being requested
#' @keywords internal
#' @return A list of GSOD stations suitable for agroclimatology work
#' @noRd

.agroclimatology_list <-
  function(GSOD_list, isd_history, years) {
    station_list <- isd_history[isd_history$LAT >= -60 &
                                  isd_history$LAT <= 60, ]$STNID

    station_list <-
      data.table::CJ(years, station, sorted = FALSE)[, paste0(tempdir(),
                                                              station_list,
                                                              "/",
                                                              station,
                                                              ".csv")]
    station_list <- do.call(paste0,
                            c(
                              expand.grid(tempdir(), "/", station_list, "-",
                                          years, ".op.gz")
                            ))
    GSOD_list <- GSOD_list[GSOD_list %in% station_list]
    rm(station_list)
    return(GSOD_list)
  }

#' Subset Country List
#'
#' @param country Country of interest to subset on
#' @param country_list Country list file provided by NCEI as a part of GSODR
#' @param GSOD_list List of GSOD files to be subset
#' @param isd_history isd_history.csv file from NCEI provided by GSODR
#' @param years Years being requested
#' @keywords internal
#' @return A list of stations in the requested country
#' @noRd

.subset_country_list <-
  function(country,
           country_list,
           GSOD_list,
           isd_history,
           years) {
    station_list <-
      isd_history[isd_history$CTRY == country,]$STNID
    station_list <- do.call(paste0,
                            c(expand.grid(
                              tempdir(),
                              "/",
                              station_list,
                              "-",
                              years,
                              ".csv"
                            )))
    GSOD_list <- GSOD_list[GSOD_list %in% station_list]
    return(GSOD_list)
    rm(station_list)
  }

#' Process .gz Files in Parallel
#'
#' @param file_list List of GSOD files
#' @param isd_history isd_history.csv file from NCEI provided by GSODR
#' @keywords internal
#' @return A `data.table()` of GSOD weather data
#' @noRd

.apply_process_csv <- function(file_list, isd_history) {
  x <- future.apply::future_lapply(X = file_list,
                                   FUN = .process_GSOD,
                                   isd_history = isd_history)
  return(data.table::rbindlist(x))
}
