# vignettes that depend on Internet access need to be pre-compiled
library("devtools")
library("here")

install()

library("knitr")

knit("vignettes/GSODR.Rmd.orig", "vignettes/GSODR.Rmd")

purl(
  "vignettes/GSODR.Rmd.orig",
  output = "vignettes/GSODR.R"
)

# remove file path such that vignettes will build with figures
replace <- readLines("vignettes/GSODR.Rmd")
replace <- gsub("<img src=\"vignettes/", "<img src=\"", replace)
file_conn <- file("vignettes/GSODR.Rmd")
writeLines(replace, file_conn)
close(file_conn)

# build vignettes
build_vignettes()

# move resource files to /docs
resources <-
  list.files("vignettes/", pattern = ".png$", full.names = TRUE)
file.copy(
  from = resources,
  to = here("doc"),
  overwrite = TRUE
)
