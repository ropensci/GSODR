#'SRTM_GSOD_elevation
#'
#' @format A data frame with 27861 observations of 2 variables:
#' \describe{
#'   \item{STNID}{Unique station ID, a concatenation of USAF and WBAN number,
#'   used for merging with station data weather files}
#'   \item{ELEV_M_SRTM_90m}{Elevation in metres extracted from SRTM data (Jarvis
#'   \emph{et al.} 2008)}
#' }
#'
#' Station elevation information for the US National Climatic Data Centre (NCDC)
#' Global Surface Summary of the Day (GSOD) weather data. The original file has
#' missing and incorrect geographic data including location (LAT/LON) and
#' elevation. This data frame provides an alternative set of elevation values
#' with the following changes to the original list of stations from the NCDC:
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
#' \url{https://github.com/adamhsparks/GSODR/blob/master/data-raw/fetch_isd-history.md}
#' @note Users of these data should take into account the following (from the
#' NCDC website): \dQuote{The following data and products may have conditions
#' placed on their international commercial use. They can be used within the
#' U.S. or for non-commercial international activities without restriction. The
#' non-U.S. data cannot be redistributed for commercial purposes.
#' Re-distribution of these data by others must provide this same
#' notification.}
#'
#' The \code{SRTM_GSOD_elevation} data are automatically loaded with the
#' \code{GSODR} package and merged with the latest available data from the NCDC
#' in the "isd-history.csv" file.
#'
#' @source \url{ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.csv}
#' @references {Jarvis, A, HI Reuter, A Nelson, E Guevara, 2008, Hole-filled
#' SRTM for the globe Version 4, available from the CGIAR-CSI SRTM 90m Database
#' \url{http://srtm.csi.cgiar.org}}
"SRTM_GSOD_elevation"

#' country_list
#' @format A data frame with 293 observations of 4 variables:
#' \describe{
#' \item{FIPS}{Federal Information Processing Standards (FIPS) code}
#' \item{COUNTRY_NAME}{English language name}
#' \item{iso2c}{ISO 3166-1 alpha-2 – two-letter country codes}
#' \item{iso3c}{ISO 3166-1 alpha-3 – three-letter country codes}
#' }
#'
#' @note Users of these data should take into account the following (from the
#' NCDC website): \dQuote{The following data and products may have conditions
#' placed on their international commercial use. They can be used within the
#' U.S. or for non-commercial international activities without restriction. The
#' non-U.S. data cannot be redistributed for commercial purposes.
#' Re-distribution of these data by others must provide this same
#' notification.}
#'
#' The \code{country_list} data are automatically loaded with the
#' \code{GSODR} package.
#'
#' @source \url{ftp://ftp.ncdc.noaa.gov/pub/data/noaa/country-list.txt}
#'
"country_list"

