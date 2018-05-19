
context("get_station_list")
# Check that the deprecated function returns a message -------------------------

test_that("get_station_list returns a deprecated message", {
  expect_warning(get_station_list())
})
