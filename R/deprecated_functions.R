#' Deprecated function(s) in the GSODR package
#' 
#' These functions are provided for compatibility with older version of
#' the GSODR package.  They may eventually be completely removed.
#' @rdname GSODR-deprecated
#' @name GSODR-deprecated
#' @docType package
#' @export  get_station_list
#' @aliases get_station_list
#' @section Details:
#' \tabular{rl}{
#'   \code{get_station_list} \tab now superceded by \code{\link{update_station_list}}\cr
#' }
#' \code{get_station_list} was used to download the list of weather stations
#' and the corresponding metadata. The station list is no longer fetched 
#' on-the-fly. Instead a version is supplied with the GSODR package upon
#' installation. To update the internal database, please use
#' \code{\link{update_station_list}}.
#' 
#'  
get_station_list <- function() {
  .Deprecated("get_stations_list", package = "GSODR")
  update_station_list()
}
NULL
