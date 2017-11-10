
# Check that reformat_GSOD functions properly ----------------------------------
context("reformat_GSOD")
file.remove(file.path(tempdir(), list.files(tempdir(), pattern = ".op.gz$")))
test_that("reformat_GSOD file_list parameter reformats data properly", {
  skip_on_cran()

  do.call(file.remove, list(list.files(
    tempdir(),
    pattern = ".gz$",
    full.names = TRUE
  )))

  ftp_base <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1960/"
  test_files <-
    c("066000-99999-1960.op.gz", "066200-99999-1960.op.gz")
  dsn <- tempdir()
  destinations <- file.path(dsn, test_files)

  Map(
    function(u, d)
      download.file(u, d, mode = "wb"),
    paste0(ftp_base, test_files),
    destinations
  )

  file_list <- list.files(path = dsn,
                          pattern = "^.*\\.op.gz$",
                          full.names = TRUE)
  expect_equal(length(file_list), 2)
  expect_equal(basename(file_list),
               c("066000-99999-1960.op.gz",
                 "066200-99999-1960.op.gz"))

  # check that provided a file list, the function works properly
  x <- reformat_GSOD(file_list = file_list)
  expect_equal(nrow(x), 722)
  expect_length(x, 48)
  expect_is(x, "data.frame")

  # check that provided a dsn only, the function works properly
  x <- reformat_GSOD(dsn = dsn)
  expect_equal(nrow(x), 722)
  expect_length(x, 48)
  expect_is(x, "data.frame")

  unlink(destinations)

})
