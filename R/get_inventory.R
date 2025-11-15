#' Download and Return a data.table Object of GSOD Weather Station Data Inventories
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function was deprecated because the handling of country inventories has
#'  changed and I did not want to introduce geospatial package dependencies for
#'  this package.
#' @keywords internal
get_inventory <- function() {
  lifecycle::deprecate_stop(
    when = "5.0.0",
    what = "get_inventory()",
    details = c(
      x = "This function was deprecated due to changes in how the country inventories are managed.",
      i = "It has been removed, there is no replacement function."
    )
  )
}
