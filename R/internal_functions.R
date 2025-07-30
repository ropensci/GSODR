#' Validate Years
#'
#' @param years User entered years for request
#' @returns None unless error in years being requested by users.
#' @autoglobal
#' @dev
.validate_years <- function(years) {
  if (inherits(years, what = "character")) {
    stop(
      call. = FALSE,
      "Years must be entered as a numeric value."
    )
  }
  this_year <- 1900L + as.POSIXlt(Sys.Date())$year
  for (i in years) {
    if (i <= 0L) {
      stop("\nThis is not a valid year.\n", call. = FALSE)
    } else if (i < 1929L) {
      stop(
        call. = FALSE,
        "\nThe GSOD data files start at 1929, you have entered a year prior
           to 1929.\n"
      )
    } else if (i > this_year) {
      stop(
        call. = FALSE,
        "\nThe year cannot be greater than current year.\n"
      )
    }
  }
  return(invisible(NULL))
}


#' Validate Station IDs
#'
#' @param station User entered station ID
#' @param isd_history isd_history.csv from NCEI provided by GSODR
#' @returns None unless an error with the years or invalid station ID.
#' @autoglobal
#' @dev
.validate_station_id <- function(station, isd_history) {
  if (!station %in% isd_history$STNID) {
    stop(
      call. = FALSE,
      "\n",
      station,
      " is not a valid station ID number, please check your entry.\n",
      "Valid Station IDs can be found in the isd-history.txt file\n",
      "available from the US NCEI server by combining the USAF and\n",
      "WBAN columns, e.g. '007005' '99999' is '007005-99999' from this\n",
      "file <https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.txt>\n"
    )
  }
  return(invisible(NULL))
}

#' Validate Station Data for Years Available
#'
#' @param station User entered station ID
#' @param isd_history isd_history.csv from NCEI provided by GSODR
#' @param years User entered years for query
#' @returns `station_id` value, "station", `NA` if no match with available
#' data.
#' @autoglobal
#' @dev
.validate_station_data_years <- function(station, isd_history, years) {
  BEGIN <-
    as.numeric(substr(
      isd_history[isd_history$STNID == station, ]$BEGIN,
      1L,
      4L
    ))
  END <-
    as.numeric(substr(isd_history[isd_history$STNID == station, ]$END, 1L, 4L))
  if (min(years) < BEGIN || max(years) > END) {
    warning(
      "\nThis station, ",
      station,
      ", only provides data for years ",
      BEGIN,
      " to ",
      END,
      ".\n",
      "Please send a request that falls within these years.",
      call. = FALSE
    )
    station <- NA
  }
  return(station)
}

#' Validate country requests
#'
#' @param country User requested country name
#' @param isd_history Data provided from NCEI on stations' locations and years
#' @returns A validated country name.
#' @autoglobal
#' @dev
.validate_country <-
  function(country, isd_history) {
    if (!is.null(country)) {
      country <- toupper(trimws(country[1L]))
      nc <- nchar(country)
      if (nc == 3L) {
        if (country %in% isd_history$ISO3C) {
          c <- which(country == isd_history$ISO3C)
          country <- as.character(isd_history[c, "CTRY"][1L])
        } else {
          stop(
            call. = FALSE,
            "\nPlease provide a valid name or 2 or 3 ",
            "letter ISO country code\n"
          )
        }
      } else if (nc == 2L) {
        if (country %in% isd_history$ISO2C) {
          c <- which(country == isd_history$ISO2C)
          country <- as.character(isd_history[c, "CTRY"][1L])
        } else if (country %in% isd_history$CTRY) {
          c <- which(country == isd_history$CTRY)
          country <- as.character(isd_history[c, "CTRY"][1L])
        } else {
          stop(
            call. = FALSE,
            "\nPlease provide a valid name or 2 or 3 ",
            "\nletter ISO country code"
          )
        }
      } else if (country %in% isd_history$COUNTRY_NAME) {
        c <- which(country == isd_history$COUNTRY_NAME)
        country <- as.character(isd_history[c, "CTRY"][1L])
      } else {
        stop(
          call. = FALSE,
          "\nPlease provide a valid name or 2 or 3 ",
          "letter ISO country code\n"
        )
      }
    }
    return(country)
  }


#' Validate data for missing days
#'
#' @param max_missing User entered maximum permissible missing days
#' @param GSOD_list A list of GSOD files that have been downloaded from NCEI
#' @returns A validated `list()` of GSOD files that meet requirements for
#' missing days.
#' @autoglobal
#' @dev
.validate_missing_days <-
  function(max_missing, file_list) {
    records <-
      unlist(lapply(
        X = paste0(file_list),
        FUN = R.utils::countLines
      ))
    names(records) <- file_list
    year <- as.numeric(substr(
      file_list[1L],
      start = nchar(file_list[1L]) - 19L,
      stop = nchar(file_list[1L]) - 16L
    ))
    ifelse(
      format(as.POSIXct(paste0(year, "-03-01")) - 1L, "%d") != "29",
      allow <- 365L - max_missing,
      allow <- 366L - max_missing
    )
    file_list <- stats::na.omit(ifelse(records >= allow, file_list, NA))
  }


