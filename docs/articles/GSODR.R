## ----check_packages, echo=FALSE, messages=FALSE, warning=FALSE-----------
required <- c("ggplot2", "tidyr", "lubridate")

if (!all(unlist(lapply(required, function(pkg) requireNamespace(pkg, quietly = TRUE)))))
  knitr::opts_chunk$set(eval = FALSE)

## ---- eval = TRUE, message = FALSE, echo = FALSE, warning=FALSE----------
library(ggplot2)
library(GSODR)

load(system.file("extdata", "isd_history.rda", package = "GSODR"))

ggplot(isd_history, aes(x = LON, y = LAT)) +
  geom_point(alpha = 0.1) +
  theme_bw() +
  labs(title = "GSOD Station Locations",
       caption = "Data: US NCEI isd_history.csv")

