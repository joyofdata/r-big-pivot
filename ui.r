library(shiny)

narrowSidebar <- HTML('<style>.span4 {min-width: 280px; max-width: 280px; } textarea {font-family: Courier; font-size: 8pt}</style>')
widerMainPanel <- HTML('<style>.span8 {min-width: 1200px; max-width: 1200px; } .shiny-plot-output {min-height:800px; max-height:800px}</style>')

shinyUI(pageWithSidebar(
	headerPanel("R Big Pivot"),
	sidebarPanel(
	tags$head(narrowSidebar),
		fileInput("file1", "TSV:"),
		tabsetPanel(
			tabPanel("plot",
				HTML("<textarea name='plot' rows=10 cols=10></textarea>")
			),
			tabPanel("table",
				HTML("t1: <textarea name='table_t1' rows=5 cols=10>sql(select T, tra_meas, sum(V) from o group by T, tra_meas)</textarea>"),
				HTML("t2: <textarea name='table_t2' rows=5 cols=10></textarea>")
			)
		)
	),
	mainPanel(
	tags$head(widerMainPanel),
		tabsetPanel(
			tabPanel("plot", plotOutput("plot")),
			tabPanel("table (o)", dataTableOutput("table_original")),
			tabPanel("table (t1)", dataTableOutput("table_t1")),
			tabPanel("table (t2)", dataTableOutput("table_t2")),
			tabPanel("table (t3)", dataTableOutput("table_t3")),
			tabPanel("structure", verbatimTextOutput("str_o"),verbatimTextOutput("str_t1"),verbatimTextOutput("str_t2"),verbatimTextOutput("str_t3")),
			tabPanel("values", verbatimTextOutput("val_o"),verbatimTextOutput("val_t1"),verbatimTextOutput("val_t2"),verbatimTextOutput("val_t3"))
		)
	)
))