#' Processes GSOD Data for Use in an R Sesion
#'
#' @param x A `data.table` generated from `.download_data()`
#' @param isd_history Internal metadata file for station locations
#' @return A `data.table` of well-formatted weather data
#' @keywords internal
#' @noRd

.process_csv <- function(x, isd_history) {
  # CRAN NOTE avoidance
  "EA" <- # nocov begin
    "ES" <-
    "TEMP" <-
    "DEWP" <-
    "SLP" <-
    "STP" <-
    "WDSP" <-
    "MXSPD" <-
    "GUST" <-
    "VISIB" <-
    "WDSP" <-
    "MAX" <-
    "MIN" <-
    "PRCP" <-
    "SNDP" <-
    "PRCP_ATTRIBUTES" <-
    "MIN_ATTRIBUTES" <-
    "MAX_ATTRIBUTES" <-
    "STNID" <-
    "YEARMODA" <-
    "DATE" <-
    "YEAR" <-
    "MONTH" <-
    "DAY" <-
    "YDAY" <-
    "RH" <-
    "I_FOG" <-
    "I_RAIN_DRIZZLE" <-
    "I_SNOW_ICE" <-
    "I_HAIL" <-
    "I_THUNDER" <-
    "I_TORNADO_FUNNEL" <-
    "FRSHTT" <-
    NULL # nocov end

  # Import data from the website for individual stations or tempdir() for all --
  DT <-
    fread(x,
      colClasses = c("STATION" = "character"),
      strip.white = TRUE
    )

  # Replace 99.99 et al. with NA
  set(DT, j = "PRCP", value = as.character(DT[["PRCP"]]))
  set(DT,
    i = which(DT[["PRCP"]] == "99.99"),
    j = "PRCP",
    value = NA
  )

  # Replace 999.9 with NA
  for (col in names(DT)[names(DT) %in% c(
    "VISIB",
    "WDSP",
    "MXSPD",
    "GUST",
    "SNDP",
    "STP"
  )]) {
    set(DT, j = col, value = as.character(DT[[col]]))
    set(DT,
      i = which(DT[[col]] == "999.9"),
      j = col,
      value = NA
    )
  }

  # Replace 9999.99 with NA
  for (col in names(DT)[names(DT) %in% c(
    "TEMP",
    "DEWP",
    "SLP",
    "MAX",
    "MIN"
  )]) {
    set(DT, j = col, value = as.character(DT[[col]]))
    set(DT,
      i = which(DT[[col]] == "9999.9"),
      j = col,
      value = NA
    )
  }

  # Replace " " with NA
  for (col in names(DT)[names(DT) %in% c(
    "PRCP_ATTRIBUTES",
    "MIN_ATTRIBUTES",
    "MAX_ATTRIBUTES"
  )]) {
    set(DT,
      i = which(DT[[col]] == " "),
      j = col,
      value = NA
    )
  }

  # Add STNID col --------------------------------------------------------------
  DT[, STNID := gsub("^(.{6})(.*)$", "\\1-\\2", DT$STATION)]

  # Add and convert date related columns ---------------------------------------
  DT[, YEARMODA := as.Date(DATE, format = "%Y-%m-%d")]
  DT[, YEAR := as.integer(substr(DATE, 1, 4))]
  DT[, MONTH := as.integer(substr(DATE, 6, 7))]
  DT[, DAY := as.integer(substr(DATE, 9, 10))]
  DT[, YDAY := as.integer(strftime(as.Date(DATE), format = "%j"))]

  # Convert *_ATTRIBUTES cols to integer ---------------------------------------
  for (col in names(DT)[names(DT) %in% c(
    "TEMP_ATTRIBUTES",
    "DEWP_ATTRIBUTES",
    "SLP_ATTRIBUTES",
    "STP_ATTRIBUTES",
    "VISIB_ATTRIBUTES",
    "WDSP_ATTRIBUTES"
  )]) {
    set(DT, j = col, value = as.integer(DT[[col]]))
  }

  # Drop unnecessary columns ---------------------------------------------------
  DT[, c("DATE", "STATION") := NULL]

  # Convert numeric cols to be numeric -----------------------------------------
  for (col in c(
    "TEMP",
    "DEWP",
    "SLP",
    "STP",
    "WDSP",
    "MXSPD",
    "GUST",
    "VISIB",
    "WDSP",
    "MAX",
    "MIN",
    "PRCP",
    "SNDP"
  )) {
    set(DT, j = col, value = as.numeric(DT[[col]]))
  }

  # Convert data to Metric units -----------------------------------------------
  DT[, TEMP := round(0.5556 * (TEMP - 32), 1)]
  DT[, DEWP := round(0.5556 * (DEWP - 32), 1)]
  DT[, WDSP := round(WDSP * 0.514444444, 1)]
  DT[, MXSPD := round(MXSPD * 0.514444444, 1)]
  DT[, GUST := round(GUST * 0.514444444, 1)]
  DT[, VISIB := round(VISIB * 1.60934, 1)]
  DT[, MAX := round((MAX - 32) * 0.5556, 1)]
  DT[, MIN := round((MIN - 32) * 0.5556, 1)]
  DT[, PRCP := round(PRCP * 25.4, 2)]
  DT[, SNDP := round(SNDP * 25.4, 1)]

  # Calculate EA, ES and RH using August-Roche-Magnus approximation ------------
  # Oleg A. Alduchov and Robert E. Eskridge 1995
  # https://doi.org/10.1175/1520-0450(1996)035<0601:IMFAOS>2.0.CO;2
  # EA derived from dew point
  DT[, EA := round(0.61094 * exp((17.625 * (DEWP)) /
    ((DEWP) + 243.04)), 1)]
  # ES derived from average temperature
  DT[, ES := round(0.61094 * exp((17.625 * (TEMP)) /
    ((TEMP) + 243.04)), 1)]
  DT[, RH := round(
    100 * (exp((17.625 * DEWP) / (243.04 + DEWP)) /
      exp((17.625 * (TEMP)) / (243.04 + (TEMP)))),
    1
  )]

  # Split FRSHTT into separate columns -----------------------------------------
  DT[, I_FOG := fifelse(
    DT$FRSHTT != 0,
    as.numeric(substr(
      x = DT$FRSHTT,
      start = 1,
      stop = 1
    )), 0
  )]
  DT[, I_RAIN_DRIZZLE := fifelse(
    DT$FRSHTT != 0,
    as.numeric(substr(
      x = DT$FRSHTT,
      start = 2,
      stop = 2
    )), 0
  )]
  DT[, I_SNOW_ICE := fifelse(
    DT$FRSHTT != 0,
    as.numeric(substr(
      x = DT$FRSHTT,
      start = 3,
      stop = 3
    )), 0
  )]
  DT[, I_HAIL := fifelse(
    DT$FRSHTT != 0,
    as.numeric(substr(
      x = DT$FRSHTT,
      start = 4,
      stop = 4
    )), 0
  )]
  DT[, I_THUNDER := fifelse(
    DT$FRSHTT != 0,
    as.numeric(substr(
      DT$FRSHTT,
      start = 5, stop = 5
    )), 0
  )]
  DT[, I_TORNADO_FUNNEL := fifelse(
    DT$FRSHTT != 0,
    as.numeric(substr(
      x = DT$FRSHTT,
      start = 6,
      stop = 6
    )), 0
  )]
  DT[, FRSHTT := NULL]

  # Join with internal isd-history for CTRY column -----------------------------
  setkey(DT, STNID)
  DT <- isd_history[DT]

  # drop extra cols
  DT[, c("i.NAME", "LATITUDE", "LONGITUDE", "ELEV(M)") := NULL]
  setnames(DT, c("LAT", "LON"), c("LATITUDE", "LONGITUDE"))

  # setcolorder ----------------------------------------------------------------
  setcolorder(
    DT,
    c(
      "STNID",
      "NAME",
      "CTRY",
      "COUNTRY_NAME",
      "ISO2C",
      "ISO3C",
      "STATE",
      "LATITUDE",
      "LONGITUDE",
      "ELEVATION",
      "BEGIN",
      "END",
      "YEARMODA",
      "YEAR",
      "MONTH",
      "DAY",
      "YDAY",
      "TEMP",
      "TEMP_ATTRIBUTES",
      "DEWP",
      "DEWP_ATTRIBUTES",
      "SLP",
      "SLP_ATTRIBUTES",
      "STP",
      "STP_ATTRIBUTES",
      "VISIB",
      "VISIB_ATTRIBUTES",
      "WDSP",
      "WDSP_ATTRIBUTES",
      "MXSPD",
      "GUST",
      "MAX",
      "MAX_ATTRIBUTES",
      "MIN",
      "MIN_ATTRIBUTES",
      "PRCP",
      "PRCP_ATTRIBUTES",
      "SNDP",
      "I_FOG",
      "I_RAIN_DRIZZLE",
      "I_SNOW_ICE",
      "I_HAIL",
      "I_THUNDER",
      "I_TORNADO_FUNNEL",
      "EA",
      "ES",
      "RH"
    )
  )
  return(DT)
}
