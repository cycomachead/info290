library("randomForest")

# currently handling NAs in the laziest possible way

most.common.factor <- function(v) {
  return(names(sort(table(v), decreasing = TRUE)[1]))
}

home.dest.feature <- function(D) {
  home.dest <- as.character(D$home.dest)
  london_train=grep("London",home.dest)
  uk_train=grep("England",home.dest)
  ny_train=grep("NY",home.dest)
  home.dest[london_train] <- 1
  home.dest[uk_train] <- 1
  home.dest[ny_train] <- 2
  home.dest[-c(london_train, uk_train, ny_train)] <- 0
  home.dest <- as.factor(home.dest)
  return(home.dest)
}

cabin.feature <- function(D) {
  cabin <- as.character(D$cabin)
  new.cabin <- rep(NA, length(cabin))
  cabin.letters <- toupper(letters)[1:7]
  for (i in 1:length(cabin.letters)) {
    current.indices <- grep(cabin.letters[i], cabin)
    new.cabin[current.indices] <- i
  }
  new.cabin[is.na(new.cabin)] <- 0
  return(as.factor(new.cabin))
}

cleanup <- function(D, labeled = TRUE) {
  D <- subset(D, select = -c(name, ticket)) #, cabin)) #, home.dest)) #, passenger_id))
  #D <- na.omit(D)
  D$home.dest <- home.dest.feature(D)
  D$cabin <- cabin.feature(D)
  for (i in 1:ncol(D)) {
    if (is.factor(D[,i])) {
      most.common <- most.common.factor(D[,i])
      D[is.na(D[,i]), i] <- most.common
    } else {
      D[is.na(D[,i]), i] <- mean(D[,i], na.rm = TRUE)
    }
  }
  D$log.fare <- log(D$fare + 1)
  if (labeled) {
    D$survived <- as.factor(D$survived)
  }
  D$embarked[D$embarked == ""] <- most.common.factor(D$embarked)
  D$embarked <- factor(D$embarked)
  return(D)
}

split.train <- function(D, split = 0.8) {
  #set.seed(1) # for the moment, force deterministic behavior
  indices <- sample(1:nrow(train), size = floor(split * nrow(train)))
  return(list(train = D[indices,], holdout = D[-indices,]))
}

train <- cleanup(read.csv("train.csv"))
test <- cleanup(read.csv("test.csv"), labeled = FALSE)

train.and.holdout <- split.train(train)
train <- train.and.holdout$train
holdout <- train.and.holdout$holdout
train.full <- cleanup(read.csv("train.csv"))

train$passenger_id <- holdout$passenger_id <- train.full$passenger_id <- NULL

# # separate cabin
# train.cabin <- train$cabin
# train$cabin <- NULL
# holdout.cabin <- holdout$cabin
# holdout$cabin <- NULL
# test.cabin <- test$cabin
# test$cabin <- NULL
# train.full.cabin <- train.full$cabin
# train.full$cabin <- NULL
# 
# # separate home.dest
# train.home.dest <- train$home.dest
# train$home.dest <- NULL
# holdout.home.dest <- holdout$home.dest
# holdout$home.dest <- NULL
# test.home.dest <- test$home.dest
# test$home.dest <- NULL
# train.full.home.dest <- train.full$home.dest
# train.full$home.dest <- NULL



###################
## RANDOM FOREST ##
###################

#train <- train.full


ntrees <- seq(1000, 2500, by = 500)
rf.accuraces <- rep(0, length(ntrees))
names(rf.accuraces) <- ntrees

for (i in 1:length(ntrees)) {
  #rf <- randomForest(survived~., data = train, ntree = ntrees[i])
  rf.cv <- rfcv(train[,-2], train$survived, cv.fold = 10)
  #train.acc <- mean(predict(rf, train) == train$survived)
  
  #holdout.acc <- mean(predict(rf, holdout) == holdout$survived)
  #rf.accuraces[i] <- holdout.acc
  rf.accuraces[i] <- rf.cv$error.cv[1]
  print("####################")
  print(paste("Num trees:", ntrees[i]))
  print(train.acc)
  #print(holdout.acc)
  print(rf.cv$error.cv)
}

rf <- randomForest(survived~., data = train, ntree = 1500)
mean(predict(rf, train) == train$survived)
mean(predict(rf, holdout) == holdout$survived)

rf.full <- randomForest(survived~., data = train.full, ntree = 1500)
rf.test.predictions <- predict(rf.full, test)

