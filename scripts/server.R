shinyServer(function(input, output) {
	
	library(ggplot2)
	library(reshape2)
	
	sentiment.file <- "C:/etc/Projects/Data/_Ongoing/Book Sentiment/data/AFINN-111.txt"
		
	
	#Initialize sentiment dictionary
	df.sentiments <- read.table(sentiment.file,header=F,
								sep="\t",quote="",col.names=c("term","score"))
	
	df.sentiments$term <- gsub("[^[:alnum:]]", " ",df.sentiments$term)
	
	ScoreTerm <- function(term){
		df.sentiments[match(term,df.sentiments[,"term"]),"score"]
	}
	
	ScoreText <- function(book.file){
		text <- scan(book.file, character(0))
		text <- tolower(gsub("[^[:alnum:]]", " ",text))
		
		text <- do.call(c,strsplit(text," "))
		text <- text[text!=""]
		length(text)
		scores <- ScoreTerm(text)
		scores[is.na(scores)] <- 0
		scores
	}
	
	RollUpScores <-function(scores, parts=100){
		batch.size <- length(scores)/parts
		
		s <- sapply(seq(batch.size/2, length(scores) - batch.size/2, batch.size), function(x){
			low  <- x - (batch.size/2)
			high <- x + (batch.size/2)
			mean(scores[low:high])
		})
		s
	}
	
	MovingAverage <- function(x, n=5){
		filter(x,rep(1/n,n), sides=2)
	}
	
	
	output$sentimentplot <- renderPlot({
		
		inFile <- input$file1
		if (is.null(inFile))
			return(NULL)
		
		book.file <- inFile$datapath
		scores <- ScoreText(book.file)
		nparts=input$nparts
	
		if(input$movavg){
			scores=MovingAverage(scores,n=nparts/10)
		}
		
		percent.scores <- RollUpScores(scores,parts=nparts)
		df.percent.scores=data.frame(part=1:nparts,sentiment=percent.scores)
		
		g  <- ggplot(df.percent.scores, aes(x = part, y = sentiment))
		g2 <- g + geom_point() + stat_smooth(method="loess") + geom_hline() +
				xlab("Part") + ylab("Sentiment") +
				ggtitle("Sentiment Variation Through the Book\n") +
				scale_x_continuous(expand = c(0,0))
	
		g3 <- g + stat_smooth(method="loess") + geom_hline() +
				xlab("Part") + ylab("Sentiment") +
				ggtitle("Sentiment Variation Through the Book\n") +
				scale_x_continuous(expand = c(0,0))
		
		if(input$showPoints){
			print(g2)
		} else {
			print(g3)
		}
				
		
	})

	
	
	
	
	output$sentimentheatmap <- renderPlot({
		
		inFile <- input$file1
		if (is.null(inFile))
			return(NULL)
		book.file <- inFile$datapath
		
		scores <- ScoreText(book.file)
		nparts=input$nparts
		
		if(input$movavg){
			scores=MovingAverage(scores,n=nparts/10)
		}
		
		percent.scores <- RollUpScores(scores,parts=nparts)
		df.percent.scores=data.frame(part=1:nparts,sentiment=percent.scores)
		
		g <- ggplot(df.percent.scores, aes(x = part, y = 0))
		print(g + geom_tile(aes(fill = sentiment)) +
			  	scale_fill_gradient2(low='red',mid="yellow", high='green') +
			  	theme(legend.position="none") + 
			  	xlab("Part") + ylab("  ") + 
			  	ggtitle("Sentiment Heatmap of the Book\n") +
			  	scale_x_continuous(expand = c(0,0)) +
			  	scale_y_continuous(expand = c(0,0)) + 
				theme(axis.text.y = element_blank()), axis.ticks.y = element_blank())
		
		
		
	})
	
	
	
	
	
	
	
})