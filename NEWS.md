
GSODR v0.1.5 (Release date: 2016-05-16)
==============

Changes
  * Set values where MIN > MAX to NA
  * Set more MIN/MAX/DEWP values to NA. GSOD README indicates that 999 indicates missing values in these columns, this does not appear to always be true. There are instances where 99 is the value recorded for missing data. While 99F is possible, the vast majority of these recorded values are missing data, thus the function now converts them to NA
  * Fixed bug where YDAY not correctly calculated and reported in CSV file
  * CSV files for station only queries now are names with the Station Identifier. Previously named same as Global data
  * Likesise, CSV files for agroclimatology now are names with the Station Identifier. Previously named same as Global data

GSODR v0.1.4 (Release date: 2016-05-09)
==============

Changes
  * Fixed bug related to MIN/MAX columns when agroclimatology or all stations are selected where flags were not removed properly from numeric values.
  * Add more detail to DESCRIPTION regarding flags found in original GSOD data.

GSODR v0.1.3 (Release date: 2016-05-06)
==============
Changes
  * Set NA to -9999.99
  * Bug fix in MIN/MAX with flags. Some columns have differing widths, which caused a flag to be left attached to some values
  * Correct URL in README.md for CRAN to point to CRAN not GitHub
  
GSODR v0.1.2 (Release date: 2016-05-05)
==============
  Changes:
  * Bug fix in importing isd-history.csv file. Previous issues caused all lat/lon/elev values to be >0.
  * Bug fix where WDSP was mistyped as WDPS causing the creation of a new column, rather than the conversion of the existing
  * Bug fix if Agroclimatology selected. Previously this resulted in no records.
  * Set the default encoding to UTF8.
  * Bug fix for country selection. Some countries did not return proper ISO code.
  * Use write.csv, not readr::write_csv due to issue converting double to string: https://github.com/hadley/readr/issues/387


GSODR v0.1.1 (Release date: 2016-04-21)
==============
  Changes:
  * Now available on CRAN
  
GSODR v0.1.1 (Release date: 2016-04-21)
==============

  Changes:
  * Add single quotes around possibly misspelled words and spell out comma-separated values and geographic information system rather than just using "CSV" or "GIS" in DESCRIPTION.
  * Add full name of GSOD (Global Surface Summary of the Day) and URL for GSOD, https://data.noaa.gov/dataset/global-surface-summary-of-the-day-gsod to DESCRIPTION as requested by CRAN.
  * Require user to specify directory for resulting .csv file output so that any files written to disk are interactive and with user's permission
  
GSODR v0.1 (Release date: 2016-04-18)
==============

  Changes:

  * Initial submission to cran
