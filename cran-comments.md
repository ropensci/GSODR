# Test environments

  -  macOS, R version 3.5.1 (2018-07-02)

  -  Debian Linux, R version 3.5.1 (2018-07-02)

  -  win-builder, R Under development (unstable) (2018-09-20 r75339)

  -  win-builder, R version 3.5.1 (2018-04-23)


# R CMD check results

0 errors | 0 warnings | 1 note

# New patch release

## Bug fixes

- Refactor internal functionality to be more clear and efficient in execution
    
    - `country-list` is not loaded unless user has specified a country in
      `get_GSOD()`
      
    - An instance where the FIPS code was determined twice was removed

- Replace `\dontrun{}` with `\donttest{}` in documentation examples

- Ensure that DESCRIPTION file follows CRAN guidelines

## Minor changes

- Format help files, fixing errors and formatting for attractiveness

- Update internal database of station locations
  
- Update internal database of station locations
  
- Store internal database of station locations fields `BEGIN` and `END` as
  integer, not double
  
- Clarify code of conduct statement in README that it only applies to this,
  GSODR, project
  
- Prompt user for input with warning about reproducibility if using the
  `update_station_list()` function

- Adds metadata header to the `tibble` returned by `get_inventory()`

- Remove startup message to conform with rOpenSci guidelines

# Reverse dependencies

- No ERRORs or WARNINGs found
