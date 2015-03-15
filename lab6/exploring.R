library("randomForest")

# currently handling NAs in the laziest possible way

most.common.factor <- function(v) {
  return(names(sort(table(v), decreasing = TRUE)[1]))
}

cleanup <- function(D, labeled = TRUE) {
  D <- subset(D, select = -c(home.dest, name, ticket, cabin)) #, passenger_id))
  #D <- na.omit(D)
  for (i in 1:ncol(D)) {
    if (is.factor(D[,i])) {
      most.common <- most.common.factor(D[,i])
      D[is.na(D[,i]), i] <- most.common
    } else {
      D[is.na(D[,i]), i] <- mean(D[,i], na.rm = TRUE)
    }
  }
  if (labeled) {
    D$survived <- as.factor(D$survived)
  }
  D$embarked[D$embarked == ""] <- most.common.factor(D$embarked)
  D$embarked <- factor(D$embarked)
  return(D)
}

split.train <- function(D, split = 0.8) {
  set.seed(1) # for the moment, force deterministic behavior
  indices <- sample(1:nrow(train), size = floor(split * nrow(train)))
  return(list(train = D[indices,], holdout = D[-indices,]))
}

train <- cleanup(read.csv("train.csv"))
test <- cleanup(read.csv("test.csv"), labeled = FALSE)

train.and.holdout <- split.train(train)
train <- train.and.holdout$train
holdout <- train.and.holdout$holdout


###################
## RANDOM FOREST ##
###################


ntrees <- seq(500, 2500, by = 500)
rf.accuraces <- rep(0, length(ntrees))
names(rf.accuraces) <- ntrees

for (i in 1:length(ntrees)) {
  rf <- randomForest(survived~., data = train, ntree = ntrees[i])
  train.acc <- mean(predict(rf, train) == train$survived)
  holdout.acc <- mean(predict(rf, holdout) == holdout$survived)
  rf.accuraces[i] <- holdout.acc
  print("####################")
  print(paste("Num trees:", ntrees[i]))
  print(train.acc)
  print(holdout.acc)
}

rf <- randomForest(survived~., data = train, ntree = 2000)

train.full <- cleanup(read.csv("train.csv"))
rf.full <- randomForest(survived~., data = train.full, ntree = 2000)
test.predictions <- predict(rf.full, test)

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

costs <- 10^(-3:3)
gammas <- 10^(-5:2)
mat <- matrix(0, nrow = length(costs), ncol = length(gammas))
rownames(mat) <- costs
colnames(mat) <- gammas
for (i in 1:length(costs)) {
  for (j in 1:length(gammas)) {
    single.svm <- svm(survived~., data = train, kernel = "radial", cost = costs[i], gamma = gammas[j])
    print("###############################")
    print(paste("Cost:", costs[i]))
    print(paste("Gamma:", gammas[j]))
    train.acc <- mean(predict(single.svm, train) == train$survived)
    holdout.acc <- mean(predict(single.svm, holdout) == holdout$survived)
    print(train.acc)
    print(holdout.acc)
    mat[i, j] <- holdout.acc
  }
}

# Plot the heatmap of parameters
heatmap(mat, ylab = "C", xlab = "gamma", Rowv = NA, Colv = NA)

single.svm <- svm(survived~., data = train, kernel = "radial", cost = 10, gamma = 0.1)


single.svm.full <- svm(survived~., data = train.full, kernel = "radial", cost = 10, gamma = 0.1)
svm.predictions <- predict(single.svm.full, test)

# write out the predictions - make sure to change the filename
#write.csv(data.frame(passenger_id = test$passenger_id, survived = svm.predictions), file = "submissions/test_predictions_3_10_1506_svm_only.csv", row.names = FALSE)

##############
## ADABOOST ##
##############

library("ada")

nus <- 2^(-8:3)
accuracies <- rep(0, length(nus))
names(accuracies) <- nus
for (i in 1:length(nus)) {
  ada.train <- ada(survived~., data = train, nu = nus[i])
  mean(predict(ada.train, train) == train$survived)
  mean(predict(ada.train, holdout) == holdout$survived)
  print("###############################")
  print(paste("nu:", nus[i]))
  train.acc <- mean(predict(ada.train, train) == train$survived)
  holdout.acc <- mean(predict(ada.train, holdout) == holdout$survived)
  print(train.acc)
  print(holdout.acc)
  accuracies[i] <- holdout.acc
}

ada.train <- ada(survived~., data = train, nu = 0.01)

ada.train.full <- ada(survived~., data = train.full, nu = 0.01)
ada.predictions <- predict(ada.train.full, test)
# write out the predictions - make sure to change the filename
# write.csv(data.frame(passenger_id = test$passenger_id, survived = ada.predictions), file = "submissions/test_predictions_3_10_1603_adaboost_only.csv", row.names = FALSE)

