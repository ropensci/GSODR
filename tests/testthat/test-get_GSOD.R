context("get_GSOD")

test_that("get_GSOD works", {
  skip_on_cran()


})

test_that("get_GSOD handles invalid years", {
  skip_on_cran()

  expect_error(get_GSOD(years = NULL, station = "955510-99999", country = NULL,
                        dsn = "~/", max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE), "Invalid years selected")

  expect_error(get_GSOD(years = 1923, station = "955510-99999", country = NULL,
                        dsn = "~/", max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE), "Invalid years selected")

  expect_error(get_GSOD(years = 1901 + as.POSIXlt(Sys.Date())$year,
                        station = "955510-99999", country = NULL, dsn = "~/",
                        max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE), "Invalid years selected")


})

test_that("invalid stations are handled", {
  skip_on_cran()

  expect_error(get_GSOD(years = 1900 + as.POSIXlt(Sys.Date())$year,
                        station = "999990-9999", country = NULL, dsn = "~/",
                        max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE),
               "This is not a valid station name")

})

test_that("invalid dsn is handled", {
  skip_on_cran()

  expect_error(get_GSOD(years = 1900 + as.POSIXlt(Sys.Date())$year,
                        station = "999990-9999", country = NULL, dsn = "~/",
                        max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE),
               "This is not a valid dsn for file saving")

})