#' GSOD_clim
#' @format A data frame with 23927 observations of 73 variables:
#' \describe{
#' \item{STNID}{Unique station ID}
#' \item{LON}{Longitude in WGS84 system}
#' \item{LAT}{Latitude in WGS84 system}
#' \item{CHELSA_bio1_1979-2013_V1_1}{Annual mean temperature [degree C]}
#' \item{CHELSA_bio2_1979-2013_V1_1}{Mean diurnal range [degree C]}
#' \item{CHELSA_bio3_1979-2013_V1_1}{Isothermality}
#' \item{CHELSA_bio4_1979-2013_V1_1}{Temperature seasonality}
#' \item{CHELSA_bio5_1979-2013_V1_1}{Maximum Temperature of warmest month
#' [degree C]}
#' \item{CHELSA_bio6_1979-2013_V1_1}{Minimum Temperature of coldest month
#' [degree C]}
#' \item{CHELSA_bio7_1979-2013_V1_1}{Temperature Annual Range [degree C]}
#' \item{CHELSA_bio8_1979-2013_V1_1}{Mean Temperature of wettest quarter
#' [degree C]}
#' \item{CHELSA_bio9_1979-2013_V1_1}{Mean Temperature of driest quarter
#' [degree C]}
#' \item{CHELSA_bio10_1979-2013_V1_1}{Mean Temperature of warmest quarter
#' [degree C]}
#' \item{CHELSA_bio11_1979-2013_V1_1}{Mean Temperature of coldest quarter
#' [degree C]}
#' \item{CHELSA_bio12_1979-2013_V1_1}{Annual precipitation amount [mm]}
#' \item{CHELSA_bio13_1979-2013_V1_1}{Precipitation of wettest month [mm]}
#' \item{CHELSA_bio14_1979-2013_V1_1}{Precipitation of driest month [mm]}
#' \item{CHELSA_bio15_1979-2013_V1_1}{Precipitation Seasonality}
#' \item{CHELSA_bio16_1979-2013_V1_1}{Precipitation of wettest quarter [mm]}
#' \item{CHELSA_bio17_1979-2013_V1_1}{Precipitation of driest quarter [mm]}
#' \item{CHELSA_bio18_1979-2013_V1_1}{Precipitation of warmest quarter [mm]}
#' \item{CHELSA_bio19_1979-2013_V1_1}{Precipitation of coldest quarter [mm]}
#' \item{CHELSA_prec_1_1979-2013}{Mean January precipitation}
#' \item{CHELSA_prec_2_1979-2013}{Mean February precipitation}
#' \item{CHELSA_prec_3_1979-2013}{Mean March precipitation}
#' \item{CHELSA_prec_4_1979-2013}{Mean April precipitation}
#' \item{CHELSA_prec_5_1979-2013}{Mean May precipitation}
#' \item{CHELSA_prec_6_1979-2013}{Mean June precipitation}
#' \item{CHELSA_prec_7_1979-2013}{Mean July precipitation}
#' \item{CHELSA_prec_8_1979-2013}{Mean August precipitation}
#' \item{CHELSA_prec_9_1979-2013}{Mean September precipitation}
#' \item{CHELSA_prec_10_1979-2013}{Mean October precipitation}
#' \item{CHELSA_prec_11_1979-2013}{Mean November precipitation}
#' \item{CHELSA_prec_12_1979-2013}{Mean December precipitation}
#' \item{CHELSA_prec_1979-2013_land}{Mean annual precipitation}
#' \item{CHELSA_temp_1_1979-2013}{Mean January temperature}
#' \item{CHELSA_temp_2_1979-2013}{Mean February temperature}
#' \item{CHELSA_temp_3_1979-2013}{Mean March temperature}
#' \item{CHELSA_temp_4_1979-2013}{Mean April temperature}
#' \item{CHELSA_temp_5_1979-2013}{Mean May temperature}
#' \item{CHELSA_temp_6_1979-2013}{Mean June temperature}
#' \item{CHELSA_temp_7_1979-2013}{Mean July temperature}
#' \item{CHELSA_temp_8_1979-2013}{Mean August temperature}
#' \item{CHELSA_temp_9_1979-2013}{Mean September temperature}
#' \item{CHELSA_temp_10_1979-2013}{Mean October temperature}
#' \item{CHELSA_temp_11_1979-2013}{Mean November temperature}
#' \item{CHELSA_temp_12_1979-2013}{Mean December temperature}
#' \item{CHELSA_temp_1979-2013_land}{Mean annual temperature}
#' \item{MODCF_meanannual}{Mean annual cloud fraction}
#' \item{MODCF_monthlymean_01}{Mean January cloud fraction}
#' \item{MODCF_monthlymean_02}{Mean February fraction}
#' \item{MODCF_monthlymean_03}{Mean March cloud fraction}
#' \item{MODCF_monthlymean_04}{Mean April cloud fraction}
#' \item{MODCF_monthlymean_05}{Mean May cloud fraction}
#' \item{MODCF_monthlymean_06}{Mean June cloud fraction}
#' \item{MODCF_monthlymean_07}{Mean July cloud fraction}
#' \item{MODCF_monthlymean_08}{Mean August cloud fraction}
#' \item{MODCF_monthlymean_09}{Mean September cloud fraction}
#' \item{MODCF_monthlymean_10}{Mean October cloud fraction}
#' \item{MODCF_monthlymean_11}{Mean November cloud fraction}
#' \item{MODCF_monthlymean_12}{Mean December cloud fraction}
#' \item{MODCF_seasonality_concentration}{Cloud fraction seasonality
#' concentration}
#' \item{ESACCI_snow_prob_Jan_500m}{Mean January snow probability}
#' \item{ESACCI_snow_prob_Feb_500m}{Mean February fraction}
#' \item{ESACCI_snow_prob_Mar_500m}{Mean March snow probability}
#' \item{ESACCI_snow_prob_Apr_500m}{Mean April snow probability}
#' \item{ESACCI_snow_prob_May_500m}{Mean May snow probability}
#' \item{ESACCI_snow_prob_Jun_500m}{Mean June snow probability}
#' \item{ESACCI_snow_prob_Jul_500m}{Mean July snow probability}
#' \item{ESACCI_snow_prob_Aug_500m}{Mean August snow probability}
#' \item{ESACCI_snow_prob_Sep_500m}{Mean September snow probability}
#' \item{ESACCI_snow_prob_Oct_500m}{Mean October snow probability}
#' \item{ESACCI_snow_prob_Nov_500m}{Mean November snow probability}
#' \item{ESACCI_snow_prob_Dec_500m}{Mean December snow probability}
#' }
#'
#' @note CHELSA (climatic surfaces at 1 km resolution) is based on a
#' quasi-mechanistical statistical downscaling of the ERA interim global
#' circulation model (Karger et al. 2016). ESA's CCI-LC cloud
#' probability monthly averages are based on the MODIS snow products
#' (MOD10A2).
#'
#' @source CHELSA climate layers (\url{http://chelsa-climate.org/}) / Karger,
#' D. N., Conrad, O., Bohner, J., Kawohl, T., Kreft, H., Soria-Auza, R. W., et
#' al. (2016). Climatologies at high resolution for the Earth land surface
#' areas. arXiv preprint arXiv:1607.00217.
#' @source EarthEnv MODIS Cloud fraction (\url{http://www.earthenv.org/cloud}) /
#' Wilson AM, Jetz W (2016). Remotely Sensed High-Resolution Global Cloud
#' Dynamics for Predicting Ecosystem and Biodiversity Distributions. PLoS Biol
#' 14(3): e1002415.
#' @source ESA's CCI-LC cloud probability
#' (\url{http://maps.elie.ucl.ac.be/CCI/viewer/index.php})
#'
"GSOD_clim"
