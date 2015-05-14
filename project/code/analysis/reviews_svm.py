from pandas import *
from sklearn import svm
import numpy as np
import random

STYLE = "American_Pale_Ale_(APA)"

""" Performs cross validation on data using svm
    Returns the average score.
    Percent is the percentage of data to use as validation,
    this should be an integer, not a decimal.
    Rounds is the number of rounds of cv to run.
"""
def cross_val(data, labels, percent, rounds, svc):
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

        # train svm
        svc.fit(train_data, train_labels)

        # calculate score
        score_cv = svc.score(test_data, test_labels)
        scores.append(score_cv)

    return sum(scores)/len(scores)

data = read_pickle("./%s.pkl"%(STYLE))
labels = data['beer_id']
del data['beer_id']
data = data.fillna(0)

########################
### Cross Validation ###
########################

kernels = ['linear', 'poly', 'rbf', 'sigmoid', 'precomputed']
degrees = [1,2,3,4,5]
cost = [0.01,0.1,1,10,100]

for k in kernels:
    for c in cost:
        if k == 'poly':
            for d in degrees:
                print("===== Kernel: %s, Cost: %f, Degree: %d ====="%(k, c, d))
                svc = svm.SVC(kernel=k, C=c, degree=d)
                fit = svc.fit(data, labels)
                score = svc.score(data, labels)
                print("Training Score: %f"%(score))
                print("Cross Validation Score: %f"%(cross_val(data, labels, 10, rounds, svc)))
        else:
                print("===== Kernel: %s, Cost: %f ====="%(k, c))
            svc = svm.SVC(kernel=k, C=c)
            fit = svc.fit(data, labels)
            score = svc.score(data, labels)
            print("Training Score: %f"%(score))
            print("Cross Validation Score: %f"%(cross_val(data, labels, 10, rounds, svc)))
