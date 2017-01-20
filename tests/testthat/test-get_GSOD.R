context("get_GSOD")
# Check that .validate_years handles invalid years -----------------------------
test_that(".validate_years handles invalid years", {

  expect_error(.validate_years(years = NULL),
               "\nYou must provide at least one year of data to download in a numeric\n         format.\n")
  expect_error(.validate_years(years = "nineteen ninety two"),
                "\nYou must provide at least one year of data to download in a numeric\n         format.\n")
  expect_error(.validate_years(years = 1923),
               "\nThe GSOD data files start at 1929, you have entered a year prior\n             to 1929.\n")
  expect_error(.validate_years(years = 1901 + as.POSIXlt(Sys.Date())$year),
               "\nThe year cannot be greater than current year.\n")

})

# Check that .validate_years handles valid years -------------------------------
test_that(".validate_years handles valid years", {

  expect_error(.validate_years(years = 1929:2016), regexp = NA)

  expect_error(.validate_years(years = 2016), regexp = NA)

})

# Check that invalid stations are handled --------------------------------------
test_that("invalid stations are handled", {
  stations <- get_station_list()
  expect_error(.validate_station(years = 2015, station = "aaa-bbbbbb", stations),
               "\naaa-bbbbbb is not a valid station ID number, please check\n      your entry. Station IDs are provided as a part of the GSODR package in the\n      'stations' data\nin the STNID column.\n")
})

# Check that invalid dsn is handled --------------------------------------------
test_that("Missing or invalid dsn is handled", {
  dsn <- "~/NULL"
  expect_error(
    if (!is.null(dsn)) {
    .validate_fileout(CSV = FALSE, dsn = dsn, filename = NULL,
                                 GPKG = FALSE)
    },
               "\nFile dsn does not exist: ~/NULL.\n")

  expect_error(
    if (!is.null(dsn)) {
    .validate_fileout(CSV = FALSE, dsn = dsn, filename = "test",
                                 GPKG = FALSE)
      },
               "\nYou need to specify a filetype, CSV or GPKG.")
  rm(dsn)
})

test_that("If dsn is not specified, defaults to working directory", {
  outfile <- .validate_fileout(CSV = TRUE, dsn = NULL, filename = "test",
                               GPKG = FALSE)
  expect_match(outfile, paste0(getwd(), "/", "test"))
})

# Check missing days in non-leap years -----------------------------------------
test_that("missing days check allows stations with permissible days missing,
          non-leap year", {

            max_missing <- 5
            td <- tempdir()
            just_right_2015 <- data.frame(c(rep(12, 360)), c(rep("X", 360)))
            too_short_2015 <- data.frame(c(rep(12, 300)), c(rep("X", 300)))
            df_list <- list(just_right_2015, too_short_2015)

            filenames <- c("just_right_2015", "too_short_2015")
            sapply(1:length(df_list),
                   function(x) write.csv(df_list[[x]],
                                         file = gzfile(
                                           paste0(td, "/", filenames[x],
                                                  ".csv.gz"))
                   )
            )
            GSOD_list <-
              list.files(path = td,
                         pattern = ".2015.csv.gz$",
                         full.names = TRUE)

            if (!is.null(max_missing)) {
              GSOD_list_filtered <- .validate_missing_days(max_missing,
                                                           GSOD_list)
            }
            expect_length(GSOD_list, 2)
            expect_match(basename(GSOD_list_filtered), "just_right_2015.csv.gz")
            unlink(td)
          })

# Check missing days in leap years ---------------------------------------------
test_that("missing days check allows stations with permissible days missing,
          leap year", {

            max_missing <- 5
            td <- tempdir()
            just_right_2016 <- data.frame(c(rep(12, 361)), c(rep("X", 361)))
            too_short_2016 <- data.frame(c(rep(12, 300)), c(rep("X", 300)))
            df_list <- list(just_right_2016, too_short_2016)

            filenames <- c("just_right_2016", "too_short_2016")
            sapply(1:length(df_list),
                   function(x) write.csv(df_list[[x]],
                                         file = gzfile(
                                           paste0(td, "/", filenames[x],
                                                  ".csv.gz"))
                   )
            )
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

  expect_error(get_GSOD(years = 2010, max_missing = NA),
"\nThe 'max_missing' parameter must be a positive value larger than
           1\n")
})

test_that("The 'max_missing' parameter will not accept values < 1", {

  expect_error(get_GSOD(years = 2010, max_missing = 0.1),
  "\nThe 'max_missing' parameter must be a positive value larger than
           1\n")
})

# Check validate country returns a two letter code -----------------------------
test_that("Check validate country returns a two letter code", {

  country <- "Philippines"
  Philippines <- .validate_country(country)
  expect_match(Philippines, "RP")

  country <- "PHL"
  PHL <- .validate_country(country)
  expect_match(PHL, "RP")

  country <- "PH"
  PH <- .validate_country(country)
  expect_match(PH, "RP")
})

# Check validate country returns an error on invalid entry----------------------
test_that("Check validate country returns an error on invalid entry", {

  country <- "Philipines"
  expect_error(.validate_country(country),
               "\nPlease provide a valid name or 2 or 3 letter ISO country code;\n              you can view the entire list of valid countries in this data by\n              typing, 'country_list'.\n")

  country <- "RP"
  expect_error(.validate_country(country),
               "\nPlease provide a valid name or 2 or 3 letter ISO country code;\n              you can view the entire list of valid countries in this data by\n              typing, 'country_list'.\n")

})
