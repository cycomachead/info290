#! /usr/bin/env python3
from pandas import *
import sklearn
from sklearn.naive_bayes import GaussianNB
from sklearn.naive_bayes import MultinomialNB
from sklearn.grid_search import GridSearchCV
import numpy as np
import random

STYLE = "American_IPA"

""" Performs cross validation on data using a given method
    Returns the average score.
    Percent is the percentage of data to use as validation,
    this should be an integer, not a decimal.
    Rounds is the number of rounds of cv to run.
"""
def cross_val(data, labels, percent, rounds, method):
    row_count = len(data.index)
    scores = []

    # Test round times and take average score
    for _ in range(rounds):

        # randomly select row indices for test/train sets
        test_rows = []
        for i in range(row_count//percent):
            test_rows.append(random.randint(0, row_count-1))
        test_rows.sort()
        train_rows = [i for i in range(len(data.index))]
        train_rows = [i for i in train_rows if i not in test_rows]
        train_rows.sort()

        # select test/train sets
        test_data = data.drop(train_rows)
        train_data = data.drop(test_rows)

        test_labels = labels.drop(train_rows)
        train_labels = labels.drop(test_rows)

        # train random forest
        fit_cv = method.fit(train_data, train_labels)

        # calculate score
        score_cv = method.score(test_data, test_labels)
        scores.append(score_cv)

    return sum(scores)/len(scores)

data = read_pickle("processed/pandas/%s.pkl"%(STYLE))
labels = data['beer_id']
del data['beer_id']
data = data.fillna(0)

###########################
### Basic Bayes Methods ###
###########################

gnb = GaussianNB()
fit = gnb.fit(data, labels)
score = gnb.score(data, labels)
print('Gaussian NB')
print(score)


mbn = MultinomialNB()
fit = mbn.fit(data, labels)
score = mbn.score(data, labels)
print('Multinomial NB')
print(score)


########################
### Cross Validation ###
########################

# rounds = 2
# pct = 10
# # for c in criterion:
# #     for t in trees:
# #         for s in samples:
#
# param_grid = {'C': [0.001, 0.01, 0.1, 1, 10, 100, 1000] }
# clf = GridSearchCV(LogisticRegression(penalty='l2'), param_grid)
# lr = LogisticRegression(C=1.0, intercept_scaling=1, dual=False,
#                         fit_intercept=True, penalty='l2', tol=0.0001)
#
# gs = GridSearchCV(cv=None, estimator=lr, param_grid=param_grid)
#
# # fit = clf.fit(data, labels)
# # score = clf.score(data, labels)
# # print('Grid Search Method')
# # print(score)
#
# print("===== Cross Validation ====")
# lr = LogisticRegression(C=1.0, intercept_scaling=1, dual=False,
#                         fit_intercept=True, penalty='l2', tol=0.0001)
# fit = clf.fit(data, labels)
# score = clf.score(data, labels)
# print("Training Score: %f "% score)
# print("Cross Validation Score: %f" % (cross_val(data, labels, pct, rounds, clf)))
#

