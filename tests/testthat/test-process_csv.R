test_that(
  ".process_csv returns a data.table", {

    # Check that .process_gz returns a properly formatted data.table -----------
    load(system.file("extdata", "isd_history.rda", package = "GSODR"))
    setkey(isd_history, "STNID")
    stations <- isd_history

    csv_file <- .download_files(station = "955510-99999", years = "2016")
    csv_out <- .process_csv(csv_file, stations)

    expect_length(csv_out, 47)

    expect_is(csv_out, "data.frame")

    expect_is(csv_out$STNID, "character")
    expect_equal(csv_out$STNID[[1]], "955510-99999")

    expect_is(csv_out$NAME, "character")
    expect_equal(csv_out$NAME[[1]], "TOOWOOMBA AIRPORT")

    expect_is(csv_out$CTRY, "character")
    expect_equal(csv_out$CTRY[[1]], "AS")

    expect_is(csv_out$LATITUDE, "numeric")
    expect_equal(csv_out$LATITUDE[[1]], -27.55, tolerance = 0.01)

    expect_is(csv_out$LONGITUDE, "numeric")
    expect_equal(csv_out$LONGITUDE[[1]], 151.9, tolerance = 0.01)

    expect_is(csv_out$ELEVATION, "numeric")
    expect_equal(csv_out$ELEVATION[[1]], 642, tolerance = 0.01)

    expect_is(csv_out$YEARMODA, "Date")
    expect_equal(csv_out$YEARMODA[[1]], as.Date("2016-01-01"))

    expect_is(csv_out$YEAR, "integer")
    expect_equal(csv_out$YEAR[[1]], 2016)

    expect_is(csv_out$MONTH, "integer")
    expect_equal(csv_out$MONTH[[1]], 1)

    expect_is(csv_out$DAY, "integer")
    expect_equal(csv_out$DAY[[1]], 1)

    expect_is(csv_out$YDAY, "integer")
    expect_equal(csv_out$YDAY[[1]], 1)

    expect_is(csv_out$TEMP, "numeric")
    expect_equal(csv_out$TEMP[[1]], 20.2, tolerance = 0.1)

    expect_is(csv_out$TEMP_ATTRIBUTES, "integer")
    expect_equal(csv_out$TEMP_ATTRIBUTES[[1]], 8)

    expect_is(csv_out$DEWP, "numeric")
    expect_equal(csv_out$DEWP[[1]], 12.4, tolerance = 0.1)

    expect_is(csv_out$DEWP_ATTRIBUTES, "integer")
    expect_equal(csv_out$DEWP_ATTRIBUTES[[1]], 8)

    expect_is(csv_out$SLP, "numeric")
    expect_equal(csv_out$SLP[[1]], 1011, tolerance = 0.1)

    expect_is(csv_out$SLP_ATTRIBUTES, "integer")
    expect_equal(csv_out$SLP_ATTRIBUTES[[1]], 8)

    expect_is(csv_out$STP, "numeric")
    expect_equal(csv_out$STP[[1]], 939.6, tolerance = 0.1)

    expect_is(csv_out$STP_ATTRIBUTES, "integer")
    expect_equal(csv_out$STP_ATTRIBUTES[[1]], 8)

    expect_is(csv_out$VISIB, "numeric")
    expect_equal(csv_out$VISIB[[1]], as.numeric(NA))

    expect_is(csv_out$VISIB_ATTRIBUTES, "integer")
    expect_equal(csv_out$VISIB_ATTRIBUTES[[1]], 0)

    expect_is(csv_out$WDSP, "numeric")
    expect_equal(csv_out$WDSP[[1]], 5.2, tolerance =  0.1)

    expect_is(csv_out$WDSP_ATTRIBUTES, "integer")
    expect_equal(csv_out$WDSP_ATTRIBUTES[[1]], 8)

    expect_is(csv_out$MXSPD, "numeric")
    expect_equal(csv_out$MXSPD[[1]], 7.2, tolerance = 0.1)

    expect_is(csv_out$GUST, "numeric")
    expect_equal(csv_out$GUST[[1]], as.numeric(NA))

    expect_is(csv_out$MAX, "numeric")
    expect_equal(csv_out$MAX[[1]], 25.7, tolerance = 0.1)

    expect_is(csv_out$MAX_ATTRIBUTES, "character")
    expect_equal(csv_out$MAX_ATTRIBUTES[[1]], "*")

    expect_is(csv_out$MIN, "numeric")
    expect_equal(csv_out$MIN[[1]], 14.5, tolerance = 0.1)

    expect_is(csv_out$MIN_ATTRIBUTES, "character")
    expect_equal(csv_out$MIN_ATTRIBUTES[[1]], as.character(NA))

    expect_is(csv_out$PRCP, "numeric")
    expect_equal(csv_out$PRCP[[1]], 0)

    expect_is(csv_out$PRCP_ATTRIBUTES, "character")
    expect_equal(csv_out$PRCP_ATTRIBUTES[[1]], "I")

    expect_is(csv_out$SNDP, "numeric")
    expect_equal(csv_out$SNDP[[1]], as.numeric(NA))

    expect_is(csv_out$I_FOG, "numeric")
    expect_equal(csv_out$I_FOG[[1]], 0)

    expect_is(csv_out$I_RAIN_DRIZZLE, "numeric")
    expect_equal(csv_out$I_RAIN_DRIZZLE[[1]], 0)

    expect_is(csv_out$I_SNOW_ICE, "numeric")
    expect_equal(csv_out$I_SNOW_ICE[[1]], 0)

    expect_is(csv_out$I_HAIL, "numeric")
    expect_equal(csv_out$I_HAIL[[1]], 0)

    expect_is(csv_out$I_THUNDER, "numeric")
    expect_equal(csv_out$I_THUNDER[[1]], 0)

    expect_is(csv_out$I_TORNADO_FUNNEL, "numeric")
    expect_equal(csv_out$I_TORNADO_FUNNEL[[1]], 0)

    expect_is(csv_out$EA, "numeric")
    expect_equal(csv_out$EA[[1]], 1.4, tolerance = 0.1)

    expect_is(csv_out$ES, "numeric")
    expect_equal(csv_out$ES[[1]], 2.4, tolerance = 0.1)

    expect_is(csv_out$RH, "numeric")
    expect_equal(csv_out$RH[[1]], 60.8, tolerance = 0.1)
  }
)
