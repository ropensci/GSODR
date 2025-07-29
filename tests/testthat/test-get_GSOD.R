load(system.file("extdata", "isd_history.rda", package = "GSODR"))

# Check that invalid years are handled gracefully -----------------------------

test_that("invalid years are handled gracefully", {
  skip_if_offline()
  expect_error(get_GSOD(years = ""))
  expect_error(get_GSOD(years = "nineteen ninety two"))
  expect_error(get_GSOD(years = "1923"))
  expect_error(get_GSOD(years = 1923))
  expect_error(get_GSOD(years = 1901 + as.POSIXlt(Sys.Date())$year))
  expect_error(get_GSOD(years = 0))
  expect_error(get_GSOD(years = -1))
})

# some of these tests, test the sub-functions to avoid downloading files
# Check that .validate_years handles valid years -------------------------------
test_that(".validate_years handles valid years", {
  skip_if_offline()
  expect_silent(.validate_years(years = 1929:2016))
  expect_silent(.validate_years(years = 2016))
})

# Check that invalid stations are handled --------------------------------------
test_that("invalid stations are handled", {
  skip_if_offline()
  expect_error(.validate_station_id(
    station = "aaa-bbbbbb",
    isd_history = isd_history
  ))
})

# Check that station validation for years available on server works properly ---
test_that("Station validations are properly handled for years available", {
  skip_if_offline()
  expect_warning(.validate_station_data_years(
    station = "949999-00170",
    isd_history = isd_history,
    years = 2010
  ))
})

test_that("Station validations are properly handled for years available", {
  skip_if_offline()
  expect_silent(.validate_station_data_years(
    years = 2010,
    station = "955510-99999",
    isd_history = isd_history
  ))
})

# Check missing days in non-leap years -----------------------------------------
test_that("missing days check allows stations with permissible days missing,
          non-leap year", {
  skip_if_offline()
  max_missing <- 5
  td <- tempdir()
  just_right_2015 <-
    data.frame(c(rep(12, 360)), c(rep("X", 360)))
  too_short_2015 <-
    data.frame(c(rep(12, 300)), c(rep("X", 300)))
  df_list <- list(just_right_2015, too_short_2015)
  dir.create(path = file.path(td, "2015"))

  filenames <- c("just_right0", "too_short00")
  sapply(
    seq_len(length(df_list)),
    function(x) {
      write.csv(
        df_list[[x]],
        file = paste0(
          td,
          "/2015/",
          filenames[x],
          ".csv"
        )
      )
    }
  )
  GSOD_list <-
    list.files(
      path = file.path(td, "2015"),
      pattern = ".csv$",
      full.names = TRUE
    )

  if (!is.null(max_missing)) {
    GSOD_list_filtered <- .validate_missing_days(
      max_missing,
      GSOD_list
    )
  }
  expect_length(GSOD_list, 2)
  expect_match(
    basename(GSOD_list_filtered),
    "just_right0.csv"
  )
  rm_files <-
    list.files(file.path(td, "2015"), full.names = TRUE)
  file.remove(rm_files)
  file.remove(file.path(td, "2015"))
})

# Check missing days in leap years ---------------------------------------------
test_that("missing days check allows stations with permissible days missing,
          leap year", {
  skip_if_offline()
  max_missing <- 5
  td <- tempdir()
  just_right_2016 <-
    data.frame(c(rep(12, 361)), c(rep("X", 361)))
  too_short_2016 <-
    data.frame(c(rep(12, 300)), c(rep("X", 300)))
  df_list <- list(just_right_2016, too_short_2016)
  dir.create(path = file.path(td, "2016"))

  filenames <- c("just_right0", "too_short00")
  sapply(
    seq_len(length(df_list)),
    function(x) {
      write.csv(
        df_list[[x]],
        file = paste0(
          td,
          "/2016/",
          filenames[x],
          ".csv"
        )
      )
    }
  )
  GSOD_list <-
    list.files(
      path = file.path(td, "2016"),
      pattern = ".csv$",
      full.names = TRUE
    )
  if (!is.null(max_missing)) {
    GSOD_list_filtered <- .validate_missing_days(
      max_missing,
      GSOD_list
    )
  }

  expect_length(GSOD_list, 2)
  expect_match(basename(GSOD_list_filtered), "just_right0.csv")
  rm_files <-
    list.files(file.path(td, "2016"), full.names = TRUE)
  file.remove(rm_files)
  file.remove(file.path(td, "2016"))
})

# Check that max_missing only accepts positive values --------------------------
test_that("The 'max_missing' parameter will not accept NA values", {
  skip_if_offline()
  expect_error(get_GSOD(years = 2010, max_missing = NA))
})

test_that("The 'max_missing' parameter will not accept values < 1", {
  skip_if_offline()
  expect_error(get_GSOD(years = 2010, max_missing = 0.1))
})

# Check validate country returns a two letter code -----------------------------
test_that("Check validate country returns a two letter code", {
  skip_if_offline()
  # Load country list
  # CRAN NOTE avoidance

  country <- "Philippines"
  Philippines <- .validate_country(country, isd_history)
  expect_match(Philippines, "RP")

  country <- "PHL"
  PHL <- .validate_country(country, isd_history)
  expect_match(PHL, "RP")

  country <- "PH"
  PH <- .validate_country(country, isd_history)
  expect_match(PH, "RP")
})

