## ----check_packages, echo=FALSE, messages=FALSE, warning=FALSE-----------
required <- c("raster", "rgdal", "rgeos")

if (!all(unlist(lapply(required, function(pkg) requireNamespace(pkg, quietly = TRUE)))))
  knitr::opts_chunk$set(eval = FALSE)

