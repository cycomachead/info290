from pandas import *
from sklearn.ensemble import RandomForestClassifier
import numpy as np
import random

STYLE = "American_Pale_Ale_(APA)"

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

data = read_pickle("./%s.pkl"%(STYLE))
labels = data['beer_id']
del data['beer_id']
data = data.fillna(0)

###########################
### Basic Random Forest ###
###########################

rf = RandomForestClassifier()
fit = rf.fit(data, labels)
score = rf.score(data, labels)

########################
### Cross Validation ###
########################

criterion = ["gini", "entropy"]
trees = [2,5,10,20,50]
samples = [2,10,20,50,100]
percents = [1,2,5,10,15,20,25]
rounds = 10

for c in criterion:
    for t in trees:
        for s in samples:
            print("===== Criterion: %s, Trees: %d, Samples/Leaf: %d ====="%(c, t, s))
            rf = RandomForestClassifier(criterion=c, n_estimators=t, min_samples_split=s)
            for percent in percents:
                print("Cross Validation Score (%d%%): %f"%(percent, cross_val(data, labels, percent, rounds, rf)))

