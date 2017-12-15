
#' GSODR: Global Surface Summary of the Day (GSOD) Weather Data from R
#'
#'Provides automated downloading, parsing, cleaning, unit conversion and
#'formatting of Global Surface Summary of the Day (GSOD) weather data from
#'the from the USA's National Oceanic and Atmospheric Administration's (NOAA)
#'National Centre for Environmental Information (NCEI) for use in R.  All units
#'are converted from from United States Customary System (USCS) units to
#'International System of Units (SI).  Stations may be individually checked for
#'number of missing days defined by the user, where stations with too many
#'missing observations are omitted.  Only stations with valid reported latitude
#'and longitude values are permitted in the final data.  Additional useful
#'elements, saturation vapour pressure (es), actual vapour pressure (ea) and
#'relative humidity are calculated from the original data and included in the
#'final data set.  The resulting data include station identification
#'information, state, country, latitude, longitude, elevation, weather
#'observations and associated flags.  Data may be automatically saved to disk.
#'File output may be saved as a comma-separated values (CSV) or GeoPackage
#'(GPKG) file.  Additional data are included with this R package: a list of
#'elevation values for stations between -60 and 60 degrees latitude derived from
#'the Shuttle Radar Topography Measuring Mission (SRTM).  For information on the
#'GSOD data from NCEI, please see the  GSOD readme.txt file available from,
#'\url{http://www1.ncdc.noaa.gov/pub/data/gsod/readme.txt}.
#'For climate data that have been formatted specifically for use with the
#'\code{GSODR} package, please see the \code{GSODRdata} package
#'(Sparks \emph{et al}.) available on GitHub:
#'\url{https://adamhsparks.github.io/GSODRdata/}. Four data frames of climate
#'data are provided from various sources for GSOD station locations.
#'
#' @docType package
#'
#' @name GSODR
#'
#' @author Adam Sparks, Tomislav Hengl and Andrew Nelson
#'
#' @seealso
#'
#' \strong{GSODR functions:}
#'
#' \code{\link{get_GSOD}} Download, Clean, Reformat Generate New Elements and
#' Return a Tidy Data Frame of GSOD Weather Data
#'
#' \code{\link{reformat_GSOD}} Clean, Reformat Generate New Elements and Return
#' a Tidy Data Frame of GSOD Weather Data from Local Disk
#'
#' \code{\link{nearest_stations}} Find Nearest GSOD Stations to Specified
#' a Latitude and Longitude
#'
#' \code{\link{update_station_list}} Download the Latest Station List
#' Information and Update GSODR's Internal Database
#'
#' \code{\link{get_inventory}} Download and return a tidy data frame of GSOD
#' weather station data inventories
#'
#' \strong{Useful links:}
#' \itemize{
#' \item{Static documentation at \url{https://ropensci.github.io/GSODR/}}
#' \item{Development repository at \url{https://github.com/ropensci/GSODR}}
#' \item{Report bugs at \url{https://github.com/ropensci/GSODR/issues}}
#' }
#'
#' @source
#' \url{https://data.noaa.gov/dataset/dataset/global-surface-summary-of-the-day-gsod/}
#'
#' @references
#' Karger, D. N., Conrad, O., Bohner, J., Kawohl, T., Kreft, H., Soria-Auza,
#' R. W., \emph{et al}. (2016) Climatologies at high resolution for the Earth
#' land surface areas. \emph{arXiv preprint} \bold{arXiv:1607.00217}
#'
#' New, M., Lister, D., Hulme, M., Makin, I., (2002) A high-resolution data
#' set of surface climate over global land areas. \emph{Climate Research}
#' \bold{21}:1--25
#'
#' Sparks A., Hengl T., Nelson A. (2017) GSODRdata: Extra Climate Data for
#' the GSODR Package. R package version 0.1.0,
#' \url{https://adamhsparks.github.io/GSODRdata/index.html}.
#'
#' Wilson A. M., Jetz W. (2016) Remotely Sensed High-Resolution Global Cloud
#' Dynamics for Predicting Ecosystem and Biodiversity Distributions.
#' \emph{PLoS Biol} \bold{14(3)}: e1002415. doi:10.1371/journal. pbio.1002415
#'
NULL
