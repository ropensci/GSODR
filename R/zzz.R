
.onLoad <-
  function(libname = find.package("GSODR"),
           pkgname = "GSODR") {
    # CRAN Note avoidance
    if (getRversion() >= "2.15.1") {
      utils::globalVariables(c("."))
    }
  }
