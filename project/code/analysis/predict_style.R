#!/usr/bin/Rscript

load("style_random_forest")
load("principle_components")
load("labels")
library(randomForest)

load("all_words")

text <- commandArgs()[6]

text <- gsub("\\.", " ", text)
text <- gsub("[[:punct:]]", "", text)
text <- tolower(text)
text <- strsplit(text, split = "\\s+")
text <- Reduce(c, text, c())
text <- text[text != ""]

counts <- rle(sort(text)) # generates word counts
counts <- data.frame(word = counts$value, count = counts$lengths)
#counts <- counts[!is.element(counts$word, common.words),] # filters out common words

sorted.indices <- order(counts$count, decreasing = TRUE)
counts <- counts[sorted.indices,] # put in decreasing order
#counts$percent <- counts$count / sum(counts$count)


shared.words <- intersect(words, counts$word)
columns <- which(is.element(words, shared.words))
shared.counts <- counts[is.element(counts$word, shared.words),"count"]

counts.matrix <- matrix(0, nrow = 1, ncol = length(words))
counts.matrix[1, columns] <- shared.counts
counts.matrix[1,] <- counts.matrix[1,] / sum(counts.matrix[1,])

pcs.df <- as.data.frame(counts.matrix %*% decomp$v)
pred <- predict(rf, pcs.df, type = "prob")
top <- pred[,order(pred, decreasing = TRUE)][1:10]
top <- data.frame(name = names(top), probs = top)
rownames(top) <- NULL
print(top)
