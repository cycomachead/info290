#!/usr/bin/Rscript

load("style_random_forest")
load("principle_components")
load("labels")
library(randomForest)

load("all_words")

text <- "This is a standard go-to beer for Sierra Nevada. I really like this brewery, but this variety isn't their best. I'll discuss each aspect of the beer below.

A: It pours a pretty clear deep golden yellow whose shade depends on the ambient lighting. I was in a relatively dim room so it might be a lighter shade than I perceived. Nice foamy head that results from a good pour, but make it a vigorous pour so that you can get the little head that it has to offer.

S: The smell is nice with a toasty cracker base and hints of piney hops and mango citrus.

T: The taste starts with the malty toasty flavor and then a mild hop character that gives way into the citrus mango. It leaves a coating on the tongue that begs for another sip. It is quite delicious when chilled down real good.

F: The mouthfeel is pretty standard. Smooth crisp with carbonation that is a mild level of effervescence. Fine lacing on the glass and the head lasts until the last sip.

O: Overall, I think this is a nice beer for any day of the year, but if you want a strong hoppy beer, then move on to their Torpedo Extra IPA. The Pale Ales are good, but should be reserved for those days when you want to switch it up."

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