#' Download GSOD files from NCEI server
#'
#' @param station Station ID being requested. Optional
#' @param years Years being requested. Mandatory
#' @autoglobal
#' @returns A list of data for processing before returning to user.
#'
#' @dev
.download_files <-
  function(station, years) {
    # if no station or station > 10 download annual zip files ------------------
    if (is.null(station) | length(station) > 10L) {
      url_list <-
        paste0(
          "https://www.ncei.noaa.gov/data/global-summary-of-the-day/archive/",
          years,
          ".tar.gz"
        )

      tryCatch(
        for (i in url_list) {
          if (.check_url_exists(x = i)) {
            curl::curl_download(
              url = i,
              destfile = file.path(tempdir(), basename(i)),
              mode = "wb"
            )
          }
        },
        error = function(x) {
          stop(
            call. = FALSE,
            "\nA file download has failed.\n"
          )
        }
      )
      # create a list of files that have been downloaded and untar them
      tar_files <-
        list.files(tempdir(), pattern = "*\\.tar.gz$", full.names = TRUE)

      withr::with_dir(tempdir(), .untar_files(tar_files))

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
        # Get a Cartesian join of all stations of interest and all years
        files_stations <-
          CJ(years, station, sorted = FALSE)[, paste0(
            tempdir(),
            "/",
            years,
            "/",
            gsub("-", "", station, fixed = TRUE),
            ".csv"
          )]

        GSOD_list <-
          subset(GSOD_list, GSOD_list %in% files_stations)

        return(GSOD_list)
      }
    }

    # if a station is provided, download its files -----------------------------
    if (!is.null(station)) {
      station <- gsub("-", "", station, fixed = TRUE)
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
          # check for an http error b4 proceeding'
          if (.check_url_exists(x = i)) {
            curl::curl_download(
              url = i,
              destfile = paste0(
                tempdir(),
                "/",
                substr(i, nchar(i) - 20L, nchar(i) - 16L),
                # year
                "-",
                basename(i) # filename
              )
            )
          }
        },
        error = function(x) {
          stop(
            call. = FALSE,
            "\nThe file downloads have failed. Please retry.\n"
          )
        }
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
#' @returns A list of GSOD stations suitable for agroclimatology work.
#' @autoglobal
#' @dev

.agroclimatology_list <-
  function(file_list, isd_history, years) {
    station_list <- isd_history[
      isd_history$LAT >= -60L &
        isd_history$LAT <= 60L,
    ]$STNID
    station_list <- gsub("-", "", station_list, fixed = TRUE)

    station_list <-
      CJ(years, sorted = FALSE)[, paste0(
        tempdir(),
        "/",
        years,
        "/",
        station_list,
        ".csv"
      )]

    file_list <- file_list[file_list %in% station_list]
    rm(station_list)
    return(file_list)
  }

#' Subset country list
#'
#' @param country Country of interest to subset on
#' @param GSOD_list List of GSOD files to be subset
#' @param isd_history isd_history.csv file from NCEI provided by GSODR
#' @param years Years being requested
#' @keywords internal
#' @returns A list of stations in the requested country.
#' @autoglobal
#' @dev
.subset_country_list <-
  function(country, file_list, isd_history, years) {
    station_list <-
      isd_history[isd_history$CTRY == country, ]$STNID
    station_list <- gsub("-", "", station_list, fixed = TRUE)
    station_list <-
      CJ(years, sorted = FALSE)[, paste0(
        tempdir(),
        "/",
        years,
        "/",
        station_list,
        ".csv"
      )]
    file_list <- file_list[file_list %in% station_list]
    rm(station_list)
    return(file_list)
  }

#' Process .gz files
#'
#' @param file_list List of GSOD files
#' @param isd_history isd_history.csv file from NCEI provided by GSODR
#' @keywords internal
#' @returns A `data.table` of GSOD weather data.
#' @autoglobal
#' @dev
.apply_process_csv <- function(file_list, isd_history) {
  x <- lapply(
    X = file_list,
    FUN = .process_csv,
    isd_history = isd_history
  )
  return(rbindlist(x))
}

#' Check That a URL Exists Before Downloading
#'
#' @param x a URL for checking
#' @returns A numeric value representing the HTTP response.
#' @dev

.check_url_exists <- function(x) {
  # check for an http error b4 proceeding, only if status is 200
  return(grepl(
    200L,
    curlGetHeaders(
      x,
      redirect = TRUE,
      verify = TRUE,
      timeout = 0L,
      TLS = ""
    )[[1L]]
  ))
}


#' Untar GSOD Tar Archive Files
#'
#' @param tar_files a list of tar files located in in `tempdir()`
#'
#' @dev
#' @returns Called for it's side-effects, untars the archive files in the
#'  `tempdir()`.

.untar_files <- function(tar_files) {
  for (i in tar_files) {
    year_dir <- substr(i, nchar(i) - 10L, nchar(i) - 7L)
    utils::untar(i, exdir = year_dir)
  }
}
