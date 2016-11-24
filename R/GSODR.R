

#' GSODR: Global Surface Summary Daily Weather Data in R.
#'
#'The GSODR package offers automated downloading, parsing, cleaning,
#'unit conversion and formatting of Global Surface Summary of the Day (GSOD)
#'weather data from the from the USA National Climatic Data Center (NCDC).
#'All units are converted from from United States Customary System (USCS)
#'units to International System of Units (SI). Stations may be individually
#'checked for number of missing days defined by the user, where stations
#'with too many missing observations are omitted. Only stations with valid
#'reported latitude and longitude values are permitted in the final data.
#'Additional useful variables, saturation vapour pressure (es), actual vapour
#'pressure (ea) and relative humidity are calculated from the original data
#'and included in the final data set. A list of elevation values generated from
#'a 200 metre buffer of 90m elevation data, CGIAR-CSI SRTM hole-filled 90
#'metre data (Jarvis et al. 2008), are included for stations between -60 and
#'60 degrees latitude. The resulting data include station data (e.g., station
#'name, country, latitude, longitude, elevation) and weather observations and
#'associated flags. Data may be automatically saved to disk. File output may
#'be returned as a comma-separated values (CSV) or GeoPackage (GPKG) file.
#'For information on the original data from NCDC, please see the GSOD
#'readme.txt file available from,
#'\url{http://www1.ncdc.noaa.gov/pub/data/gsod/readme.txt}.
#'
#' @docType package
#'
#' @name GSODR
#'
#' @seealso \code{\link{get_GSOD}} Fetch, clean and reformat data from NCDC GSOD
#' database
#'
#' @seealso \code{\link{reformat_GSOD}} Clean and reformat local files from NCDC
#' GSOD database
#'
#' @seealso \code{\link{nearest_stations}} Find stations within a given radius
#' expressed in kilometres for a given point using Latitude and Longitude
#'
#' @references
#' \url{https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod}
#'
#'@author Adam H Sparks, Tomislav Hengle and Andrew Nelson
NULL
