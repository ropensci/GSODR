
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

  # set up options for .download_files function
  years <- 1960
  station <-  c("066000-99999", "066200-99999")
  cache_dir <- tempdir()
  ftp_base <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/"


  dir_list_handle <-
    curl::new_handle(
      ftp_use_epsv = FALSE,
      dirlistonly = TRUE,
      crlf = TRUE,
      ssl_verifypeer = TRUE,
      ftp_response_timeout = 30,
      connecttimeout = 8
    )

  ftp_base <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/1960/"

  test_files <-
    c("066000-99999-1960.op.gz", "066200-99999-1960.op.gz")

  dsn <- tempdir()

  destinations <- file.path(dsn, test_files)

  Map(
    function(u, d)
      curl_download(u, d, handle = dir_list_handle, mode = "wb"),
    paste0(ftp_base, test_files),
    destinations
  )

  file_list <- list.files(path = cache_dir,
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


# Check that reformat_GSOD stops if no files are found -------------------------
context("reformat_GSOD")
test_that("reformat_GSOD stops if no files are found", {
  expect_error(reformat_GSOD(dsn = "/dev/NULL"))
})

