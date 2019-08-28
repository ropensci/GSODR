#' @import data.table

.onAttach <- function(libname, pkgname) {
  options(GSODR_connection = stdin())
}
