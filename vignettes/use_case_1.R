## ----check_packages, echo=FALSE, messages=FALSE, warning=FALSE-----------
required <- c("raster", "rgdal", "rgeos", "sp")

if (!all(unlist(lapply(required, function(pkg) requireNamespace(pkg, quietly = TRUE)))))
    knitr::opts_chunk$set(eval = FALSE, collapse = TRUE, comment = "#>", fig.align = "center", fig.width = 5, fig.height = 5)
library(sp)

## ---- eval=FALSE, message=FALSE------------------------------------------
#  library(raster)
#  RP0 <- getData(country = "Philippines", level = 0)
#  RP1 <- getData(country = "Philippines", level = 1)

## ---- eval=FALSE---------------------------------------------------------
#  Central_Luzon <- RP1[RP1@data$NAME_1 == "Pampanga" |
#                       RP1@data$NAME_1 == "Tarlac" |
#                       RP1@data$NAME_1 == "Pangasinan" |
#                       RP1@data$NAME_1 == "La Union" |
#                       RP1@data$NAME_1 == "Nueva Ecija" |
#                       RP1@data$NAME_1 == "Bulacan", ]

## ---- eval=FALSE---------------------------------------------------------
#  library(rgeos)
#  RP0 <- gSimplify(RP0, tol = 0.05)

## ---- eval=FALSE---------------------------------------------------------
#  library(ggplot2)
#  library(grid)
#  library(gridExtra)
#  library(sp)
#  
#  # get center coordinates of provinces in Central Luzon
#  CL_names <- data.frame(coordinates(Central_Luzon))
#  
#  # this is then used to label the procinces on the map
#  CL_names$label <- Central_Luzon@data$NAME_1
#  
#  # Main map
#  p1 <- ggplot() +
#    geom_polygon(data = Central_Luzon,
#                 aes(x = long,
#                     y = lat,
#                     group = group),
#                 colour = "grey10",
#                 fill = "#fff7bc") +
#    geom_text(data = CL_names, aes(x = X1,
#                                   y = X2,
#                                   label = label),
#              size = 2,
#              colour = "grey20") +
#    theme(axis.text.y = element_text(angle = 90,
#                                     hjust = 0.5)) +
#    ggtitle("Central Luzon Provinces Surveyed") +
#    theme_bw() +
#    xlab("Longitude") +
#    ylab("Latitude") +
#    coord_map()
#  
#  # Inset map
#  p2 <- ggplot() +
#    geom_polygon(data = RP0, aes(long, lat, group = group),
#                 colour = "grey10",
#                 fill = "#fff7bc") +
#    coord_equal() +
#    theme_bw() +
#    labs(x = NULL, y = NULL) +
#    geom_rect(aes(xmin = extent(Central_Luzon)[1],
#                  xmax = extent(Central_Luzon)[2],
#                  ymin = extent(Central_Luzon)[3],
#                  ymax = extent(Central_Luzon)[4]),
#              alpha = 0,
#              colour = "red",
#              size = 0.7,
#              linetype = 1) +
#    theme(axis.text.x = element_blank(),
#          axis.text.y = element_blank(),
#          axis.ticks = element_blank(),
#          axis.title.x = element_blank(),
#          axis.title.y = element_blank(),
#          plot.margin = unit(c(0, 0, 0 ,0), "mm"))
#  
#  grid.newpage()
#  # plot area for the main map
#  v1 <- viewport(width = 1, height = 1, x = 0.5, y = 0.5)
#  
#  # plot area for the inset map
#  v2 <- viewport(width = 0.28, height = 0.28, x = 0.67, y = 0.79)
#  
#  # print the map object
#  print(p1, vp = v1)
#  print(p2, vp = v2)

## ---- eval=FALSE---------------------------------------------------------
#  library(GSODR)
#  
#  # load the station metadata file from GSODR (this loads `isd_history` in your
#  # R sesion)
#  load(system.file("extdata", "isd_history.rda", package = "GSODR"))
#  
#  isd_history <- as.data.frame(isd_history)
#  
#  # convert to a spatial object to find stations within the states
#  coordinates(isd_history) <- ~ LON + LAT
#  proj4string(isd_history) <- proj4string(Central_Luzon)
#  
#  # what are the coordinates? We use the row numbers from this to match the
#  # `stations` data.frame
#  station_coords <- coordinates(isd_history[Central_Luzon, ])
#  
#  # get row numbers as an object
#  rows <- as.numeric(row.names(station_coords))
#  
#  # create a data frame of only the stations which rows have been identified
#  loop_stations <- as.data.frame(isd_history)[rows, ]
#  
#  # subset stations that match our criteria for years
#  loop_stations <- loop_stations[loop_stations$BEGIN <= 19600101 &
#                                 loop_stations$END >= 20151231, ]
#  
#  print(loop_stations[, c(1:2, 3, 7:12)])

## ---- station_locations, eval=FALSE--------------------------------------
#  p1 +
#    geom_point(data = loop_stations,
#               aes(x = LON,
#                   y = LAT),
#               size = 2) +
#    geom_text(data = loop_stations,
#              aes(x = LON,
#                  y = LAT,
#                  label = STN_NAME),
#              alpha = 0.6,
#              size = 2,
#              position = position_nudge(0.1, -0.05)) +
#    ggtitle("Station locations")

## ---- eval=FALSE---------------------------------------------------------
#  PHL <- get_GSOD(station = loop_stations[, 12], years = 1960:2015)

## ---- eval=FALSE---------------------------------------------------------
#  years <- 1960:2015
#  
#  loop_stations <- eval(parse(text = loop_stations[, 12]))
#  
#  # create file list
#  loop_stations <- do.call(
#    paste0, c(expand.grid(loop_stations, "-", years, ".op.gz"))
#    )
#  
#  local_files <- list.files(path = "./GSOD", full.names = TRUE, recursive = TRUE)
#  local_files <- local_files[basename(local_files) %in% loop_stations]
#  
#  loop_data <- reformat_GSOD(file_list = local_files)
#  
#  readr::write_csv(loop_data, path = "Loop_Survey_Weather_1960-2015", path = "./")

## ----cleanup GADM files, eval=TRUE, echo=FALSE, message=FALSE------------
unlink("GADM_2.8_PHL_adm0.rds")
unlink("GADM_2.8_PHL_adm1.rds")

