# vignettes that depend on internet access need to be precompiled
library(knitr)
knit("vignettes/GSODR.Rmd.orig", "vignettes/GSODR.Rmd")
knit("vignettes/Spatial.Rmd.orig", "vignettes/Spatial.Rmd")
knit(
  "vignettes/Working_with_spatial_and_climate_data.Rmd.orig",
  "vignettes/Working_with_spatial_and_climate_data.Rmd"
)

# remove file path such that vignette will build with figures
replace <- readLines("vignettes/GSODR.Rmd")
replace <- gsub("<img src=\"vignettes/", "<img src=\"", replace)
fileConn <- file("vignettes/GSODR.Rmd")
writeLines(replace, fileConn)
close(fileConn)

# build vignettes
library(devtools)
build_vignettes()
