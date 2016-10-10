## ----load_library--------------------------------------------------------
library(GSODR)
stations <- GSODR::GSOD_stations

## ----plot_stations, fig.width=7, fig.height=7, fig.cap="GSOD Station Locations"----
library(ggplot2)
library(ggalt)

ggplot(stations, aes(x = LON, y = LAT)) +
  geom_point(alpha = 0.1) +
  coord_proj("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs") +
  theme_bw()


## ----australia_stations, message=FALSE, warning=FALSE--------------------
library(dplyr)
# left_join the the station data with the country list
station_locations <- left_join(stations, GSODR::GSOD_country_list, by = c("CTRY" = "FIPS"))

# create data.frame for Australia only
Oz <- filter(station_locations, COUNTRY_NAME == "AUSTRALIA")
head(Oz)

# find a station in Toowoomba, Queensland
filter(Oz, STN_NAME == "TOOWOOMBA")


## ----Toowoomba_Airport, eval=TRUE----------------------------------------
get_GSOD(years = 2010, station = "955510-99999", dsn = "~/",
         filename = "Toowoomba_Airport")

