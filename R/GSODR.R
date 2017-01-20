

#' GSODR: Global Surface Summary Daily Weather Data in R.
#'
#'Provides automated downloading, parsing, cleaning, unit conversion and
#'formatting of Global Surface Summary of the Day (GSOD) weather data from
#'the from the USA National Climatic Data Center (NCDC) for use in R.  All units
#'are converted from from United States Customary System (USCS) units to
#'International System of Units (SI).  Stations may be individually checked for
#'number of missing days defined by the user, where stations with too many
#'missing observations are omitted.  Only stations with valid reported latitude
#'and longitude values are permitted in the final data.  Additional useful
#'variables, saturation vapour pressure (es), actual vapour pressure (ea) and
#'relative humidity are calculated from the original data and included in the
#'final data set.  The resulting data include station identification information,
#'state, country, latitude, longitude, elevation, weather observations and
#'associated flags.  Data may be automatically saved to disk.  File output may be
#'returned as a comma-separated values (CSV) or GeoPackage (GPKG) file.
#'Additional data are included with this R package: a list of elevation values
#'for stations between -60 and 60 degrees latitude derived from the Shuttle
#'Radar Topography Measuring Mission (SRTM).  For information on the GSOD data
#'from NCDC, please see the  GSOD readme.txt file available from,
#'\url{http://www1.ncdc.noaa.gov/pub/data/gsod/readme.txt}.
#'For climate data that have been formatted specifically for use with the
#'\code{GSODR} package, please see the \code{GSODRdata} package
#'(Sparks \emph{et al}.) available on GitHub:
#'\url{https://adamhsparks.github.io/GSODRdata/}. Four data frames of climate
#'data are provided from various sources for GSOD station locations.
#'\describe{
#'\item{CHELSA}{Climatic surfaces at 1 km resolution is based on a
#'quasi-mechanistic statistical downscaling of the ERA interim global
#'circulation model (Karger \emph{et al}. 2016). ESA’s CCI-LC cloud probability
#'monthly averages are based on the MODIS snow products (MOD10A2).}
#'\item{CRU CL2.0}{The CRU CL 2.0 data-set (New \emph{et al}. 2002) comprises
#'monthly grids of observed mean climate from 1961-1990, and covering the
#'global land surface at a 10 minute spatial resolution. There are eight
#'climatic variables available, and also the elevations on the grid: diurnal
#'temperature range, precipitation, mean temperature, wet-day frequency,
#'frost-day frequency, relative humidity, sunshine, and wind-speed.
#'In addition minimum and maximum temperature may be deduced from mean
#'temperature and diurnal temperature range (see FAQ).}
#'\item{ESACCI}{ESA’s CCI-LC snow cover probability
#'\url{http://maps.elie.ucl.ac.be/CCI/viewer/index.php}}
#'\item{MODCF}{Remotely sensed high-resolution global cloud dynamics for
#'predicting ecosystem and biodiversity distributions (Wilson et al. 2016)
#'provides new near-global, fine-grain (~1km) monthly cloud frequencies from
#'15 years of twice-daily MODIS satellite images.}
#'}
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
#' @seealso \code{\link{get_station_list}} Fetch latest list of stations and
#' corresponding metadata from the NCDC FTP server
#'
#' @seealso \code{\link{SRTM_GSOD_elevation}} GSDOR provides additional
#' elevation data derived from SRTM90m data
#'
#' @seealso \code{\link{country_list}} GSDOR provides a cleaned list of the
#' countries which are represented in the GSOD data set
#'
#' @source
#' \url{https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod}
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
#' @author Adam Sparks, Tomislav Hengle and Andrew Nelson
NULL
