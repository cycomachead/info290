library(irlba)
library(e1071)
library(randomForest)
library(parallel)
library(fpc)
load("counts_matrix")
load("labels")

counts.by.beer <- counts.by.beer[name.labels != 0,]
name.labels <- name.labels[name.labels != 0]
style.labels <- style.labels[style.labels != 0]
style.labels <- as.factor(style.labels)

train.rf <- function(D, subset, labels) {
    rf <- randomForest(D[subset,], labels[subset], scale = F)
    print(mean(predict(rf, D[subset,]) == labels[subset]))
    print(mean(predict(rf, D[-subset,]) == labels[-subset]))
    return(rf)
}


top100 <- as.matrix(counts.by.beer[,order(colSums(counts.by.beer), decreasing = TRUE) <= 500])
ind <- (rowSums(top100) > 0)
top100 <- top100[ind,]
style.labels <- style.labels[ind]
top100 <- t(apply(top100, MARGIN = 1, function(x) x / sum(x)))
train.indices <- sample(1:nrow(top100), 3500)
rf.top100 <- train.rf(top100, train.indices, style.labels)
