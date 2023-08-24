
#' Download Latest Station List Metadata and Update an Internal Database
#'
#' This function downloads the latest station list (isd-history.csv) from the
#' \acronym{NCEI} server and updates the data distributed with \CRANpkg{GSODR}
#' to the latest stations available.  These data provide unique identifiers,
#' country, state (if in U.S.) and when weather observations begin and end.
#'
#' Care should be taken when using this function if reproducibility is necessary
#' as different machines with the same version of \CRANpkg{GSODR} can end up
#' with different versions of the 'isd_history.csv' file internally.
#'
#' There is no need to use this unless you know that a station exists in the
#' isd_history.csv file that is not available in the self-contained
#' database distributed with \CRANpkg{GSODR}.
#'
#' To directly access these data, use: \cr
#' \code{load(system.file("extdata", "isd_history.rda", package = "GSODR"))}
#'
#' @examplesIf interactive()
#' update_station_list()
#'
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @autoglobal
#' @export update_station_list

update_station_list <- function() {

  message(
    "This will overwrite GSODR's current internal list of GSOD stations.\n",
    "If reproducibility is necessary, you may not wish to proceed.\n",
    "Do you understand and wish to proceed (Y/n)?\n"
  )

  answer <-
    readLines(con = getOption("GSODR_connection"), n = 1)

  answer <- toupper(answer)

  if (answer != "Y" & answer != "YES") {
    stop("Station list was not updated.",
         call. = FALSE)
  }

  tryCatch({
    # download data
    isd_history <-
      fread("https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.csv")

    # pad WBAN where necessary
    isd_history[, WBAN := sprintf("%05d", WBAN)]

    # add STNID column
    isd_history[, STNID := paste(USAF, WBAN, sep = "-")]
    setcolorder(isd_history, "STNID")
    setnames(isd_history, "STATION NAME", "NAME")

    # remove stations where LAT or LON is NA
    isd_history <- stats::na.omit(isd_history, cols = c("LAT", "LON"))

    # remove extra columns
    isd_history[, c("USAF", "WBAN", "ICAO") := NULL]

    isd_history <-
      isd_history[setDT(countrycode::codelist), on = c("CTRY" = "fips")]

    isd_history <- isd_history[, c(
      "STNID",
      "NAME",
      "LAT",
      "LON",
      "ELEV(M)",
      "CTRY",
      "STATE",
      "BEGIN",
      "END",
      "country.name.en",
      "iso2c",
      "iso3c"
    )]

    # clean data
    isd_history[isd_history == -999] <- NA
    isd_history[isd_history == -999.9] <- NA
    isd_history <-
      isd_history[!is.na(isd_history$LAT) &
                    !is.na(isd_history$LON), ]
    isd_history <-
      isd_history[isd_history$LAT != 0 &
                    isd_history$LON != 0, ]
    isd_history <-
      isd_history[isd_history$LAT > -90 &
                    isd_history$LAT < 90, ]
    isd_history <-
      isd_history[isd_history$LON > -180 &
                    isd_history$LON < 180, ]

    # set colnames to upper case
    names(isd_history) <- toupper(names(isd_history))
    setnames(isd_history,
             old = "COUNTRY.NAME.EN",
             new = "COUNTRY_NAME")

    # set country names to be upper case for easier internal verifications
    isd_history[, COUNTRY_NAME := toupper(COUNTRY_NAME)]

    # set key for joins when processing CSV files
    setkeyv(isd_history, "STNID")[]

    # write rda file to disk for use with GSODR package
    fname <-
      system.file("extdata", "isd_history.rda", package = "GSODR")
    save(isd_history,
         file = fname,
         compress = "bzip2")
  },

  error = function(cond) {
    stop(
      "There was a problem retrieving the station list file. Perhaps \n",
      "the server is not responding currently or there is no \n",
      "Internet connection. Please try again later.",
      call. = FALSE
    )
  })
}
