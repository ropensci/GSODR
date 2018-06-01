
context("get_GSOD")
# Check that .validate_years handles invalid years -----------------------------

test_that(".validate_years handles invalid years", {
  expect_error(.validate_years(years = NULL))
  expect_error(.validate_years(years = "nineteen ninety two"))
  expect_error(.validate_years(years = 1923))
  expect_error(.validate_years(years = 1901 +
                                         as.POSIXlt(Sys.Date())$year))
  expect_error(.validate_years(years = 0))
  expect_error(.validate_years(years = -1))
})

# Check that .validate_years handles valid years -------------------------------
test_that(".validate_years handles valid years", {
  expect_error(.validate_years(years = 1929:2016), regexp = NA)
  expect_error(.validate_years(years = 2016), regexp = NA)
})

# Check that invalid stations are handled --------------------------------------
test_that("invalid stations are handled", {
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  stations <- isd_history
  expect_error(.validate_station(years = 2015,
                                 station = "aaa-bbbbbb",
                                 stations))
})

# Check that station validation for years available on server works properly
test_that("Station validations are properly handled for years available", {
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  stations <- isd_history
  expect_message(.validate_station(station = "949999-00170",
                                   stations,
                                   years = 2010))
})

test_that("Station validations are properly handled for years available", {
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  expect_silent(.validate_station(
    years = 2010,
    station = "955510-99999",
    isd_history = isd_history
  ))
})

# Check missing days in non-leap years -----------------------------------------
test_that("missing days check allows stations with permissible days missing,
          non-leap year",
          {
            max_missing <- 5
            td <- tempdir()
            just_right_2015 <-
              data.frame(c(rep(12, 360)), c(rep("X", 360)))
            too_short_2015 <-
              data.frame(c(rep(12, 300)), c(rep("X", 300)))
            df_list <- list(just_right_2015, too_short_2015)

            filenames <- c("just_right_2015", "too_short_2015")
            sapply(1:length(df_list),
                   function(x)
                     write.csv(df_list[[x]],
                               file = gzfile(paste0(
                                 td, "/", filenames[x],
                                 ".csv.gz"
                               ))))
            GSOD_list <-
              list.files(path = td,
                         pattern = ".2015.csv.gz$",
                         full.names = TRUE)

            if (!is.null(max_missing)) {
              GSOD_list_filtered <- .validate_missing_days(max_missing,
                                                           GSOD_list)
            }
            expect_length(GSOD_list, 2)
            expect_match(basename(GSOD_list_filtered),
                         "just_right_2015.csv.gz")
            unlink(td)
          })

# Check missing days in leap years ---------------------------------------------
test_that("missing days check allows stations with permissible days missing,
          leap year",
          {
            max_missing <- 5
            td <- tempdir()
            just_right_2016 <-
              data.frame(c(rep(12, 361)), c(rep("X", 361)))
            too_short_2016 <-
              data.frame(c(rep(12, 300)), c(rep("X", 300)))
            df_list <- list(just_right_2016, too_short_2016)

            filenames <- c("just_right_2016", "too_short_2016")
            sapply(1:length(df_list),
                   function(x)
                     write.csv(df_list[[x]],
                               file = gzfile(paste0(
                                 td, "/", filenames[x],
                                 ".csv.gz"
                               ))))
            GSOD_list <-
              list.files(path = td,
                         pattern = ".2016.csv.gz$",
                         full.names = TRUE)
            if (!is.null(max_missing)) {
              GSOD_list_filtered <- .validate_missing_days(max_missing,
                                                           GSOD_list)
            }

            expect_length(GSOD_list, 2)
            expect_match(basename(GSOD_list_filtered), "just_right_2016.csv.gz")
            unlink(td)
          })

# Check that max_missing only accepts positive values --------------------------
test_that("The 'max_missing' parameter will not accept NA values", {
  expect_error(get_GSOD(years = 2010, max_missing = NA))
})

test_that("The 'max_missing' parameter will not accept values < 1", {
  expect_error(get_GSOD(years = 2010, max_missing = 0.1))
})

# Check validate country returns a two letter code -----------------------------
test_that("Check validate country returns a two letter code", {
  # Load country list
  # CRAN NOTE avoidance
  country_list <- NULL
  load(system.file("extdata", "country_list.rda", package = "GSODR"))

  country <- "Philippines"
  Philippines <- .validate_country(country, country_list)
  expect_match(Philippines, "RP")

  country <- "PHL"
  PHL <- .validate_country(country, country_list)
  expect_match(PHL, "RP")

  country <- "PH"
  PH <- .validate_country(country, country_list)
  expect_match(PH, "RP")
})

# Check validate country returns an error on invalid entry----------------------
test_that("Check validate country returns an error on invalid entry when
          mispelled",
          {
            country_list <- NULL
            load(system.file("extdata", "country_list.rda", package = "GSODR"))
            country <- "Philipines"
            expect_error(.validate_country(country, country_list))
          })

test_that(
  "Check validate country returns an error on invalid entry when two
  two characters are used that are not in the list",
  {
    country_list <- NULL
    load(system.file("extdata", "country_list.rda", package = "GSODR"))
    country <- "RP"
    expect_error(.validate_country(country, country_list))
  }
)

test_that(
  "Check validate country returns an error on invalid entry when two
  three characters are used that are not in the list",
  {
    country_list <- NULL
    load(system.file("extdata", "country_list.rda", package = "GSODR"))
    country <- "RPS"
    expect_error(.validate_country(country, country_list))
  }
)

test_that("Timeout options are reset on get_GSOD() exit", {
  # get the original timeout value for net connections for last check to be sure
  # get_GSOD() resets on exit.
  skip_on_cran()
  original_timeout <- options("timeout")[[1]]
  x <- get_GSOD(years = 2010, station = "945510-99999")
  expect_is(x, "data.frame")
  expect_equal(options("timeout")[[1]], original_timeout)
  rm(x)
})

# Check that max_missing is not allowed for current year -----------------------
test_that("max_missing is not allowed for current year", {
  years <- 1983:format(Sys.Date(), "%Y")
 expect_error(get_GSOD(years = years, max_missing = 5))
  })
