
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

train.indices <- sample(1:nrow(pcs.df), 4000)

style.labels <- as.factor(style.labels)

#svm.50 <- svm(pcs.df, as.numeric(style.labels), scale = F)

rf <- randomForest(pcs.df[train.indices,], style.labels[train.indices], scale = F) # subset = train.indices)

mean(predict(rf, pcs.df[train.indices,]) == style.labels[train.indices])

mean(predict(rf, pcs.df[-train.indices,]) == style.labels[-train.indices])

blah <- data.frame(style.labels[-train.indices][p != style.labels[-train.indices]], p[p!= style.labels[-train.indices]])

names(blah) <- c("true", "predicted")

p.prob <- predict(rf, pcs.df[-train.indices,], type = "prob")
preds <- t(apply(X = p.prob, MARGIN = 1, FUN = function(x) names(sort(x))[95:104]))

mean(sapply(1:length(p), function(i) is.element(as.character(style.labels[-train.indices][i]), as.character(preds[i,]))))

save(rf, file = "style_random_forest")
save(decomp, file = "principle_components")


## rf2 <- randomForest(pcs.df[train.indices,], as.factor(name.labels)[train.indices], scale = F)
## mean(predict(rf2, pcs.df[train.indices,]) == as.factor(name.labels)[train.indices])
## mean(predict(rf2, pcs.df[-train.indices,]) == as.factor(name.labels)[-train.indices])

## ## # clustering

## clust <- kmeans(pcs.df, centers = 104, iter.max = 30)

## clust.stats <- cluster.stats(clustering = clust$cluster, alt.clustering = as.integer(style.labels), compareonly = TRUE)
