context("get_GSOD")

test_that("get_GSOD handles invalid years", {
  skip_on_cran()

  expect_error(get_GSOD(years = NULL, station = "955510-99999", country = NULL,
                        dsn = "~/", max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE),
               "\nYou must provide at least one year of data to download in a numeric format.\n")

  expect_error(get_GSOD(years = "2010", station = "955510-99999",
                        country = NULL, dsn = "~/", max_missing = 5,
                        agroclimatology = FALSE, CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE),
               "\nYou must provide at least one year of data to download in a numeric format.\n")

  expect_error(get_GSOD(years = 1923, station = "955510-99999", country = NULL,
                        dsn = "~/", max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE),
               "\nThe GSOD data files start at 1929, you have entered a year prior to 1929.\n")

  expect_error(get_GSOD(years = 1901 + as.POSIXlt(Sys.Date())$year,
                        station = "955510-99999", country = NULL, dsn = "~/",
                        max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE),
               "\nThe year cannot be greater than current year.\n")
})

test_that("invalid stations are handled", {
  skip_on_cran()

  expect_error(get_GSOD(years = 1900 + as.POSIXlt(Sys.Date())$year,
                        station = "999990-9999", country = NULL, dsn = "~/",
                        max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE),
               "\nThis is not a valid station ID number, please check your entry.\n
         Station IDs are provided as a part of the GSODR package in the 'stations' data frame in the STNID column.\n")

})

test_that("invalid dsn is handled", {
  skip_on_cran()

  expect_error(get_GSOD(years = 1900 + as.POSIXlt(Sys.Date())$year,
                        station = "999990-9999", country = NULL, dsn = "~/dev/NULL",
                        max_missing = 5, agroclimatology = FALSE,
                        CSV = TRUE, GPKG = FALSE,
                        merge_station_years = FALSE),
               "\nFile dsn does not exist: ~/dev/NULL.\n")

})
