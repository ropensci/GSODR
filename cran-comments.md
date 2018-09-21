# Test environments

  -  local macOS install, R version 3.5.1 (2018-07-02)

  -  local Ubuntu 18.04, R version 3.5.1 (2018-07-02)

  -  win-builder R Under development (unstable) (2018-08-14 r75146)

  -  win-builder R version 3.5.1 (2018-04-23)


# R CMD check results

0 errors | 0 warnings | 1 note

# New patch release

## Bug fixes

- Refactor internal functionality to be more clear and efficient in execution
    
    - `country-list` is not loaded unless user has specified a country in
      `get_GSOD()`
      
    - An instance where the FIPS code was determined twice was removed

## Minor changes

- Update internal database of station locations
  
- Internal database of station locations stores `BEGIN` and `END` fields as
  integer, not double
  
- Clarify code of conduct statement in README that it only applies to this,
  GSODR, project
  
- Prompt user for input with warning about reproducibility if using the
  `update_station_list()` function

# Reverse dependencies

- No ERRORs or WARNINGs found
