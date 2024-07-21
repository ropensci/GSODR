

#' Get the Most Recent isd_history File
#'
#' @return A [data.table::data.table] object
#' @export
#' @family metadata
#' @autoglobal
#' @examplesIf interactive()
#' get_isd_history()
#'
get_isd_history <- function() {
  isd_history <- fread(
    input = "https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
    strip.white = TRUE,
    showProgress = FALSE,
    keepLeadingZeros = TRUE
  )

  # add STNID column
  isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
  setcolorder(isd_history, "STNID")
  setnames(isd_history, "STATION NAME", "NAME")

  # remove stations where LAT or LON is NA
  isd_history <- stats::na.omit(isd_history, cols = c("LAT", "LON"))

  # remove extra columns
  isd_history[, c("USAF", "WBAN", "ICAO") := NULL]

  isd_history <-
    isd_history[setDT(countrycode::codelist), on = c("CTRY" = "fips")]

  isd_history <- isd_history[, c(
    "STNID",
    "NAME",
    "LAT",
    "LON",
    "ELEV(M)",
    "CTRY",
    "STATE",
    "BEGIN",
    "END",
    "country.name.en",
    "iso2c",
    "iso3c"
  )]

  # clean data
  isd_history[isd_history == -999] <- NA
  isd_history[isd_history == -999.9] <- NA
  isd_history <-
    isd_history[!is.na(isd_history$LAT) &
                  !is.na(isd_history$LON), ]
  isd_history <-
    isd_history[isd_history$LAT != 0 &
                  isd_history$LON != 0, ]
  isd_history <-
    isd_history[isd_history$LAT > -90 &
                  isd_history$LAT < 90, ]
  isd_history <-
    isd_history[isd_history$LON > -180 &
                  isd_history$LON < 180, ]

  # set colnames to upper case
  names(isd_history) <- toupper(names(isd_history))
  setnames(isd_history, old = "COUNTRY.NAME.EN", new = "COUNTRY_NAME")

  # set country names to be upper case for easier internal verifications
  isd_history[, COUNTRY_NAME := toupper(COUNTRY_NAME)]

  # set key for joins when processing CSV files
  setkeyv(isd_history, "STNID")

  # select only the cols of interest
  x <- c(
    "STNID",
    "NAME",
    "LAT",
    "LON",
    "ELEV(M)",
    "CTRY",
    "STATE",
    "BEGIN",
    "END",
    "COUNTRY_NAME",
    "ISO2C",
    "ISO3C"
  )

  isd_history <- isd_history[, ..x]

  return(isd_history[])
}
