## ----example_1, eval=FALSE, message=FALSE, results='hide'----------------
#  library(GSODR)
#  get_GSOD(years = 2010, country = "Philippines", dsn = "~/",
#           filename = "PHL-2010", GPKG = TRUE, max_missing = 5)

## ----example_1.1, eval=FALSE, echo=TRUE----------------------------------
#  library(rgdal)
#  library(spacetime)
#  library(plotKML)
#  
#  layers <- ogrListLayers(dsn = path.expand("~/PHL-2010.gpkg"))
#  pnts <- readOGR(dsn = path.expand("~/PHL-2010.gpkg"), layers[1])
#  
#  # Plot results in Google Earth as a spacetime object:
#  pnts$DATE = as.Date(paste(pnts$YEAR, pnts$MONTH, pnts$DAY, sep = "-"))
#  row.names(pnts) <- paste("point", 1:nrow(pnts), sep = "")
#  
#  tmp_ST <- STIDF(sp = as(pnts, "SpatialPoints"),
#                  time = pnts$DATE - 0.5,
#                  data = pnts@data[, c("TEMP", "STNID")],
#                  endTime = pnts$DATE + 0.5)
#  
#  shape = "http://maps.google.com/mapfiles/kml/pal2/icon18.png"
#  
#  kml(tmp_ST, dtime = 24 * 3600, colour = TEMP, shape = shape, labels = TEMP,
#      file.name = "Temperatures_PHL_2010-2010.kml", folder.name = "TEMP")
#  
#  system("zip -m Temperatures_PHL_2010-2010.kmz Temperatures_PHL_2010-2010.kml")

