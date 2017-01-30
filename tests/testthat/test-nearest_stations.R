
# Check that nearest stations functions properly -------------------------------
context("nearest_stations")

test_that("nearest stations returns character value station IDs", {
  skip_on_cran()

  n <- nearest_stations(LAT = -27.5598, LON = 151.9507, distance = 100)
  expect_length(n, 15)
  expect_type(n, "character")
  expect_equal(n, c("749459-99999",
                    "945420-99999",
                    "945490-99999",
                    "945510-99999",
                    "945520-99999",
                    "945550-99999",
                    "945620-99999",
                    "945951-99999",
                    "949999-00170",
                    "949999-00172",
                    "949999-00179",
                    "949999-00183",
                    "949999-00186",
                    "955510-99999",
                    "955550-99999"))
  rm(n)

})

test_that("Timeout options are reset on nearest_stations() exit", {
  skip_on_cran()
  n <- nearest_stations(LAT = -27.5598, LON = 151.9507, distance = 10)
  expect_equal(options("timeout")[[1]], 60)
  rm(n)
})

