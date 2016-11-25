## ----example_1, eval=TRUE, message=FALSE, results='hide'-----------------
library(GSODR)
get_GSOD(years = 2010, country = "Philippines", dsn = "~/",
         filename = "PHL-2010", GPKG = TRUE, max_missing = 5)

## ----example_1.1, eval=TRUE, echo=TRUE-----------------------------------
library(rgdal)
library(spacetime)
library(plotKML)

layers <- ogrListLayers(dsn = path.expand("~/PHL-2010.gpkg"))
pnts <- readOGR(dsn = path.expand("~/PHL-2010.gpkg"), layers[1])

# Plot results in Google Earth as a spacetime object:
pnts$DATE = as.Date(paste(pnts$YEAR, pnts$MONTH, pnts$DAY, sep = "-"))
row.names(pnts) <- paste("point", 1:nrow(pnts), sep = "")

tmp_ST <- STIDF(sp = as(pnts, "SpatialPoints"),
                time = pnts$DATE - 0.5,
                data = pnts@data[, c("TEMP", "STNID")],
                endTime = pnts$DATE + 0.5)

shape = "http://maps.google.com/mapfiles/kml/pal2/icon18.png"

kml(tmp_ST, dtime = 24 * 3600, colour = TEMP, shape = shape, labels = TEMP,
    file.name = "Temperatures_PHL_2010-2010.kml", folder.name = "TEMP")

system("zip -m Temperatures_PHL_2010-2010.kmz Temperatures_PHL_2010-2010.kml")

## ----example_1.2, eval=TRUE, fig.cap="Comparison of GSOD daily values and average monthly values with CHELSA climate monthly values", fig.width=8----
library(dplyr)
library(ggplot2)
library(reshape2)

data(GSOD_clim)
cnames <- paste0("CHELSA_temp_", 1:12, "_1979-2013")
clim_temp <- GSOD_clim[GSOD_clim$STNID %in% pnts$STNID,
                       paste(c("STNID", cnames))]
clim_temp_df <- data.frame(STNID = rep(clim_temp$STNID, 12),
                           MONTHC = as.vector(sapply(1:12, rep,
                                                    times = nrow(clim_temp))), 
                           CHELSA_TEMP = as.vector(unlist(clim_temp[, cnames])))

pnts$MONTHC <- as.numeric(paste(pnts$MONTH))
temp <- left_join(pnts@data, clim_temp_df, by = c("STNID", "MONTHC"))

temp <- temp %>% 
  group_by(MONTH) %>% 
  mutate(AVG_DAILY_TEMP = round(mean(TEMP), 1))

df_melt <- na.omit(melt(temp[, c("STNID", "DATE", "CHELSA_TEMP", "TEMP", "AVG_DAILY_TEMP")],
                        id = c("DATE", "STNID")))

ggplot(df_melt, aes(x = DATE, y = value)) +
  geom_point(aes(color = variable), alpha = 0.2) +
  scale_x_date(date_labels = "%b") +
  ylab("Temperature (C)") +
  xlab("Month") +
  labs(colour = "") +
  scale_color_brewer(palette = "Dark2") +
  facet_wrap( ~ STNID)


