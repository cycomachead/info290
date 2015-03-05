### Authors: Michael Ball, Alex Caravan, Alec Guertin, Peter Sujan

library("nnet")
library("e1071")


### utility functions from question 7

get.train.q7 <- function(rows, skip, old_train = NULL) {
  train <- read.csv("lab5_train.csv")
  if (rows > -1) {
    train <- train[(skip+1):(skip+rows),]
    # drop unused levels
    for (name in names(train)[sapply(train, class) == "factor"]) {
      train[,name] = factor(train[,name])
    }
  }
  train$CAND_ID <- as.integer(train$CAND_ID == "Romney")
  CAND_ID=train$CAND_ID
  train$TRANSACTION_DT <- sapply(as.character(train$TRANSACTION_DT), function(x) {ifelse(nchar(x) == 7, paste("0", x, sep=""), x)})
  train$TRANSACTION_DT <- as.POSIXct(train$TRANSACTION_DT, format='%m%d%Y')
  train$TRANSACTION_DT <- sapply(train$TRANSACTION_DT, function(x) {as.integer(x)})
  
  train.z <- train
  train.z[,c( "TRANSACTION_DT")] <- scale(train.z[,c("TRANSACTION_DT")])
  dt=train.z$TRANSACTION_DT
  
  train.log <- train
  #train.log$TRANSACTION_AMT <- log(train.log$TRANSACTION_AMT)
  #train.log$ZIP_CODE <- log(train.log$ZIP_CODE)
  train.log$TRANSACTION_AMT <- scale(train.log$TRANSACTION_AMT)
  train.log$ZIP_CODE <- scale(train.log$ZIP_CODE)
  zp <- train.log[,c("ZIP_CODE")]
  amt <- train.log[,c("TRANSACTION_AMT")]
  
  keep.cols <- c("CMTE_ID", "AMNDT_IND", "RPT_TP", "ENTITY_TP", "STATE", "CAND_ID") #, "ZIP_CODE", "TRANSACTION_DT")
  train <- train[, keep.cols]
  remove.cols <- which(sapply(train, class) == "factor")
  train <- cbind(train, model.matrix(CAND_ID~.+0, train))
  train <- train[,-remove.cols]
  
  
  amt <- as.matrix(amt)
  zp <- as.matrix(zp)
  CAND_ID <- as.matrix(CAND_ID)
  
  train <- cbind(train, dt,zp,amt, CAND_ID)
  train <- train[is.finite(train$zp),]
  train <- train[is.finite(train$amt),]
  
  missing.cols <- setdiff(names(old_train), names(train))
  train[,missing.cols]  <-  0
  
  return(train)
  
}

get.test.q7 <- function(rows, train) {
  test <- read.csv("lab5_test.csv", nrows = rows)
  test$CAND_ID <- as.integer(test$CAND_ID == "Romney")
  cd <- test$CAND_ID
  
  test.z <- test
  test.z[,c("TRANSACTION_DT")] <- scale(test.z[,c("TRANSACTION_DT")])
  dt_test <- test.z$TRANSACTION_DT
  
  test.log <- test
  test.log$TRANSACTION_AMT <- log(test.log$TRANSACTION_AMT)
  test.log$ZIP_CODE <- log(test.log$ZIP_CODE)
  zp_test <- test.log[,c("ZIP_CODE")]
  amt_test <- test.log[,c("TRANSACTION_AMT")]
  
  keep.cols <- c("CMTE_ID", "AMNDT_IND", "RPT_TP", "ENTITY_TP", "STATE", "CAND_ID") #, "ZIP_CODE", "TRANSACTION_DT")
  test <- test[, keep.cols]
  remove.cols <- which(sapply(test, class) == "factor")
  test <- cbind(test, model.matrix(~.+0, test))
  test <- test[,-remove.cols]
  
  
  missing.cols <- setdiff(names(train), names(test))
  test[,missing.cols]  <-  0
  
  zp_test <- as.matrix(zp_test)
  CAND_ID <- as.matrix(cd)
  amt_test <- as.matrix(amt_test)
  
  test <- cbind(test, dt_test,zp_test,amt_test, CAND_ID)
  test <- test[is.finite(test$zp_test),]
  test <- test[is.finite(test$amt_test),]
  
  return(test)
}

################
## question 8 ##
################

# a
train <- get.train.q7(2000, 0)
test <- get.test.q7(-1, train)

best.acc <- 0
best.C <- 0
best.mu <- 0
C <- 2^seq(-5, 15, by = 5)
mu <- 2^seq(-15, 5, by = 5)
for (i in 1:length(C)) {
  for (j in 1:length(mu)) {
    svm.q8.rbf <- svm(CAND_ID~., data = train, kernel = "radial", cost = C[i], gamma = mu[j])
    acc <- mean((predict(svm.q8.rbf, newdata = train) > 0.5) == train$CAND_ID) 
    if (acc > best.acc) {
      best.C <- C[i]
      best.mu <- mu[j]
      best.acc <- acc
    }
  }
}

