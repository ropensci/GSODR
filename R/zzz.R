.onAttach <- function(libname, pkgname) {
  options(GSODR_connection = stdin())

  msg <- paste(
    "{.strong The GSOD dataset was retired} on {.date 2025-08-29}.",
    "{.pkg {pkgname}} will not receive further updates.",
    sep = "\n"
  )

  packageStartupMessage(cli::format_inline(msg))
}
