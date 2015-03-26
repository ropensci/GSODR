An R package to deliver a function that automates downloading and cleaning data from the Global Summary of the Day (GSOD) data provided by the US National Climatic
Data Center (NCDC). Stations are individually checked for number of missing days to assure data quality, stations with too many missing observations are
omitted. All units are converted to metric, e.g. feet to metres and Fahrenheit to Celcius. Output is saved as a .csv file summarizing each year by
station, which includes vapor pressure and relative humidity variables calculated from existing data in GSOD.

Be sure to have disk space free and allocate the proper time for this to run. This is a time, processor and disk space intensive process.

For more information see the description of the data provided by NCDC, http://www7.ncdc.noaa.gov/CDO/GSOD_DESC.txt
