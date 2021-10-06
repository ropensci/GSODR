
#' Find nearest GSOD stations to a specified latitude and longitude
#'
#' Given latitude and longitude values entered as decimal degrees (DD), this
#' function returns a list (as an atomic vector) of station ID
#' values, which can be used in \code{\link{get_GSOD}} to query for specific
#' stations as an argument in the \code{station} parameter of that function.
#'
#' @param LAT Latitude expressed as decimal degrees (DD) (WGS84)
#' @param LON Longitude expressed as decimal degrees (DD) (WGS84)
#' @param distance Distance in kilometres from point for which stations are to
#' be returned.
#'
#' @note The \acronym{GSOD} data, which are downloaded and manipulated by
#' \CRANpkg{GSODR} stipulate that the following notice should be given.
#' \dQuote{The following data and products may have conditions placed on their
#' international commercial use.  They can be used within the U.S. or for non-
#' commercial international activities without restriction.  The non-U.S. data
#' cannot be redistributed for commercial purposes.  Re-distribution of these
#' data by others must provide this same notification.}
#'
#' @examplesIf interactive()
#' # Find stations within a 100km radius of Toowoomba, QLD, AUS
#'
#' n <- nearest_stations(LAT = -27.5598, LON = 151.9507, distance = 100)
#' n
#'
#' @return By default a class \code{\link[base]{character}}
#'  \code{\link[base]{vector}} object of station identification numbers.
#'  in order from nearest to farthest in increasing order.  If
#'  \code{return_full} is \code{TRUE}, a \code{\link[data.table]{data.table}}
#'  with full station metadata including the distance from the user specified
#'  coordinates is returned.
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @export nearest_stations

nearest_stations <- function(LAT, LON, distance) {
  # CRAN NOTE avoidance
  isd_history <- distance_km <- NULL #nocov
  # load current local copy of isd_history
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))

  user_LAT <- LAT
  user_LON <- LON

  # Distance over a great circle. Reasonable approximation.
  # From HughParsonage in our bomrang package,
  # https://github.com/ropensci/bomrang/blob/master/R/internal_functions.R
  haversine_distance <- function(lat1, lon1, lat2, lon2) {
    # to radians
    lat1 <- lat1 * pi / 180
    lat2 <- lat2 * pi / 180
    lon1 <- lon1 * pi / 180
    lon2 <- lon2 * pi / 180

    delta_lat <- abs(lat1 - lat2)
    delta_lon <- abs(lon1 - lon2)

    # radius of earth
    6371 * 2 * asin(sqrt(`+`(
      (sin(delta_lat / 2)) ^ 2,
      cos(lat1) * cos(lat2) * (sin(delta_lon / 2)) ^ 2
    )))
  }


  isd_history[, distance_km := haversine_distance(
    lat1 = LAT,
    lon1 = LON,
    lat2 = user_LAT,
    lon2 = user_LON
  )]

  return(subset(isd_history[order(distance_km)], distance_km < distance)[[1]])

}
