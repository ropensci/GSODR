
# Check that .process_csv() works properly and returns a tibble ----------------
test_that(
  ".download_files properly works, subsetting for country and
  agroclimatology works and .process_gz returns a tibble", {
    skip_on_cran()
    do.call(file.remove, list(list.files(
      tempdir(),
      pattern = ".csv$",
      full.names = TRUE
    )))
    years <- 1982
    agroclimatology <- TRUE
    country <- "RP"
    station <- NULL

    load(system.file("extdata", "isd_history.rda", package = "GSODR"))
    setkey(isd_history, "STNID")
    stations <- isd_history

    load(system.file("extdata", "isd_history.rda",
                     package = "GSODR"))

    GSOD_list <- .download_files(station,
                                 years)

    agro_list <- .agroclimatology_list(GSOD_list,
                                       stations,
                                       years)
    expect_length(agro_list, 7480)

    RP_list <- .subset_country_list(country,
                                    GSOD_list,
                                    stations,
                                    years)
    expect_length(RP_list, 54)

    # Check that .process_gz returns a properly formatted data.table -----------
    csv_file <- GSOD_list[[10]]
    csv_out <- .process_csv(csv_file, stations)

    expect_length(csv_out, 47)

    expect_is(csv_out, "data.frame")

    expect_is(csv_out$STNID, "character")
    expect_is(csv_out$NAME, "character")
    expect_is(csv_out$CTRY, "character")
    expect_is(csv_out$STATE, "character")
    expect_is(csv_out$LATITUDE, "numeric")
    expect_is(csv_out$LONGITUDE, "numeric")
    expect_is(csv_out$ELEVATION, "numeric")
    expect_is(csv_out$YEARMODA, "Date")
    expect_is(csv_out$YEAR, "integer")
    expect_is(csv_out$MONTH, "integer")
    expect_is(csv_out$DAY, "integer")
    expect_is(csv_out$YDAY, "integer")
    expect_is(csv_out$TEMP, "numeric")
    expect_is(csv_out$TEMP_ATTRIBUTES, "character")
    expect_is(csv_out$DEWP, "numeric")
    expect_is(csv_out$DEWP_ATTRIBUTES, "character")
    expect_is(csv_out$SLP, "numeric")
    expect_is(csv_out$SLP_ATTRIBUTES, "character")
    expect_is(csv_out$STP, "numeric")
    expect_is(csv_out$STP_ATTRIBUTES, "character")
    expect_is(csv_out$VISIB, "numeric")
    expect_is(csv_out$VISIB_ATTRIBUTES, "character")
    expect_is(csv_out$WDSP, "numeric")
    expect_is(csv_out$WDSP_ATTRIBUTES, "character")
    expect_is(csv_out$MXSPD, "numeric")
    expect_is(csv_out$GUST, "numeric")
    expect_is(csv_out$MAX, "numeric")
    expect_is(csv_out$MAX_ATTRIBUTES, "character")
    expect_is(csv_out$MIN, "numeric")
    expect_is(csv_out$MIN_ATTRIBUTES, "character")
    expect_is(csv_out$PRCP, "numeric")
    expect_is(csv_out$PRCP_ATTRIBUTES, "character")
    expect_is(csv_out$SNDP, "numeric")
    expect_is(csv_out$I_FOG, "integer")
    expect_is(csv_out$I_RAIN_DRIZZLE, "integer")
    expect_is(csv_out$I_SNOW_ICE, "integer")
    expect_is(csv_out$I_HAIL, "integer")
    expect_is(csv_out$I_THUNDER, "integer")
    expect_is(csv_out$I_TORNADO_FUNNEL, "integer")
    expect_is(csv_out$EA, "numeric")
    expect_is(csv_out$ES, "numeric")
    expect_is(csv_out$RH, "numeric")
  }
)
