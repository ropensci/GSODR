

#' GSODR: Global Surface Summary Daily Weather Data in R.
#'
#'Provides automated downloading, parsing, cleaning, unit conversion and formatting of Global Surface Summary of the Day (GSOD) weather data from
#'the from the USA National Climatic Data Center (NCDC) for use in R. All units are converted from from United States Customary System (USCS) units to
#'International System of Units (SI). Stations may be individually checked for number of missing days defined by the user, where stations with too many
#'missing observations are omitted. Only stations with valid reported latitude and longitude values are permitted in the final data. Additional useful
#'variables, saturation vapour pressure (es), actual vapour pressure (ea) and relative humidity are calculated from the original data and included in the
#'final data set. The resulting data include station identification information, state, country, latitude, longitude, elevation, weather
#'observations and associated flags. Data may be automatically saved to disk. File output may be returned as a comma-separated values (CSV) or GeoPackage
#'(GPKG) file. Additional data are included with this R package: a list of elevation values for stations between -60 and 60 degrees latitude derived
#'from the Shuttle Radar Topography Measuring Mission (SRTM). For information on the GSOD data from NCDC, please see the  GSOD readme.txt file available
#'from, <http://www1.ncdc.noaa.gov/pub/data/gsod/readme.txt>.
#'
#' @docType package
#'
#' @name GSODR
#'
#' @seealso \code{\link{get_GSOD}} Fetch, clean and reformat data from NCDC GSOD database
#'
#' @seealso \code{\link{reformat_GSOD}} Clean and reformat local files from NCDC GSOD database
#'
#' @seealso \code{\link{nearest_stations}} Find stations within a given radius expressed in kilometres for a given point using Latitude and Longitude
#'
#' @seealso \code{\link{get_station_list}} Fetch latest list of stations and corresponding metadata from the NCDC FTP server
#'
#' @seealso \code{\link{SRTM_GSOD_elevation}} GSDOR provides additional elevation data derived from SRTM90m data
#'
#' @seealso \code{\link{country_list}} GSDOR provides a cleaned list of the countries which are represented in the GSOD data set
#'
#' @references
#' \url{https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod}
#'
#'@author Adam Sparks, Tomislav Hengl and Andrew Nelson
NULL
