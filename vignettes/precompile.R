# vignettes that depend on Internet access need to be pre-compiled
library("knitr")
knit("vignettes/GSODR.Rmd.orig", "vignettes/GSODR.Rmd")

# remove file path such that vignettes will build with figures
replace <- readLines("vignettes/GSODR.Rmd")
replace <- gsub("<img src=\"vignettes/", "<img src=\"", replace)
file_conn <- file("vignettes/GSODR.Rmd")
writeLines(replace, file_conn)
close(file_conn)

# build vignettes
library("devtools")
build_vignettes()
