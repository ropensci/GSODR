
.onLoad <-
  function(libname = find.package("GSODR"),
           pkgname = "GSODR") {
    # CRAN Note avoidance
    if (getRversion() >= "2.15.1") {
      utils::globalVariables(c("."))
    }
  }


.onAttach <- function(libname, pkgname) {
  msg <- paste0("\nGSOD is distributed free by the US NCEI with the\n",
                "following conditions.\n",
                "'The following data and products may have conditions placed\n",
                "their international commercial use. They can be used within\n",
                "the U.S. or for non-commercial international activities\n",
                "without restriction. The non-U.S. data cannot be\n",
                "redistributed for commercial purposes. Re-distribution of\n",
                "these data by others must provide this same notification.\n",
                "WMO Resolution 40. NOAA Policy'\n")
  packageStartupMessage(msg)
}
