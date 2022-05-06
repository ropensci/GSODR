
# Check that .validate_years handles invalid years -----------------------------

test_that(".validate_years handles invalid years", {
  skip_on_cran()
  expect_error(.validate_years())
  expect_error(.validate_years(years = "nineteen ninety two"))
  expect_error(.validate_years(years = 1923))
  expect_error(.validate_years(years = 1901 +
                                 as.POSIXlt(Sys.Date())$year))
  expect_error(.validate_years(years = 0))
  expect_error(.validate_years(years = -1))
})

# Check that .validate_years handles valid years -------------------------------
test_that(".validate_years handles valid years", {
  skip_on_cran()
  expect_error(.validate_years(years = 1929:2016), regexp = NA)
  expect_error(.validate_years(years = 2016), regexp = NA)
})

# Check that invalid stations are handled --------------------------------------
test_that("invalid stations are handled", {
  skip_on_cran()
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  stations <- isd_history
  expect_error(.validate_station(years = 2015,
                                 station = "aaa-bbbbbb",
                                 stations))
})

# Check that station validation for years available on server works properly
test_that("Station validations are properly handled for years available", {
  skip_on_cran()
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  stations <- isd_history
  expect_error(.validate_station(station = "949999-00170",
                                 stations,
                                 years = 2010))
})

test_that("Station validations are properly handled for years available", {
  skip_on_cran()
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
  expect_silent(.validate_station(
    years = 2010,
    station = "955510-99999",
    isd_history = isd_history
  ))
})

# Check missing days in non-leap years -----------------------------------------
test_that("missing days check allows stations with permissible days missing,
          non-leap year", {
            skip_on_cran()
            max_missing <- 5
            td <- tempdir()
            just_right_2015 <-
              data.frame(c(rep(12, 360)), c(rep("X", 360)))
            too_short_2015 <-
              data.frame(c(rep(12, 300)), c(rep("X", 300)))
            df_list <- list(just_right_2015, too_short_2015)
            dir.create(path = file.path(td, "2015"))

            filenames <- c("just_right0", "too_short00")
            sapply(seq_len(length(df_list)),
                   function(x)
                     write.csv(df_list[[x]],
                               file = paste0(td, "/2015/", filenames[x],
                                             ".csv")))
            GSOD_list <-
              list.files(
                path = file.path(td, "2015"),
                pattern = ".csv$",
                full.names = TRUE
              )

            if (!is.null(max_missing)) {
              GSOD_list_filtered <- .validate_missing_days(max_missing,
                                                           GSOD_list)
            }
            expect_length(GSOD_list, 2)
            expect_match(basename(GSOD_list_filtered),
                         "just_right0.csv")
            rm_files <-
              list.files(file.path(td, "2015"), full.names = TRUE)
            file.remove(rm_files)
            file.remove(file.path(td, "2015"))
          })

# Check missing days in leap years ---------------------------------------------
test_that("missing days check allows stations with permissible days missing,
          leap year", {
            skip_on_cran()
            max_missing <- 5
            td <- tempdir()
            just_right_2016 <-
              data.frame(c(rep(12, 361)), c(rep("X", 361)))
            too_short_2016 <-
              data.frame(c(rep(12, 300)), c(rep("X", 300)))
            df_list <- list(just_right_2016, too_short_2016)
            dir.create(path = file.path(td, "2016"))

            filenames <- c("just_right0", "too_short00")
            sapply(seq_len(length(df_list)),
                   function(x)
                     write.csv(df_list[[x]],
                               file = paste0(td, "/2016/", filenames[x],
                                             ".csv")))
            GSOD_list <-
              list.files(
                path = file.path(td, "2016"),
                pattern = ".csv$",
                full.names = TRUE
              )
            if (!is.null(max_missing)) {
              GSOD_list_filtered <- .validate_missing_days(max_missing,
                                                           GSOD_list)
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
  skip_on_cran()
  expect_error(get_GSOD(years = 2010, max_missing = NA))
})

test_that("The 'max_missing' parameter will not accept values < 1", {
  skip_on_cran()
  expect_error(get_GSOD(years = 2010, max_missing = 0.1))
})

# Check validate country returns a two letter code -----------------------------
test_that("Check validate country returns a two letter code", {
  skip_on_cran()
  # Load country list
  # CRAN NOTE avoidance
  isd_history <- NULL
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))

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
            skip_on_cran()
            isd_history <- NULL
            load(system.file("extdata", "isd_history.rda", package = "GSODR"))
            country <- "Philipines"
            expect_error(.validate_country(country, isd_history))
          })

test_that(
  "Check validate country returns an error on invalid entry when two
  two characters are used that are not in the list", {
    skip_on_cran()
    isd_history <- NULL
    load(system.file("extdata", "isd_history.rda", package = "GSODR"))
    country <- "RZ"
    expect_error(.validate_country(country, isd_history))
  }
)

test_that(
  "Check validate country returns an error on invalid entry when two
  three characters are used that are not in the list", {
    skip_on_cran()
    isd_history <- NULL
    load(system.file("extdata", "isd_history.rda", package = "GSODR"))
    country <- "RPS"
    expect_error(.validate_country(country, isd_history))
  }
)

# Check that max_missing is not allowed for current year -----------------------
test_that("max_missing is not allowed for current year", {
  skip_on_cran()
  years <- 1983:format(Sys.Date(), "%Y")
  expect_error(get_GSOD(years = years, max_missing = 5))
})

# Check that only unique stations returned, tempdir() is cleaned up on exit ----
test_that("unique stations are returned, tempdir() is cleaned up on exit", {
  skip_on_cran()
  a <- get_GSOD(years = 2010, station = "489300-99999")
  b <- get_GSOD(years = 2010, station = "489260-99999")
  expect_false(isTRUE(list.files(
    tempdir(),
    pattern = ".csv$",
    full.names = TRUE
  )))
  expect_equal(length(unique(b$STNID)), 1)
})

# Check that agroclimatology is returned when requested ------------------------
test_that("agroclimatology data is returned as requested", {
  skip_on_cran()
  a <- get_GSOD(years = 1929, agroclimatology = TRUE)
  expect_lt(max(a$LATITUDE), 60)
  expect_gt(min(a$LATITUDE), -60)
})

# Check that agroclimatology and station cannot be specified concurrently ------
test_that("agroclimatology and station cannot be specified concurrently", {
  skip_on_cran()
  expect_error(get_GSOD(
    years = 2010,
    agroclimatology = TRUE,
    station = "489300-99999"
  ))
})

# Check that when specifying a country only that country is returned -----------
test_that("only specified country is returned using FIPS and ISO codes", {
  skip_on_cran()
  a <- get_GSOD(years = 1929, country = "UK")
  expect_equal(a$CTRY[1], "UK")
})

test_that("only specified country is returned using 2 letter ISO codes", {
  skip_on_cran()
  a <- get_GSOD(years = 1930, country = "GB")
  expect_equal(a$CTRY[1], "UK")
})

test_that("only specified country is returned using 3 letter ISO codes", {
  skip_on_cran()
  a <- get_GSOD(years = 1931, country = "GBR")
  expect_equal(a$CTRY[1], "UK")
})


# Check that if an invalid station/year combo is selected, error result --------
test_that("when year is selected for a station not providing it, error", {
  skip_on_cran()
  expect_message(get_GSOD(years = 1950, station = "959360-99999"),
                 regexp = "This station, 959360-99999, only provides")
})
