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

- The `get_GSOD()` function returns a data.frame object in the current R session with the option to save data to local disk
- Multiple stations can be specified for download rather than just downloading a single station or all stations  
- A new function, `nearest_stations()` is now included to find stations within a user specified radius (in kilometres) of a point given as latitude and longitude in decimal degrees  
- A general use vignette is now included  
- New vignette with a detailed use-case  
- Output files now include fields for State (US only) and Call (International Civil Aviation Organization (ICAO) Airport Code)  
- Use FIPS codes in place of ISO3c for file name and in output files because some stations do not have an ISO country code  
- Spatial file output is now in GeoPackage format (GPKG). This results in a single file output unlike shapefile and allows for long field names  
- Users can specify file name of output  
- Users can ask for the most recent list of GSOD stations from the NCDC
  FTP server to use in place of the list provided with GSODR  
- All files are written to same output folder, specified by user in the `dsn` parameter. For multiple year queries, the year is appended to the file name
  that is specified by the user  
- R >= 3.2.0 now required  
- Field names in output files use "\_" in place of "."  
- Long field names now used in file outputs  
- Country is specified using FIPS codes in file name and output file contents due to stations occurring in some locales that lack ISO 3166 3 letter country codes  
- The `get_GSOD()` function will retrieve the latest station data from NCDC and automatically merge it with the CGIAR-CSI SRTM elevation values provided by this package. Previously, the package provided it's own list of station information, which was difficult to keep up-to-date  
- A new `reformat_GSOD()` function reformats station files in "WMO-WBAN-YYYY.op.gz" format that have been downloaded from the United States
  National Climatic Data Center's (NCDC) FTP server.  
- A internal new function, `get_station_list()`, fetches the latest station list from the FTP server.  
- New data layers are provided through a separate package, GSOD.data (https://github.com/adamhsparks/GSODR.data), which provide climate data formatted for use with GSODR. CHELSA (climatic surfaces at 1 km resolution), http://chelsa-climate.org/, http://www.earthenv.org/cloud, http://maps.elie.ucl.ac.be/CCI/viewer/index.php and CRU CL2.0 (https://crudata.uea.ac.uk/%7Etimm/grid/CRU_CL_2_0.html) 
- Improved file handling for individual station downloads  
- Missing values are handled as `NA` not -9999  
- Change from GPL >= 3 to MIT licence to bring into line with ropensci packages  
  
## Minor changes

- `get_GSOD()` function optimised for speed as best possible after FTPing files from NCDC server  
- All files are downloaded from server and then locally processed, previously these were sequentially downloaded by year and then processed  
- A progress bar is now shown when processing files locally after   downloading  
- Reduced package dependencies  
- The `get_GSOD()` function now checks stations to see if the years being queried are provided and returns a message alerting user if the station and years requested are not available  
- When stations are specified for retrieval using the `station = ""` parameter, the `get_GSOD()` function now checks to see if the file exists on the server, if it does not, a message is returned and all other stations that have files are processed and returned in output  
- Documentation has been improved throughout package  
- Better testing of internal functions  
  
## Bug Fixes

- Fixed: Remove redundant code in `get_GSOD()` function  
- Fixed: The stations data frame distributed with the package now include
  stations that are located above 60 latitude and below -60 latitude  
  
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
