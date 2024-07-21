do.call(file.remove, list(list.files(
  tempdir(), pattern = ".csv$", full.names = TRUE
)))

test_that(".download_files properly works, subsetting for country and
  agroclimatology works",
          {
            skip_if_offline()
            years <- 1982
            agroclimatology <- TRUE
            country <- "RP"
            station <- NULL

            stations <- get_isd_history()
            setkey(stations, "STNID")

            GSOD_list <- .download_files(station, years)

            agro_list <- .agroclimatology_list(GSOD_list, stations, years)

            RP_list <- .subset_country_list(country, GSOD_list, stations, years)
          })

