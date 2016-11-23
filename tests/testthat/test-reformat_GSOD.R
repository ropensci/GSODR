
# Check that reformat_GSOD functions properly ----------------------------------
context("reformat_GSOD")

test_that("reformat_GSOD file_list parameter reformats data properly", {
  skip_on_cran()
  skip_on_appveyor()
  skip_on_travis()

  y <- list.files("data-raw/GSOD-files", full.names = TRUE)
  x <- reformat_GSOD(file_list = y)
  expect_equal(nrow(x), 1454)
  expect_equal(ncol(x), 48)
  expect_type(x, "data.frame")
})

test_that("reformat_GSOD dsn parameter reformats data properly", {
  skip_on_cran()
  skip_on_appveyor()
  skip_on_travis()

  x <- reformat_GSOD(dsn = "data-raw/GSOD-files")
  expect_equal(nrow(x), 1454)
  expect_equal(ncol(x), 48)
  expect_type(x, "data.frame")
})

