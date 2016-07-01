#' GSOD Station Data
#'
#' Station information for the US National Climatic Data Centre (NCDC)
#' Global Surface Summary of the Day (GSOD) weather data. The original file has
#' missing and incorrect information. This is a clean version of this dataset,
#' provided by this package. The following changes were made.
#' \enumerate{
#' \item{Stations with both a latitude and longitude of 0 degrees were removed.}
#' \item{Stations with longitude values that are beyond -180/180 degrees were
#' removed.}
#' \item{Stations with latitude values that are beyond -90/90 degrees were
#' removed.}
#' \item{For convenience elevation is converted from decimetres to metres.}
#' \item{STNID is added as a new field, a concatenation of USAF and WBAN.}
#' \item{A new field for elevation is included, ELEV.M.90m. This was created
#' using mean values of a 200m buffer around the reported LAT/LON station
#' location within the CGIAR-CSI hole-filled 90m SRTM digital elevation model
#' (Jarvis et al. 2008)}
#' }
#' Users of these data should take into account the following (from the NCDC
#' website): \dQuote{"The following data and products may have conditions
#' placed on their international commercial use. They can be used within the
#' U.S. or for non-commercial international activities without restriction. The
#' non-U.S. data cannot be redistributed for commercial purposes.
#' Re-distribution of these data by others must provide this same
#' notification."}
#'
#' The data are automatically loaded with the package, to see the stations, type
#' \code{stations}
#'
#' @format A data frame with 27699 observations of 12 variables:
#' \describe{
#'   \item{USAF}{Air Force Datsav3 station number}
#'   \item{WBAN}{Weather Bureau Army Navy (5 digit identifier)}
#'   \item{STN.NAME}{Unique station name}
#'   \item{CTRY}{FIPS country ID}
#'   \item{STATE}{If applicable, US states only (2 letter code)}
#'   \item{CALL}{ICAO Identifier, identifiers approved for use under the
#'   International Civil Aviation Administration plan of identifiers
#'   (4 letter identifier)}
#'   \item{LAT}{Latitude in thousandths of decimal degrees}
#'   \item{LON}{Longitude in thousandths of decimal degrees}
#'   \item{ELEV.M}{Elevation to tenthts in metres}
#'   \item{BEGIN}{First available date of data for station, YYYYMMDD format}
#'   \item{END}{Last available date of data for station, YYYYMMDD format}
#'   \item{STNID}{Unique station ID, a concatenation of USAF and WBAN number,
#'   used for merging with station data weather files}
#'   \item{ELEV.M.SRTM.90m}{Elevation in metres corrected for possible errors}
#' }
#' @source \url{ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv}
#' @references {Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled
#' SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m Database
#' \url{http://srtm.csi.cgiar.org}}
"stations"
