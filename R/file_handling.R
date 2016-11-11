# Functions used in GSODR for handling files -----------------------------------

#'@noRd
#'@importFrom foreach %dopar%

.dl_global_files <- function(agroclimatology, country, max_missing, s, stations,
                             td, threads, years) {

  i <- NULL

  tryCatch(Map(function(ftp, dest)
    utils::download.file(url = ftp, destfile = dest),
    s, file.path(td, basename(s))), error = function(x) stop(
      "\nThe file downloads have failed. Please restart.\n"))

  tar_files <- list.files(td, pattern = "^gsod.*\\.tar$", full.names = TRUE)

  plyr::ldply(.data = tar_files, .fun = utils::untar, exdir = td)

  GSOD_list <- list.files(td, pattern = "^.*\\.op.gz$", full.names = TRUE)

  if (!is.null(max_missing)) {
    GSOD_list <- .check_missing(GSOD_list, years)
  }

  # If agroclimatology == TRUE, subset list of stations to process--------------
  if (agroclimatology == TRUE) {
    station_list <- stations[stations$LAT >= -60 &
                               stations$LAT <= 60, ]$STNID
    station_list <- do.call(paste0,
                            c(expand.grid(station_list, "-", years, ".op.gz")))
    GSOD_list <- paste0(td, "/", GSOD_list[GSOD_list %in% station_list == TRUE])
    rm(station_list)
  }

  # If country is set, subset list of stations to process ----------------------
  if (!is.null(country)) {
    country_FIPS <- unlist(as.character(stats::na.omit(
      GSODR::country_list[GSODR::country_list$FIPS == country, ][[1]]),
      use.names = FALSE))
    station_list <- stations[stations$CTRY == country_FIPS, ]$STNID
    station_list <- do.call(paste0,
                            c(expand.grid(station_list, "-", years, ".op.gz")))
    GSOD_list <- paste0(td, "/", GSOD_list[GSOD_list %in% station_list == TRUE])
  }

  ity <- iterators::iter(GSOD_list)
  GSODY_XY <- as.data.frame(
    data.table::rbindlist(
      foreach::foreach(i = ity) %dopar% { process_gz(i, stations = stations)
      }
    )
  )

  return(GSOD_XY)
  unlink(td)
}

#' @noRd
.dl_specified_stations <- function(file_list, filename, CSV, dsn, GPKG,
                                   stations, td, threads, years) {

  filenames <- paste0(substr(file_list, 1, 43),
                      strsplit(RCurl::getURL(substr(file_list, 1, 43),
                                             ftp.use.epsv = FALSE,
                                             ftplistonly = TRUE, crlf = TRUE),
                               "\r*\n")[[1]])[-c(1:2)]
  file_list <- filenames[which(file_list %in% filenames)]

  tryCatch(Map(function(ftp, dest)
    utils::download.file(url = ftp, destfile = dest),
    file_list, file.path(td, basename(file_list))),
    error = function(x) message(paste0(
      "\nThe file downloads have failed. Please restart.\n")))

  GSOD_list <- list.files(path = td, pattern = "^.*\\.op.gz$",
                          full.names = TRUE)
  .process_files(GSOD_list, dsn. = dsn, GPKG. = GPKG, CSV. = CSV,
                 filename. = filename, stations. = stations,
                 threads. = threads, years. = years)
}

#' @noRd
.fetch_station_list <- function() {
  STNID <- NULL
  stations <- readr::read_csv(
    "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
    col_types = "ccccccddddd",
    col_names = c("USAF", "WBAN", "STN_NAME", "CTRY", "STATE", "CALL",
                  "LAT", "LON", "ELEV_M", "BEGIN", "END"), skip = 1)

  stations[stations == -999.9] <- NA
  stations[stations == -999] <- NA

  stations <- stations[stations$LAT != 0 & stations$LON != 0, ]
  stations <- stations[stations$LAT > -90 & stations$LAT < 90, ]
  stations <- stations[stations$LON > -180 & stations$LON < 180, ]
  stations$STNID <- as.character(paste(stations$USAF, stations$WBAN, sep = "-"))

  SRTM_GSOD_elevation <- data.table::setkey(GSODR::SRTM_GSOD_elevation, STNID)
  data.table::setDT(stations)
  data.table::setkey(stations, STNID)
  stations <- stations[SRTM_GSOD_elevation, on = "STNID"]

  stations <- stations[!is.na(stations$LAT), ]
  stations <- stations[!is.na(stations$LON), ]
  return(stations)
}


#' @noRd
#' @importFrom foreach %dopar%
.process_files <- function(GSOD_list, dsn., filename., GPKG., CSV.,
                           stations., threads., years.) {

  j <- NULL
  itx <- iterators::iter(GSOD_list)
  GSOD_XY <- data.table::rbindlist(
    foreach::foreach(j = itx) %dopar% {
      .process_gz(j, dsn., years., GPKG., CSV., filename., stations.)
    }
  )
  return(GSOD_XY)
}
