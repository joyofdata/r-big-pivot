library(shiny)
library(reshape2)
library(ggplot2)

options(shiny.maxRequestSize=1024^4)

shinyServer(function(input, output) {
	df <- reactive({
		inFile <- input$file1
		if (is.null(inFile))
			return(NULL)
			
		cat("reads csv\n")
		df <- read.csv(inFile$datapath, header=TRUE, sep="\t", stringsAsFactors=FALSE)
		if("time" %in% names(df)) {
			df$time <- as.Date(df$time, origin="1970-01-01")
		}
		if("value" %in% names(df)) {
			df$value <- as.numeric(df$value)
		}
		df
	})
	
	d <- reactive({
		if(is.null(df())
			| input$row == ""
			| input$col == ""
			| input$val == "")
			return(NULL)
		
		formula <- paste(
			gsub(",","+",input$row),
			"~",
			gsub(",","+",input$col),
			sep=""
		)
		
		cat(formula)
		
		dcast(df(),
			formula,
			value.var=input$val,
			fun.aggregate=get(input$fun),
			na.rm=TRUE,
			drop=FALSE
		)
	})
	
	d2 <- reactive({
		if(is.null(d()))
			return(NULL)
			
		melt(d(),id.vars=input$row,variable.name=input$col,value.name="value")
	})
	
	output$plot <- renderPlot({
		if(is.null(d2()))
			return(NULL)
	
		df2 <- d2()
	
		n <- names(df2)
		gg <- ggplot(data=df2,aes_string(x=n[1],y=n[3],color=n[2])) + geom_line()
		
		print(gg)
	})
	
	output$table <- renderDataTable({
		d()
	})
	
	output$structure <- renderPrint({
		if(is.null(df()))
			return(NULL)
		
		df <- df()
		
		str(df)
		lapply(df[,-which(names(df)=="value")],unique)
	})
})