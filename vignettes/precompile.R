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

# move resource files to /doc
resources <-
  list.files("vignettes/", pattern = ".png$", full.names = TRUE)
file.copy(from = resources,
          to = "doc",
          overwrite =  TRUE)
