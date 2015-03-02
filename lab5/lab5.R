
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

train <- read.csv("lab5_train.csv")
test <- read.csv("lab5_test.csv")

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
## question 5 ##
################

train <- read.csv("lab5_train.csv")
test <- read.csv("lab5_test.csv")

train$CAND_ID <- as.integer(train$CAND_ID == "Romney")
test$CAND_ID <- as.integer(test$CAND_ID == "Romney")
#original
netq5 = nnet(formula = CAND_ID~TRANSACTION_AMT + ZIP_CODE, data = train, size = 10,maxit = 50)
q5.train.accuracy <- mean((netq5$fitted.values > 0.5) == train$CAND_ID)
q5.test.accuracy <- mean((predict(netq5, test) > 0.5) == test$CAND_ID)
#log
train.log <- train
test.log <- test
train.log$TRANSACTION_AMT <- log(train.log$TRANSACTION_AMT)
test.log$TRANSACTION_AMT <- log(test.log$TRANSACTION_AMT)
train.log <- train.log[is.finite(train.log$TRANSACTION_AMT),]
test.log <- test.log[is.finite(test.log$TRANSACTION_AMT),]
train.log$ZIP_CODE <- log(train.log$ZIP_CODE)
test.log$ZIP_CODE <- log(test.log$ZIP_CODE)
train.log <- train.log[is.finite(train.log$ZIP_CODE),]
test.log <- test.log[is.finite(test.log$ZIP_CODE),]

net.log.q5 = nnet(formula = CAND_ID~TRANSACTION_AMT + ZIP_CODE, data = train.log, size = 10, maxit = 50)
q5.log.train.accuracy <- mean((net.log.q5$fitted.values > 0.5) == train.log$CAND_ID)
q5.log.test.accuracy <- mean((predict(net.log.q5, test.log) > 0.5) == test.log$CAND_ID)

#zscore
zscore.train=train
zscore.test=test
zscore.train$TRANSACTION_AMT=scale(train$TRANSACTION_AMT, center=TRUE, scale= TRUE)
zscore.test$TRANSACTION_AMT=scale(test$TRANSACTION_AMT, center=TRUE, scale= TRUE)


net.zscore.q5 = nnet(formula = CAND_ID~TRANSACTION_AMT + ZIP_CODE, data = zscore.train, size = 10, maxit = 50)
q5.zscore.train.accuracy <- mean((net.zscore.q5$fitted.values > 0.5) == zscore.train$CAND_ID)
q5.zscore.test.accuracy <- mean((predict(net.zscore.q5, zscore.test) > 0.5) == zscore.test$CAND_ID)

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
q6.orig.net <- nnet(formula = CAND_ID~., data = train, size = 10,
                    maxit = 50)

q6.orig.train.accuracy <- mean((q6.orig.net$fitted.values > 0.5) == train$CAND_ID)
q6.orig.test.accuracy <- mean((predict(q6.orig.net, test) > 0.5) == test$CAND_ID)

# part b
train.log <- train
test.log <- test
train.log[,c("ZIP_CODE", "TRANSACTION_DT")] <- log(train.log[,c("ZIP_CODE", "TRANSACTION_DT")])
test.log[,c("ZIP_CODE", "TRANSACTION_DT")] <- log(test.log[,c("ZIP_CODE", "TRANSACTION_DT")])
q6.log.net <- nnet(formula = CAND_ID~., data = train.log, size = 10,
                   maxit = 50)

q6.log.train.accuracy <- mean((q6.log.net$fitted.values > 0.5) == train$CAND_ID)
q6.log.test.accuracy <- mean((predict(q6.log.net, test) > 0.5) == test$CAND_ID)


# part c
# normalize columns that aren't the response variable
train.z <- train
test.z <- test
train.z[,c("ZIP_CODE", "TRANSACTION_DT")] <- scale(train.z[,c("ZIP_CODE", "TRANSACTION_DT")])
test.z[,c("ZIP_CODE", "TRANSACTION_DT")] <- scale(test.z[,c("ZIP_CODE", "TRANSACTION_DT")])
q6.z.net <- nnet(formula = CAND_ID~., data = train.z, size = 10,
                   maxit = 50)

q6.z.train.accuracy <- mean((q6.z.net$fitted.values > 0.5) == train$CAND_ID)
q6.z.test.accuracy <- mean((predict(q6.z.net, test) > 0.5) == test$CAND_ID)


################
## question 7 ##
################

#for DT, z score is better for train, original is better for test
#for transaction_amt + zip, log is best
library("nnet")

train <- read.csv("lab5_train.csv")
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


missing.cols <- setdiff(names(train), names(test))
amt <- as.matrix(amt)
zp <- as.matrix(zp)
CAND_ID <- as.matrix(CAND_ID)


train <- cbind(train, dt,zp,amt, CAND_ID)
train <- train[is.finite(train$zp),]
train <- train[is.finite(train$amt),]

test <- read.csv("lab5_test.csv")
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

q7.net <- nnet(formula = CAND_ID~., data = train, size = 10,
                 maxit = 50, MaxNWts=3340)

q7.train.accuracy <- mean((q7.net$fitted.values > 0.5) == train$CAND_ID)
#[1] 0.5725948
q7.test.accuracy <- mean((predict(q7.net, test) > 0.5) == test$CAND_ID)
#[1] 0.5725948

#part b
library("e1071")
#Might have to rerun the "train" equalities in the first half of 7a
svm.q7.rbf <- svm(CAND_ID~., data = train, kernel = "radial")
q7.rbf.train.accuracy <- mean((predict(svm.q7.rbf, newdata = train) > 0.5) == train$CAND_ID) 
#[1] 0.633258
q7.rbf.test.accuracy <- mean((predict(svm.q7.rbf, newdata = test) > 0.5) == test$CAND_ID) 
#[1] 0.6482134


################
## question 8 ##
################

C <- 2^seq(-5, 15, by = 2)
mu <- 2^seq(-15, 3, by = 2)
for (i in 1:length(C)) {
  for (j in 1:length(mu)) {
    
  }
}



################
## question 9 ##
################

# from http://download.geonames.org/export/zip/
zips <- read.csv("US.txt", sep="\t", header = F)
zips <- zips[,c("V2", "V10", "V11")]
names(zips) <- c("ZIP", "LAT", "LON")
