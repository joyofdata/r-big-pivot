library(shiny)

narrowSidebar <- HTML('<style>.span4 {min-width: 300px; max-width: 300px; } textarea {font-family: Courier; font-size: 8pt}</style>')
widerMainPanel <- HTML('<style>.span8 {min-width: 1500px; max-width: 1500px; } .shiny-plot-output {min-height:1000px; max-height:1000px}</style>')
flexibleSizes <- HTML("w1:<input id='w1' value='280'> - w2:<input id='w2' value='1200'> - h:<input id='h' value='800'> - <input type='button' value='set' id='set'>
						<style>#w1,#w2,#h{width:30px}</style>
						<script>
							$('#set').click(function(){$('.span4').css({'min-width':$('#w1').val()+'px','max-width':$('#w1').val()+'px'})})
							$('#set').click(function(){$('.span8').css({'min-width':$('#w2').val()+'px','max-width':$('#w2').val()+'px'})})
							$('#set').click(function(){$('.shiny-plot-output').css({'min-height':$('#h').val()+'px','max-height':$('#h').val()+'px'})})
						</script>")
shinyUI(pageWithSidebar(
	headerPanel("R Big Pivot"),
	sidebarPanel(
	tags$head(narrowSidebar),
		flexibleSizes,
		fileInput("file1", "TSV:"),
		tabsetPanel(
			tabPanel("plot",
				HTML("<textarea name='plot' rows=10 cols=10></textarea>")
			),
			tabPanel("table",
				HTML("t1: <textarea name='table_t1' rows=5 cols=10></textarea>"),
				HTML("t2: <textarea name='table_t2' rows=5 cols=10></textarea>"),
				HTML("t3: <textarea name='table_t2' rows=5 cols=10></textarea>")
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