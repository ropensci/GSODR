
# Check that nearest stations functions properly -------------------------------
context("nearest_stations")

test_that("nearest stations returns station IDs nearest to farthest", {
  n <-
    nearest_stations(LAT = -27.5598,
                     LON = 151.9507,
                     distance = 100)
  expect_length(n, 9)
  expect_type(n, "character")
  expect_equal(
    n,
    c(
      "945510-99999",
      "955510-99999",
      "945520-99999",
      "945620-99999",
      "749459-99999",
      "945550-99999",
      "955550-99999",
      "945951-99999",
      "945420-99999"
    )
  )
  rm(n)
})
