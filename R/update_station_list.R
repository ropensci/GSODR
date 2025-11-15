#' Download Latest isd-history.csv File and Update an Internal Database
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#' This function was deprecated because I realised that it broke reproducibility
#'  and the handling of country inventories has changed and I did not want to
#'  introduce geospatial package dependencies for this package.
#' @keywords internal
update_station_list <- function() {
  lifecycle::deprecate_stop(
    when = "5.0.0",
    what = "update_station_list()",
    details = c(
      x = "This broke reproducibility by changing the local internal state of the package.",
      i = "It has been removed, there is no replacement function."
    )
  )
}
