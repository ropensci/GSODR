
context("get_stations_list")

context("update_station_list")

# Timeout options are reset on update_station_list() exit ----------------------
test_that("Timeout options are reset on update_station_list() exit", {
  skip_on_cran()
  update_station_list()
  expect_equal(options("timeout")[[1]], 60)
})

# update_forecast_locations() downloads and imports the proper file ------------
test_that("update_station_list() downloads and imports proper file", {
  skip_on_cran()
  update_station_list()
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
})
