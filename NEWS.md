# GSODR v1.0.0

## Major changes

- `get_GSOD` returns a data.frame object in the current R session with the option to save data to local disk  
- Multiple stations can be specified for download rather than just downloading a single station or all stations  
- A new function, `nearest_stations` is now included to find stations within a user specified radius (in kilometres) of a point given as latitude and longitude in decimal degrees  
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
- The `get_GSOD` function will retrieve the latest station data from NCDC and automatically merge it with the CGIAR-CSI SRTM elevation values provided by this package. Previously, the package provided it's own list of station information, which was difficult to keep up-to-date  
- A new `reformat_GSOD` function reformats station files in "WMO-WBAN-YYYY.op.gz" format that have been downloaded from the United States  
  National Climatic Data Center's (NCDC) FTP server.  
- A internal new function, `get_station_list`, fetches the latest station list from the FTP server.  
- New data layers are provided through a separate package, GSOD.data (https://github.com/adamhsparks/GSODR.data), which provide climate data formatted for use with GSODR. CHELSA (climatic surfaces at 1 km resolution), http://chelsa-climate.org/, http://www.earthenv.org/cloud, http://maps.elie.ucl.ac.be/CCI/viewer/index.php and CRU CL2.0 (https://crudata.uea.ac.uk/%7Etimm/grid/CRU_CL_2_0.html)  
- Improved file handling for individual station downloads  
- Missing values are handled as `NA` not -9999  
