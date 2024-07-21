
# Check that nearest stations functions properly -------------------------------
test_that("nearest stations returns station IDs nearest to farthest", {
  skip_if_offline()
  n <-
    nearest_stations(LAT = -27.5598,
                     LON = 151.9507,
                     distance = 100)
  expect_equal(dim(n), c(17, 13))
  expect_s3_class(n, "data.table")
  expect_equal(
    n$STNID,
    c(
      "945510-99999",
      "955510-99999",
      "945520-99999",
      "949999-00170",
      "949999-00183",
      "945620-99999",
      "749459-99999",
      "945550-99999",
      "949999-00186",
      "955550-99999",
      "945951-99999",
      "949999-00172",
      "945420-99999",
      "949999-00179",
      "949999-00185",
      "949999-00176",
      "949999-00180"
    )
  )
  rm(n)
})
