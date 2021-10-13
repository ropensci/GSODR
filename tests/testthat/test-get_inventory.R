
# Check that get_inventory functions properly ----------------------------------
test_that("get_inventory fetches the inventory doc and returns a data frame", {
  skip_on_cran()
  x <- get_inventory()
  expect_length(x, 24)
  expect_is(x, "data.frame")
  expect_is(x$STNID, "character")
  expect_is(x$NAME, "character")
  expect_is(x$LAT, "numeric")
  expect_is(x$LON, "numeric")
  expect_is(x$CTRY, "character")
  expect_is(x$STATE, "character")
  expect_is(x$BEGIN, "integer")
  expect_is(x$END, "integer")
  expect_is(x$COUNTRY_NAME, "character")
  expect_is(x$ISO2C, "character")
  expect_is(x$ISO3C, "character")
  expect_is(x$YEAR, "integer")
  expect_is(x$JAN, "integer")
  expect_is(x$FEB, "integer")
  expect_is(x$MAR, "integer")
  expect_is(x$APR, "integer")
  expect_is(x$MAY, "integer")
  expect_is(x$JUN, "integer")
  expect_is(x$JUL, "integer")
  expect_is(x$AUG, "integer")
  expect_is(x$SEP, "integer")
  expect_is(x$OCT, "integer")
  expect_is(x$NOV, "integer")
  expect_is(x$DEC, "integer")

  y <- capture.output(x)
  expect_type(y, "character")
  expect_equal(y[[1]],
               "  *** FEDERAL CLIMATE COMPLEX INTEGRATED SURFACE DATA INVENTORY ***  ")
  expect_equal(y[[2]],
               "   This inventory provides the number of weather observations by  ")
})

test_that("inventory file is removed after download", {
  skip_on_cran()
  expect_true(!file.exists(file.path(tempdir(), "inventory.txt")))
})
