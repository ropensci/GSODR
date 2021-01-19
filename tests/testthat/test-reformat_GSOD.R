
# Check that reformat_GSOD functions properly ----------------------------------
test_that("reformat_GSOD file_list parameter reformats data properly", {
  skip_on_cran()
  do.call(file.remove, list(list.files(
    tempdir(),
    pattern = ".csv$",
    full.names = TRUE
  )))

  # set up options for curl

  url_base <-
    "https://www.ncei.noaa.gov/data/global-summary-of-the-day/access/1960/"
  test_files <-
    c("06600099999.csv", "06620099999.csv")
  destinations <- file.path(tempdir(), test_files)

  Map(
    function(u, d)
      curl::curl_download(u, d,
                          mode = "wb",
                          quiet = TRUE),
    paste0(url_base, test_files),
    destinations
  )

  file_list <- list.files(path = tempdir(),
                          pattern = "^.*\\.csv$",
                          full.names = TRUE)
  expect_equal(length(file_list), 2)
  expect_equal(basename(file_list),
               c("06600099999.csv",
                 "06620099999.csv"))

  # check that provided a file list, the function works properly
  x <- reformat_GSOD(file_list = file_list)
  expect_equal(nrow(x), 722)
  expect_length(x, 44)
  expect_is(x, "data.frame")

  # check that provided a dsn only, the function works properly
  x <- reformat_GSOD(dsn = tempdir())
  expect_equal(nrow(x), 722)
  expect_length(x, 44)
  expect_is(x, "data.frame")

  # Check that a message is emitted when both dsn and file_list are set --------
  expect_message(reformat_GSOD(dsn = tempdir(),
                               file_list = file_list),
                 regexp = "\nYou have specified both `file_list` and `dsn`. *")

  unlink(destinations)
})


# Check that reformat_GSOD stops if no files are found -------------------------
context("reformat_GSOD")
test_that("reformat_GSOD stops if no files are found", {
  skip_on_cran()
  expect_error(reformat_GSOD(dsn = "/dev/NULL"))
})
