#' Processes GSOD Data for Use in an R Session
#'
#' @param x A `data.table` generated from `.download_data()`
#' @param isd_history Internal metadata file for station locations
#' @returns A `data.table` of well-formatted weather data
#' @keywords internal
#' @autoglobal
#' @noRd

.process_csv <- function(x, isd_history) {
  # Import data from the website for individual stations or tempdir() for all --
  # The "STP" column is set to be character here to handle the issues with vals
  # over 1000 having the leading zero removed.
  DT <- fread(
    x,
    strip.white = TRUE,
    keepLeadingZeros = TRUE,
    colClasses = c("STP" = "character")
  )

  # Replace 99.99 et al. with NA
  set(DT, i = which(DT[["PRCP"]] == "99.99"), j = "PRCP", value = NA)

  # Replace 999.9 with NA
  for (col in names(DT)[
    names(DT) %in%
      c(
        "VISIB",
        "WDSP",
        "MXSPD",
        "GUST",
        "SNDP"
      )
  ]) {
    set(DT, i = which(DT[[col]] == "999.9"), j = col, value = NA)
  }

  # Replace 9999.99 with NA
  for (col in names(DT)[
    names(DT) %in%
      c(
        "TEMP",
        "DEWP",
        "SLP",
        "STP",
        "MAX",
        "MIN"
      )
  ]) {
    set(DT, i = which(DT[[col]] == "9999.9"), j = col, value = NA)
  }

  # Replace " " with NA
  for (col in names(DT)[
    names(DT) %in%
      c(
        "PRCP_ATTRIBUTES",
        "MIN_ATTRIBUTES",
        "MAX_ATTRIBUTES"
      )
  ]) {
    set(DT, i = which(DT[[col]] == " "), j = col, value = NA)
  }

  # Add STNID col --------------------------------------------------------------
  DT[, STNID := gsub("^(.{6})(.*)$", "\\1-\\2", DT$STATION)]

  # Correct STP values ---------------------------------------------------------
  # The NCEI supplied CSV files are broken, they lop off the "1" in values >1000
  # See https://github.com/ropensci/GSODR/issues/117
  DT[,
    STP := fifelse(
      startsWith(x = STP, prefix = "0"),
      sprintf("%s%s", 1L, DT$STP),
      STP,
      na = NA
    )
  ]

  DT[, STP := fifelse(STP_ATTRIBUTES == " 0", NA, STP)]

  # Add and convert date related columns ---------------------------------------
  DT[, YEARMODA := as.Date(DATE, format = "%Y-%m-%d")]
  DT[, YEAR := as.integer(substr(DATE, 1L, 4L))]
  DT[, MONTH := as.integer(substr(DATE, 6L, 7L))]
  DT[, DAY := as.integer(substr(DATE, 9L, 10L))]
  DT[, YDAY := as.integer(strftime(as.Date(DATE), format = "%j"))]

  # Convert *_ATTRIBUTES cols to integer ---------------------------------------
  for (col in names(DT)[
    names(DT) %in%
      c(
        "TEMP_ATTRIBUTES",
        "DEWP_ATTRIBUTES",
        "SLP_ATTRIBUTES",
        "STP_ATTRIBUTES",
        "VISIB_ATTRIBUTES",
        "WDSP_ATTRIBUTES"
      )
  ]) {
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
  DT[, TEMP := round(0.5556 * (TEMP - 32.0), 1L)]
  DT[, DEWP := round(0.5556 * (DEWP - 32.0), 1L)]
  DT[, WDSP := round(WDSP * 0.514444444, 1L)]
  DT[, MXSPD := round(MXSPD * 0.514444444, 1L)]
  DT[, GUST := round(GUST * 0.514444444, 1L)]
  DT[, VISIB := round(VISIB * 1.60934, 1L)]
  DT[, MAX := round((MAX - 32.0) * 0.5556, 1L)]
  DT[, MIN := round((MIN - 32.0) * 0.5556, 1L)]
  DT[, PRCP := round(PRCP * 25.4, 2L)]
  DT[, SNDP := round(SNDP * 25.4, 1L)]

  # Calculate EA, ES and RH using August-Roche-Magnus approximation ------------
  # Oleg A. Alduchov and Robert E. Eskridge 1995
  # https://doi.org/10.1175/1520-0450(1996)035<0601:IMFAOS>2.0.CO;2
  # EA derived from dew point
  DT[,
    EA := round(
      0.61094 *
        exp(
          (17.625 * (DEWP)) /
            ((DEWP) + 243.04)
        ),
      1L
    )
  ]
  # ES derived from average temperature
  DT[,
    ES := round(
      0.61094 *
        exp(
          (17.625 * (TEMP)) /
            ((TEMP) + 243.04)
        ),
      1L
    )
  ]
  DT[,
    RH := round(
      100L *
        (exp((17.625 * DEWP) / (243.04 + DEWP)) /
          exp((17.625 * (TEMP)) / (243.04 + (TEMP)))),
      1L
    )
  ]

  # Split FRSHTT into separate columns -----------------------------------------
  DT[,
    I_FOG := fifelse(
      DT$FRSHTT != 0L,
      as.numeric(substr(
        x = DT$FRSHTT,
        start = 1L,
        stop = 1L
      )),
      0L
    )
  ]
  DT[,
    I_RAIN_DRIZZLE := fifelse(
      DT$FRSHTT != 0L,
      as.numeric(substr(
        x = DT$FRSHTT,
        start = 2L,
        stop = 2L
      )),
      0L
    )
  ]
  DT[,
    I_SNOW_ICE := fifelse(
      DT$FRSHTT != 0L,
      as.numeric(substr(
        x = DT$FRSHTT,
        start = 3L,
        stop = 3L
      )),
      0L
    )
  ]
  DT[,
    I_HAIL := fifelse(
      DT$FRSHTT != 0L,
      as.numeric(substr(
        x = DT$FRSHTT,
        start = 4L,
        stop = 4L
      )),
      0L
    )
  ]
  DT[,
    I_THUNDER := fifelse(
      DT$FRSHTT != 0L,
      as.numeric(substr(
        DT$FRSHTT,
        start = 5L,
        stop = 5L
      )),
      0L
    )
  ]
  DT[,
    I_TORNADO_FUNNEL := fifelse(
      DT$FRSHTT != 0L,
      as.numeric(substr(
        x = DT$FRSHTT,
        start = 6L,
        stop = 6L
      )),
      0L
    )
  ]
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
