##all.files <- list.files("word_frequencies_by_beer", full.names = TRUE)
all.files <- list.files("../../data", full.names = TRUE)
all.beers.names.only <- sapply(strsplit(all.files, "/"), function(x) x[4])
input <- "word_frequencies_by_beer"
files.tm <- dir(path=input, pattern="*\\.txt")
chunk.size <- 1000 ## number of words per chunk
library('stringr')

TextChunks <- function(input,file.name, chunk.size=1000){
    words <- NULL
    ## load(file.path(input, file.name))
    ##current.words <- Reduce(function(agg, df) union(agg, df$word[df$count > 1]), word.freqs, NULL) ## count > 1 is a simple (though probably overly aggressive) way to remove weird words
    ##text.word <- union(words, current.words)
    text.word <- scan(paste(file.name, ".txt", sep = ""), what = "character")
    if (is.null(text.word)) {
        return(matrix())
    }
    x <- seq_along(text.word)
    chunks.split <- split(text.word, ceiling(x/chunk.size))
    ## deal with small chunks at the end
    if(length(chunks.split[[length(chunks.split)]]) <= chunk.size/2){
        if (length(chunks.split) == 1){
            return (chunks.split)
        }
        else {
            ##add to second to last split, the last split, so they're all above 1000
            chunks.split[[length(chunks.split)-1]] <- c(chunks.split[[length(chunks.split)-1]], 
                                                        chunks.split[[length(chunks.split)]])
            chunks.split[[length(chunks.split)]] <- NULL
        }
        
    }
    chunks.split <- lapply(chunks.split, paste, collapse=" ")
    chunks.bind <- do.call(rbind, chunks.split)
    return(chunks.bind)
}



topics <- NULL
for(i in 1:length(all.beers.names.only)){
    print(i)
    ##topic.chunk <- TextChunks(input, all.beers.names.only[i], chunk.size)
    topic.chunk <- TextChunks(input, paste("combined_text", all.beers.names.only[i], sep = "/"), chunk.size)
    textname <- gsub("\\..*","", all.beers.names.only[i])
    segments.m <- cbind(paste(textname, segment=1:nrow(topic.chunk), sep="_"), topic.chunk)
    topics[[textname]] <- segments.m
}

save(topics, file = "topics")
load("topics")

topics1 <- do.call(rbind, topics)

topics.df <- as.data.frame(topics1, stringsAsFactors=F)
colnames(topics.df) <- c("id", "text")

save(topics.df, file = "topics_df")

load("topics_df")

library('rJava')
.jinit(parameters = "-Xmx4g")
library('mallet')
mallet.instances <- mallet.import(topics.df$id, topics.df$text, file.path("common-english-words.txt"), FALSE, token.regexp="[\\p{L}']+")
#mallet.instances <- mallet.import(c("_1"), topics1[1:1], file.path("common-english-words.txt"), FALSE, token.regexp="[\\p{L}']+")

##topic modeling
topic.model <- MalletLDA(num.topics=104)
topic.model$loadDocuments(mallet.instances)
vocabulary <- topic.model$getVocabulary()


vocabulary[1:100]

tm_word.freqs <- mallet.word.freqs(topic.model)
## examine some of the word frequencies:
head(tm_word.freqs)

topic.model$setAlphaOptimization(40, 100)
topic.model$train(1600)

topic.words.m <- mallet.topic.words(topic.model, smoothed=TRUE, normalized=TRUE)

dim(topic.words.m)

colnames(topic.words.m) <- vocabulary

## examine a specific topic
topic.num <- 1 ## the topic id you wish to examine
num.top.words<-10 ## the number of top words in the topic you want to examine

mallet.top.words(topic.model, topic.words.m[topic.num,], num.top.words)

## Visualize topics as word clouds
library(wordcloud)
topic.num <- 1
num.top.words<-100
topic.top.words <- mallet.top.words(topic.model, topic.words.m[1,], 100)
wordcloud(topic.top.words$words, topic.top.words$weights, c(4,.8), rot.per=0, random.order=F)

pdf(file="new_wordclouds.pdf")
num.topics<-104
num.top.words<-25
for(i in 1:num.topics){
    topic.top.words <- mallet.top.words(topic.model, topic.words.m[i,], num.top.words)
    wordcloud(topic.top.words$words, topic.top.words$weights, c(4,.8), rot.per=0, random.order=F)
}
dev.off()
