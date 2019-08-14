
#' Processes GSOD data
#'
#' @param x A `data.table` generated from `.download_data()`
#'
#' @return A `data.table` of well-formatted weather data
#' @noRd

.process_csv <- function(x, isd_history) {
  # CRAN NOTE avoidance
  "EA" <- #nocov begin
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
    NULL # nocov end

  # Import data from the website for indvidual stations or tempdir() for all ---
  DT <-
    fread(x, colClasses = c("FRSHTT" = "c"))

  # Replace 99.99 with NA
  for (col in names(DT)[names(DT) == "PRCP"]) {
    set(DT,
        i = which(DT[[col]] == 99.99),
        j = col,
        value = NA)
  }

  # Replace 999.9 with NA
  for (col in names(DT)[names(DT) %in% c("VISIB",
                                         "WDSP",
                                         "MXSPD",
                                         "GUST",
                                         "SNDP",
                                         "STP")]) {
    set(DT,
        i = which(DT[[col]] == 999.9),
        j = col,
        value = NA)
  }

  # Replace 9999.99 with NA
  for (col in names(DT)[names(DT) %in% c("TEMP",
                                         "DEWP",
                                         "SLP",
                                         "MAX",
                                         "MIN")]) {
    set(DT,
        i = which(DT[[col]] == 9999.9),
        j = col,
        value = NA)
  }

  # Replace " " with NA
  for (col in names(DT)[names(DT) %in% c("PRCP_ATTRIBUTES",
                                         "MIN_ATTRIBUTES",
                                         "MAX_ATTRIBUTES")]) {
    set(DT,
        i = which(DT[[col]] == " "),
        j = col,
        value = NA)
  }

  # Add STNID col --------------------------------------------------------------
  DT[, STNID := gsub('^(.{6})(.*)$', '\\1-\\2', DT$STATION)]

  # Add and convert date related columns ---------------------------------------
  DT[, YEARMODA := as.Date(DATE, format = "%Y-%m-%d")]
  DT[, YEAR := as.integer(substr(DATE, 1, 4))]
  DT[, MONTH := as.integer(substr(DATE, 6, 7))]
  DT[, DAY := as.integer(substr(DATE, 9, 10))]
  DT[, YDAY := as.integer(strftime(as.Date(DATE), format = "%j"))]

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
  DT[, TEMP := round((5 / 9) * (TEMP - 32), 1)]
  DT[, DEWP := round((5 / 9) * (DEWP - 32), 1)]
  DT[, WDSP := round(WDSP * 0.514444444, 1)]
  DT[, MXSPD := round(MXSPD * 0.514444444, 1)]
  DT[, GUST := round(GUST * 0.514444444, 1)]
  DT[, VISIB := round(VISIB * 1.60934, 1)]
  DT[, MAX := round((MAX - 32) * (5 / 9), 1)]
  DT[, MIN := round((MIN - 32) * (5 / 9), 1)]
  DT[, PRCP := round(PRCP * 25.4, 1)]
  DT[, SNDP := round(SNDP * 25.4, 1)]

  # Compute EA, ES and RH vars--------------------------------------------------
  # Mean actual (EA) and mean saturation vapour pressure (ES)
  # Monteith JL (1973) Principles of environmental physics.
  #   Edward Arnold, London
  # EA derived from dew point
  DT[, EA := round(0.61078 * exp((17.2694 * (DEWP)) /
                                   ((DEWP) + 237.3)), 1)]
  # ES derived from average temperature
  DT[, ES := round(0.61078 * exp((17.2694 * (TEMP)) /
                                   ((TEMP) + 237.3)), 1)]
  # Calculate relative humidity
  DT[, RH := round(EA / ES * 100, 1)]

  # Join to the station and SRTM data-------------------------------------------
  DT <- isd_history[DT, on = "STNID"]

  setcolorder(
    DT,
    c(
      "STNID",
      "STN_NAME",
      "CTRY",
      "STATE",
      "LATITUDE",
      "LONGITUDE",
      "ELEVATION",
      "ELEV_M_SRTM_90m",
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
      "FRSHTT",
      "EA",
      "ES",
      "RH"
    )
  )
  return(DT)
}
