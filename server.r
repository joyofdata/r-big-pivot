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
	
	df_agg_wide <- reactive({
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
		
	df_agg_long <- reactive({
		if(is.null(df_agg_wide()))
			return(NULL)
			
		melt(df_agg_wide(),id.vars=input$row,variable.name=input$col,value.name="value")
	})
	
	output$line_plot <- renderPlot({
		if(is.null(df_agg_long()))
			return(NULL)
	
		df2 <- df_agg_long()
	
		n <- names(df2)
		gg <- ggplot(data=df2,aes_string(x=n[1],y=n[3],color=n[2])) + geom_line()
		
		print(gg)
	},height=1000)
	
	output$scatter_plot <- renderPlot({
		if(is.null(df()))
			return(NULL)
	
		df <- df()
	
		n <- names(df)
		gg <- ggplot(data=df,aes_string(x=input$x,y=input$y,color=input$category)) + geom_point()
		
		print(gg)
	})
	
	output$boxplot_plot <- renderPlot({
		if(is.null(df_agg_long()))
			return(NULL)
			
		df <- df()
	
		n <- names(df)
		gg <- ggplot(data=df,aes_string(y=input$boxplot.value,x=input$boxplot.category,fill=input$boxplot.category)) + geom_boxplot()
		
		print(gg)
	})
	
	output$table <- renderDataTable({
		df_agg_wide()
	})
	
	output$structure <- renderPrint({
		if(is.null(df()))
			return(NULL)
		
		df <- df()
		
		str(df)
		lapply(df[,-which(names(df)=="value")],unique)
	})
})