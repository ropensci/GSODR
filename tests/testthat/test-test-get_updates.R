test_that("get_updates() returns a data.table", {
  x <- get_updates()
  expect_s3_class(x, "data.table")
  expect_named(x, c("STNID", "YEAR", "DATE", "COMMENT"))
  expect_type(x$STNID, "character")
  expect_type(x$YEAR, "integer")
  expect_s3_class(x$DATE, "Date")
  expect_type(x$COMMENT, "character")
})
