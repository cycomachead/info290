
library(irlba)
library(e1071)
library(randomForest)
load("counts_matrix")
load("labels")

# clean up rows I accidentally added
counts.by.beer <- counts.by.beer[name.labels != 0,]
name.labels <- name.labels[name.labels != 0]
style.labels <- style.labels[style.labels != 0]

for (i in 1:nrow(counts.by.beer)) {
    if (i %% 10 == 0) {
        print(i)
    }
    if (any(counts.by.beer[i,] != 0)) {
        counts.by.beer[i,] <- counts.by.beer[i,] / mean(counts.by.beer[i,])
    }
}

save(counts.by.beer, file = "counts_matrix_scaled")

## decomp <- irlba(counts.by.beer, nu = 0, nv = 50)

## pcs <- counts.by.beer %*% decomp$v

## #svm.50 <- svm(as.data.frame(as.matrix(pcs)), style.labels, scale = F)

## pcs.df <- as.data.frame(as.matrix(pcs))

## rf <- randomForest(pcs.df, as.factor(style.labels), scale = F)

## mean(predict(rf, pcs.df) == as.factor(style.labels))

## # clustering

## clust <- kmeans(pcs.df, centers = 104)
