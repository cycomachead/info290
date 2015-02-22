
library("nnet")

train <- read.csv("lab5_train.csv")
test <- read.csv("lab5_test.csv")

# fix the data types of some variables
train$ZIP_CODE <- as.factor(train$ZIP_CODE)
test$ZIP_CODE <- as.factor(test$ZIP_CODE)

train$CAND_ID <- as.integer(train$CAND_ID == "Romney")
test$CAND_ID <- as.integer(test$CAND_ID == "Romney")

################
## question 1 ##
################

maj.class <- round(mean(train$CAND_ID))
baseline.train.accuracy <- mean(train$CAND_ID == maj.class)
baseline.test.accuracy <- mean(test$CAND_ID == maj.class)

################
## question 2 ##
################

net = nnet(formula = CAND_ID~TRANSACTION_AMT, data = train, size = 10)
q2.train.accuracy <- mean((net$fitted.values > 0.5) == train$CAND_ID)
q2.test.accuracy <- mean((predict(net, test) > 0.5) == test$CAND_ID)

train.log <- train
test.log <- test
train.log$TRANSACTION_AMT <- log(train.log$TRANSACTION_AMT)
test.log$TRANSACTION_AMT <- log(test.log$TRANSACTION_AMT)
train.log <- train.log[is.finite(train.log$TRANSACTION_AMT),]
test.log <- test.log[is.finite(test.log$TRANSACTION_AMT),]

log.net = nnet(formula = CAND_ID~TRANSACTION_AMT, data = train.log, size = 10)
q2.log.train.accuracy <- mean((log.net$fitted.values > 0.5) == train.log$CAND_ID)
q2.log.test.accuracy <- mean((predict(log.net, test.log) > 0.5) == test.log$CAND_ID)

################
## question 3 ##
################

library("e1071")
svm.q3 <- svm(CAND_ID~TRANSACTION_AMT, data = train, kernel = "linear")
q3.train.accuracy <- mean((predict(svm.q3, newdata = train) > 0.5) == train$CAND_ID) # b
q3.test.accuracy <- mean((predict(svm.q3, newdata = test) > 0.5) == test$CAND_ID) # c

svm.q3.rbf <- svm(CAND_ID~TRANSACTION_AMT, data = train, kernel = "radial")
q3.rbf.train.accuracy <- mean((predict(svm.q3.rbf, newdata = train) > 0.5) == train$CAND_ID) # d
q3.rbf.test.accuracy <- mean((predict(svm.q3.rbf, newdata = test) > 0.5) == test$CAND_ID) # e

svm.q3.rbf.log <- svm(CAND_ID~TRANSACTION_AMT, data = train.log, kernel = "radial")
q3.rbf.train.log.accuracy <- mean((predict(svm.q3.rbf.log, newdata = train.log) > 0.5) == train.log$CAND_ID)
q3.rbf.test.log.accuracy <- mean((predict(svm.q3.rbf.log, newdata = test.log) > 0.5) == test.log$CAND_ID) # f

# g ???


################
## question 4 ##
################

remove.cols <- which(sapply(train, class) == "factor")
train <- cbind(train, model.matrix(~.+0, train))
train <- train[,-remove.cols]
test <- cbind(test, model.matrix(~.+0, test))
test <- test[,-remove.cols]

q4.net <- nnet(formula = CAND_ID~., data = train, size = 10, MaxNWts = 50000)
