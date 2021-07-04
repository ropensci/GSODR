test_that(
  ".download_files properly works, subsetting for country and
  agroclimatology works",
  {
    skip_on_cran()
    do.call(file.remove, list(list.files(
      tempdir(),
      pattern = ".csv$",
      full.names = TRUE
    )))
    years <- 1982
    agroclimatology <- TRUE
    country <- "RP"
    station <- NULL
    
    load(system.file("extdata", "isd_history.rda", package = "GSODR"))
    setkey(isd_history, "STNID")
    stations <- isd_history
    
    load(system.file("extdata", "isd_history.rda",
                     package = "GSODR"))
    
    GSOD_list <- .download_files(station,
                                 years)
    
    agro_list <- .agroclimatology_list(GSOD_list,
                                       stations,
                                       years)
    expect_length(agro_list, 7480)
    
    RP_list <- .subset_country_list(country,
                                    GSOD_list,
                                    stations,
                                    years)
    expect_length(RP_list, 54)
  }
)
