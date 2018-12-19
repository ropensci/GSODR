# Validation functions ---------------------------------------------------------
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

# Function to download files from server ---------------------------------------
#' @noRd
.download_files <-
  function(ftp_base, station, years, cache_dir) {
    if (is.null(station)) {
      file_list <-
        paste0(sprintf(ftp_base, years), "gsod_", years, ".tar")
      tryCatch(
        Map(
          function(ftp, dest)
            curl::curl_download(
              url = ftp,
              destfile = dest,
              mode = "wb"
            ),
          file_list,
          file.path(cache_dir, basename(file_list))
        ),
        error = function(x)
          stop(call. = FALSE,
               "\nThe file downloads have failed. Please restart.\n")
      )
      tar_files <-
        list.files(cache_dir, pattern = "^gsod.*\\.tar$", full.names = TRUE)
      purrr::map(.x = tar_files,
                 .f = utils::untar,
                 exdir = cache_dir)
      GSOD_list <-
        list.files(cache_dir, pattern = "^.*\\.op.gz$", full.names = TRUE)
    }
    if (!is.null(station)) {
      # Written by @hrbrmstr
      max_retries <- 6
      dir_list_handle <-
        curl::new_handle(
          ftp_use_epsv = FALSE,
          crlf = TRUE,
          dirlistonly = TRUE,
          ssl_verifypeer = FALSE,
          ftp_response_timeout = 30,
          ftp_skip_pasv_ip = TRUE
        )
      s_curl_fetch_memory <- purrr::safely(curl::curl_fetch_memory)
      retry_cfm <-
        function(url, handle) {
          i <- 0
          repeat {
            i <- i + 1
            res <- s_curl_fetch_memory(url, handle = handle)
            if (!is.null(res$result))
              return(res$result)
            if (i == max_retries) {
              stop(
                call. = FALSE,
                "\nWe've tried to get the file(s) you requested six\n",
                "times, but the server is not responding, so we are\n",
                "unable to process your request now.\n",
                "Please try again later.\n"
              )
            }
          }
        }
      # Wrapping the disk writer (for the actual files)
      # Note the use of the cache dir. It won't waste your bandwidth or the
      # server's bandwidth or CPU if the file has already been retrieved.
      s_curl_fetch_disk <- purrr::safely(curl::curl_fetch_disk)
      retry_cfd <-
        function(url, path) {
          cache_file <- sprintf("%s/%s", cache_dir, basename(url))
          if (file.exists(cache_file))
            return()
          i <- 0
          repeat {
            i <- i + 1
            if (i == max_retries) {
              stop(
                call. = FALSE,
                "\nWe've tried to get the file(s) you requested six\n",
                "times, but the server is not responding, so we are\n",
                "unable to process your request now.\n",
                "Please try again later.\n"
              )
            }
            res <- s_curl_fetch_disk(url, cache_file)
            if (!is.null(res$result))
              return()
          }
        }

      pb <- dplyr::progress_estimated(length(years))
      purrr::walk(years, function(yr) {
        year_url <- sprintf(ftp_base, yr)
        tmp <- retry_cfm(year_url, handle = dir_list_handle)
        con <- rawConnection(tmp$content)
        fils <- readLines(con)
        close(con)
        # sift out only the target stations
        purrr::map(station, ~ grep(., fils, value = TRUE)) %>%
          purrr::keep( ~ length(.) > 0) %>%
          purrr::flatten_chr() -> fils

        if (length(fils) > 0) {
          # grab the station files
          purrr::walk(paste0(year_url, fils), retry_cfd)
          # progress bar
          pb$tick()$print()
        }
        else {
          message("\nThere are no files for station ID ",
                  station,
                  " in ",
                  yr,
                  ".\n")
        }
      })
    }
    GSOD_list <-
      list.files(path = cache_dir,
                 pattern = "^.*\\.op.gz$",
                 full.names = TRUE)
  }

# Agroclimatology: subset list of stations to process---------------------------
.agroclimatology_list <-
  function(GSOD_list, isd_history, cache_dir, years) {
    station_list <- isd_history[isd_history$LAT >= -60 &
                                  isd_history$LAT <= 60,]$STNID
    station_list <- do.call(paste0,
                            c(
                              expand.grid(cache_dir, "/", station_list, "-",
                                          years, ".op.gz")
                            ))
    GSOD_list <- GSOD_list[GSOD_list %in% station_list]
    rm(station_list)
    return(GSOD_list)
  }

# Specified country: subset list of stations to process ------------------------
.subset_country_list <-
  function(country,
           country_list,
           GSOD_list,
           isd_history,
           cache_dir,
           years) {

    station_list <-
      isd_history[isd_history$CTRY == country, ]$STNID
    station_list <- do.call(paste0,
                            c(
                              expand.grid(cache_dir,
                                          "/",
                                          station_list,
                                          "-",
                                          years,
                                          ".op.gz")
                            ))
    GSOD_list <- GSOD_list[GSOD_list %in% station_list]
    return(GSOD_list)
    rm(station_list)
  }

# Clean and reformat list of station files from local disk in tempdir ----------

apply_process_gz <- function(file_list, isd_history) {
  future.apply::future_lapply(X = file_list,
                              FUN = .process_gz,
                              isd_history = isd_history)  %>%
    dplyr::bind_rows()
}
