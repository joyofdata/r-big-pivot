library(shiny)
library(reshape2)
library(ggplot2)

shinyServer(function(input, output) {
	df <- reactive({
		inFile <- input$file1
		if (is.null(inFile))
			return(NULL)
			
		cat("reads csv\n")
		read.csv(inFile$datapath, header=TRUE, sep="\t")
	})
	
	d <- reactive({
		cat("casts\n")
	
		formula <- paste(
			gsub(",","+",input$row),
			"~",
			gsub(",","+",input$col),
			sep=""
		)
		
		dcast(df(),
			formula,
			value.var=input$val,
			fun.aggregate=get(input$fun)
		)
	})
	
	output$plot <- renderPlot({
		if(nrow(d()) == 0) return
	
		df0 <- d()
		#plot(d[,1],d[,2])
	
		n <- names(df0)
		gg <- ggplot(data=df0)
		for(j in 2:ncol(df0)){
			
			gg <- gg + geom_line(aes_string(x=n[1],y=n[j]))
		}
		
		print(gg)
	})
	
	output$table <- renderDataTable({
		d()
	})
	
	output$structure <- renderPrint({
		cat("prints structure\n")
		str(df())
	})
})