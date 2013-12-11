library(shiny)

shinyUI(pageWithSidebar(
	headerPanel("R Big Pivot"),
	sidebarPanel(
		fileInput("file1", "TSV:"),
		textInput("row", "Row (Y)", "time"),
		textInput("col", "Col (X)", "tra_meas"),
		textInput("val", "Val", "value"),
		selectInput("fun", "Fun", list("mean"="mean","sum"="sum","count"="length")),
		submitButton("do it!")
	),
	
	mainPanel(
		tabsetPanel(
			tabPanel("plot", plotOutput("plot")),
			tabPanel("table", dataTableOutput("table")),
			tabPanel("structure", verbatimTextOutput("structure"))
		)
	)
))