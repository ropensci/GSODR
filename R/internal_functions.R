
#' Validate Years
#'
#' @param years User entered years for request
#' @keywords internal
#' @return None unless error in years being requested by users
#' @noRd

.validate_years <- function(years) {
  if (class(years) == "character") {
    stop(call. = FALSE,
         "Years must be entered as a numeric value.")
  }
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
  if (!station %in% isd_history$STNID) {
    stop(
      call. = FALSE,
      "\n",
      paste0(station),
      " is not a valid station ID number, please check your entry.\n",
      "Valid Station IDs can be found in the isd-history.txt file\n",
      "available from the US NCEI server by combining the USAF and\n",
      "WBAN columns, e.g. '007005' '99999' is '007005-99999' from this\n",
      "file <https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.txt>\n"
    )
  }
  BEGIN <-
    as.numeric(substr(isd_history[isd_history$STNID == station,]$BEGIN, 1, 4))
  END <-
    as.numeric(substr(isd_history[isd_history$STNID == station,]$END, 1, 4))
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
#' @param isd_history Data provided from NCEI on stations' locations and years
#' @keywords internal
#' @return A validated country name
#' @noRd

.validate_country <-
  function(country, isd_history) {
    if (!is.null(country)) {
      country <- toupper(trimws(country[1]))
      nc <- nchar(country)
      if (nc == 3) {
        if (country %in% isd_history$ISO3C) {
          c <- which(country == isd_history$ISO3C)
          country <- as.character(isd_history[c, "CTRY"][1])
        } else {
          stop(call. = FALSE,
               "\nPlease provide a valid name or 2 or 3 ",
               "letter ISO country code\n")
        }
      } else if (nc == 2) {
        if (country %in% isd_history$ISO2C) {
          c <- which(country == isd_history$ISO2C)
          country <- as.character(isd_history[c, "CTRY"][1])
        } else if (country %in% isd_history$CTRY) {
          c <- which(country == isd_history$CTRY)
          country <- as.character(isd_history[c, "CTRY"][1])
        } else {
          stop(call. = FALSE,
               "\nPlease provide a valid name or 2 or 3 ",
               "\nletter ISO country code")
        }
      } else if (country %in% isd_history$COUNTRY_NAME) {
        c <- which(country == isd_history$COUNTRY_NAME)
        country <- as.character(isd_history[c, "CTRY"][1])
      } else {
        stop(call. = FALSE,
             "\nPlease provide a valid name or 2 or 3 ",
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
  function(max_missing, file_list) {
    records <-
      unlist(lapply(X = paste0(file_list),
                    FUN = R.utils::countLines))
    names(records) <- file_list
    year <- as.numeric(substr(
      file_list[1],
      start = nchar(file_list[1]) - 19,
      stop  = nchar(file_list[1]) - 16
    ))
    ifelse(
      format(as.POSIXct(paste0(year, "-03-01")) - 1, "%d") != "29",
      allow <- 365 - max_missing,
      allow <- 366 - max_missing
    )
    file_list <- stats::na.omit(ifelse(records >= allow,
                                       file_list,
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
    # if no station or station > 10 download annual zip files ------------------
    if (is.null(station) | length(station) > 10) {
      url_list <-
        paste0(
          "https://www.ncei.noaa.gov/data/global-summary-of-the-day/archive/",
          years,
          ".tar.gz"
        )

      tryCatch(
        for (i in url_list) {
          if (!httr::http_error(i)) {
            # check for an http error b4 proceeding
            curl::curl_download(
              url = i,
              destfile = file.path(tempdir(), basename(i)),
              mode = "wb"
            )
          }
        },
        error = function(x)
          stop(call. = FALSE,
               "\nThe file downloads have failed. Please restart.\n")
      )

      # create a list of files that have been downloaded and untar them
      tar_files <-
        list.files(tempdir(), pattern = "*\\.tar.gz$", full.names = TRUE)
      for (i in tar_files) {
        wd <- getwd()
        setwd(tempdir())
        year_dir <- substr(i, nchar(i) - 10, nchar(i) - 7)
        utils::untar(i, exdir = year_dir)
        setwd(wd)
      }

      GSOD_list <-
        list.files(
          tempdir(),
          pattern = "*\\.csv$",
          full.names = TRUE,
          recursive = TRUE
        )

      if (is.null(station)) {
        return(GSOD_list)
      } else {
        # Get a cartesian join of all stations of interest and all years
        files_stations <-
          CJ(years, station, sorted = FALSE)[, paste0(tempdir(),
                                                      "/",
                                                      years,
                                                      "/",
                                                      gsub("-", "", station),
                                                      ".csv")]

        GSOD_list <-
          subset(GSOD_list, GSOD_list %in% files_stations)

        return(GSOD_list)
      }
    }

    # if a station is provided, download its files -----------------------------
    if (!is.null(station)) {
      station <- gsub("-", "", station)
      url_list <-
        CJ(years, station, sorted = FALSE)[, paste0(
          "https://www.ncei.noaa.gov/data/global-summary-of-the-day/access/",
          years,
          "/",
          station,
          ".csv"
        )]
      tryCatch(
        for (i in url_list) {
          if (!httr::http_error(i)) {
            # check for an http error b4 proceeding
            httr::GET(url = i, httr::write_disk(
              paste0(
                tempdir(),
                "/",
                substr(i, nchar(i) - 20, nchar(i) - 16),
                # year
                "-",
                basename(i) # filename
              ),
              overwrite = TRUE
            ))
          }
        },
        error = function(x)
          stop(call. = FALSE,
               "\nThe file downloads have failed. Please restart.\n")
      )

      GSOD_list <-
        list.files(tempdir(), pattern = "*\\.csv$", full.names = TRUE)
    }
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
  function(file_list, isd_history, years) {
    station_list <- isd_history[isd_history$LAT >= -60 &
                                  isd_history$LAT <= 60,]$STNID
    station_list <- gsub("-", "", station_list)

    station_list <-
      CJ(years, sorted = FALSE)[, paste0(tempdir(),
                                         "/",
                                         years,
                                         "/",
                                         station_list,
                                         ".csv")]

    file_list <- file_list[file_list %in% station_list]
    rm(station_list)
    return(file_list)
  }

#' Subset Country List
#'
#' @param country Country of interest to subset on
#' @param GSOD_list List of GSOD files to be subset
#' @param isd_history isd_history.csv file from NCEI provided by GSODR
#' @param years Years being requested
#' @keywords internal
#' @return A list of stations in the requested country
#' @noRd

.subset_country_list <-
  function(country,
           file_list,
           isd_history,
           years) {
    station_list <-
      isd_history[isd_history$CTRY == country,]$STNID
    station_list <- gsub("-", "", station_list)
    station_list <-
      CJ(years, sorted = FALSE)[, paste0(tempdir(),
                                         "/",
                                         years,
                                         "/",
                                         station_list,
                                         ".csv")]
    file_list <- file_list[file_list %in% station_list]
    return(file_list)
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
                                   FUN = .process_csv,
                                   isd_history = isd_history)
  return(rbindlist(x))
}
