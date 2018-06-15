# Test environments

- local macOS install, R version 3.5.0 (2018-04-23)

- local Ubuntu 18.04, R version 3.5.0 (2018-04-23)

- win-builder R Under development (unstable) (2018-06-13 r74894)

- win-builder R version 3.5.0 (2018-04-23)

# R CMD check results

0 errors | 0 warnings | 1 note

# New minor release

This is a new minor release

## Bug fixes

- Introduce a message if a station ID is requested but files are not found on
the server. This is in response to an inquiry from John Paul Bigouette where
a station is reported as having data in the inventory but the files do not exist
on the server.

- Fix bug that removed a few hundred stations from the internal `GSODR` database
of stations in the `data-raw` files.

## Minor changes

  - Clean documentation, shortening long lines, fixing formatting, incomplete
  sentences and broken links

- Clarify the reasons for errors that a user may encounter when running package

- Update internal databases of station metadata

# Reverse dependencies

- No ERRORs or WARNINGs found

# Downstream dependencies

- There currently are no downstream dependencies for this package
