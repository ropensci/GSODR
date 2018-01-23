## ----check_packages, echo=FALSE, messages=FALSE, warning=FALSE-----------
required <- c("raster", "rgdal", "rgeos")

if (!all(unlist(lapply(required, function(pkg) requireNamespace(pkg, quietly = TRUE)))))
    knitr::opts_chunk$set(eval = FALSE, collapse = TRUE, comment = "#>", fig.align = "center")

## ---- eval=TRUE----------------------------------------------------------
library(raster)
RP0 <- raster::getData(country = "Philippines", level = 0)
RP1 <- raster::getData(country = "Philippines", level = 1)

## ---- eval=TRUE----------------------------------------------------------
Central_Luzon <- RP1[RP1@data$NAME_1 == "Pampanga" | 
                     RP1@data$NAME_1 == "Tarlac" |
                     RP1@data$NAME_1 == "Pangasinan" |
                     RP1@data$NAME_1 == "La Union" |
                     RP1@data$NAME_1 == "Nueva Ecija" |
                     RP1@data$NAME_1 == "Bulacan", ]

## ---- eval=TRUE----------------------------------------------------------
RP0 <- rgeos::gSimplify(RP0, tol = 0.05)

## ---- eval=TRUE----------------------------------------------------------
library(ggplot2)
library(grid)
library(gridExtra)

CL_names <- data.frame(coordinates(Central_Luzon)) # get center coordinates of provinces in Central Luzon
CL_names$label <- Central_Luzon@data$NAME_1

# Main Map
p1 <- ggplot() + 
  geom_polygon(data = Central_Luzon, aes(x = long, y = lat, group = group),
               colour = "grey10", fill = "#fff7bc") +
  geom_text(data = CL_names, aes(x = X1, y = X2, label = label), 
            size = 2, colour = "grey20") +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5)) +
  ggtitle("Central Luzon Provinces Surveyed") +
  theme_bw() + 
  xlab("Longitude") + 
  ylab("Latitude") +
  coord_map()

# Inset
p2 <- ggplot() + 
  geom_polygon(data = RP0, aes(long, lat, group = group),
               colour = "grey10",
               fill = "#fff7bc") +
  coord_equal() +
  theme_bw() + 
  labs(x = NULL, y = NULL) +
  geom_rect(aes(xmin = extent(Central_Luzon)[1],
                xmax = extent(Central_Luzon)[2],
                ymin = extent(Central_Luzon)[3],
                ymax = extent(Central_Luzon)[4]),
            alpha = 0,
            colour = "red",
            size = 0.7,
            linetype = 1) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        plot.margin = unit(c(0, 0, 0 ,0), "mm"))

grid.newpage()
v1 <- viewport(width = 1, height = 1, x = 0.5, y = 0.5) # plot area for the main map
v2 <- viewport(width = 0.28, height = 0.28, x = 0.67, y = 0.78) # plot area for the inset map
print(p1, vp = v1) 
print(p2, vp = v2)

## ---- eval=TRUE----------------------------------------------------------
Central_Luzon <- rgeos::gUnaryUnion(Central_Luzon)
centroid <- rgeos::gCentroid(Central_Luzon)

ggplot() + 
  geom_polygon(data = Central_Luzon, aes(x = long, y = lat, group = group),
               colour = "grey10", fill = "#fff7bc") +
  geom_point(aes(x = centroid@coords[1], y = centroid@coords[2])) +
  theme(axis.text.y = element_text(angle = 90, hjust = 0.5)) +
  ggtitle("Centre of Survey\nArea") +
  theme_bw() + 
  xlab("Longitude") + 
  ylab("Latitude") +
  coord_map()

## ---- eval=TRUE----------------------------------------------------------
library(GSODR)
library(readr)
# Fetch station list from NCEI
station_meta <- read_csv(
  "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
  col_types = "ccccccddddd",
  col_names = c("USAF", "WBAN", "STN_NAME", "CTRY", "STATE", "CALL", "LAT",
                "LON", "ELEV_M", "BEGIN", "END"), skip = 1)
station_meta$STNID <- as.character(paste(station_meta$USAF,
                                         station_meta$WBAN,
                                         sep = "-"))

loop_stations <- nearest_stations(LAT = centroid@coords[2],
                                  LON = centroid@coords[1], 
                                  distance = 100)

loop_stations <- station_meta[station_meta$STNID %in% loop_stations, ]

loop_stations <- loop_stations[loop_stations$BEGIN <= 19591231 &
                               loop_stations$END >= 20151231, ]

print(loop_stations[, c(1:2, 3, 7:12)])

## ---- eval=FALSE---------------------------------------------------------
#  PHL <- get_GSOD(station =
#                    eval(parse(text = loop_stations[, 12])), years = 1960:2015)

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
#  readr::write_csv(loop_data, file = "Loop_Survey_Weather_1960-2015", path = "./")

## ----cleanup GADM files, eval=TRUE, echo=FALSE, message = FALSE----------
unlink("GADM_2.8_PHL_adm0.rds")
unlink("GADM_2.8_PHL_adm1.rds")

