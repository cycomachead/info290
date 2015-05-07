#carries over code from topic_modeling.R specifically the topics.df data frame
library('topicmodels')
library('tm')
library('SnowballC')

load("topics_df")

topics.df.full <- topics.df

topics.df <- topics.df[sample(1:nrow(topics.df))[1:5000],]

corpus.l <- Corpus(VectorSource(topics.df$text))

dtm.l <- DocumentTermMatrix(corpus.l,control = list(stemming = TRUE, 
                                                        stopwords = TRUE, minWordLength = 3,removeNumbers = TRUE, removePunctuation = TRUE))


highestfreq <- findFreqTerms(dtm.l, lowfreq=500)
highestfreq
# [1] "bubbl"   "chang"   "compar"  "consist" "domin"   "enjoy"   "flavor"  "import" 
#[9] "live"    "notic"   "offer"   "pack"    "rate"    "refresh" "review"  "surpris"
#[17] "tast"  
# which words are associated with "hop"?
findAssocs(dtm.l, 'hop', 0.1)
#         hop
#balanc  0.99
#bottl   0.98
#serv    0.98
#seem    0.97
#surpris 0.97
#enjoy   0.95
#Are all associated with the word 'hop' in 0.9 of the document
