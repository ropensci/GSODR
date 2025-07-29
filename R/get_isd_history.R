#' Get the Most Recent isd_history File
#'
#' @returns A [data.table::data.table] object
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

  cclist <- data.table::as.data.table(countrycode::codelist[, c(
    "country.name.en",
    "iso2c",
    "fips"
  )])
  cclist <- data.table::melt(cclist, id.vars = "country.name.en")
  cclist <- cclist[order(cclist$country.name.en)]
  cclist <- unique(cclist, by = "value")

  isd_history <-
    isd_history[cclist, on = c("CTRY" = "value")]

  isd_history <-
    isd_history[
      data.table::as.data.table(countrycode::codelist),
      on = "country.name.en"
    ]
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
  isd_history[isd_history == -999L] <- NA
  isd_history[isd_history == -999.9] <- NA
  isd_history <-
    isd_history[
      !is.na(isd_history$LAT) &
        !is.na(isd_history$LON),
    ]
  isd_history <-
    isd_history[
      isd_history$LAT != 0.0 &
        isd_history$LON != 0.0,
    ]
  isd_history <-
    isd_history[
      isd_history$LAT > -90.0 &
        isd_history$LAT < 90.0,
    ]
  isd_history <-
    isd_history[
      isd_history$LON > -180.0 &
        isd_history$LON < 180.0,
    ]

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
