
#'isd_history
#'
#' \describe{
#'   \item{USAF}{Air Force Datsav3 station number}
#'   \item{WBAN}{Weather Bureau Army Navy (5 digit identifier)}
#'   \item{STN_NAME}{Unique station name }
#'   \item{CTRY}{FIPS country ID}
#'   \item{STATE}{If applicable, US states only (2 letter code)}
#'   \item{CALL}{ICAO Identifier, identifiers approved for use under the
#'   International Civil Aviation Administration plan of identifiers
#'   (4 letter identifier)}
#'   \item{LAT}{Latitude in thousandths of decimal degrees}
#'   \item{LON}{Longitude in thousandths of decimal degrees}
#'   \item{ELEV_M}{Elevation to tenthts in metres}
#'   \item{BEGIN}{First available date of data for station, YYYYMMDD format}
#'   \item{END}{Last available date of data for station, YYYYMMDD format}
#'   \item{STNID}{Unique station ID, a concatenation of USAF and WBAN number,
#'   used for merging with station data weather files}
#'   \item{ELEV_M_SRTM_90m}{Elevation in metres extracted from SRTM data (Jarvis
#'   \emph{et al}. 2008)}
#' }
#'
#'
#' Station elevation information for the US National Centers for Environmental
#' Information (NCEI) Global Surface Summary of the Day (GSOD) weather data.
#' The original file has missing and incorrect geographic data including
#' location (LAT/LON) and elevation.  These data provide an alternative
#' set of elevation values with the following changes to the original list of
#' stations from the NCEI:
#' \enumerate{
#' \item{Stations with both a latitude and longitude of 0 degrees were removed.}
#' \item{Stations with longitude values that are beyond -180/180 degrees were
#' removed.}
#' \item{Stations with latitude values that are beyond -90/90 degrees were
#' removed.}
#' \item{A new field for elevation is included, ELEV_M_SRTM_90m. This was
#' created using mean values of a 200m buffer around the reported LAT/LON
#' station location within the CGIAR-CSI hole-filled 90m SRTM digital elevation
#' model (Jarvis \emph{et al}. 2008).}
#' }
#' For more on this, please consult the document available from the GSODR
#' GitHub repository detailing the process used to generate these data,
#' \url{https://github.com/ropensci/GSODR/blob/master/data-raw/fetch_isd-history.md}
#'
#' @note Users of these data should take into account the following (from the
#' NCEI website): \dQuote{The following data and products may have conditions
#' placed on their international commercial use.  They can be used within the
#' U.S. or for non-commercial international activities without restriction. The
#' non-U.S. data cannot be redistributed for commercial purposes.
#' Re-distribution of these data by others must provide this same notification.}
#'
#' The \code{isd_history} data are automatically loaded with the
#' \code{\link{GSODR}} package and merged with the latest available data from the NCEI
#' in the "isd-history.csv" file.
#'
#' To update these data with the latest available, use
#' \code{\link{update_station_list}}.
#'
#' @source \url{ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv}
#'
#' @references {Jarvis, A., Reuter, H. I, Nelson, A., Guevara, E. (2008)
#' Hole-filled SRTM for the globe Version 4, available from the CGIAR-CSI SRTM
#' 90m Database  \url{http://srtm.csi.cgiar.org}}
"isd_history"

#' country_list
#'
#' \describe{
#' \item{FIPS}{Federal Information Processing Standards (FIPS) code}
#' \item{COUNTRY_NAME}{English language name}
#' \item{iso2c}{ISO 3166-1 alpha-2 – two-letter country codes}
#' \item{iso3c}{ISO 3166-1 alpha-3 – three-letter country codes}
#' }
#'
#' @note Users of these data should take into account the following
#' (from the NCEI website): \dQuote{The following data and products may have
#' conditions placed on their international commercial use. They can be used
#' within the U.S. or for non-commercial international activities without
#' restriction. The non-U.S. data cannot be redistributed for commercial
#' purposes. Re-distribution of these data by others must provide this same
#' notification.}
#'
#' The \code{country_list} data are automatically loaded with the \code{GSODR}
#' package.
#'
#' @source \url{ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt}
"country_list"
