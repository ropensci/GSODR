# Check that get_inventory functions properly ----------------------------------
test_that("get_inventory fetches the inventory doc and returns a data frame", {
  skip_if_offline()
  x <- get_inventory()
  expect_length(x, 25)
  expect_s3_class(x, "data.frame")
  expect_type(x$STNID, "character")
  expect_type(x$NAME, "character")
  expect_type(x$LAT, "double")
  expect_type(x$LON, "double")
  expect_type(x$`ELEV(M)`, "double")
  expect_type(x$CTRY, "character")
  expect_type(x$STATE, "character")
  expect_type(x$BEGIN, "integer")
  expect_type(x$END, "integer")
  expect_type(x$COUNTRY_NAME, "character")
  expect_type(x$ISO2C, "character")
  expect_type(x$ISO3C, "character")
  expect_type(x$YEAR, "integer")
  expect_type(x$JAN, "integer")
  expect_type(x$FEB, "integer")
  expect_type(x$MAR, "integer")
  expect_type(x$APR, "integer")
  expect_type(x$MAY, "integer")
  expect_type(x$JUN, "integer")
  expect_type(x$JUL, "integer")
  expect_type(x$AUG, "integer")
  expect_type(x$SEP, "integer")
  expect_type(x$OCT, "integer")
  expect_type(x$NOV, "integer")
  expect_type(x$DEC, "integer")

  y <- capture.output(x)
  expect_type(y, "character")
  expect_equal(
    y[[1]],
    "  *** FEDERAL CLIMATE COMPLEX INTEGRATED SURFACE DATA INVENTORY ***  "
  )
  expect_equal(
    y[[2]],
    "   This inventory provides the number of weather observations by  "
  )
})

test_that("inventory file is removed after download", {
  skip_if_offline()
  expect_true(!file.exists(file.path(tempdir(), "inventory.txt")))
})
