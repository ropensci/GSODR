#' Select Nearest Stations to Specified Latitude and Longitude
#'
#'Given a latitude and longitiude value entered as decimal degrees (DD),
#'this function will return a dataframe of stations within the specified number
#'of kilometres.
#'
#' @param LAT Latitude expressed as decimal degrees (DD)
#' @param LON Longitude expressed as decimal degrees (DD)
#' @param distance Distance in kilometres from point for which stations should
#' be returned.
#'
#'@note Users of these data should take into account the following (from the
#' NCDC website): \dQuote{The following data and products may have conditions
#' placed on their international commercial use. They can be used within the
#' U.S. or for non-commercial international activities without restriction. The
#' non-U.S. data cannot be redistributed for commercial purposes.
#' Re-distribution of these data by others must provide this same
#' notification.}
#'
#' @examples
#' # Find stations within a 100km radius of Toowoomba, QLD, AUS
#'
#' nearest_stations(LAT = -27.5598, LON = 151.9507, distance = 100)
#'
#' @export
nearest_stations <- function(LAT, LON, distance) {
  options(warn = 2)
  options(timeout = 300)

  utils::data("stations", package = "GSODR", envir = environment())
  stations <- as.data.frame(get("stations", envir = environment()))

  sp_stations <- stations
  sp::coordinates(sp_stations) <- ~LON + LAT

  sp_stations <- stations
  sp::coordinates(sp_stations) <- c("LON", "LAT")
  sp::proj4string(sp_stations) <- sp::CRS("+init=epsg:4326")

  x <- 37.359031
  y <- -3.065053
  pt <- data.frame(x, y)
  sp::coordinates(pt) <- c("x", "y")
  sp::proj4string(pt) <- sp::CRS("+init=epsg:4326")

  nearby <- apply(sp::spDists(sp_stations, pt), 2,
                  function(x) paste(which(x < 500 & x != 0), sep = ", "))

  return(stations_df[nearby, ])
}
