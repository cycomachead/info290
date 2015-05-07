library('topicmodels')
library('tm')
library('SnowballC')
data("AssociatedPress", package = "topicmodels")
ctm <- CTM(AssociatedPress[1:20,], k = 2)
AssociatedPress[1:20,]
class (topic.model)



load(file.path(input, all.beers.names.only[1]))
current.words.l8 <- Reduce(function(agg, df) union(agg, df$word[df$count > 1]), word.freqs, NULL) # count > 1 is a simple (though probably overly aggressive) way to remove weird words
write(words_everything, file="words_everything.txt")

textdoc_data=read.table("words_everything.txt")
termFreq(textdoc_data)
class(textdoc_data)

corpus <- Corpus(VectorSource(textdoc_data))

JSS_dtm <- DocumentTermMatrix(corpus,control = list(stemming = TRUE, 
                                                    stopwords = TRUE, minWordLength = 3,removeNumbers = TRUE, removePunctuation = TRUE))
dim (JSS_dtm)
class(JSS_dtm)
#[1] "DocumentTermMatrix"    "simple_triplet_matrix"

CTM = CTM(JSS_dtm, k = 30, control = list(seed = 2010,
                                          var = list(tol = 10^-4), em = list(tol = 10^-3)))

k <- 104
SEED <- 2010
jss_TM <- list(
  VEM = LDA(JSS_dtm, k = k, control = list(seed = SEED)),
  VEM_fixed = LDA(JSS_dtm, k = k, control = list(estimate.alpha = FALSE,
                                                 seed = SEED)),
  Gibbs = LDA(JSS_dtm, k = k, method = "Gibbs", control = list(
    seed = SEED, burnin = 1000, thin = 100, iter = 1000)),
  CTM = CTM(JSS_dtm, k = k, control = list(seed = SEED,
                                           var = list(tol = 10^-4), em = list(tol = 10^-3))))
sapply(jss_TM[1:2], slot, "alpha")
#        VEM   VEM_fixed 
#625.5746889   0.4807692 
#These are the alpha scores; the lower the alpha, the higher is the percentage of 
#documents which are assigned to one single topic with a high probability
sapply(jss_TM, function(x) mean(apply(posterior(x)$topics,
                                      1, function(z) - sum(z * log(z)))))
#VEM VEM_fixed     Gibbs       CTM 
#4.644391  4.644383  4.519253  4.644379 
#Higher values indicate topic distributions are spread out more evenly

Topic <- topics(jss_TM[["VEM"]], 1)
#estimated topic

#The five most frequent terms for each topic are obtained by
Terms <- terms(jss_TM[["VEM"]], 5)
Terms[, 1:5]
#Topic 1    Topic 2    Topic 3    Topic 4    Topic 5   
#[1,] "abv"      "overal"   "overal"   "this"     "overal"  
#[2,] "overal"   "abv"      "pour"     "abv"      "this"    
#[3,] "drinkabl" "drinkabl" "pack"     "pour"     "pour"    
#[4,] "pack"     "pack"     "bottl"    "drinkabl" "this"    
#[5,] "bottl"    "pour"     "drinkabl" "bottl"    "drinkabl"

