
library("nnet")

train <- read.csv("lab5_train.csv")
test <- read.csv("lab5_test.csv")

# fix the data types of some variables
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

keep.cols <- c("CMTE_ID", "AMNDT_IND", "RPT_TP", "ENTITY_TP", "STATE", "CAND_ID") #, "ZIP_CODE", "TRANSACTION_DT")
train <- train[, keep.cols]
test <- test[, keep.cols]
remove.cols <- which(sapply(train, class) == "factor")
train <- cbind(train, model.matrix(CAND_ID~.+0, train))
train <- train[,-remove.cols]
test <- cbind(test, model.matrix(~.+0, test))
test <- test[,-remove.cols]


# need to add the columns of TRAIN in order to pass TEST into PREDICT
missing.cols <- setdiff(names(train), names(test))
test[,missing.cols] = 0

q4.net <- nnet(formula = CAND_ID~., data = train, size = 10,
               MaxNWts = 5000, maxit = 50)
q4.net.train.accuracy <- mean((q4.net$fitted.values > 0.5) == train$CAND_ID)
q4.net.test.accuracy <- mean((predict(q4.net, test) > 0.5) == test$CAND_ID)


################
## question 6 ##
################

train <- read.csv("lab5_train.csv")
test <- read.csv("lab5_test.csv")

# fix the data types of some variables
train$CAND_ID <- as.integer(train$CAND_ID == "Romney")
test$CAND_ID <- as.integer(test$CAND_ID == "Romney")

# convert TRANSACTION_DT to seconds
train$TRANSACTION_DT <- sapply(as.character(train$TRANSACTION_DT), function(x) {ifelse(nchar(x) == 7, paste("0", x, sep=""), x)})
train$TRANSACTION_DT <- as.POSIXct(train$TRANSACTION_DT, format='%m%d%Y')
train$TRANSACTION_DT <- sapply(train$TRANSACTION_DT, function(x) {as.integer(x)})
test$TRANSACTION_DT <- sapply(as.character(test$TRANSACTION_DT), function(x) {ifelse(nchar(x) == 7, paste("0", x, sep=""), x)})
test$TRANSACTION_DT <- as.POSIXct(test$TRANSACTION_DT, format='%m%d%Y')
test$TRANSACTION_DT <- sapply(test$TRANSACTION_DT, function(x) {as.integer(x)})

keep.cols <- c("CAND_ID", "ZIP_CODE", "TRANSACTION_DT")
train <- train[, keep.cols]
test <- test[, keep.cols]

# part a
q5.orig.net <- nnet(formula = CAND_ID~., data = train, size = 10,
                    maxit = 50)

q5.orig.train.accuracy <- mean((q5.orig.net$fitted.values > 0.5) == train$CAND_ID)
q5.orig.test.accuracy <- mean((predict(q5.orig.net, test) > 0.5) == test$CAND_ID)

# part b
train.log <- train
test.log <- test
train.log[,c("ZIP_CODE", "TRANSACTION_DT")] <- log(train.log[,c("ZIP_CODE", "TRANSACTION_DT")])
test.log[,c("ZIP_CODE", "TRANSACTION_DT")] <- log(test.log[,c("ZIP_CODE", "TRANSACTION_DT")])
q5.log.net <- nnet(formula = CAND_ID~., data = train.log, size = 10,
                   maxit = 50)

q5.log.train.accuracy <- mean((q5.log.net$fitted.values > 0.5) == train$CAND_ID)
q5.log.test.accuracy <- mean((predict(q5.log.net, test) > 0.5) == test$CAND_ID)


# part c
# normalize columns that aren't the response variable
train.z <- train
test.z <- test
train.z[,c("ZIP_CODE", "TRANSACTION_DT")] <- scale(train.z[,c("ZIP_CODE", "TRANSACTION_DT")])
test.z[,c("ZIP_CODE", "TRANSACTION_DT")] <- scale(test.z[,c("ZIP_CODE", "TRANSACTION_DT")])
q5.z.net <- nnet(formula = CAND_ID~., data = train.z, size = 10,
                   maxit = 50)

q5.z.train.accuracy <- mean((q5.z.net$fitted.values > 0.5) == train$CAND_ID)
q5.z.test.accuracy <- mean((predict(q5.z.net, test) > 0.5) == test$CAND_ID)


