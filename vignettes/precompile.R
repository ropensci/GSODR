# vignettes that depend on Internet access need to be pre-compiled
library("knitr")
knit("vignettes/GSODR.Rmd.orig", "vignettes/GSODR.Rmd")

# remove file path such that vignettes will build with figures
replace <- readLines("vignettes/GSODR.Rmd")
replace <- gsub("<img src=\"vignettes/", "<img src=\"", replace)
fileConn <- file("vignettes/GSODR.Rmd")
writeLines(replace, fileConn)
close(fileConn)

# build vignettes
library("devtools")
build_vignettes()
