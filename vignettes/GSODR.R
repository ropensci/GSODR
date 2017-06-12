## ----check_packages, echo=FALSE, messages=FALSE, warning=FALSE-----------
required <- c("ggplot2", "tidyr", "lubridate")

if (!all(unlist(lapply(required, function(pkg) requireNamespace(pkg, quietly = TRUE)))))
  knitr::opts_chunk$set(eval = FALSE)

## ---- eval = TRUE, message = FALSE---------------------------------------
library(ggplot2)
library(GSODR)

utils::data("isd_history", package = "GSODR")
GSOD_stations <- as.data.frame(isd_history)

ggplot(GSOD_stations, aes(x = LON, y = LAT)) +
  geom_point(alpha = 0.1) +
  theme_bw()

