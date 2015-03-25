#' @title Download, Clean and Generate New Variables From GSOD Weather Data
#'
#'@description This function automates downloading and cleaning data from the
#'Global Summary of the Day (GSOD) data provided by the US National Climatic
#'Data Center (NCDC). Stations are individually checked for number of missing
#'days to assure data quality, stations with too many missing observations are
#'omitted. All units are converted to metric, e.g. feet to metres and
#'Fahrenheit to Celcius. Output is saved as a .csv file summarizing each year by
#'station, which includes vapor pressure and relative humidity variables
#'calculated from existing data in GSOD.
#'
#'Be sure to have disk space free and allocate the proper time for this to run.
#'This is a time, processor and disk space intensive process.
#'
#'For more information see the description of the data provided by NCDC,
#'\url{http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt}
#' @param start_year The first year of the series of weather data to download
#' @param end_year The last year of the series of weather data to download
#' @param max_missing The maximum number of days allowed to be missing from a
#' station's data before it is excluded from .csv file output
#'
#' @details This function generates a GSOD_TPYYYY_XY.csv file in the respective
#' year directory containing the following data:
#' weather variables as columns
#' STNID - Station ID,
#' LAT - latitude,
#' LON - longitude,
#' ELEV.M - elevation in metres,
#' YEARMODA - Date in YYYY-MM-DD format,
#' YEAR - Year,
#' MONTH - Month,
#' DAY - Day,
#' TEMPC - Mean daily temperature in *C,
#' DEWPC-  Mean daily dewpoint in *C,
#' WDSPC - Mean daily wind speed value,
#' MAXC - Daily maximum temperature,
#' MINC - Daily minimum temperature,
#' ea - Mean daily actual vapor, pressure,
#' es - Mean daily saturation vapor pressure,
#' RH - Mean daily relative humidity
#'
#' @examples
#' # Download data for years 2009 and 2010 and generate yearly summary files,
#' # GSOD_TP2009_XY and GSOD_TP2010_XY files in folders 2009 and 2010 of your
#' # working directory with a maximum of five missing days per weather station
#' # allowed.
#'
#' get_GSOD(start_year = 2009, end_year = 2010, max_missing = 5)

