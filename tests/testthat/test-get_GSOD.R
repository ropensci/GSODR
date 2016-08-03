context("get_GSOD")

test_that("get_GSOD works", {
  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()


})

test_that("get_GSOD fails well", {
  skip_on_cran()

  expect_error(gethydro(dbkey = "15081", date_min = "1980-01-01",
                        date_max = "1980-02-02"), "No data found")

})

test_that("invalid stations are handled", {
  skip_on_cran()

  expect_error(gethydro(dbkey = "15081", date_min = 1980-01-01,
                        date_max = "1980-02-02"),
               "Enter dates as quote-wrapped character strings in YYYY-MM-DD format")

})

test_that("invalid years are handled", {
  skip_on_cran()

  expect_error(gethydro(dbkey = "15081", date_min = 1980-01-01,
                        date_max = "1980-02-02"),
               "Enter dates as quote-wrapped character strings in YYYY-MM-DD format")

})

test_that("invalid dsn is handled", {
  skip_on_cran()

  expect_error(gethydro(dbkey = "15081", date_min = 1980-01-01,
                        date_max = "1980-02-02"),
               "Enter dates as quote-wrapped character strings in YYYY-MM-DD format")

})