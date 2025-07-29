load(system.file("extdata", "isd_history.rda", package = "GSODR"))

test_that("If user selects no, database not updated", {
  skip_if_offline()
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
  skip_if_offline()
  f <- file()
  options(GSODR_connection = f)
  ans <- "yes"
  write(ans, f)
  expect_message(update_station_list())
  expect_identical(ncol(isd_history), 12L)
  expect_named(
    isd_history,
    c(
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
  )
  expect_identical(options("timeout")[[1L]], 60L)
  options(GSODR_connection = stdin())
  close(f)
})
