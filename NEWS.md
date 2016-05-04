GSODR v0.1.2 2016-05-04
==============
  Changes:
  * Bug fix in importing isd-history.csv file. Previous issues caused all lat/lon/elev values to be >0.
  * Bug fix where WDSP was mistyped as WDPS causing the creation of a new column, rather than the conversion of the existing
  * Bug fix if Agroclimatology selected. Previously this resulted in no records.
  * Set the default encoding to UTF8.
  * Bug fix for country selection. Some countries did not return proper ISO code.

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
