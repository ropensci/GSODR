## ----check_packages, echo=FALSE, messages=FALSE, warning=FALSE-----------
required <- c("ggplot2", "tidyr", "lubridate")

if (!all(unlist(lapply(required, function(pkg) requireNamespace(pkg, quietly = TRUE)))))
knitr::opts_chunk$set(eval = FALSE, collapse = TRUE, comment = "#>", fig.width = 7, fig.height = 7, fig.align = "center")

## ----Ex1, eval=FALSE-----------------------------------------------------
#  library(GSODR)
#  library(data.table)
#  load(system.file("extdata", "country_list.rda", package = "GSODR"))
#  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
#  
#  station_locations <- isd_history[country_list, on = c("CTRY" = "FIPS")]
#  
#  # create data.frame for Australia only
#  Oz <- subset(station_locations, COUNTRY_NAME == "AUSTRALIA")
#  
#  Oz
#  
#  subset(Oz, grepl("TOOWOOMBA", STN_NAME))

## ----Ex2, eval=FALSE-----------------------------------------------------
#  tbar <- get_GSOD(years = 2010, station = "955510-99999")
#  
#  tbar

## ----Ex3, eval=FALSE-----------------------------------------------------
#  tbar_stations <- nearest_stations(LAT = -27.5598,
#                                    LON = 151.9507,
#                                    distance = 50)
#  
#  tbar_stations
#  
#  tbar <- get_GSOD(years = 2010, station = tbar_stations)

## ----Ex4, eval=FALSE-----------------------------------------------------
#  remove <- c("949999-00170", "949999-00183")
#  
#  tbar_stations <- tbar_stations[!tbar_stations %in% remove]
#  
#  tbar <- get_GSOD(years = 2010,
#                   station = tbar_stations)

## ----Ex5, eval=FALSE, fig.width = 7, fig.height = 7, fig.align = "center"----
#  library(ggplot2)
#  library(lubridate)
#  library(tidyr)
#  
#  # Create a dataframe of just the date and temperature values that we want to
#  # plot
#  tbar_temps <- tbar[, c("YEARMODA", "TEMP", "MAX", "MIN")]
#  
#  # Gather the data from wide to long
#  tbar_temps <-
#    gather(tbar_temps, Measurement, gather_cols = TEMP:MIN)
#  
#  ggplot(data = tbar_temps, aes(
#    x = ymd(YEARMODA),
#    y = value,
#    colour = Measurement
#  )) +
#    geom_line() +
#    scale_color_brewer(type = "qual", na.value = "black") +
#    scale_y_continuous(name = "Temperature") +
#    scale_x_date(name = "Date") +
#    theme_bw()

## ----Ex6, eval=FALSE-----------------------------------------------------
#  future::plan("multisession")
#  global <- get_GSOD(years = 2010:2011)
#  summary(global)

## ----Ex15, eval=FALSE----------------------------------------------------
#  y <- c("~/GSOD/gsod_1960/20049099999.csv",
#         "~/GSOD/gsod_1961/20049099999.csv")
#  x <- reformat_GSOD(file_list = y)

## ----Ex16, eval=FALSE----------------------------------------------------
#  x <- reformat_GSOD(dsn = "~/GSOD/gsod_1960")

## ----Ex17, eval=FALSE----------------------------------------------------
#  update_station_list()
#  
#  inventory
#  
#  subset(inventory, STNID %in% "955510-99999")

## ----Ex18, eval=FALSE----------------------------------------------------
#  inventory <- get_inventory()
#  
#  subset(inventory, STNID %in% "955510-99999")

## ----Ex19, eval=FALSE----------------------------------------------------
#  #install.packages("devtools")
#  devtools::install_github("adamhsparks/GSODRdata")
#  library("GSODRdata")

## ---- eval=FALSE, message=FALSE, echo=FALSE, warning=FALSE, fig.width = 7, fig.height = 5, fig.align = "center"----
#  if (requireNamespace("ggplot2", quietly = TRUE) &&
#      requireNamespace("ggthemes", quietly = TRUE) &&
#      requireNamespace("maps", quietly = TRUE) &&
#      requireNamespace("mapproj", quietly = TRUE) &&
#      requireNamespace("gridExtra", quietly = TRUE) &&
#      requireNamespace("grid", quietly = TRUE)) {
#    library(ggplot2)
#    library(mapproj)
#    library(ggthemes)
#    library(maps)
#    library(grid)
#    library(gridExtra)
#    library(GSODR)
#    load(system.file("extdata", "isd_history.rda", package = "GSODR"))
#    world_map <- map_data("world")
#  
#    GSOD_stations <- ggplot(isd_history, aes(x = LON, y = LAT)) +
#      geom_polygon(
#        data = world_map,
#        aes(x = long, y = lat, group = group),
#        color = grey(0.7),
#        fill = NA
#      ) +
#      geom_point(color = "red",
#                 size = 0.05) +
#      coord_map(xlim = c(-180, 180)) +
#      theme_map() +
#      labs(title = "GSOD Station Locations",
#           caption = "Data: US NCEI GSOD and CIA World DataBank II")
#  
#    # Using the gridExtra and grid packages add a neatline to the map
#    grid.arrange(GSOD_stations, ncol = 1)
#    grid.rect(
#      width = 0.98,
#      height = 0.98,
#      gp = grid::gpar(lwd = 0.25,
#                      col = "black",
#                      fill = NA)
#    )
#  }

