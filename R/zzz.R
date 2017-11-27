
.onAttach <- function(libname, pkgname) {
  msg <- paste0("\nGSOD is distributed free by the U.S. NCEI with the\n",
                "following conditions.\n",
                "'The following data and products may have conditions placed\n",
                "their international commercial use. They can be used within\n",
                "the U.S. or for non-commercial international activities\n",
                "without restriction. The non-U.S. data cannot be\n",
                "redistributed for commercial purposes. Re-distribution of\n",
                "these data by others must provide this same notification.\n",
                "WMO Resolution 40. NOAA Policy'\n",
                "\n",
                "GSODR does not redistribute any weather data itself. It \n",
                "only provides an interface for R users to download these\n",
                "data, however it does redistribute station metadata in the\n",
                "package.\n")
  packageStartupMessage(msg)
}
