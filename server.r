library(shiny)
library(reshape2)
library(ggplot2)
library(sqldf)

options(shiny.maxRequestSize=1024^4)

shinyServer(function(input, output) {

	o <- NULL
	t1 <- NULL
	t1 <- NULL
	
	wide <- function(row,col,val,table,fun) {
		if(is.null(table))
				return(NULL)
			
		formula <- paste(
			gsub(",","+",row),
			"~",
			gsub(",","+",col),
			sep=""
		)
		
		cat(formula)
		
		dcast(table,
			formula,
			value.var=val,
			fun.aggregate=fun,
			na.rm=TRUE,
			drop=FALSE
		)
	}
	
	sql <- function(query) {
		while(TRUE) {
			d <- (str_match(query,"'[0-9]{4}-[0-9]{2}-[0-9]{2}'"))[1,1]
			if(is.na(d)) break
			query <- str_replace(query,d,as.numeric(as.Date(str_sub(d,2,-2))))
		}
	
		sqldf(query)
	}
	
	line <- function(table,X,Y,col=NULL) {
		ggplot(data=table,aes_string(x=X,y=Y,color=col)) + geom_line()
	}
	
	point <- function(table,x,y,col=NULL) {
		ggplot(data=table,aes_string(x=x,y=y,color=col)) + geom_point()
	}
	
	box <- function(table,cat,val) {
		ggplot(data=table,aes_string(y=val,x=cat,fill=cat)) + geom_boxplot()
	}

	fo <- reactive({
		inFile <- input$file1
		if (is.null(inFile))
			return(NULL)
			
		cat("reads csv\n")
		df <- read.csv(inFile$datapath, header=TRUE, sep="\t", stringsAsFactors=FALSE)
		if("T" %in% names(df)) {
			df$T <- as.Date(df$T)
		}
		#if("V" %in% names(df)) {
		#	df$V <- as.numeric(df$V)
		#}
		o <<- df
		df
	})
	
	ft1 <- reactive({
		t1 <<- eval(parse(text=input$table_t1))
	})
	
	ft2 <- reactive({
		t2 <<- eval(parse(text=input$table_t2))
	})
		
	df_agg_long <- reactive({
		if(is.null(df_agg_wide()))
			return(NULL)
			
		melt(df_agg_wide(),id.vars=input$row,variable.name=input$col,value.name="value")
	})
	
	output$plot <- renderPlot({
		if(is.null(fo()))
			return(NULL)
	
		gg <- eval(parse(text=input$plot))
		
		print(gg)
	}, height=1000)
	
	output$table_original <- renderDataTable({
		fo()
	})
	
	output$table_t1 <- renderDataTable({
		if(is.null(ft1()))
			return(NULL)
			
		ft1()
	})
	
	output$table_t2 <- renderDataTable({
		if(is.null(ft2()))
			return(NULL)
			
		ft2()
	})
	
	output$structure <- renderPrint({
		if(is.null(fo()))
			return(NULL)
		
		df <- fo()
		str(df)
		
		if(!is.null(ft1()))
			str(ft1())
		
		lapply(df[,-which(names(df)=="V")],unique)
	})
})