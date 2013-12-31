r-big-pivot
===========

Pivoting and charting big tabular data sets in a browser UI based on R and Shiny.


#set up data to play with

1. Download `hlth_cd_acdr.sdmx.zip` from  [EUROSTAT](http://epp.eurostat.ec.europa.eu/NavTree_prod/everybody/BulkDownloadListing?dir=data&filter=SDMX&sort=1&sort=2&start=h).
2. Convert containing SDMX/DSD to CSV using most recent version of [SDMX Converter](https://webgate.ec.europa.eu/fpfis/mwikis/sdmx/index.php/SDMX_Converter) with settings:
  * Input File: ...\hlth_cd_acdr.sdmx.xml
  * Output File: ...\hlth_cd_acdr.csv
  * DSD File: ...\hlth_cd_acdr.dsd.xml
  * Input Format: COMPACT_SDMX
  * Output Format: CSV
3. The resulting CSV is lacking a header and needs further processing:

    ```R
    df <- read.table("path\\hlth_cd_acdr.csv", header=FALSE, sep=";")
    df <- df[,1:(ncol(df)-1)]
    names(df) <- c("freq","unit","sex","age","icd10","geo","T","V")
    df$T <- paste(as.character(df$T),"-01-01",sep="")
    dfx <- df[nchar(as.character(df$geo)) == 2, !(names(df) %in% c("unit","freq"))]
    write.table(dfx,"path\\hlth_cd_acdr.tsv",sep="\t",row.names=FALSE)
    ```

The resulting TSV should look like this:
```
"sex"	"age"	"icd10"	"geo"	"T"	"V"
"F"	"TOTAL"	"A-R_V-Y"	"AL"	"2000-01-01"	452.4
"F"	"TOTAL"	"A-R_V-Y"	"AL"	"2001-01-01"	417
"F"	"TOTAL"	"A-R_V-Y"	"AL"	"2002-01-01"	459.3
"F"	"TOTAL"	"A-R_V-Y"	"AL"	"2003-01-01"	509.7
```