get_GSOD <- function(start_year,
                     end_year,
                     max_missing) {
  yr <- NULL

  # ftp site for data download
  ftp.GSOD <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/"
  k <- 1 # enumerator for appending to .csv file out

  # ---------------------------------------------------------
  # STEP 1: Download the data from server
  # ---------------------------------------------------------
  # Download the location coordinates of stations:
  if(!file.exists(paste(getwd(), "/isd-history.csv", sep = ""))) {
    cat("Downloading station file\n")
    download.file(paste(ftp.GSOD, "isd-history.csv", sep = ""),
                  destfile = paste(getwd(), "/isd-history.csv",
                                   sep = ""), mode = "wb")
  }
  # Read .csv file
  stations <- read.csv(paste(getwd(), "/isd-history.csv", sep = ""),
                       colClasses = c(USAF = "character", WBAN = "character"))
  stations$STNID <- paste(stations$USAF, stations$WBAN, sep = "-")
  # Format coordinates to decimal degrees:
  stations$LAT <- ifelse(stations$LAT > 90.0 * 1000 |
                           stations$LAT < -90.0 * 1000,
                         NA, stations$LAT / 1000)
  stations$LON <- ifelse(stations$LON > 180 * 1000 |
                           stations$LON < -180 * 1000,
                         NA, stations$LON / 1000)
  # Format elevation to metres:
  stations$ELEV.M <- ifelse(stations$ELEV.M == -99999 |
                              stations$ELEV.M == -999.999,
                            NA, stations$ELEV.M / 10)

  for (yr in start_year:end_year) { # loop to download all years
    # download gsod data .gz file for the whole year

    try(dir.create(paste(getwd(), yr, sep = "/")))

    #setwd(paste(getwd(), yr, sep = "/"))

    outfile <- paste(getwd(), "/", yr, "/GSOD_TP", yr, "_XY.csv", sep = "")

    if(!file.exists(paste(getwd(), "/", yr, ".tar", sep = ""))) {
      cat("Downloading gsod tar file\n")
      try(download.file(paste(ftp.GSOD, yr, "/gsod_", yr, ".tar", sep = ""),
                        destfile = paste(getwd(), "/", yr, "/",
                                         yr, ".tar", sep = ""), mode = "wb"))
    }

    # Extract files
    untar(tarfile = paste(getwd(), "/", yr, "/", yr, ".tar", sep = ""),
          exdir  = paste(getwd(), "/", yr, "/", sep = ""))

    # Clean up by removing the downloaded tar file, shortens code in next section
    file.remove(paste(getwd(), "/", yr, "/", yr, ".tar", sep = ""))

    # list all files:
    GSOD_list <- dir(paste(getwd(), "/", yr, sep = ""), pattern = glob2rx("*.gz"),
                     full.names = FALSE)

    # ---------------------------------------------------------
    # STEP 2: Reformat, tidy up and compute climate variables
    # ---------------------------------------------------------

    # create an empty list:
    GSOD_TP.list <- as.list(rep(NA, 1))
    k <- 1
    # run in a loop. unzip values, trim white spaces and write to a single file:
    for(j in 1:length(GSOD_list)){

      # import the current station file
      tmp <- readLines(paste(getwd(), yr, GSOD_list[j], sep = "/"))

      # ---------------------------------------------------------
      # STEP 2.1: check against maximum permissible missing days
      # ---------------------------------------------------------
      if(leap_year(yr) == TRUE){
        s <- 366 - max_missing + 1 # complete leap year is 367 lines
      } else {
        s <- 365 - max_missing + 1 # complete year is 366 lines
      }

      if (length(tmp) < s) {
        file.remove(paste(getwd(), yr, GSOD_list[j], sep = "/"))
      } else {

        tmp.f <- tmp[-1] #remove header for formatting purposes

        #---------------------------------------------------------
        # STEP 2.2: clean up the station and weather data
        # ---------------------------------------------------------

        STN <- substr(tmp.f, 1, 6) #station number
        WBAN <- substr(tmp.f, 8, 12) #WBAN number
        STNID <- paste(STN, WBAN, sep = "-") # WMO/DATSAV3 number

        YEARMODA <- as.integer(substr(tmp.f, 15, 22)) #YYYYMODA
        YEAR <- as.numeric(substr(tmp.f, 15, 18)) #year
        MONTH <- as.numeric(substr(tmp.f, 19, 20)) #month
        DAY <- as.numeric(substr(tmp.f, 21, 22)) #day
        YDAY <- 1 + as.POSIXlt(as.Date(as.character(YEARMODA), "%Y%m%d"),
                               "GMT")$yday # DAY OF YEAR

        #############################################
        # Convert daily mean temp from degree F to degree C
        TEMPC <- as.numeric(substr(tmp.f, 25, 30)) # mean T
        TEMPC <- ifelse(TEMPC == 9999.9, NA, (TEMPC - 32) * (5 / 9))
        DEWPC <- as.numeric(substr(tmp.f, 36, 41)) # mean dewpoint
        DEWPC <- ifelse(DEWPC == 9999.9, NA, (DEWPC - 32) * (5 / 9))

        ##############################################
        # Windspeed
        WDSPC <- as.numeric(substr(tmp.f, 79, 83))
        WDSPC <- ifelse(WDSPC == 999.9, NA, WDSPC*0.514444444)

        ##############################################
        # Convert daily max temp from degree F to degree C
        MAXC <- as.numeric(substr(tmp.f, 103, 108))
        MAXC <- ifelse(MAXC == 9999.9, NA, (MAXC - 32) * (5 / 9))

        ##############################################
        # Convert daily min temp from degree F to degree C
        MINC <- as.numeric(substr(tmp.f, 111, 116))
        MINC <- ifelse(MINC == 9999.9, NA, (MINC - 32) * (5 / 9))

        # Convert precipitation depth to mm
        PRCP <- as.numeric(substr(tmp.f, 119, 123))
        PRCP <- ifelse(PRCP == 999.9, NA, round(PRCP * 25.4, 1) * 10)

        # Convert snow depth to mm
        SNDP <- as.numeric(substr(tmp.f, 126, 130))
        SNDP <- ifelse(SNDP == 999.9, NA, round(SNDP * 25.4, 1) * 10)

        indicators <- substr(tmp.f, 133, 138)
        indicators <- matrix(as.numeric(unlist(strsplit(indicators, ""))),
                             byrow = TRUE, ncol = 6)
        colnames(indicators) <- c("ifog", "irain", "isnow", "ihail",
                                  "ithunder", "itornado")

        tmp.f <- data.frame(
          STNID,
          YEARMODA,
          YEAR,
          MONTH,
          DAY,
          YDAY,
          TEMPC,
          DEWPC,
          WDSPC,
          MAXC,
          MINC,
          SNDP,
          indicators,
          stringsAsFactors = FALSE)

        tmp.f$STNID <- as.character(tmp.f$STNID)

        # ---------------------------------------------------------
        # STEP 2.3: join to the station data
        # ---------------------------------------------------------
        GSOD.XY <- inner_join(tmp.f, stations, by = "STNID")

        # Somehwow the isd-history.csv file does not always agree with
        # station names, if that happens and GSOD.XY contains
        # no data, this statment skips any further calculations.
        if(length(GSOD.XY[, 1] > 1)){
          # ---------------------------------------------------------
          # STEP 2.4: compute other weather vars
          # ---------------------------------------------------------

          ##############################################
          # MEAN ACTUAL (EA) AND MEAN SATURATION VAPOUR PRESSURE (ES)
          # http://www.apesimulator.it/help/models/evapotranspiration/
          # MEAN ACTUAL VAPOUR PRESSURE (EA) DERIVED FROM DEWPOINT TEMPERATURE
          GSOD.XY$ea <- 0.61078 * exp((17.2694 * GSOD.XY$DEWPC) /
                                        (GSOD.XY$DEWPC + 237.3)) # kPa
          # MEAN SATURATION VAPOUR PRESSURE FROM AVG TEMPERATURE
          GSOD.XY$es <- 0.61078 * exp((17.2694 * GSOD.XY$TEMPC) /
                                        (GSOD.XY$TEMPC + 237.3)) # kPa
          # Calculate relative humidity (RH)
          GSOD.XY$RH <- GSOD.XY$ea / GSOD.XY$es * 100

          # ---------------------------------------------------------
          # STEP 3: Write to csv file, one row per day per station - huge file
          # ---------------------------------------------------------
          # WRITE OUT ROW BY ROW
          GSOD_TP.list[[1]] <- GSOD.XY[,c("STNID",
                                          "LAT",
                                          "LON",
                                          "ELEV.M",
                                          "YEARMODA",
                                          "YEAR",
                                          "MONTH",
                                          "DAY",
                                          "TEMPC",
                                          "DEWPC",
                                          "WDSPC",
                                          "MAXC",
                                          "MINC",
                                          "SNDP",
                                          "ifog",
                                          "irain",
                                          "isnow",
                                          "ihail",
                                          "ithunder",
                                          "itornado",
                                          "ea",
                                          "es",
                                          "RH")]
          # Write data into .csv file
          if(k == 1) {
            write.table(GSOD_TP.list[[1]], outfile , na = "-9999",  sep = ",",
                        row.names = FALSE, col.names = TRUE, append = FALSE)
          } else {
            write.table(GSOD_TP.list[[1]], outfile , na = "-9999",  sep = ",",
                        row.names = FALSE, col.names = FALSE, append = TRUE)
          }
          # iterate through k for previous section in writing .csv file outputs
          k <- k + 1
        }
        # clean up
        rm(tmp.f)
      }
    }
    # delete the gz weather files leaving only the .csv file in the year dir
    file.remove(paste(getwd(), "/", yr, "/", sep = ""),
                pattern = glob2rx("*.gz"), full.names = FALSE)
  }
}

# eos