best.acc # 0.803

train <- get.train.q7(-1, 0)
test <- get.test.q7(-1, train)
svm.q8.rbf <- svm(CAND_ID~., data = train, kernel = "radial", cost = best.C, gamma = best.mu)
q8.rbf.train.accuracy <- mean((predict(svm.q8.rbf, newdata = train) > 0.5) == train$CAND_ID) 
# 0.723875
q8.rbf.test.accuracy <- mean((predict(svm.q8.rbf, newdata = test) > 0.5) == test$CAND_ID) 
# 0.5646704
best.mu # 32
best.C # 2^15

# b
train <- get.train.q7(1400, 0)
holdout <- get.train.q7(600, 1400, train)
test <- get.test.q7(-1, train)

best.acc <- 0
best.C <- 0
best.mu <- 0
C <- 2^seq(-5, 15, by = 5)
mu <- 2^seq(-15, 5, by = 5)
for (i in 1:length(C)) {
  for (j in 1:length(mu)) {
    svm.q8.rbf <- svm(CAND_ID~., data = train, kernel = "radial", cost = C[i], gamma = mu[j])
    acc <- mean((predict(svm.q8.rbf, newdata = holdout) > 0.5) == holdout$CAND_ID) 
    if (acc > best.acc) {
      best.C <- C[i]
      best.mu <- mu[j]
      best.acc <- acc
    }
  }
}

best.acc # 0.625

train <- get.train.q7(-1, 0)
test <- get.test.q7(-1, train)
svm.q8.rbf <- svm(CAND_ID~., data = train, kernel = "radial", cost = best.C, gamma = best.mu)
q8.rbf.train.accuracy <- mean((predict(svm.q8.rbf, newdata = train) > 0.5) == train$CAND_ID) 
# 0.683125
q8.rbf.test.accuracy <- mean((predict(svm.q8.rbf, newdata = test) > 0.5) == test$CAND_ID) 
# 0.580775
best.mu # 1
best.C # 32

# c
cv.svm.r <- function(data,g,l){
  #Get the number of observations
  n <- nrow(data)
  #Define 10-fold CV error
  error <- rep(0,n)
  #Define random indices.
  random.ind <- sample(n)
  #Define the predicted values.
  yhat <- rep(0,n) 
  for (i in 1:5){
    #Divide the entire data set as training and test by indices
    ind <- random.ind[(i*n/5-n/5+1):(i*n/5)]
    #Get SVM model
    mod.svm=svm(CAND_ID~., data=data[-ind,], kernel ="radial",gamma=g, cost=l,scale=F)
    #Predict
    yhat[ind] <- predict(mod.svm,data[ind,])
    print(i)
  }
  #yhat <- as.numeric(yhat)-1
  #Compute the test error.
  #error[which((data$CAND_ID == yhat)==F)] <- 1
  error[which((data$CAND_ID - yhat) > .5)] <- 1
  #Print the table
  print(table(predict=yhat , truth = data$CAND_ID))
  #Return the prediction accuracy.
  return(1-sum(error)/n)
}

train <- get.train.q7(2000, 0)
test <- get.test.q7(-1, train)

best.acc <- 0
best.C <- 0
best.mu <- 0
C <- 2^seq(-5, 5, by = 5)
mu <- 2^seq(-15, 5, by = 5)
# C <- 2^seq(-1, 1, by = 1)
# mu <- 2^seq(-7, -1, by = 1)
accuracies <- matrix(nrow = length(C), ncol = length(mu))
for (i in 1:length(C)) {
  for (j in 1:length(mu)) {
    print(paste("current mu:", mu[j]))
    print(paste("current C:", C[i]))
    acc <- cv.svm.r(train, mu[j], C[i])
    accuracies[i, j] <- acc
    if (acc > best.acc) {
      best.C <- C[i]
      best.mu <- mu[j]
      best.acc <- acc
    }
    print(paste("acc:", acc))
    print("ITERATION COMPLETE")
  }
}

best.acc # 0.7545

train <- get.train.q7(-1, 0)
test <- get.test.q7(-1, train)
svm.q8.rbf <- svm(CAND_ID~., data = train, kernel = "radial", cost = best.C, gamma = best.mu)
q8.rbf.train.accuracy <- mean((predict(svm.q8.rbf, newdata = train) > 0.5) == train$CAND_ID) 
# 0.683125
q8.rbf.test.accuracy <- mean((predict(svm.q8.rbf, newdata = test) > 0.5) == test$CAND_ID)
# 0.580775
best.mu # 1
best.C # 32
