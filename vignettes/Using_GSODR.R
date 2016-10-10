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

## ----spatial_query, message----------------------------------------------
tbar_stations <- nearest_stations(LAT = -27.5598, LON = 151.9507, distance = 50)
tbar_stations <- tbar_stations$STNID

get_GSOD(years = 2010, station = tbar_stations, dsn = "~/",
         filename = "Toowoomba_50km_2010")

## ----use_nearest_stations, eval=FALSE------------------------------------
#  remove <- c("949999-00170", "949999-00183")
#  tbar_stations <- tbar_stations[!tbar_stations %in% remove]
#  
#  get_GSOD(years = 2010, station = tbar_stations, dsn = "~/",
#           filename = "Toowoomba_50km")

## ----plot_temps, fig.width=7, fig.height=7, message=FALSE, fig.cap="Toowoomba 2010 Temperatures"----
library(lubridate)
library(readr)
library(tidyr)

# Import the data for Toowoomba previously downloaded and cleaned
tbar <- read_csv("~/Toowoomba_Airport-2010.csv", na = "-9999")

# Create a dataframe of just the date and temperature values that we want to plot
tbar_temps <- tbar[, c(14, 19, 33, 35)]

# Gather the data from wide to long
tbar_temps <- gather(tbar_temps, Measurement, gather_cols = TEMP:MIN)

ggplot(data = tbar_temps, aes(x = ymd(YEARMODA), y = value,
                              colour = Measurement)) +
  geom_line() +
  scale_color_brewer(type = "qual", na.value = "black") +
  scale_y_continuous(name = "Temperature") +
  scale_x_date(name = "Date") +
  theme_bw()


## ----refresh_stations, eval=FALSE----------------------------------------
#  
#  get_GSOD(years = 2016, dsn = "~/", filename = "newest_stations", refresh = TRUE)
#  
#  

## ----spatial_files, message=FALSE----------------------------------------

get_GSOD(years = 2015, country = "Australia", dsn = "~/", filename = "AUS",
         CSV = FALSE, GPKG = TRUE)

## ----import_spatial_files, message=FALSE---------------------------------

library(rgdal)
AUS_stations <- readOGR(dsn = path.expand("~/AUS-2015.gpkg"), layer = "GSOD")

class(AUS_stations)

print(unique(AUS_stations$STN_NAME))


## ----as_gpkg_database----------------------------------------------------

AUS_sqlite <- tbl(src_sqlite(path.expand("~/AUS-2015.gpkg")), "GSOD")
class(AUS_sqlite)
print(AUS_sqlite, n = 5)


## ----temporal_downscaling------------------------------------------------
library(chillR)

# rename columns and convert the object to a standard data.frame
colnames(tbar)[colnames(tbar) == "MAX"] <- "Tmax"
colnames(tbar)[colnames(tbar) == "MIN"] <- "Tmin"
colnames(tbar)[colnames(tbar) == "YEAR"] <- "Year"
colnames(tbar)[colnames(tbar) == "YDAY"] <- "JDay"
tbar <- as.data.frame(tbar)

# generate hourly temperature values
tbar <- make_hourly_temps(tbar[, 8], tbar)

head(tbar)


