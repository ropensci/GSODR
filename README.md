#GSODR
An R package that provides a function that automates downloading and cleaning data from the Global Summary of the Day (GSOD) data provided by the US National Climatic Data Center (NCDC). Stations are individually checked for number of missing days to assure data quality, stations with too many missing observations are omitted. All units are converted to metric, e.g. feet to metres and Fahrenheit to Celcius. Output is saved as a .csv file summarizing each year by station, which includes vapor pressure and relative humidity variables calculated from existing data in GSOD.

Be sure to have disk space free and allocate the proper time for this to run. This is a time, processor and disk space intensive process.

For more information see the description of the data provided by NCDC, http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt.

##To install this package
Install the devtools package, available from CRAN.

`install.packages("devtools")`

Load the devtools package.

`library(devtools)`

Use `install_github("author/package")` to install this package.

`install_github("adamhsparks/GSODR")`

##Using get_GSOD() from GSODR
See `?get_GSOD()` for the help file.

Example from help file, to download data for years 2009 and 2010 and generate yearly summary files, GSOD_TP2009_XY and GSOD_TP2010_XY files in folders 2009 and 2010 of your default working directory with a maximum of five missing days per weather station allowed.

`get_GSOD(start_year = 2009, end_year = 2010, max_missing = 5)`