# write out the predictions - make sure to change the filename
# write.csv(data.frame(passenger_id = test$passenger_id, survived = test.predictions), file = "submissions/test_predictions_3_11_2217_rf_better.csv", row.names = FALSE)

#########################
## LOGISTIC REGRESSION ##
#########################

logistic <- glm(survived~., data = train, family = "binomial")
mean((predict(logistic, train, type = "response") > 0.5) == as.integer(train$survived) - 1)
mean((predict(logistic, holdout, type = "response") > 0.5) == as.integer(holdout$survived) - 1)

logit.train.correct <- (predict(logistic, train, type = "response") > 0.5) == as.integer(train$survived) - 1
rf.train.correct <- predict(rf, train) == train$survived
sum(logit.train.correct & !rf.train.correct) # conclusion: logistic sucks

logistic.full <- glm(survived~., data = train.full, family = "binomial")

############################
## SUPPORT VECTOR MACHINE ##
############################

library("e1071")

all.svm.preds.train <- NULL
all.svm.preds.holdout <- NULL
costs <- 1:12 # 10^(-3:3)
#gammas <- 10^(-5:2)
gammas <- 1:4 # actually degree right now
mat <- matrix(0, nrow = length(costs), ncol = length(gammas))
rownames(mat) <- costs
colnames(mat) <- gammas
cv.holdout.accuracies <- cv.train.accuracies <- cv.accuracies <- mat
use.cv = TRUE
for (i in 1:length(costs)) {
  for (j in 1:length(gammas)) {
    print("###############################")
    print(paste("Cost:", costs[i]))
    print(paste("Gamma:", gammas[j]))
    if (use.cv) {
      #single.svm <- svm(survived~., data = train, kernel = "radial", cost = costs[i], gamma = gammas[j],
      #                       cross=10)
      single.svm <- svm(survived~., data = train, kernel = "polynomial", cost = costs[i], degree = gammas[j],
                        cross=10)
      cv.accuracies[i, j]  <- single.svm$tot.accuracy 
      cv.train.accuracies[i, j] <- mean(single.svm$fitted == train$survived)
      cv.holdout.accuracies[i, j]  <- mean(predict(single.svm, holdout) == holdout$survived)
      print(cv.accuracies[i, j])
      print(cv.holdout.accuracies[i, j])
    } else {
      single.svm <- svm(survived~., data = train, kernel = "radial", cost = costs[i], gamma = gammas[j])
      train.acc <- mean(predict(single.svm, train) == train$survived)
      holdout.acc <- mean(predict(single.svm, holdout) == holdout$survived)
      if (holdout.acc > .80) {
        all.svm.preds.train  <- cbind(all.svm.preds.train, predict(single.svm, train))
        all.svm.preds.holdout  <- cbind(all.svm.preds.holdout, predict(single.svm, holdout))
      }
      print(train.acc)
      print(holdout.acc)
      mat[i, j] <- holdout.acc
    }
  }
}

## SVM -> SVM
# svm.svm  <- svm(train$survived~., data = all.svm.preds.train)

# Plot the heatmap of parameters
heatmap(mat, ylab = "C", xlab = "gamma", Rowv = NA, Colv = NA)

#single.svm <- svm(survived~., data = train, kernel = "radial", cost = 10, gamma = 0.1, probability = TRUE, cross = 10)
single.svm <- svm(survived~., data = train, kernel = "radial", cost = 7, degree = 2, probability = TRUE, cross = 10)
mean(predict(single.svm, train) == train$survived)
mean(predict(single.svm, holdout) == holdout$survived)

#single.svm.full <- svm(survived~., data = train.full, kernel = "radial", cost = 10, gamma = 0.1, probability = TRUE, cross=10)
single.svm.full <- svm(survived~., data = train.full, kernel = "radial", cost = 10, degree = 2, probability = TRUE, cross=10)
svm.predictions <- predict(single.svm.full, test)

# write out the predictions - make sure to change the filename
#write.csv(data.frame(passenger_id = test$passenger_id, survived = svm.predictions), file = "submissions/test_predictions_3_10_1506_svm_only.csv", row.names = FALSE)

##############
## ADABOOST ##
##############

library("ada")


cv.ada <- function(D, nfold = 10, ...) {
  n <- nrow(D)
  scrambled <- sample(1:n, replace = FALSE)
  cv.size = round(n / nfold)
  start = 1
  end = cv.size
  errors = NULL
  for (i in 1:nfold) {
    if (end > n) {
      end <- n
    }
    leave.out = scrambled[start:end]
    print(leave.out)
    ada.train <- ada(survived~., data = D, subset = -leave.out,...)
    error = mean((D[leave.out, "survived"] != predict(ada.train, newdata = D[leave.out,])))
    errors = c(errors, error)
    start = start + cv.size
    end = end + cv.size
  }
  return(mean(errors))
}


