context("update_station_list")

  # Check stations list and associated metadata for validity -------------------
  test_that("stations list and associated metatdata", {
    skip_on_cran()

    stations <- update_station_list()

    expect_length(stations, 13)

    expect_is(stations, "data.table")
    expect_is(stations$USAF, "character")
    expect_is(stations$WBAN, "character")
    expect_is(stations$STN_NAME, "character")
    expect_is(stations$CTRY, "character")
    expect_is(stations$STATE, "character")
    expect_is(stations$CALL, "character")
    expect_is(stations$LAT, "numeric")
    expect_is(stations$LON, "numeric")
    expect_is(stations$ELEV_M, "numeric")
    expect_is(stations$BEGIN, "numeric")
    expect_is(stations$END, "numeric")
    expect_is(stations$STNID, "character")
    expect_is(stations$ELEV_M_SRTM_90m, "numeric")
    
    expect_equal(options("timeout")[[1]], 60)
  })
