## Test environments
* local OS X install, R version 3.3.2 (2016-10-31)
* Ubuntu 12.04 (on travis-ci), R version 3.3.2 (2016-10-31)
* Windows (on win-builder), R version 3.3.2 (2016-10-31)
* Windows (on win-builder), R Under development (unstable) (2017-01-17 r72004)

## R CMD check results
There were no ERRORs or WARNINGs. 

## New major release
This is a new major release.

## Major changes

- The `get_GSOD()` function returns a `data.frame` object in the current R session with the option to save data to local disk  
- Multiple stations can be specified for download rather than just downloading a single station or all stations  
- A new function, `nearest_stations()` is now included to find stations within a user specified radius (in kilometres) of a point given as latitude and longitude in decimal degrees  
- A general use vignette is now included  
- New vignette with a detailed use-case  
- Output files now include fields for State (US only) and Call (International Civil Aviation Organization (ICAO) Airport Code)  
- Use FIPS codes in place of ISO3c for file name and in output files because some stations do not have an ISO country code  
- Spatial file output is now in GeoPackage format (GPKG). This results in a single file output unlike shapefile and allows for long field names  
- Users can specify file name of output  
- R >= 3.2.0 now required  
- Field names in output files use "\_" in place of "."  
- Long field names now used in file outputs  
- Country is specified using FIPS codes in file name and output file contents due to stations occurring in some locales that lack ISO 3166 3 letter country codes  
- The `get_GSOD()` function will retrieve the latest station data from NCDC and automatically merge it with the CGIAR-CSI SRTM elevation values provided by this package. Previously, the package provided it's own list of station information, which was difficult to keep up-to-date  
- A new `reformat_GSOD()` function reformats station files in "WMO-WBAN-YYYY.op.gz" format that have been downloaded from the United States
  National Climatic Data Center's (NCDC) FTP server.  
- A new function, `get_station_list()` allows for fetching latest station list from the FTP server and querying by the user for a specified station or location.  
- New data layers are provided through a separate package, [`GSODRdata`](https://github.com/adamhsparks/GSODRdata), which provide climate data formatted for use with GSODR. 
    - CHELSA (climatic surfaces at 1 km resolution), http://chelsa-climate.org/,
    - MODCF - Remotely sensed high-resolution global cloud dynamics for predicting ecosystem and biodiversity distributions (http://www.earthenv.org/cloud), 
    - ESACCI - ESA's CCI-LC snow cover probability (http://maps.elie.ucl.ac.be/CCI/viewer/index.php) and 
    - CRU CL2.0 (climatic surfaces at 10 minute resolution) (https://crudata.uea.ac.uk/%7Etimm/grid/CRU_CL_2_0.html)  
- Improved file handling for individual station downloads  
- Missing values are handled as `NA` not -9999  
- Change from GPL >= 3 to MIT licence to bring into line with ropensci packages  
- Now included in ropensci, [ropensci/GSODR](https://github.com/ropensci/GSODR)  
  
## Bug Fixes

- Fixed: Remove redundant code in `get_GSOD()` function  
- Fixed: The stations data frame distributed with the package now include stations that are located above 60 latitude and below -60 latitude  
  
## Deprecated and defunct

- Missing values are reported as NA for use in R, not -9999 as previously  
- The `path` parameter is now instead called `dsn` to be more inline with other tools like `readOGR()` and `writeOGR()`  
- Shapefile file out is no longer supported. Use GeoPackage (GPKG) instead  
- The option to remove stations with too many missing days is now optional, it now defaults to including all stations, the user must specify how many missing stations to check for an exclude.  
- The `max_missing` parameter is now user set, defaults to no check, return all stations regardless of missing days  


## Reverse dependencies
* There are no reverse dependencies  

## Downstream dependencies
* There currently are no downstream dependencies for this package  
