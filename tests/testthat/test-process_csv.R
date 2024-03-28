test_that(
  ".process_csv returns a data.table", {
    skip_if_offline()
    # Check that .process_gz returns a properly formatted data.table -----------
    load(system.file("extdata", "isd_history.rda", package = "GSODR"))
    setkey(isd_history, "STNID")
    stations <- isd_history

    csv_file <- .download_files(station = "955510-99999", years = "2016")
    csv_out <- .process_csv(csv_file, stations)

    expect_length(csv_out, 47)

    expect_s3_class(csv_out, "data.frame")

    expect_type(csv_out$STNID, "character")
    expect_equal(csv_out$STNID[[1]], "955510-99999")

    expect_type(csv_out$NAME, "character")
    expect_equal(csv_out$NAME[[1]], "TOOWOOMBA AIRPORT")

    expect_type(csv_out$CTRY, "character")
    expect_equal(csv_out$CTRY[[1]], "AS")

    expect_type(csv_out$LATITUDE, "double")
    expect_equal(csv_out$LATITUDE[[1]], -27.55, tolerance = 0.01)

    expect_type(csv_out$LONGITUDE, "double")
    expect_equal(csv_out$LONGITUDE[[1]], 151.9, tolerance = 0.01)

    expect_type(csv_out$ELEVATION, "double")
    expect_equal(csv_out$ELEVATION[[1]], 642, tolerance = 0.01)

    expect_type(csv_out$YEARMODA, "double")
    expect_equal(csv_out$YEARMODA[[1]], as.Date("2016-01-01"))

    expect_type(csv_out$YEAR, "integer")
    expect_equal(csv_out$YEAR[[1]], 2016)

    expect_type(csv_out$MONTH, "integer")
    expect_equal(csv_out$MONTH[[1]], 1)

    expect_type(csv_out$DAY, "integer")
    expect_equal(csv_out$DAY[[1]], 1)

    expect_type(csv_out$YDAY, "integer")
    expect_equal(csv_out$YDAY[[1]], 1)

    expect_type(csv_out$TEMP, "double")
    expect_equal(csv_out$TEMP[[1]], 20.2, tolerance = 0.1)

    expect_type(csv_out$TEMP_ATTRIBUTES, "integer")
    expect_equal(csv_out$TEMP_ATTRIBUTES[[1]], 8)

    expect_type(csv_out$DEWP, "double")
    expect_equal(csv_out$DEWP[[1]], 12.4, tolerance = 0.1)

    expect_type(csv_out$DEWP_ATTRIBUTES, "integer")
    expect_equal(csv_out$DEWP_ATTRIBUTES[[1]], 8)

    expect_type(csv_out$SLP, "double")
    expect_equal(csv_out$SLP[[1]], 1011, tolerance = 0.1)

    expect_type(csv_out$SLP_ATTRIBUTES, "integer")
    expect_equal(csv_out$SLP_ATTRIBUTES[[1]], 8)

    expect_type(csv_out$STP, "double")
    expect_equal(csv_out$STP[[1]], 939.6, tolerance = 0.1)

    expect_type(csv_out$STP_ATTRIBUTES, "integer")
    expect_equal(csv_out$STP_ATTRIBUTES[[1]], 8)

    expect_type(csv_out$VISIB, "double")
    expect_equal(csv_out$VISIB[[1]], as.double(NA))

    expect_type(csv_out$VISIB_ATTRIBUTES, "integer")
    expect_equal(csv_out$VISIB_ATTRIBUTES[[1]], 0)

    expect_type(csv_out$WDSP, "double")
    expect_equal(csv_out$WDSP[[1]], 5.2, tolerance =  0.1)

    expect_type(csv_out$WDSP_ATTRIBUTES, "integer")
    expect_equal(csv_out$WDSP_ATTRIBUTES[[1]], 8)

    expect_type(csv_out$MXSPD, "double")
    expect_equal(csv_out$MXSPD[[1]], 7.2, tolerance = 0.1)

    expect_type(csv_out$GUST, "double")
    expect_equal(csv_out$GUST[[1]], as.double(NA))

    expect_type(csv_out$MAX, "double")
    expect_equal(csv_out$MAX[[1]], 25.7, tolerance = 0.1)

    expect_type(csv_out$MAX_ATTRIBUTES, "character")
    expect_equal(csv_out$MAX_ATTRIBUTES[[1]], "*")

    expect_type(csv_out$MIN, "double")
    expect_equal(csv_out$MIN[[1]], 14.5, tolerance = 0.1)

    expect_type(csv_out$MIN_ATTRIBUTES, "character")
    expect_equal(csv_out$MIN_ATTRIBUTES[[1]], as.character(NA))

    expect_type(csv_out$PRCP, "double")
    expect_equal(csv_out$PRCP[[1]], 0)

    expect_type(csv_out$PRCP_ATTRIBUTES, "character")
    expect_equal(csv_out$PRCP_ATTRIBUTES[[1]], "I")

    expect_type(csv_out$SNDP, "double")
    expect_equal(csv_out$SNDP[[1]], as.double(NA))

    expect_type(csv_out$I_FOG, "double")
    expect_equal(csv_out$I_FOG[[1]], 0)

    expect_type(csv_out$I_RAIN_DRIZZLE, "double")
    expect_equal(csv_out$I_RAIN_DRIZZLE[[1]], 0)

    expect_type(csv_out$I_SNOW_ICE, "double")
    expect_equal(csv_out$I_SNOW_ICE[[1]], 0)

    expect_type(csv_out$I_HAIL, "double")
    expect_equal(csv_out$I_HAIL[[1]], 0)

    expect_type(csv_out$I_THUNDER, "double")
    expect_equal(csv_out$I_THUNDER[[1]], 0)

    expect_type(csv_out$I_TORNADO_FUNNEL, "double")
    expect_equal(csv_out$I_TORNADO_FUNNEL[[1]], 0)

    expect_type(csv_out$EA, "double")
    expect_equal(csv_out$EA[[1]], 1.4, tolerance = 0.1)

    expect_type(csv_out$ES, "double")
    expect_equal(csv_out$ES[[1]], 2.4, tolerance = 0.1)

    expect_type(csv_out$RH, "double")
    expect_equal(csv_out$RH[[1]], 60.8, tolerance = 0.1)
  }
)
