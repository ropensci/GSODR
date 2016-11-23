## ---- RP Data, message=FALSE, eval=FALSE---------------------------------
#  library(raster)
#  library(rgdal)
#  
#  RP <- getData(country = "Philippines", level = 1)
#  

## ---- Central_Luzon, eval=FALSE------------------------------------------
#  
#  Central_Luzon <- RP[RP@data$NAME_1 == "Pampanga" |
#             RP@data$NAME_1 == "Tarlac" |
#             RP@data$NAME_1 == "Pangasinan" |
#             RP@data$NAME_1 == "La Union" |
#             RP@data$NAME_1 == "Nueva Ecija" |
#             RP@data$NAME_1 == "Bulacan", ]
#  

## ---- dissolve, message=FALSE, eval=FALSE--------------------------------
#  library(rgeos)
#  Central_Luzon <- gUnaryUnion(Central_Luzon)
#  centroid <- gCentroid(Central_Luzon)

## ---- nearest_stations, message=FALSE, eval=FALSE------------------------
#  library(GSODR)
#  library(readr)
#  # Fetch station list from NCDC
#  station_meta <- read_csv(
#    "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv",
#    col_types = "ccccccddddd",
#    col_names = c("USAF", "WBAN", "STN_NAME", "CTRY", "STATE", "CALL", "LAT",
#                  "LON", "ELEV_M", "BEGIN", "END"), skip = 1)
#  station_meta$STNID <- as.character(paste(station_meta$USAF,
#                                           station_meta$WBAN,
#                                           sep = "-"))
#  
#  loop_stations <- nearest_stations(LAT = centroid@coords[, 2],
#                                    LON = centroid@coords[, 1],
#                                    distance = 100)
#  
#  loop_stations <- station_meta[station_meta$STNID %in% loop_stations, ]
#  
#  loop_stations <- loop_stations[loop_stations$BEGIN <= 19591231 &
#                                   loop_stations$END >= 20151231, ]
#  
#  loop_stations
#  

## ---- fetch_weather, message=FALSE, eval=FALSE---------------------------
#  get_GSOD(station = eval(parse(text = loop_stations[, 12])), years = 1960:2016,
#                                CSV = TRUE, dsn = "~/",
#                                filename = "Loop_Survey_Weather_1960-1969")
#  

## ---- list_local_files, eval=FALSE---------------------------------------
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
#  write.csv(loop_data, file = "loop_data")

