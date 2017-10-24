
#' @importFrom rlang .data
#' @noRd
.process_gz <- function(gz_file, isd_history) {
  tmp <- readr::read_fwf(
    file = gz_file,
    skip = 1,
    readr::fwf_positions(
      c(
        1,
        8,
        15,
        19,
        25,
        32,
        36,
        43,
        47,
        54,
        58,
        65,
        69,
        75,
        79,
        85,
        89,
        96,
        103,
        109,
        111,
        117,
        119,
        124,
        126,
        133,
        134,
        135,
        136,
        137,
        138
      ),
      c(
        6,
        12,
        18,
        22,
        30,
        33,
        41,
        44,
        52,
        55,
        63,
        66,
        73,
        76,
        83,
        86,
        93,
        100,
        108,
        109,
        116,
        117,
        123,
        124,
        130,
        133,
        134,
        135,
        136,
        137,
        138
      ),
      col_names = c(
        "STN",
        "WBAN",
        "YEAR",
        "MODA",
        "TEMP",
        "TEMP_CNT",
        "DEWP",
        "DEWP_CNT",
        "SLP",
        "SLP_CNT",
        "STP",
        "STP_CNT",
        "VISIB",
        "VISIB_CNT",
        "WDSP",
        "WDSP_CNT",
        "MXSPD",
        "GUST",
        "MAX",
        "MAX_FLAG",
        "MIN",
        "MIN_FLAG",
        "PRCP",
        "PRCP_FLAG",
        "SNDP",
        "I_FOG",
        "I_RAIN_DRIZZLE",
        "I_SNOW_ICE",
        "I_HAIL",
        "I_THUNDER",
        "I_TORNADO_FUNNEL"
      )
    ),
    col_types = c("ccccdididididididddcdcdcdiiiiii"),
    na = c("9999.9", "999.9", "99.99")
  )

  # Clean up and convert the station and weather data to metric ----------------
  tmp[, "STNID"] <- paste(tmp$STN, tmp$WBAN, sep = "-")
  tmp[, "YEARMODA"] <- paste0(tmp$YEAR, tmp$MODA)
  tmp[, "MONTH"] <- substr(tmp$YEARMODA, 5, 6)
  tmp[, "DAY"] <- substr(tmp$YEARMODA, 7, 8)
  tmp[, "YDAY"] <- as.numeric(strftime(as.Date(
    paste(tmp$YEAR,
          tmp$MONTH,
          tmp$DAY,
          sep = "-")
  ),
  format = "%j"))
  tmp[, "YEARMODA"] <- as.Date(as.character(tmp$YEARMODA),format = "%Y%m%d")

  # drop unnecessary columns
  tmp <- dplyr::select(tmp, -c(.data$WBAN, .data$STN, .data$MODA))

  tmp[, "TEMP"] <- round((5 / 9) * (tmp$TEMP - 32), 1)
  tmp[, "DEWP"] <- round((5 / 9) * (tmp$DEWP - 32), 1)
  tmp[, "WDSP"]  <- round(tmp$WDSP * 0.514444444, 1)
  tmp[, "MXSPD"] <- round(tmp$MXSPD * 0.514444444, 1)
  tmp[, "GUST"]  <- round(tmp$GUST * 0.514444444, 1)
  tmp[, "VISIB"] <- round(tmp$VISIB * 1.60934, 1)
  tmp[, "MAX"]   <- round((tmp$MAX - 32) * (5 / 9), 1)
  tmp[, "MIN"]  <- round((tmp$MIN - 32) * (5 / 9), 1)
  tmp[, "PRCP"]  <- round(tmp$PRCP * 25.4, 1)
  tmp[, "SNDP"] <- round(tmp$SNDP * 25.4, 1)
  # Compute other weather vars--------------------------------------------------
  # Mean actual (EA) and mean saturation vapour pressure (ES)
  # Monteith JL (1973) Principles of environmental physics.
  #   Edward Arnold, London
  # EA derived from dew point
  tmp[, "EA"] <- round(0.61078 * exp((17.2694 * (tmp$DEWP)) /
                                       ((tmp$DEWP) + 237.3)), 1)
  # ES derived from average temperature
  tmp[, "ES"] <- round(0.61078 * exp((17.2694 * (tmp$TEMP)) /
                                       ((tmp$TEMP) + 237.3)), 1)
  # Calculate relative humidity
  tmp[, "RH"] <-  round(tmp$EA / tmp$ES * 100, 1)

  # Join to the station and SRTM data-------------------------------------------

  GSOD_XY <- dplyr::left_join(tmp, isd_history, by = "STNID")

  GSOD_XY <- dplyr::select(
    GSOD_XY,
    c(
      "USAF",
      "WBAN",
      "STNID",
      "STN_NAME",
      "CTRY",
      "STATE",
      "CALL",
      "LAT",
      "LON",
      "ELEV_M",
      "ELEV_M_SRTM_90m",
      "BEGIN",
      "END",
      "YEARMODA",
      "YEAR",
      "MONTH",
      "DAY",
      "YDAY",
      "TEMP",
      "TEMP_CNT",
      "DEWP",
      "DEWP_CNT",
      "SLP",
      "SLP_CNT",
      "STP",
      "STP_CNT",
      "VISIB",
      "VISIB_CNT",
      "WDSP",
      "WDSP_CNT",
      "MXSPD",
      "GUST",
      "MAX",
      "MAX_FLAG",
      "MIN",
      "MIN_FLAG",
      "PRCP",
      "PRCP_FLAG",
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
  rm(tmp)
  tibble::as_tibble(GSOD_XY)
  return(GSOD_XY)
}
