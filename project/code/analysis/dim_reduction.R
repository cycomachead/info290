
library(irlba)
library(e1071)
library(randomForest)
library(parallel)
library(fpc)
load("counts_matrix")
load("labels")

# clean up rows I accidentally added
counts.by.beer <- counts.by.beer[name.labels != 0,]
name.labels <- name.labels[name.labels != 0]
style.labels <- style.labels[style.labels != 0]

normalize <- function(x) {
    s <- sum(x)
    return(if (s > 0) x / s else x)
}

normalize.rows <- function() {
    C <- makeCluster(detectCores()-1)
    for (i in seq(1, nrow(counts.by.beer)-100, by = 100)) {
        if (i %% 10 == 1) {
            print(i)
        }
        ## if (any(counts.by.beer[i,] != 0)) {
        ##     counts.by.beer[i,] <- counts.by.beer[i,] / sum(counts.by.beer[i,])
        ## }
        m.temp <- as.matrix(counts.by.beer[i:(i+99),])
        m.scaled <- matrix(parRapply(C, m.temp, normalize), nrow = 100, byrow = TRUE)
        counts.by.beer[i:(i+99),] <- m.scaled
    }

    stopCluster(C)

                                        # tail loop
    for (i in (i+1):nrow(counts.by.beer)) {
        if (any(counts.by.beer[i,] != 0)) {
            counts.by.beer[i,] <- counts.by.beer[i,] / sum(counts.by.beer[i,])
        }
    }
}

normalize.rows()
gc()
save(counts.by.beer, file = "counts_matrix_normalized_rows")

normalize.cols <- function() {
    C <- makeCluster(detectCores()-1)
    for (i in seq(1, ncol(counts.by.beer)-500, by = 500)) {
        if (i %% 10 == 1) {
            print(i)
        }
        ## if (any(counts.by.beer[i,] != 0)) {
        ##     counts.by.beer[i,] <- counts.by.beer[i,] / sum(counts.by.beer[i,])
        ## }
        m.temp <- as.matrix(counts.by.beer[,i:(i+499)])
        m.scaled <- matrix(parCapply(C, m.temp, normalize), ncol = 500, byrow = FALSE)
        counts.by.beer[,i:(i+499)] <- m.scaled
    }

    stopCluster(C)

    # tail loop
    for (i in (i+1):ncol(counts.by.beer)) {
        if (any(counts.by.beer[,i] != 0)) {
            counts.by.beer[,i] <- counts.by.beer[,i] / sum(counts.by.beer[,i])
        }
    }
}

normalize.cols()
gc()
save(counts.by.beer, file = "counts_matrix_normalized_rows_cols")

load("counts_matrix_normalized_rows_cols")

decomp <- irlba(counts.by.beer, nu = 0, nv = 50)

pcs <- counts.by.beer %*% decomp$v

pcs.df <- as.data.frame(as.matrix(pcs))

#svm.50 <- svm(pcs.df, style.labels, scale = F)

## rf <- randomForest(pcs.df, as.factor(style.labels), scale = F)

## mean(predict(rf, pcs.df) == as.factor(style.labels))

## # clustering

clust <- kmeans(pcs.df, centers = 104, iter.max = 30)

clust.stats <- cluster.stats(clustering = clust$cluster, alt.clustering = as.integer(as.factor(style.labels)), compareonly = TRUE)
