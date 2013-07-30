shinyUI(pageWithSidebar(
	headerPanel("Book Sentiment Visualizer"),
	sidebarPanel(
		fileInput('file1', 'Choose Book File (*.txt)',
				  accept=c('text/plain')),
		tags$br(),
		tags$br(),
		
		helpText("This app will parse the test file as-is. ",
				 "For an accurate representation, please ensure that",
				 "there are no indices, appendices, copyright notices, etc.",
				 "in the text file."),
		
		tags$br(),
		
		helpText("Depending on the size of the book it might take anywhere between ",
				 "a millisecond to a handful of seconds to create the plot"),
		
		
		tags$hr(),
		
		
		sliderInput("nparts", "Number of parts to divide the text into:", 
					min = 1, max = 1000, value = 100, step= 1),
		
		helpText("Setting a value lower than the total words in the book ",
				 "might lead to unexpected/erroneous results"),
		
		tags$hr(),
		
		checkboxInput('showPoints', 'Show Points', FALSE),
		checkboxInput('movavg', 'Use Moving Averages', FALSE)
		
		
	),
	mainPanel(
		plotOutput('sentimentplot'),
		plotOutput('sentimentheatmap')
		
	)
	
	
))


