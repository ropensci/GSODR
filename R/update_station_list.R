#' Download Latest isd-history.csv File and Update an Internal Database
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
#' `load(system.file("extdata", "isd_history.rda", package = "GSODR"))`
#'
#' To see the latest version available from the \acronym{NCEI} server, please
#' refer to [get_isd_history()].
#'
#' @examples
#' \dontrun{
#' update_station_list()
#' }
#' @returns Called for side-effects of saving a file to disk, returns an
#'  invisible `NULL`.
#' @seealso [get_isd_history()]
#' @author Adam H. Sparks, \email{adamhsparks@@gmail.com}
#' @autoglobal

update_station_list <- function() {
  message(
    "This will overwrite GSODR's current internal list of GSOD stations. \n",
    "If reproducibility is necessary, you may not wish to proceed. \n",
    "Do you understand and wish to proceed (Y/n)?\n"
  )

  answer <-
    readLines(con = getOption("GSODR_connection"), n = 1L)

  answer <- toupper(answer)

  if (answer != "Y" & answer != "YES") {
    stop("Station list was not updated.", call. = FALSE)
  }

  isd_history <- get_isd_history()

  # write rda file to disk for use with GSODR package
  fname <-
    system.file("extdata", "isd_history.rda", package = "GSODR")
  save(isd_history, file = fname, compress = "bzip2")
  return(invisible(NULL))
}
