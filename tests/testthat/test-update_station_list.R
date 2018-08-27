
context("update_station_list")

test_that("If user selects no, database not updated", {
  f <- file()
  options(GSODR_connection = f)
  ans <- "no"
  write(ans, f)
  expect_error(update_station_list())
  options(GSODR_connection = stdin())
  close(f)
})

# update_forecast_locations() d-loads, imports file and resets timeout on exit--
test_that("update_station_list() downloads and imports proper file", {
  skip_on_cran()
  f <- file()
  options(GSODR_connection = f)
  ans <- "yes"
  write(ans, f)
  expect_message(update_station_list())
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  expect_equal(ncol(isd_history), 13)
  expect_named(
    isd_history,
    c(
      "USAF",
      "WBAN",
      "STN_NAME",
      "CTRY",
      "STATE",
      "CALL",
      "LAT",
      "LON",
      "ELEV_M",
      "BEGIN",
      "END",
      "STNID",
      "ELEV_M_SRTM_90m"
    )
  )
  expect_equal(options("timeout")[[1]], 60)
  options(GSODR_connection = stdin())
  close(f)
})
