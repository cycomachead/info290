#carries over code from topic_modeling.R specifically the topics.df data frame
library('topicmodels')
library('tm')
library('SnowballC')

#load("topics_df")
#load("topics_lengths")
load("topics")

all.files <- list.files("../../data", full.names = TRUE)
all.beers.names.only <- sapply(strsplit(all.files, "/"), function(x) x[4])


#topics.df.full <- topics.df

#topics.df <- topics.df[sample(1:nrow(topics.df))[1:5000],]

freq.terms <- list()

start <- 1
i <- 90
while(i <= length(topics)) {
    if (i %% 10 == 0) {
        save(freq.terms, file = "freq_terms")
    }
    print(i)
    #current.length <- topic.lengths[i]
    #corpus.l <- Corpus(VectorSource(topics.df$text[start:(start+current.length)]))
    corpus.l <- Corpus(VectorSource(topics[[i]]))
    dtm.l <- DocumentTermMatrix(corpus.l,control = list(stemming = FALSE, 
                                             stopwords = TRUE, minWordLength = 3,removeNumbers = TRUE, removePunctuation = TRUE))
    

    highestfreq <- findFreqTerms(dtm.l, lowfreq=500)
    i <- i + 1
    #start <- start + current.length
    freq.terms[[all.beers.names.only[i]]] <- highestfreq
}


#highestfreq
# [1] "bubbl"   "chang"   "compar"  "consist" "domin"   "enjoy"   "flavor"  "import" 
#[9] "live"    "notic"   "offer"   "pack"    "rate"    "refresh" "review"  "surpris"
#[17] "tast"  
# which words are associated with "hop"?
#findAssocs(dtm.l, 'hop', 0.1)
#         hop
#balanc  0.99
#bottl   0.98
#serv    0.98
#seem    0.97
#surpris 0.97
#enjoy   0.95
#Are all associated with the word 'hop' in 0.9 of the document
