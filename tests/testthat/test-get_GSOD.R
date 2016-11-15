context("get_GSOD")
# Check that .validate_years handles invalid years -----------------------------
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

# Check that .validate_years handles valid years -------------------------------
test_that(".validate_years handles valid years", {
  skip_on_cran()
expect_error(.validate_years(years = 1929:2016), regexp = NA)

expect_error(.validate_years(years = 2016), regexp = NA)

})

# invalid stations are handled -------------------------------------------------
test_that("invalid stations are handled", {
  skip_on_cran()
  stations <- .fetch_station_list()
  expect_error(.validate_stations(years = 2015, station = "aaa-bbbbbb", stations),
               "\nThis is not a valid station ID number, please check your entry.\n           \nStation IDs are provided as a part of the GSODR package in the\n           'stations' data in the STNID column.\n")
})

# Check that invalid dsn is handled --------------------------------------------
test_that("invalid dsn is handled", {
  skip_on_cran()

  expect_error(.validate_fileout(CSV = FALSE, dsn = "~/R", filename = NULL,
                                 GPKG = FALSE),
               "\nFile dsn does not exist: ~/R.\n")
  expect_error(.validate_fileout(CSV = FALSE, dsn = NULL, filename = "test",
                                 GPKG = FALSE),
               "\nYou need to specify a filetype, CSV or GPKG.")
})

# Check stations list and associated metadata for validity ---------------------
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

# Check missing days in non-leap years -----------------------------------------
test_that("missing days check allows stations with permissible days missing,
          non-leap year", {
  skip_on_cran()
  max_missing <- 5
  td <- tempdir()
  just_right_2015 <- data.frame(c(rep(12, 360)), c(rep("X", 360)))
  too_short_2015 <- data.frame(c(rep(12, 300)), c(rep("X", 300)))
  df_list <- list(just_right_2015, too_short_2015)

  filenames <- c("just_right_2015", "too_short_2015")
  sapply(1:length(df_list),
         function(x) write.csv(df_list[[x]],
                               file = gzfile(
                                 paste0(td, "/", filenames[x], ".csv.gz"))
                               )
  )
  GSOD_list <- as.list(list.files(td, pattern = "2015.csv.gz$"))
  GSOD_list_filtered <- .validate_missing_days(max_missing, GSOD_list, td)

  expect_length(GSOD_list, 2)
  expect_match(GSOD_list_filtered, "just_right_2015.csv.gz")
})

# Check missing days in leap years ---------------------------------------------
test_that("missing days check allows stations with permissible days missing,
          leap year", {
            skip_on_cran()
            max_missing <- 5
            td <- tempdir()
            just_right_2015 <- data.frame(c(rep(12, 361)), c(rep("X", 361)))
            too_short_2015 <- data.frame(c(rep(12, 300)), c(rep("X", 300)))
            df_list <- list(just_right_2015, too_short_2015)

            filenames <- c("just_right_2016", "too_short_2016")
            sapply(1:length(df_list),
                   function(x) write.csv(df_list[[x]],
                                         file = gzfile(
                                           paste0(td, "/", filenames[x],
                                                  ".csv.gz"))
                   )
            )
            GSOD_list <- as.list(list.files(td, pattern = "2016.csv.gz$"))
            GSOD_list_filtered <- .validate_missing_days(max_missing,GSOD_list,
                                                         td)

            expect_length(GSOD_list, 2)

            expect_match(GSOD_list_filtered, "just_right_2015.csv.gz")
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

# "Check validate country returns an error on invalid entry---------------------
test_that("Check validate country returns an error on invalid entry", {
  country <- "Philipines"
  expect_error(.validate_country(country), 
               "Please provide a valid name or 2 or 3 letter ISO country code;
               you can view the entire list of valid countries in this data by
               typing, 'country_list'.")
  
  country <- "RP"
  expect_error(.validate_country(country), 
               "Please provide a valid name or 2 or 3 letter ISO country code;
               you can view the entire list of valid countries in this data by
               typing, 'country_list'.")
  
})


