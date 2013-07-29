
setwd('C:/etc/Projects/Data/_Ongoing/BookSentiment')
library(ggplot2)
library(reshape2)

sentiment.file <- "data/AFINN-111.txt"
book.label <- "misc/threemeninaboat"
book.file <- paste0("data/",book.label,".txt")


#Initialize sentiment dictionary
df.sentiments <- read.table(sentiment.file,header=F,sep="\t",quote="",col.names=c("term","score"))
df.sentiments$term <- gsub("[^[:alnum:]]", " ",df.sentiments$term)
#row.names(df.sentiments) <- df.sentiments$term

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

s <- ScoreText(book.file)


#########################
##Part 2: Visualization##

author <- 'dickens'
#book.label.list <- c('aliceinwonderland', 'threemeninaboat')
book.label.list <- c('achristmascarol','ataleoftwocities','bleakhouse','davidcopperfield','hardtimes','nicholasnickleby','olivertwist')

book.file.list <- paste0("data/", author, "/", book.label.list, ".txt")

scores <- lapply(book.file.list, ScoreText)
s1<-ScoreText("C:/Users/eeshanmalhotra/Desktop/2.txt")
RollUpScores <-function(scores, parts=100){
	batch.size <- round(length(scores)/parts,0)
	
	s <- sapply(seq(batch.size/2, length(scores) - batch.size/2, batch.size), function(x){
		low  <- x - (batch.size/2)
		high <- x + (batch.size/2)
		mean(scores[low:high])
	})
	s
}

percent.scores <- as.data.frame(sapply(scores,RollUpScores))
colnames(percent.scores)<-book.label.list
percent.scores$percent <- 1:nrow(percent.scores)

escores <- melt(percent.scores[,6:8],"percent",book.label.list[6:7],variable.name="book",value.name="sentiment")
g<- ggplot(escores, aes(x = percent, y = sentiment, color=factor(book)))

g + geom_point() + stat_smooth(method="loess") + geom_hline() + facet_grid(book ~.) + theme(legend.position="none")
g + stat_smooth(method="loess") + geom_hline() +  theme(legend.position="bottom")



g <- ggplot(escores, aes(x = percent, y = 0))
g1 <- g + geom_tile(aes(fill = sentiment)) +
	  	scale_fill_gradient2(low='red',mid="yellow", high='green') +
	  	theme(legend.position="none") + 
	  	xlab("Part") + ylab("") + 
	  	ggtitle("Sentiment Heatmap of the Book\n") +
		scale_x_continuous(expand = c(0,0)) +
		scale_y_continuous(expand = c(0,0))
g1
g1 + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) 




