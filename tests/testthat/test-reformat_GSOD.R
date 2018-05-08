
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


  dir_list_handle <-
    curl::new_handle(
      ftp_use_epsv = FALSE,
      dirlistonly = TRUE,
      crlf = TRUE,
      ssl_verifypeer = TRUE,
      ftp_response_timeout = 30,
      connecttimeout = 8
    )
  s_curl_fetch_memory <- purrr::safely(curl::curl_fetch_memory)
  retry_cfm <-
    function(url, handle) {
      i <- 0
      repeat {
        i <- i + 1
        res <- s_curl_fetch_memory(url, handle = handle)
        if (!is.null(res$result))
          return(res$result)
        if (i == max_retries) {
          stop("\nToo many retries...server may be under load\n")
        }
      }
    }
  # Wrapping the disk writer (for the actual files)
  # Note the use of the cache dir. It won't waste your bandwidth or the
  # server's bandwidth or CPU if the file has already been retrieved.
  s_curl_fetch_disk <- purrr::safely(curl::curl_fetch_disk)
  retry_cfd <-
    function(url, path) {
      cache_file <- sprintf("%s/%s", cache_dir, basename(url))
      if (file.exists(cache_file))
        return()
      i <- 0
      repeat {
        i <- i + 1
        if (i == 6) {
          stop("Too many retries...server may be under load")
        }
        res <- s_curl_fetch_disk(url, cache_file)
        if (!is.null(res$result))
          return()
      }
    }

  pb <- dplyr::progress_estimated(length(years))
  purrr::walk(years, function(yr) {
    year_url <- sprintf(ftp_base, yr)
    tmp <- retry_cfm(year_url, handle = dir_list_handle)
    con <- rawConnection(tmp$content)
    fils <- readLines(con)
    close(con)
    # sift out only the target stations
    purrr::map(station, ~ grep(., fils, value = TRUE)) %>%
      purrr::keep(~ length(.) > 0) %>%
      purrr::flatten_chr() -> fils

    if (length(fils) > 0) {
      # grab the station files
      purrr::walk(paste0(year_url, fils), retry_cfd)
      # progress bar
      pb$tick()$print()
    }
    else {
      message("\nThere are no files for station ID ", station, " in ",
              yr, ".\n")
    }
  })

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

