
.onLoad <-
  function(libname = find.package("GSODR"),
           pkgname = "GSODR") {
    # CRAN Note avoidance
    if (getRversion() >= "2.15.1") {
      utils::globalVariables(c("."))

      utils::data(
        "country_list",
        "isd_history",
        package = pkgname,
        envir = parent.env(environment())
      )
    }
  }