nus <- 2^(-5:1)
accuracies <- rep(0, length(nus))
names(accuracies) <- nus
for (i in 1:length(nus)) {
  #ada.train <- ada(survived~., data = train, nu = nus[i])
  #mean(predict(ada.train, train) == train$survived)
  #mean(predict(ada.train, holdout) == holdout$survived)
  print("###############################")
  print(paste("nu:", nus[i]))
  #train.acc <- mean(predict(ada.train, train) == train$survived)
  #holdout.acc <- mean(predict(ada.train, holdout) == holdout$survived)
  #print(train.acc)
  #print(holdout.acc)
  #accuracies[i] <- holdout.acc
  accuracies[i] <- cv.ada(train, nu = nus[i])
  print(accuracies[i])
}

ada.train <- ada(survived~., data = train, nu = 2^-3)

ada.train.full <- ada(survived~., data = train.full, nu = 2^-1)
ada.predictions <- predict(ada.train.full, test)
# write out the predictions - make sure to change the filename
# write.csv(data.frame(passenger_id = test$passenger_id, survived = ada.predictions), file = "submissions/test_predictions_3_10_1603_adaboost_only.csv", row.names = FALSE)

################
## NEURAL NET ##
################

library("nnet")

cv.nnet <- function(D, nfold = 10, ...) {
  n <- nrow(D)
  scrambled <- sample(1:n, replace = FALSE)
  cv.size = round(n / nfold)
  start = 1
  end = cv.size
  errors = NULL
  for (i in 1:nfold) {
    if (end > n) {
      end <- n
    }
    leave.out = scrambled[start:end]
    print(leave.out)
    net = nnet(formula = survived~., data = train, maxit = 500, subset = -leave.out, ...)
    error = mean(as.integer(predict(net, D[leave.out,]) > 0.5) != D[leave.out, "survived"])
    errors = c(errors, error)
    start = start + cv.size
    end = end + cv.size
  }
  return(mean(errors))
}


sizes = 5:15
net.accuracies <- rep(0, length(sizes))
names(net.accuracies) <- sizes
for (i in 1:length(net.accuracies)) {
  #net = nnet(formula = survived~., data = train, size = sizes[i], maxit = 500)
  #train.acc <- mean(as.integer(predict(net, train) > 0.5) == train$survived)
  #holdout.acc <- mean(as.integer(predict(net, holdout) > 0.5) == holdout$survived)
  #net.accuracies[i] <- holdout.acc
  net.accuracies[i] <- cv.nnet(train, size = sizes[i])
}

net = nnet(formula = survived~., data = train, size = 6, maxit = 500)

net.full = nnet(formula = survived~., data = train.full, size = 5, maxit = 500)

net.predictions <- as.integer(predict(net.full, test) > 0.5)

# write out the predictions - make sure to change the filename
# write.csv(data.frame(passenger_id = test$passenger_id, survived = net.predictions), file = "submissions/test_predictions_3_11_2237_nnet_only.csv", row.names = FALSE)

##################
## ENSEMBLE SVM ##
##################

use.probs = TRUE

normalize <- function(d, means, sds) {
  scale(d, center = means, scale = sds)
}

