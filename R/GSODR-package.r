#' @title GSODR
#'
#' @description GSODR is an R package to retrieve and clean GSOD data from the US NCDC.
#'
#' Download, clean, reformat and create new variables from the USA National
#' Climatic Data Center (NCDC) Global Surface Summary of the Day
#' (GSOD) weather stations data, 
#' <https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod>. The
#' function, get_GSOD(), retrieves data from the GSOD ftp site and reformats i
#' from United States Customary System (USCS) units to International System of
#' Units (SI), also for convenience elevation is converted from decimetres to
#' metres. Stations are individually checked for number of missing days, as
#' defined by the user, to assure data quality. Stations with too many missing
#' observations, as determined by the user, are omitted from final file.
#' Stations with missing latitude or longitude or values for both of 0 are
#' omitted. Also omitted are stations with a latitude of < -90 or > 90 or
#' longitude of < - 180 or > 180. Output is returned as a comma-separated value
#' (CSV) file written to disk in a location selected by the user, which 
#' summarises each year by station and includes new variables: actual vapor
#' pressure, saturation vapor pressure and relative humidity are calculated
#' from the original GSOD data. The resulting files can be as large as 500mb
#' depending on the user's stringency for missing data and geographic area of
#' interest. Be sure to have sufficient RAM and disk space as well as a
#' reasonably fast internet connection to use this package to perform this
#' operation. However, for much smaller and more manageable data sets, an
#' individual country of interest may be selected as well as only stations
#' falling between -60/60 degrees latitude for agroclimatology work or
#' individual stations if the station ID is known. The resulting files include
#' station data (e.g., station name, country, latitude, longitude, elevation)
#' for use in a geographic information system (GIS). The function was largely
#' based on T. Hengl's 'getGSOD.R' script, available from
#' <http://spatial-analyst.net/book/system/files/getGSOD.R> with enhancements
#' to be more cross-platform, faster and more flexible. For information on the
#' data themseves, please see the GSOD readme.txt,
#' <http://www1.ncdc.noaa.gov/pub/data/gsod/readme.txt>.#' The CSV or ESRI
#' format shapefile in the respective year-directory
#' will contain the following fields/values:
#' \describe{
#' \item{STNID}{Station number (WMO/DATSAV3 number) for the location}
#' \item{WBAN}{Number where applicable--this is the historical "Weather Bureau
#' Air Force Navy" number - with WBAN being the acronym}
#' \item{STN.NAME}{Unique text string identifier}
#' \item{CTRY}{Country}
#' \item{LAT}{Latitude}
#' \item{LON}{Longitude}
#' \item{ELEV.M}{Station reported elevation (metres to tenths)}
#' \item{ELEV.M.SRTM.90m}{Corrected elevation data in whole metres for stations
#' derived from Jarvis et al. (2008), extracted from DEM using reported LAT/LON
#' values in metres}
#' \item{YEARMODA}{Date in YYYY-MM-DD format}
#' \item{YEAR}{The year}
#' \item{MONTH}{The month}
#' \item{DAY}{The day}
#' \item{YDAY}{Sequential day of year (not in original GSOD)}
#' \item{TEMP}{Mean daily temperature converted to degrees C to tenths.
#' Missing = -9999}
#' \item{TEMP.CNT}{Number of observations used in calculating mean daily
#' temperature}
#' \item{DEWP}{Mean daily dew point converted to degrees C to tenths. Missing =
#' -9999}
#' \item{DEWP.CNT}{Number of observations used in calculating mean daily
#' dew point}
#' \item{SLP}{Mean sea level pressure in millibars to tenths. Missing =
#' -9999}
#' \item{SLP.CNT}{Number of observations used in calculating mean sea level
#' pressure}
#' \item{STP}{Mean station pressure for the day in millibars to tenths
#' Missing = -9999}
#' \item{STP.CNT}{Number of observations used in calculating mean station
#' pressure}
#' \item{VISIB}{Mean visibility for the day converted to kilometers to tenths
#' Missing = -9999}
#' \item{VISIB.CNT}{Number of observations used in calculating mean daily
#' visibility}
#' \item{WDSP}{Mean daily wind speed value converted to metres/second to tenths
#' Missing = -9999}
#' \item{WDSP.CNT}{Number of observations used in calculating mean daily
#' windspeed}
#' \item{MXSPD}{Maximum sustained wind speed reported for the day converted to
#' metres/second to tenths. Missing = -9999}
#' \item{GUST}{Maximum wind gust reported for the day converted to
#' metres/second to tenths. Missing = -9999}
#' \item{MAX}{Maximum temperature reported during the day converted to Celsius
#' to tenths--time of maximum temperature report varies by country and region,
#' so this will sometimes not be the maximum for the calendar day. Missing =
#' -9999}
#' \item{MAX.FLAG}{Blank indicates maximum temperature was taken from the
#' explicit maximum temperature report and not from the 'hourly' data. " * "
#' indicates maximum temperature was derived from the hourly data (i.e., highest
#' hourly or synoptic-reported temperature)}
#' \item{MIN}{Minimum temperature reported during the day converted to Celsius
#' to tenths--time of minimum temperature report varies by country and region,
#' so this will sometimes not be the minimum for the calendar day. Missing =
#' -9999}
#' \item{MIN.FLAG}{Blank indicates minimum temperature was taken from the
#' explicit minimum temperature report and not from the 'hourly' data. " * "
#' indicates minimum temperature was derived from the hourly data (i.e., lowest
#' hourly or synoptic-reported temperature)}
#' \item{PRCP}{Total precipitation (rain and/or melted snow) reported during
#' the day converted to millimetres to hundredths will usually not end with the
#' midnight observation--i.e., may include latter part of previous day. ".00"
#' indicates no measurable precipitation (includes a trace). Missing = -9999.
#' \emph{Note}: Many stations do not report '0' on days with no precipitation--
#' therefore, '-9999' will often appear on these days. For example, a
#' station may only report a 6-hour amount for the period during which rain
#' fell. See PRCP.FLAG column for source of data}
#' \item{PRCP.FLAG}{
#'  \describe{
#'    \item{A}{= 1 report of 6-hour precipitation amount}
#'    \item{B}{= Summation of 2 reports of 6-hour precipitation amount}
#'    \item{C}{= Summation of 3 reports of 6-hour precipitation amount}
#'    \item{D}{= Summation of 4 reports of 6-hour precipitation amount}
#'    \item{E}{= 1 report of 12-hour precipitation amount}
#'    \item{F}{= Summation of 2 reports of 12-hour precipitation amount}
#'    \item{G}{= 1 report of 24-hour precipitation amount}
#'    \item{H}{= Station reported '0' as the amount for the day (eg, from
#'    6-hour reports), but also reported at least one occurrence of
#'    precipitation in hourly observations--this could indicate a trace
#'    occurred, but should be considered as incomplete data for the day}
#'    \item{I}{= Station did not report any precipitation data for the day and
#'    did not report any occurrences of precipitation in its hourly
#'    observations. It's still possible that precipitation occurred but was not
#'    reported}
#'    }
#'  }
#' \item{SNDP}{Snow depth in millimetres to tenths. Missing = -9999}
#' \item{I.FOG}{Fog, (1 = yes, 0 = no/not reported) for the occurrence during
#' the day}
#' \item{I.RAIN_DZL}{Rain or drizzle, (1 = yes, 0 = no/not reported) for the
#' occurrence during the day}
#' \item{I.SNW_ICE}{Snow or ice pellets, (1 = yes, 0 = no/not reported) for the
#' occurrence during the day}
#' \item{I.HAIL}{Hail, (1 = yes, 0 = no/not reported) for the occurrence during
#' the day}
#' \item{I.THUNDER}{Thunder, (1 = yes, 0 = no/not reported) for the occurrence
#' during the #' day}
#' \item{I.TDO_FNL}{Tornado or funnel cloud, (1 = yes, 0 = no/not reported) for
#' the occurrence during the day}
#'}
#'
#' \emph{Values calculated by this package and included in final output:}
#' \describe{
#' \item{ea}{Mean daily actual vapour pressure}
#' \item{es}{Mean daily saturation vapour pressure}
#' \item{RH}{Mean daily relative humidity}
#'}
#'
#'
#'@note Users of these data should take into account the following (from the
#' NCDC website): 
#' "The following data and products may have conditions placed on
#' their international commercial use. They can be used within the U.S. or for
#' non-commercial international activities without restriction. The non-U.S.
#' data cannot be redistributed for commercial purposes. Re-distribution of
#' these data by others must provide this same notification."
#' 
#'
#' @importFrom countrycode countrycode_data
#' @importFrom curl curl_download
#' @importFrom data.table rbindlist
#' @importFrom dplyr inner_join left_join mutate
#' @importFrom lubridate leap_year yday
#' @importFrom raster ccodes shapefile trim
#' @importFrom readr fwf_positions read_fwf read_table
#' @importFrom sp coordinates CRS proj4string
#' @importFrom stats na.omit
#' @importFrom stringr str_sub
#' @importFrom utils data glob2rx untar write.csv
#' @name GSODR-package
#' @aliases GSODR
#' @docType package
#' @keywords package
