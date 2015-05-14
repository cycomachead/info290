from pandas import *
from sklearn.ensemble import RandomForestClassifier
import numpy as np
import random

STYLE = "American_Brown_Ale"

""" Performs cross validation on data using random forest
    Returns the average score.
    Percent is the percentage of data to use as validation,
    this should be an integer, not a decimal.
    Rounds is the number of rounds of cv to run.
"""
def cross_val(data, labels, percent, rounds, rf):
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
        fit_cv = rf.fit(train_data, train_labels)

        # calculate score
        score_cv = rf.score(test_data, test_labels)
        scores.append(score_cv)

    return sum(scores)/len(scores)

def topX(l, n, c):
    tops = {}
    for i in range(n):
        ind = l.index(max(l))
        tops[c[ind]] = l[ind]
        l[ind] = 0
    return tops

def cross_val_topX(data, labels, percent, rounds, rf, x):
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
        fit_cv = rf.fit(train_data, train_labels)

        # calculate score
        probs = rf.predict_proba(test_data)
        classes = rf.classes_

        tally = 0
        j = 0
        for k in test_labels.iteritems():
            tops = topX(list(probs[j]), x, classes)
            if k[1] in tops.keys():
                tally += 1
            j += 1
        scores.append(float(tally)/float(len(test_labels)))

    return sum(scores)/len(scores)

data = read_pickle("./%s.pkl"%(STYLE))
labels = data['beer_id']
del data['beer_id']
data = data.fillna(0)

########################
### Cross Validation ###
########################

"""
criterion = ["gini", "entropy"]
trees = [10,20,50]
samples = [20,50,100,500]
rounds = 10

for c in criterion:
    for t in trees:
        for s in samples:
            print("===== Criterion: %s, Trees: %d, Samples/Leaf: %d ====="%(c, t, s))
            rf = RandomForestClassifier(criterion=c, n_estimators=t, min_samples_split=s)
            fit = rf.fit(data, labels)
            score = rf.score(data, labels)
            print("Training Score: %f"%(score))
            print("Cross Validation Score: %f"%(cross_val(data, labels, 10, rounds, rf)))
"""

rf = RandomForestClassifier(criterion="gini", n_estimators=50, min_samples_split=50)
score = cross_val_topX(data, labels, 10, 5, rf, 10)
