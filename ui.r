library(shiny)

narrowSidebar <- HTML('<style>.span4 {min-width: 280px; max-width: 280px; }</style>')
widerMainPanel <- HTML('<style>.span8 {min-width: 1200px; max-width: 1200px; } .shiny-plot-output {min-height:800px; max-height:800px}</style>')

shinyUI(pageWithSidebar(
	headerPanel("R Big Pivot"),
	sidebarPanel(
	tags$head(narrowSidebar),
		fileInput("file1", "TSV:"),
		tabsetPanel(
			tabPanel("lineplot",
				h4("line plot:"),
				textInput("row", "Row (X)", "time"),
				textInput("col", "Column (Category)", "tra_meas"),
				textInput("val", "Value (Y)", "value"),
				selectInput("fun", "Aggregation", list("mean"="mean","sum"="sum","count"="length")),
				HTML("<textarea name='filter.line.plot' rows=10 cols=10></textarea>")
			),
			tabPanel("scatterplot",
				h4("scatter plot:"),
				textInput("x","X"),
				textInput("y","Y"),
				textInput("category","Category")
			),
			tabPanel("boxplot",
				h4("box plot"),
				textInput("boxplot.category","Category"),
				textInput("boxplot.value","Value")
			)
		),
		submitButton("do it!")
	),
	mainPanel(
	tags$head(widerMainPanel),
		tabsetPanel(
			tabPanel("line plot", plotOutput("line_plot")),
			tabPanel("scatter plot", plotOutput("scatter_plot")),
			tabPanel("boxplot plot", plotOutput("boxplot_plot")),
			tabPanel("table", dataTableOutput("table")),
			tabPanel("structure", verbatimTextOutput("structure"))
		)
	)
))