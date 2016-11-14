context("get_GSOD")

test_that(".validate_years handles invalid years", {
  skip_on_cran()

  expect_error(.validate_years(years = NULL),
    "\nYou must provide at least one year of data to download in a numeric\n         format.\n")
  expect_error( .validate_years(years = "nineteen ninety two"),
    "\nYou must provide at least one year of data to download in a numeric\n         format.\n")
  expect_error(.validate_years(years = 1923),
    "\nThe GSOD data files start at 1929, you have entered a year prior\n             to 1929.\n")
  expect_error(.validate_years(years = 1901 + as.POSIXlt(Sys.Date())$year),
    "\nThe year cannot be greater than current year.\n")
  
})

test_that(".validate_years handles valid years", {
  skip_on_cran()
expect_error(.validate_years(years = 1929:2016), regexp = NA)

expect_error(.validate_years(years = 2016), regexp = NA)

})

test_that("invalid stations are handled", {
  skip_on_cran()
  stations <- .fetch_station_list()
  expect_error(.check_stations(years = 2015, station = "aaa-bbbbbb", stations),
               "\nThis is not a valid station ID number, please check your entry.\n           \nStation IDs are provided as a part of the GSODR package in the\n           'stations' data in the STNID column.\n")
})

test_that("invalid dsn is handled", {
  skip_on_cran()

  expect_error(.validate_fileout(CSV = FALSE, dsn = "~/R", filename = NULL,
                                 GPKG = FALSE),
               "\nFile dsn does not exist: ~/R.\n")
  expect_error(.validate_fileout(CSV = FALSE, dsn = NULL, filename = "test",
                                 GPKG = FALSE),
               "\nYou need to specify a filetype, CSV or GPKG.")
})

test_that("stations list and associated metatdata", {
  skip_on_cran()
  
  stations <- .fetch_station_list()
  
  expect_equal(ncol(stations), 13)
  expect_is(stations, "data.table")
  expect_is(stations$USAF, "character")
  expect_is(stations$WBAN , "character")
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
  expect_gt(nrow(stations), 2300)
})

test_that("missing days check allows stations with permissible days missing", {
  skip_on_cran()
  max_missing <- 5
  GSOD_list <- 
  .check_missing_days(max_missing, GSOD_list)
  
})

