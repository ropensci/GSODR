#' Find Nearest GSOD Stations to a Specified Latitude and Longitude
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
#' @return A \code{\link[data.table]{data.table}} with full station metadata
#' including the distance from the user specified coordinates.
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @autoglobal
#' @export nearest_stations

nearest_stations <- function(LAT, LON, distance) {
  # load current local copy of isd_history
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))

  user_LAT <- LAT
  user_LON <- LON

  # Distance over a great circle. Reasonable approximation.
  # From @HughParsonage in our (now retired) {bomrang} package,
  # https://github.com/ropensci/bomrang/blob/master/R/internal_functions.R
  haversine_distance <- function(lat1, lon1, lat2, lon2) {
    # to radians
    lat1 <- lat1 * 0.01745329 # this is `pi / 180` pre calculated for efficiency
    lat2 <- lat2 * 0.01745329
    lon1 <- lon1 * 0.01745329
    lon2 <- lon2 * 0.01745329

    delta_lat <- abs(lat1 - lat2)
    delta_lon <- abs(lon1 - lon2)

    # radius of earth
    6371 * 2 * asin(sqrt(`+`(
      (sin(delta_lat / 2)) ^ 2,
      cos(lat1) * cos(lat2) * (sin(delta_lon / 2)) ^ 2
    )))
  }


  isd_history[, distance_km := round(haversine_distance(
    lat1 = LAT,
    lon1 = LON,
    lat2 = user_LAT,
    lon2 = user_LON
  ), 1)]

  subset_stns <-
    data.table(subset(isd_history[order(distance_km)],
                      distance_km < distance)[[1]])
  setnames(subset_stns, "V1", "STNID")

  return(isd_history[subset_stns, on = "STNID"])
}
