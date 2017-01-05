#'SRTM_GSOD_elevation
#'
#' @format A data frame with 28322 observations of 2 variables:
#' \describe{
#'   \item{STNID}{Unique station ID, a concatenation of USAF and WBAN number,
#'   used for merging with station data weather files}
#'   \item{ELEV_M_SRTM_90m}{Elevation in metres extracted from SRTM data (Jarvis
#'   \emph{et al}. 2008)}
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
#' \item{CHELSA_bio1_1979-2013_V1_1}{Annual mean temperature [degrees Celsius]}
#' \item{CHELSA_bio2_1979-2013_V1_1}{Mean diurnal range [degrees Celsius]}
#' \item{CHELSA_bio3_1979-2013_V1_1}{Isothermality}
#' \item{CHELSA_bio4_1979-2013_V1_1}{Temperature seasonality}
#' \item{CHELSA_bio5_1979-2013_V1_1}{Maximum temperature of warmest month
#' [degrees Celsius]}
#' \item{CHELSA_bio6_1979-2013_V1_1}{Minimum temperature of coldest month
#' [degrees Celsius]}
#' \item{CHELSA_bio7_1979-2013_V1_1}{Temperature annual range [degrees Celsius]}
#' \item{CHELSA_bio8_1979-2013_V1_1}{Mean Temperature of wettest quarter
#' [degrees Celsius]}
#' \item{CHELSA_bio9_1979-2013_V1_1}{Mean Temperature of driest quarter
#' [degrees Celsius]}
#' \item{CHELSA_bio10_1979-2013_V1_1}{Mean Temperature of warmest quarter
#' [degrees Celsius]}
#' \item{CHELSA_bio11_1979-2013_V1_1}{Mean Temperature of coldest quarter
#' [degrees Celsius]}
#' \item{CHELSA_bio12_1979-2013_V1_1}{Annual precipitation amount [mm]}
#' \item{CHELSA_bio13_1979-2013_V1_1}{Precipitation of wettest month [mm]}
#' \item{CHELSA_bio14_1979-2013_V1_1}{Precipitation of driest month [mm]}
#' \item{CHELSA_bio15_1979-2013_V1_1}{Precipitation seasonality}
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
#' \item{CRU_CL2_0_dtr_01}{Mean January diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_02}{Mean Februrary diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_03}{Mean March diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_04}{Mean April diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_05}{Mean May diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_06}{Mean June diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_07}{Mean July diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_08}{Mean August diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_09}{Mean September diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_10}{Mean October diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_11}{Mean November diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_dtr_12}{Mean December diurnal temperature range [degrees Celsius]}
#' \item{CRU_CL2_0_frs_01}{January ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_02}{Februrary ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_03}{March ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_04}{April ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_05}{May ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_06}{June ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_07}{July ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_08}{August ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_09}{September ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_10}{October ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_11}{November ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_frs_12}{December ground-frost [number of days with ground-frost per month]}
#' \item{CRU_CL2_0_pre_01}{January precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_02}{Februrary precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_03}{March precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_04}{April precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_05}{May precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_06}{June precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_07}{July precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_08}{August precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_09}{September precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_10}{October precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_11}{November precipitation [millimetres per month]}
#' \item{CRU_CL2_0_pre_12}{December precipitation [millimetres per month]}
#' \item{CRU_CL2_0_rd0_01}{January wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_02}{Februrary wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_03}{March wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_04}{April wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_05}{May wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_06}{June wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_07}{July wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_08}{August wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_09}{September wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_10}{October wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_11}{November wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_rd0_12}{December wet-days [no days with >0.1mm rain per month]}
#' \item{CRU_CL2_0_reh_01}{Mean January relative humidity [percent]}
#' \item{CRU_CL2_0_reh_02}{Mean Februrary relative humidity [percent]}
#' \item{CRU_CL2_0_reh_03}{Mean March relative humidity [percent]}
#' \item{CRU_CL2_0_reh_04}{Mean April relative humidity [percent]}
#' \item{CRU_CL2_0_reh_05}{Mean May relative humidity [percent]}
#' \item{CRU_CL2_0_reh_06}{Mean June relative humidity [percent]}
#' \item{CRU_CL2_0_reh_07}{Mean July relative humidity [percent]}
#' \item{CRU_CL2_0_reh_08}{Mean August relative humidity [percent]}
#' \item{CRU_CL2_0_reh_09}{Mean September relative humidity [percent]}
#' \item{CRU_CL2_0_reh_10}{Mean October relative humidity [percent]}
#' \item{CRU_CL2_0_reh_11}{Mean November relative humidity [percent]}
#' \item{CRU_CL2_0_sun_01}{Mean January sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_02}{Mean Februrary sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_03}{Mean March sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_04}{Mean April sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_05}{Mean May sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_06}{Mean June sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_07}{Mean July sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_08}{Mean August sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_09}{Mean September sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_10}{Mean October sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_11}{Mean November sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_sun_12}{Mean December sunshine [percent of maximum possible (percent of day length)]}
#' \item{CRU_CL2_0_tmp_01}{Mean January temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_02}{Mean Februrary temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_03}{Mean March temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_04}{Mean April temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_05}{Mean May temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_06}{Mean June temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_07}{Mean July temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_08}{Mean August temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_09}{Mean September temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_10}{Mean October temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_11}{Mean November temperature [degrees Celsius]}
#' \item{CRU_CL2_0_tmp_12}{Mean December temperature [degrees Celsius]}
#' \item{CRU_CL2_0_wnd_01}{Mean January 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_02}{Mean Februrary 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_03}{Mean March 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_04}{Mean April 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_05}{Mean May 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_06}{Mean June 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_07}{Mean July 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_08}{Mean August 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_09}{Mean September 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_10}{Mean October 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_11}{Mean November 10 metre wind speed [metres per second]}
#' \item{CRU_CL2_0_wnd_12}{Mean December 10 metre wind speed [metres per second]}
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
#' \item{ESACCI_snow_prob_1_500m}{Mean January snow cover probability}
#' \item{ESACCI_snow_prob_2_500m}{Mean February snow cover probability}
#' \item{ESACCI_snow_prob_3_500m}{Mean March snow cover probability}
#' \item{ESACCI_snow_prob_4_500m}{Mean April snow cover probability}
#' \item{ESACCI_snow_prob_5_500m}{Mean May snow cover probability}
#' \item{ESACCI_snow_prob_6_500m}{Mean June snow cover probability}
#' \item{ESACCI_snow_prob_7_500m}{Mean July snow cover probability}
#' \item{ESACCI_snow_prob_8_500m}{Mean August snow cover probability}
#' \item{ESACCI_snow_prob_9_500m}{Mean September snow cover probability}
#' \item{ESACCI_snow_prob_10_500m}{Mean October snow cover probability}
#' \item{ESACCI_snow_prob_11_500m}{Mean November snow cover probability}
#' \item{ESACCI_snow_prob_12_500m}{Mean December snow cover probability}
#' }
#'
#' @note CHELSA (climatic surfaces at 1 km resolution) is based on a
#' quasi-mechanistic statistical downscaling of the ERA interim global
#' circulation model (Karger et al. 2016). ESA's CCI-LC cloud
#' probability monthly averages are based on the MODIS snow products
#' (MOD10A2).
#'
#' @source CHELSA climate layers (\url{http://chelsa-climate.org/}) / Karger,
#' D. N., Conrad, O., Bohner, J., Kawohl, T., Kreft, H., Soria-Auza, R. W., et
#' al. (2016). Climatologies at high resolution for the Earth land surface
#' areas. arXiv preprint arXiv:1607.00217.
#' @source EarthEnv MODIS cloud fraction (\url{http://www.earthenv.org/cloud}) /
#' Wilson AM, Jetz W (2016). Remotely Sensed High-Resolution Global Cloud
#' Dynamics for Predicting Ecosystem and Biodiversity Distributions. PLoS Biol
#' 14(3): e1002415.
#' @source ESA's CCI-LC snow cover probability
#' (\url{http://maps.elie.ucl.ac.be/CCI/viewer/index.php})
#' @source A high-resolution data set of surface climate over global land areas.
#' (2000) New M, Lister D, Hulme M, Makin I. Climate Research, Vol 21, pg 1-25
#' http://www.cru.uea.ac.uk/cru/data/hrg/tmc/readme.txt
#'
"GSOD_clim"
