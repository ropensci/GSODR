# vignettes that depend on internet access have been precompiled:

library(knitr)
knit("vignettes/GSODR.Rmd.orig", "vignettes/GSODR.Rmd")
knit("vignettes/Spatial.Rmd.orig", "vignettes/Spatial.Rmd")
knit(
  "Working_with_spatial_and_climate_data.Rmd.orig",
  "Working_with_spatial_and_climate_data.Rmd"
)

library(devtools)
build_vignettes()