################
## NEURAL NET ##
################

library("nnet")

sizes = 5:15
net.accuracies <- rep(0, length(sizes))
names(net.accuracies) <- sizes
for (i in 1:length(net.accuracies)) {
  net = nnet(formula = survived~., data = train, size = sizes[i], maxit = 500)
  train.acc <- mean(as.integer(predict(net, train) > 0.5) == train$survived)
  holdout.acc <- mean(as.integer(predict(net, holdout) > 0.5) == holdout$survived)
  net.accuracies[i] <- holdout.acc
}

net = nnet(formula = survived~., data = train, size = 10, maxit = 500)

net.full = nnet(formula = survived~., data = train.full, size = 10, maxit = 500)

net.predictions <- as.integer(predict(net.full, test) > 0.5)

# write out the predictions - make sure to change the filename
# write.csv(data.frame(passenger_id = test$passenger_id, survived = net.predictions), file = "submissions/test_predictions_3_11_2237_nnet_only.csv", row.names = FALSE)

##################
## ENSEMBLE SVM ##
##################


models <- data.frame(rf = predict(rf, train),
                     logit = ifelse(predict(logistic, train, type = "response") > 0.5, 1, 0),
                     svm = predict(single.svm, train),
                     ada = predict(ada.train, train),
                     net = as.integer(predict(net, holdout) > 0.5),
                     survived = train$survived)

models.holdout <- data.frame(rf = predict(rf, holdout),
                             logit = ifelse(predict(logistic, holdout, type = "response") > 0.5, 1, 0),
                             svm = predict(single.svm, holdout), ada = predict(ada.train, holdout),
                             net = as.integer(predict(net, holdout) > 0.5),
                             survived = holdout$survived)

# models.holdout <- apply(X = models.holdout, FUN = as.integer, MARGIN = 2)

models.train.full <- data.frame(rf = predict(rf.full, train.full),
                                #logit = ifelse(predict(logistic.full, train.full, type = "response") > 0.5, 1, 0),
                                svm = predict(single.svm.full, train.full),
                                ada = predict(ada.train.full, train.full),
                                net = as.integer(predict(net.full, train.full) > 0.5),
                                survived = train.full$survived)

models.test <- data.frame(rf = predict(rf.full, test),
                          #logit = ifelse(predict(logistic.full, test, type = "response") > 0.5, 1, 0),
                          svm = predict(single.svm.full, test),
                          ada = predict(ada.train.full, test),
                          net = as.integer(predict(net.full, test) > 0.5))


ensemble.svm <- svm(survived~., data = models, kernel = "radial")

mean(predict(ensemble.svm, models) == train$survived)
mean(predict(ensemble.svm, models.holdout) == holdout$survived)

ensemble.svm.full <- svm(survived~., data = models.train.full, kernel = "radial")
test.predictions <- predict(ensemble.svm.full, models.test)

# write out the predictions - make sure to change the filename
# write.csv(data.frame(passenger_id = test$passenger_id, survived = test.predictions), file = "submissions/test_predictions_3_14_0005_ensemble.csv", row.names = FALSE)


#######################
## ENSEMBLE ADABOOST ##
#######################

ensemble.ada <- ada(survived~., data = models)
mean(predict(ensemble.ada, models) == train$survived)
mean(predict(ensemble.ada, models.holdout) == holdout$survived)

##################################
## ENSEMBLE LOGISTIC REGRESSION ##
##################################

models.numeric <- as.data.frame(apply(FUN = as.integer, X = models, 2))
models.holdout.numeric <- as.data.frame(apply(FUN = as.integer, X = models.holdout, 2))

ensemble.glm <- glm(survived~., data = models.numeric, family = "binomial")
mean(as.integer(predict(ensemble.glm, models.numeric) > 0.15) == train$survived)
mean(as.integer(predict(ensemble.glm, models.holdout.numeric) > 0.5) == holdout$survived)

##########################
## SVM -> RANDOM FOREST ##
##########################

train.full$svm.pred <- predict(single.svm.full, train.full)
train.and.holdout <- split.train(train.full)
train <- train.and.holdout$train
holdout <- train.and.holdout$holdout
test$svm.pred <- predict(single.svm.full, test)

rf.with.svm <- randomForest(survived~., data = train)

mean(predict(rf, train) == train$survived)
mean(predict(rf, holdout) == holdout$survived)

rv.with.svm.full <- randomForest(survived~., data = train.full)
rf.with.svm.predictions <- predict(rv.with.svm.full, test)

# write out the predictions - make sure to change the filename
#write.csv(data.frame(passenger_id = test$passenger_id, survived = rf.with.svm.predictions), file = "submissions/test_predictions_3_9_0951_svm_to_rf.csv", row.names = FALSE)
