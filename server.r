library(shiny)
library(reshape2)
library(ggplot2)
library(sqldf)
library(stringr)

options(shiny.maxRequestSize=1024^4)

shinyServer(function(input, output) {

	o <- NULL
	t1 <- NULL
	t2 <- NULL
	t3 <- NULL
	
	wide <- function(row,col,val,table,fun) {
	
		if(is.null(get(table)))
				return(NULL)
			
		row <- str_replace_all(row,"\\[","")
		col <- str_replace_all(col,"\\[","")
		
		row <- str_replace_all(row,"\\]","")
		col <- str_replace_all(col,"\\]","")
		
		formula <- paste(
			gsub(" ","+",row),
			"~",
			gsub(" ","+",col),
			sep=""
		)
		
		cat(formula)
		
		dcast(get(table),
			formula,
			value.var=val,
			fun.aggregate=get(fun),
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
		ggplot(data=get(table),aes_string(x=X,y=Y,color=col)) + geom_line()
	}
	
	point <- function(table,x,y,col=NULL) {
		ggplot(data=get(table),aes_string(x=x,y=y,color=col)) + geom_point()
	}
	
	box <- function(table,cat,val) {
		ggplot(data=get(table),aes_string(y=val,x=cat,fill=cat)) + geom_boxplot()
	}
	
	paramsToStrings <- function(cmd) {
		cmd <- str_replace(cmd,";$","")
		
		if(str_sub(cmd,1,3) == "sql") {
			cmd <- str_replace(cmd,"sql\\(","sql('")
			cmd <- str_replace(cmd,"\\)$","')")
		} else if(str_sub(cmd,1,4) == "wide"
			|| str_sub(cmd,1,4) == "line"
			|| str_sub(cmd,1,5) == "point"
			|| str_sub(cmd,1,3) == "box"
			) {
			cmd <- str_replace(cmd,"\\(","('")
			cmd <- str_replace(cmd,"\\)","')")
			cmd <- str_replace_all(cmd,",","','")
		}
		cmd
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
		cmd <- input$table_t1
		if(str_sub(cmd,-1,-1) != ";")
			return(NULL)
			
		cmd <- paramsToStrings(cmd)
		t1 <<- eval(parse(text=cmd))
	})
	
	ft2 <- reactive({
		cmd <- input$table_t2
		if(str_sub(cmd,-1,-1) != ";")
			return(NULL)
		
		cmd <- paramsToStrings(cmd)
		t2 <<- eval(parse(text=cmd))
	})
	
	ft3 <- reactive({
		cmd <- input$table_t3
		if(str_sub(cmd,-1,-1) != ";")
			return(NULL)
		
		cmd <- paramsToStrings(cmd)
		t3 <<- eval(parse(text=cmd))
	})
		
	df_agg_long <- reactive({
		if(is.null(df_agg_wide()))
			return(NULL)
			
		melt(df_agg_wide(),id.vars=input$row,variable.name=input$col,value.name="value")
	})
	
	output$plot <- renderPlot({
		if(is.null(fo()))
			return(NULL)
			
		cmd <- input$plot
		if(str_sub(cmd,-1,-1) != ";")
			return(NULL)
		cmd <- paramsToStrings(cmd)
	
		gg <- eval(parse(text=cmd))
		
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
	
	output$table_t3 <- renderDataTable({
		if(is.null(ft3()))
			return(NULL)
			
		ft3()
	})

	
	output$str_o <- renderPrint({
		if(is.null(fo()))
			return(NULL)
		
		df <- fo()
		cat("original table (o):\n")
		str(df)
	})
	
	output$str_t1 <- renderPrint({
		if(is.null(ft1()))
			return(NULL)
		
		cat("t1:\n")
		str(ft1())
	})
	
	output$str_t2 <- renderPrint({
		if(is.null(ft2()))
			return(NULL)
		
		cat("t2:\n")
		str(ft2())
	})
	
	output$str_t3 <- renderPrint({
		if(is.null(ft3()))
			return(NULL)
		
		cat("t3:\n")
		str(ft3())
	})
	
	output$val_o <- renderPrint({
		if(is.null(fo()))
			return(NULL)
		cat("o:\n")
		df <- fo()
		lapply(df[,-which(names(df)=="V")],unique)
	})
	
	output$val_t1 <- renderPrint({
		if(is.null(ft1()))
			return(NULL)
		df<-ft1()
		cat("t1:\n")
		lapply(df[,-which(names(df)=="V")],unique)
	})
	
	output$val_t2 <- renderPrint({
		if(is.null(ft2()))
			return(NULL)
			
		df<-ft2()
		cat("t2:\n")
		lapply(df[,-which(names(df)=="V")],unique)
	})
	
	output$val_t3 <- renderPrint({
		if(is.null(ft3()))
			return(NULL)
			
		df<-ft3()
		cat("t3:\n")
		lapply(df[,-which(names(df)=="V")],unique)
	})
})