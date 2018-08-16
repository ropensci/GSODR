# Test environments

  -  local macOS install, R version 3.5.1 (2018-07-02)

  -  local Ubuntu 18.04, R version 3.5.1 (2018-07-02)

  -  win-builder R Under development (unstable) (2018-08-14 r75146)

  -  win-builder R version 3.5.1 (2018-04-23)


# R CMD check results

0 errors | 0 warnings | 1 note

# New patch release

## Bug fixes

  - Fix bug in creating `isd-history.rda` file where duplicate stations existed
  in the file distributed with `GSODR` but with different corrected elevation
  values

  - Repatch bug reported and fixed previously in version 1.2.0 where Windows
  users could not successfully download files. This somehow snuck back in with
  the last release.

## Minor changes

  - Refactor vignettes for clarity

# Reverse dependencies

- No ERRORs or WARNINGs found
