r-big-pivot
===========

Pivoting and charting big tabular data sets in a web UI based on R and Shiny.

Given that this works but lacks ease of use and necessary features, I consider this project so far rather a proof of concept to show that an interactive data explorer can be comparatively easily realized with R.

Further details on the project you may [find on my web-site](http://www.joyofdata.de/blog/pivoting-data-r-excel-style/).


##set up data to play with

1. Download `hlth_cd_acdr.sdmx.zip` from  [EUROSTAT](http://epp.eurostat.ec.europa.eu/NavTree_prod/everybody/BulkDownloadListing?dir=data&filter=SDMX&sort=1&sort=2&start=h).
2. Convert containing SDMX/DSD to CSV using most recent version of [SDMX Converter](https://webgate.ec.europa.eu/fpfis/mwikis/sdmx/index.php/SDMX_Converter) with settings:
  * Input File: ...\hlth_cd_acdr.sdmx.xml
  * Output File: ...\hlth_cd_acdr.csv
  * DSD File: ...\hlth_cd_acdr.dsd.xml
  * Input Format: COMPACT_SDMX
  * Output Format: CSV
3. The resulting CSV is lacking a header and needs further processing:

    ```
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

##launch r-big-pivot:
Place server.r and ui.r in a folder named "r-big-pivot".

```
library(shiny)
runApp("path/r-big-pivot")
```

##load the data file and run some commands:
1. "upload" the TSV file (and wait until values for it are displayed)
2. adjust w1,w2 and h
3. t1:

  ```
  sql(
    select T, age, geo, sex, V 
    from o 
    where sex in ("M","F") 
      and age in ("Y_GE65","Y_LT65") 
      and geo in ("DE","FR") 
      # viral hepatitis
      and icd10 = "B15-B19_B942"
  );
  ```
4. t2:
```
sql(select T, (geo || "_" || sex || "_" || age) as x, V as V from t1);
```
5. t3:
```
wide([T],[x],V,t2,sum);
```
6. plot:
```
line(t2,T,V,x);
# also implemented are point(...) for scatter plots and box(...) for box plots
```

(Shiny checks if the content of a text box changed in short intervals. Only if command is ended with a semicolon, the command is parsed and executed.)

![the chart we just plotted](https://raw.github.com/joyofdata/r-big-pivot/master/pics/sample-chart.gif)

(In case you are curious about the sudden rise of death due to viral hepatitis, have a look [here](http://www.joyofdata.de/blog/increase-of-deaths-due-to-viral-hepatitis-in-the-year-1998-in-germany/))