if (use.probs) {
  models <- data.frame(rf = predict(rf, train, type = "prob")[,2],
                       #logit = predict(logistic, train, type = "response"),
                       svm = attr(predict(single.svm, train, probability = TRUE), "probabilities")[,2],
                       ada = predict(ada.train, train, type = "prob")[,2],
                       net = predict(net, train),
                       #log.fare = log(train$fare + 1),
                       #home.dest = train.home.dest,
                       #cabin = train.cabin,
                       survived = train$survived)

#   centers <- colMeans(models[,1:(ncol(models)-3)])
#   scales <- sapply(models[,1:(ncol(models)-3)], sd)
#   models[,1:(ncol(models)-3)] <- normalize(models[,1:(ncol(models)-3)], centers, scales)
  
  models.holdout <- data.frame(rf = predict(rf, holdout, type = "prob")[,2],
                               #logit = predict(logistic, holdout, type = "response"),
                               svm = attr(predict(single.svm, holdout, probability = TRUE), "probabilities")[,2],
                               ada = predict(ada.train, holdout, type = "prob")[,2],
                               net = predict(net, holdout),
#                                log.fare = log(holdout$fare + 1),
#                                home.dest = holdout.home.dest,
#                                cabin = holdout.cabin,
                               survived = holdout$survived)
  
                                        # models.holdout <- apply(X = models.holdout, FUN = as.integer, MARGIN = 2)

#   models.holdout[,1:(ncol(models)-3)] <- normalize(models.holdout[,1:(ncol(models)-3)], centers, scales)
  
  models.train.full <- data.frame(rf = predict(rf.full, train.full, type = "prob")[,2],
                                  #logit = predict(logistic.full, train.full, type = "response"),
                                  svm = attr(predict(single.svm.full, train.full, probability = TRUE), "probabilities")[,2],
                                  ada = predict(ada.train.full, train.full, type = "prob")[,2],
                                  net = predict(net.full, train.full),
#                                   log.fare = log(train.full$fare + 1),
#                                   home.dest = train.full.home.dest,
#                                   cabin = train.full.cabin,
                                  survived = train.full$survived)

#   centers <- colMeans(models.train.full[,1:(ncol(models)-3)])
#   scales <- sapply(models.train.full[,1:(ncol(models)-3)], sd)
#   models.train.full[,1:(ncol(models)-3)] <- normalize(models.train.full[,1:(ncol(models)-3)], centers, scales)
  
  models.test <- data.frame(rf = predict(rf.full, test, type = "prob")[,2],
                            #logit = predict(logistic.full, test, type = "response"),
                            svm = attr(predict(single.svm.full, test, probability = TRUE), "probabilities")[,2],
                            ada = predict(ada.train.full, test, type = "prob")[,2],
                            net = predict(net.full, test)
#                             log.fare = log(test$fare + 1),
#                             home.dest = test.home.dest,
#                             cabin = test.cabin
                            )
#   models.test[,1:(ncol(models)-3)] <- normalize(models.test[,1:(ncol(models)-3)], centers, scales)
  
} else {
  models <- data.frame(rf = predict(rf, train),
                       #logit = ifelse(predict(logistic, train, type = "response") > 0.5, 1, 0),
                       svm = predict(single.svm, train),
                       ada = predict(ada.train, train),
                       net = as.integer(predict(net, holdout) > 0.5),
                       log.fare = log(train$fare + 1),
                       home.dest = train.home.dest,
                       #cabin = train.cabin,
                       survived = train$survived)
  
  models.holdout <- data.frame(rf = predict(rf, holdout),
                               #logit = ifelse(predict(logistic, holdout, type = "response") > 0.5, 1, 0),
                               svm = predict(single.svm, holdout), ada = predict(ada.train, holdout),
                               net = as.integer(predict(net, holdout) > 0.5),
                               log.fare = log(holdout$fare + 1),
                               home.dest = holdout.home.dest,
                               #cabin = holdout.cabin,
                               survived = holdout$survived)
  
                                        # models.holdout <- apply(X = models.holdout, FUN = as.integer, MARGIN = 2)
  
  models.train.full <- data.frame(rf = predict(rf.full, train.full),
                                        #logit = ifelse(predict(logistic.full, train.full, type = "response") > 0.5, 1, 0),
                                  svm = predict(single.svm.full, train.full),
                                  ada = predict(ada.train.full, train.full),
                                  net = as.integer(predict(net.full, train.full) > 0.5),
                                  log.fare = log(train.full$fare + 1),
                                  home.dest = train.full.home.dest,
                                  #cabin = train.full.cabin,
                                  survived = train.full$survived)
  
  models.test <- data.frame(rf = predict(rf.full, test),
                                        #logit = ifelse(predict(logistic.full, test, type = "response") > 0.5, 1, 0),
                            svm = predict(single.svm.full, test),
                            ada = predict(ada.train.full, test),
                            net = as.integer(predict(net.full, test) > 0.5),
                            log.fare = log(test$fare + 1),
                            home.dest = test.home.dest
                            #cabin = test.cabin
                            )

}
  
ensemble.svm <- svm(survived~., data = models, kernel = "polynomial", gamma = 2, cost = 5)

mean(predict(ensemble.svm, models) == train$survived)
mean(predict(ensemble.svm, models.holdout) == holdout$survived)

