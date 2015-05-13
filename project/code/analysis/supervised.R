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
    rf <- randomForest(D[subset,], factor(labels[subset]), scale = F)
    print(mean(predict(rf, D[subset,]) == labels[subset]))
    print(mean(predict(rf, D[-subset,]) == labels[-subset]))
    return(rf)
}


top100 <- as.matrix(counts.by.beer[,order(colSums(counts.by.beer), decreasing = TRUE) <= 500])
ind <- (rowSums(top100) > 0)
top100 <- top100[ind,]
style.labels <- style.labels[ind]
#style.labels <- as.factor(style.labels)
top100 <- t(apply(top100, MARGIN = 1, function(x) x / sum(x)))
train.indices <- sample(1:nrow(top100), 3000)
#old training sample size was 3500
rf.top100 <- train.rf(top100, train.indices, style.labels)

model.func <- function(data,  b, m) {
  mod = randomForest(data[train.indices,], factor(style.labels[train.indices]), 
                      ntree = b, mtry =m, scale = F)
  print(mean(predict(mod, data[-train.indices,]) == style.labels[-train.indices]))
  return(mod)
}

#Do the same model selection for random forests.
#Select for the best number of trees, holding m = sqrt(p), so 22
best.b <- function(data){
  b.choice <- c(100,200,300,400,500,600,700)
  output <- rep(0,7)
  for (i in 1:7){

    output[i] <- model.func(top100, b.choice[1],22)
  }
  return(b.choice[which.max(output)])
}
best.b(top100)
#[1] 0.199446
#[1] 0.1972299
#[1] 0.1916898
#[1] 0.1944598
#[1] 0.2033241
#[1] 0.200554
#[1] 0.1927978
#looks like the default 500 is the best

#Select for m. Candidates are sqrt(p)-2, sqrt(p)-1, sqrt(p), sqrt(p)+1, sqrt(p)+2.
#WARNING: This takes very, very long to run
best.m <- function(data){
  m.choice <- c(18,20,21,22,23,25,27)
  output <- rep(0,7)
  for (i in 1:7){
  output[i] <- model.func(top100, 500,m.choice[i])
  }
  return(m.choice[which.max(output)])
  }
best.m(top100)
#[1] 0.233241
#[1] 0.2243767
#[1] 0.2299169
#[1] 0.2371191
#[1] 0.2470914
#[1] 0.2360111
#[1] 0.234903
#Welp, this gives us 23, rather than 22 as the more optimal parameter