#' Station information for the US National Climatic Data Centre (NCDC)
#' Global Surface Summary of the Day (GSOD) weather data. The original file has
#' missing and incorrect information. This is a clean version of this dataset,
#' provided by this package. The following changes were made.
#' 1. All stations with no Country Code were removed.
#' 2. Stations with both a latitude and longitude of 0 degrees were removed.
#' 3. Stations with longitude values that are beyond -180/180 degrees were
#' removed.
#' 4. Stations with latitude values that are beyond -90/90 degrees were
#' removed.
#' 5. All units are converted to International System of Units (SI), e.g.
#' Fahrenheit to Celcius and inches to millimetres.
#' 6. For convenience elevation is converted from decimetres to metres.
#' 6. StationID is added as a column, a concatenation of USAF and WBAN.
#'
#' Users of these data should take into account the following (from the NCDC
#' website): "The following data and products may have conditions placed on
#' their international commercial use. They can be used within the U.S. or for
#' non-commercial international activities without restriction. The non-U.S.
#' data cannot be redistributed for commercial purposes. Re-distribution of
#' these data by others must provide this same notification."
#'
#' A dataset containing the prices and other attributes of almost 54,000
#' diamonds.
#'
#' @format A data frame with 27252 observations of 8 variables:
#' \describe{
#'   \item{USAF}{}
#'   \item{WBAN}{}
#'   \item{STATION.NAME}{}
#'   \item{CTRY}{}
#'   \item{LAT}{}
#'   \item{LON}{}
#'   \item{ELEV.M}{}
#'   \item{STNID}{}
#' }
#' @source \url{ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv}
"stations"
