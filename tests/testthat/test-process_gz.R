  # Check that .process_gz works properly and returns a data table.
  test_that(".download_files properly works, subsetting for country and
            agroclimatology works and .process_gz returns a data table", {
              skip_on_cran()
              skip_on_appveyor() # appveyor will not properly untar the file
              years <- 2015
              agroclimatology <- TRUE
              country <- "RP"
              station <- NULL
              cache_dir <- tempdir()
              ftp_base <- "ftp://ftp.ncdc.noaa.gov/pub/data/gsod/%s/"

              stations <- get_station_list()

              GSOD_list <- .download_files(ftp_base, station, years, cache_dir)

              expect_length(GSOD_list, 12976)

              agro_list <- .agroclimatology_list(GSOD_list, stations, cache_dir
                                                 , years)
              expect_length(agro_list, 11302)

              RP_list <- .country_list(country, GSOD_list, stations, cache_dir,
                                       years)
              expect_length(RP_list, 53)

              # Check that .process_gz returns a properly formated data table-----------------
              gz_file <- GSOD_list[[10]]
              gz_out <- .process_gz(gz_file, stations)

              expect_length(gz_out, 48)

              expect_is(gz_out, "data.table")

              expect_is(gz_out$USAF, "character")
              expect_is(gz_out$WBAN, "character")
              expect_is(gz_out$STNID, "character")
              expect_is(gz_out$STN_NAME, "character")
              expect_is(gz_out$CTRY, "character")
              expect_is(gz_out$CALL, "character")
              expect_is(gz_out$STATE, "character")
              expect_is(gz_out$CALL, "character")
              expect_is(gz_out$LAT, "numeric")
              expect_is(gz_out$LON, "numeric")
              expect_is(gz_out$ELEV_M, "numeric")
              expect_is(gz_out$ELEV_M_SRTM_90m, "numeric")
              expect_is(gz_out$BEGIN, "numeric")
              expect_is(gz_out$END, "numeric")
              expect_is(gz_out$YEARMODA, "character")
              expect_is(gz_out$YEAR, "character")
              expect_is(gz_out$MONTH, "character")
              expect_is(gz_out$DAY, "character")
              expect_is(gz_out$YDAY, "numeric")
              expect_is(gz_out$TEMP, "numeric")
              expect_is(gz_out$TEMP_CNT, "integer")
              expect_is(gz_out$DEWP, "numeric")
              expect_is(gz_out$DEWP_CNT, "integer")
              expect_is(gz_out$SLP, "numeric")
              expect_is(gz_out$SLP_CNT, "integer")
              expect_is(gz_out$STP, "numeric")
              expect_is(gz_out$STP_CNT, "integer")
              expect_is(gz_out$VISIB, "numeric")
              expect_is(gz_out$VISIB_CNT, "integer")
              expect_is(gz_out$WDSP, "numeric")
              expect_is(gz_out$WDSP_CNT, "integer")
              expect_is(gz_out$MXSPD, "numeric")
              expect_is(gz_out$GUST, "numeric")
              expect_is(gz_out$MAX, "numeric")
              expect_is(gz_out$MAX_FLAG, "character")
              expect_is(gz_out$MIN, "numeric")
              expect_is(gz_out$MIN_FLAG, "character")
              expect_is(gz_out$PRCP, "numeric")
              expect_is(gz_out$PRCP_FLAG, "character")
              expect_is(gz_out$SNDP, "numeric")
              expect_is(gz_out$I_FOG, "integer")
              expect_is(gz_out$I_RAIN_DRIZZLE, "integer")
              expect_is(gz_out$I_SNOW_ICE, "integer")
              expect_is(gz_out$I_HAIL, "integer")
              expect_is(gz_out$I_THUNDER, "integer")
              expect_is(gz_out$I_TORNADO_FUNNEL, "integer")
              expect_is(gz_out$EA, "numeric")
              expect_is(gz_out$ES, "numeric")
              expect_is(gz_out$RH, "numeric")

              })
