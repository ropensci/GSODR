
context("update_station_list")

test_that("If user selects no, database not updated", {
  f <- file()
  options(GSODR_connection = f)
  ans <- "no"
  write(ans, f)
  expect_error(update_station_list())
  options(GSODR_connection = stdin())
  close(f)
})
