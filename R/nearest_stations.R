
#' Find Nearest GSOD Stations to a Specified Latitude and Longitude
#'
#'Given latitude and longitude values entered as decimal degrees (DD), this
#'function returns a list (atomic vector) of STNID values, which can be used in
#'\code{\link{get_GSOD}} to query for specific stations as an argument in the
#'\code{station} parameter of that function.
#'
#' @param LAT Latitude expressed as decimal degrees (DD) [WGS84]
#' @param LON Longitude expressed as decimal degrees (DD) [WGS84]
#' @param distance Distance in kilometres from point for which stations are to
#' be returned.
#'
#' @note The GSOD data, which are downloaded and manipulated by this R package,
#' stipulate that the following notice should be given.  \dQuote{The following
#' data and products may have conditions placed on their international
#' commercial use.  They can be used within the U.S. or for non-commercial
#' international activities without restriction.  The non-U.S. data cannot be
#' redistributed for commercial purposes.  Re-distribution of these data by
#' others must provide this same notification.}
#'
#' @examples
#' \dontrun{
#' # Find stations within a 100km radius of Toowoomba, QLD, AUS
#'
#' n <- nearest_stations(LAT = -27.5598, LON = 151.9507, distance = 100)
#'}
#' @return \code{\link[base]{vector}} object of station identification numbers
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#' @export
nearest_stations <- function(LAT, LON, distance) {

  # CRAN NOTE avoidance
  isd_history <- NULL
  # load current local copy of isd_history
  load(system.file("extdata", "isd_history.rda", package = "GSODR"))

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

  nearby <- haversine_distance(isd_history["LAT"], isd_history["LON"], LAT, LON)

  nearby <- which(nearby < distance)
  return(isd_history[as.numeric(nearby), ]$STNID)
}