# Check validate country returns an error on invalid entry----------------------
test_that("Check validate country returns an error on invalid entry when
          mispelled", {
  skip_if_offline()
  country <- "Philipines"
  expect_error(.validate_country(country, isd_history))
})

test_that("Check validate country returns an error on invalid entry when two
  two characters are used that are not in the list", {
  skip_if_offline()
  country <- "RZ"
  expect_error(.validate_country(country, isd_history))
})

test_that("Check validate country returns an error on invalid entry when two
  three characters are used that are not in the list", {
  skip_if_offline()
  country <- "RPS"
  expect_error(.validate_country(country, isd_history))
})

# Check that max_missing is not allowed for current year -----------------------
test_that("max_missing is not allowed for current year", {
  skip_if_offline()
  years <- 1983:format(Sys.Date(), "%Y")
  expect_error(get_GSOD(years = years, max_missing = 5))
})

# Check that only unique stations returned, tempdir() is cleaned up on exit ----
test_that("unique stations are returned, tempdir() is cleaned up on exit", {
  skip_if_offline()
  a <- get_GSOD(years = 1929, station = "039800-99999")
  b <- get_GSOD(years = 1929, station = "039730-99999")
  expect_false(isTRUE(list.files(
    tempdir(),
    pattern = ".csv$",
    full.names = TRUE
  )))
  expect_length(unique(b$STNID), 1)
})

# Check that agroclimatology is returned when requested ------------------------
test_that("agroclimatology data is returned as requested", {
  skip_if_offline()
  a <- get_GSOD(years = 1929, agroclimatology = TRUE)
  expect_lt(max(a$LATITUDE), 60)
  expect_gt(min(a$LATITUDE), -60)
})

# Check that agroclimatology and station cannot be specified concurrently ------
test_that("agroclimatology and station cannot be specified concurrently", {
  skip_if_offline()
  expect_error(get_GSOD(
    years = 2010,
    agroclimatology = TRUE,
    station = "489300-99999"
  ))
})

# Check the structure of the data.table and contents ---------------------------
# this also provides tests for `.process_csv()`
# Check that when specifying a country only that country is returned -----------
test_that("get_GSOD works properly and for one country only", {
  skip_if_offline()
  a <- get_GSOD(years = 1929, country = "UK")
  expect_identical(a$CTRY[1], "UK")
  expect_s3_class(a, "data.table")
  expect_identical(a$STNID[[1]], "030050-99999")
  expect_identical(a$NAME[[1]], "LERWICK")
  expect_identical(a$CTRY[[1]], "UK")
  expect_identical(a$COUNTRY_NAME[[1]], "UNITED KINGDOM")
  expect_identical(a$ISO2C[[1]], "GB")
  expect_identical(a$ISO3C[[1]], "GBR")
  expect_identical(a$STATE[[1]], "")
  expect_equal(a$LATITUDE[[1]], 60.133)
  expect_equal(a$LONGITUDE[[1]], -1.183)
  expect_identical(a$ELEVATION[[1]], 84)
  expect_identical(a$BEGIN[[1]], 19291001L)
  expect_identical(
    lapply(a, class),
    list(
      STNID = "character",
      NAME = "character",
      CTRY = "character",
      COUNTRY_NAME = "character",
      ISO2C = "character",
      ISO3C = "character",
      STATE = "character",
      LATITUDE = "numeric",
      LONGITUDE = "numeric",
      ELEVATION = "numeric",
      BEGIN = "integer",
      END = "integer",
      YEARMODA = "Date",
      YEAR = "integer",
      MONTH = "integer",
      DAY = "integer",
      YDAY = "integer",
      TEMP = "numeric",
      TEMP_ATTRIBUTES = "integer",
      DEWP = "numeric",
      DEWP_ATTRIBUTES = "integer",
      SLP = "numeric",
      SLP_ATTRIBUTES = "integer",
      STP = "numeric",
      STP_ATTRIBUTES = "integer",
      VISIB = "numeric",
      VISIB_ATTRIBUTES = "integer",
      WDSP = "numeric",
      WDSP_ATTRIBUTES = "integer",
      MXSPD = "numeric",
      GUST = "numeric",
      MAX = "numeric",
      MAX_ATTRIBUTES = "character",
      MIN = "numeric",
      MIN_ATTRIBUTES = "character",
      PRCP = "numeric",
      PRCP_ATTRIBUTES = "character",
      SNDP = "numeric",
      I_FOG = "numeric",
      I_RAIN_DRIZZLE = "numeric",
      I_SNOW_ICE = "numeric",
      I_HAIL = "numeric",
      I_THUNDER = "numeric",
      I_TORNADO_FUNNEL = "numeric",
      EA = "numeric",
      ES = "numeric",
      RH = "numeric"
    )
  )
})

test_that("only specified country is returned using 2 letter ISO codes", {
  skip_if_offline()
  a <- get_GSOD(years = 1929, country = "GB")
  expect_identical(a$CTRY[1], "UK")
})

test_that("only specified country is returned using 3 letter ISO codes", {
  skip_if_offline()
  a <- get_GSOD(years = 1929, country = "GBR")
  expect_identical(a$CTRY[1], "UK")
})
