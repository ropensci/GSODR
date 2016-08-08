#' Select Nearest Stations to Specified Latitude and Longitude
#'
#'Given a latitude and longitiude value entered as decimal degrees (DD),
#'this function will return a dataframe of stations within the specified number
#'of kilometres.
#'
#' @param LAT Latitude expressed as decimal degrees (DD)
#' @param LON Longitude expressed as decimal degrees (DD)
#' @param distance Distance in kilometres from point for which stations are to
#' be returned.
#'
#' @note Some of these data are redistributed with this R package. Originally
#' from these data come from the US NCDC which states that users of these data
#' should take into account the following: \dQuote{The following data and
#' products may have conditions placed on their international commercial use.
#' They can be used within the U.S. or for non-commercial international
#' activities without restriction. The non-U.S. data cannot be redistributed for
#' commercial purposes. Re-distribution of these data by others must provide
#' this same notification.}
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
  
  # this data frame serves to return the list of stations at the end
  stations <- as.data.frame(get("stations", envir = environment()))
  
  # this is a spatial object dataframe for calculating the nearest
  sp_stations <- as.data.frame(get("stations", envir = environment()))
  sp::coordinates(sp_stations) <- c("LON", "LAT")
  sp::proj4string(sp_stations) <- sp::CRS("+init=epsg:4326")

  pt <- data.frame(LON, LAT)
  sp::coordinates(pt) <- c("LON", "LAT")
  sp::proj4string(pt) <- sp::CRS("+init=epsg:4326")

  nearby <- apply(sp::spDists(sp_stations, pt), 2,
                  function(x) paste(which(x < as.numeric(paste(distance))
                                          & x != 0), sep = ", "))

  print(as.data.frame(stations[nearby, ]))
}