#costs <- 10^(-3:3)
costs <- 1:10
gammas <- 10^(-5:2)
#gammas <- 1:6 # actually degree
mat <- matrix(0, nrow = length(costs), ncol = length(gammas))
rownames(mat) <- costs
colnames(mat) <- gammas
ensemble.cv.accuracies <- mat
for (i in 1:length(costs)) {
  for (j in 1:length(gammas)) {
    print("###############################")
    print(paste("Cost:", costs[i]))
    print(paste("Gamma:", gammas[j]))
    single.svm <- svm(survived~., data = models.train.full, kernel = "radial", cost = costs[i], gamma = gammas[j],
                      cross=10)
#     single.svm <- svm(survived~., data = models.train.full, kernel = "polynomial", cost = costs[i], degree = gammas[j],
#                   cross=10)
    ensemble.cv.accuracies[i, j]  <- single.svm$tot.accuracy 
    print(ensemble.cv.accuracies[i, j])
  }
}

#single.svm<- svm(survived~., data = models.train.full, kernel = "radial", cost = costs[i], gamma = gammas[j])

ensemble.svm.full <- svm(survived~., data = models.train.full, kernel = "polynomial", C = 10, degree = 2)
test.predictions <- predict(ensemble.svm.full, models.test)

      

# write out the predictions - make sure to change the filename
#write.csv(data.frame(passenger_id = test$passenger_id, survived = test.predictions), file = "submissions/test_predictions_4_2_0047_ensemble_svm_cv.csv", row.names = FALSE)
# submissions/test_predictions_3_31_2308_ensemble_svm_cv.csv had parameters C: 0.1, gamma: 1


#######################
## ENSEMBLE ADABOOST ##
#######################

# ensemble.ada <- ada(survived~., data = models)
# mean(predict(ensemble.ada, models) == train$survived)
# mean(predict(ensemble.ada, models.holdout) == holdout$survived)

##################################
## ENSEMBLE LOGISTIC REGRESSION ##
##################################

#models.numeric <- as.data.frame(apply(FUN = as.numeric, X = models, 2))
#models.numeric <- as.data.frame(scale(model.matrix(survived~.+0, data = models)))
#models.numeric$survived <- models$survived
models.numeric <- models
#models.holdout.numeric <- as.data.frame(apply(FUN = as.numeric, X = models.holdout, 2))
#models.holdout.numeric <- as.data.frame(model.matrix(survived~.+0, data = models.holdout))
#models.holdout.numeric$survived <- models.holdout$survived
models.holdout.numeric <- models.holdout

ensemble.glm <- glm(survived~., data = models.numeric, family = "binomial")
mean(as.integer(predict(ensemble.glm, models.numeric) > 0.5) == train$survived)
mean(as.integer(predict(ensemble.glm, models.holdout.numeric) > 0.5) == holdout$survived)

#models.train.full.numeric <- as.data.frame(apply(FUN = as.integer, X = models.train.full, 2))
models.train.full.numeric <- as.data.frame(scale(model.matrix(survived~.+0, data = models.train.full)))
models.train.full.numeric$survived <- train.full$survived
#models.test.numeric <- as.data.frame(apply(FUN = as.integer, X = models.test, 2))
models.test.numeric <- as.data.frame(scale(model.matrix(~.+0, data = models.test)))

ensemble.glm.full <- glm(survived~., data = models.train.full.numeric, family = "binomial")
mean(as.integer(predict(ensemble.glm.full, models.train.full.numeric) > 0.5) == train.full$survived)

test.predictions <- as.integer(predict(ensemble.glm.full, models.test.numeric) > 0.5)

# write out the predictions - make sure to change the filename
#write.csv(data.frame(passenger_id = test$passenger_id, survived = test.predictions), file = "submissions/test_predictions_4_2_0215_ensemble_logistic.csv", row.names = FALSE)

##########################
## SVM -> RANDOM FOREST ##
##########################

# train.full$svm.pred <- predict(single.svm.full, train.full)
# train.and.holdout <- split.train(train.full)
# train <- train.and.holdout$train
# holdout <- train.and.holdout$holdout
# test$svm.pred <- predict(single.svm.full, test)
# 
# rf.with.svm <- randomForest(survived~., data = train)
# 
# mean(predict(rf, train) == train$survived)
# mean(predict(rf, holdout) == holdout$survived)
# 
# rv.with.svm.full <- randomForest(survived~., data = train.full)
# rf.with.svm.predictions <- predict(rv.with.svm.full, test)

# write out the predictions - make sure to change the filename
#write.csv(data.frame(passenger_id = test$passenger_id, survived = rf.with.svm.predictions), file = "submissions/test_predictions_3_9_0951_svm_to_rf.csv", row.names = FALSE)
