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

rf <- randomForest(survived~., data = train)

mean(predict(rf, train) == train$survived)
mean(predict(rf, holdout) == holdout$survived)


train.full <- cleanup(read.csv("train.csv"))
rf.full <- randomForest(survived~., data = train.full)
test.predictions <- predict(rf.full, test)

# write out the predictions - make sure to change the filename
#write.csv(data.frame(passenger_id = test$passenger_id, survived = test.predictions), file = "submissions/test_predictions_3_8_1309_rf_only.csv", row.names = FALSE)

#########################
## LOGISTIC REGRESSION ##
#########################

logistic <- glm(survived~., data = train, family = "binomial")
mean((predict(logistic, train, type = "response") > 0.5) == as.integer(train$survived) - 1)
mean((predict(logistic, holdout, type = "response") > 0.5) == as.integer(holdout$survived) - 1)

logit.train.correct <- (predict(logistic, train, type = "response") > 0.5) == as.integer(train$survived) - 1
rf.train.correct <- predict(rf, train) == train$survived
sum(logit.train.correct & !rf.train.correct) # conclusion: logistic sucks

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
    print(paste("Cost:", C))
    print(paste("Gamma:", g))
    train.acc <- mean(predict(single.svm, train) == train$survived)
    holdout.acc <- mean(predict(single.svm, holdout) == holdout$survived)
    print(train.acc)
    print(holdout.acc)
    mat[i, j] <- holdout.acc
  }
}

# Plot the heatmap of parameters
heatmap(mat, ylab = "C", xlab = "gamma", Rowv = NA, Colv = NA)


single.svm.full <- svm(survived~., data = train.full, kernel = "radial", cost = 10, gamma = 0.1)
svm.predictions <- predict(single.svm.full, test)

# write out the predictions - make sure to change the filename
#write.csv(data.frame(passenger_id = test$passenger_id, survived = svm.predictions), file = "submissions/test_predictions_3_10_1506_svm_only.csv", row.names = FALSE)

##############
## ADABOOST ##
##############

library("ada")

ada.train <- ada(survived~., data = train)
mean(predict(ada.train, train) == train$survived)
mean(predict(ada.train, train) == holdout$survived)


##############
## ENSEMBLE ##
##############


models <- data.frame(rf = predict(rf, train),
                                        #logit = ifelse(predict(logistic, train, type = "response") > 0.5, 1, 0),
                     svm = predict(single.svm, train), survived = train$survived)

models.holdout <- data.frame(rf = predict(rf, holdout), logit = ifelse(predict(logistic, holdout, type = "response") > 0.5, 1, 0), svm = predict(single.svm, holdout), survived = holdout$survived)

ensemble.svm <- svm(survived~., data = models, kernel = "radial")

mean(predict(ensemble.svm, models) == train$survived)
mean(predict(ensemble.svm, models.holdout) == holdout$survived)


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
