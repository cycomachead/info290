from __future__ import print_function

from sklearn import cluster, metrics
from numpy import recfromcsv
import numpy as np
from sklearn.preprocessing import normalize

import matplotlib.pyplot as plt

#from file_utils import reviewers
import csv

### utility functions

def which_na(data):
    return np.logical_or(np.isnan(data).any(axis=1), np.isinf(data).any(axis=1))

def na_rm(data):
    return data[~which_na(data)]


def returnNaNs(data):
    return [i for i in data if np.isnan(i)]

D = recfromcsv("../yelp_reviewers.txt", delimiter='|')
D["q17"] = np.log(D["q17"])
D2 = np.array(D[["q4", "q5", "q6"]].tolist())
D3 = np.array(D[["q8", "q9", "q10"]].tolist())
D3 = na_rm(D3)
D4 = np.array(D[["q11", "q12", "q13"]].tolist())
D4 = na_rm(D4)
D61 = np.array(D[["q8", "q9", "q10", "q11", "q12", "q13", "q16a", "q16b", "q16c", "q16d", "q16e", "q16f", "q16g", "q16h", "q16i", "q17", "q14"]].tolist())
D61 = na_rm(D61)
D6 = np.array([i[:-1] for i in D61])

D18 = np.array(D[['q8', 'q9', 'q10', 'q11', 'q12', 'q13',
                  'q18_group2', 'q18_group3', 'q18_group5', 'q18_group6',
                  'q18_group7', 'q18_group11', 'q18_group13', 'q18_group14',
                  'q18_group15', 'q18_group16_a', 'q18_group16_b',
                  'q18_group16_c', 'q18_group16_d', 'q18_group16_e',
                  'q18_group16_f', 'q18_group16_g', 'q18_group16_h']].tolist())


def get_clustering(n, data):
    clusterer = cluster.KMeans(n_clusters = n)
    clustering = clusterer.fit(data)
    return clustering



### Question 5
# cool, funny, useful
best_clustering = get_clustering(8, D4)
# a
for i in range(8):
   print("C%i: %i"%(i, np.sum(best_clustering.labels_ == i)))

# b
print(best_clustering.cluster_centers_)
# the fifth cluster has a much higher funny rating than useful rating

# c
# the sixth cluster has the most evenly distributed votes
print(np.sum(best_clustering.labels_ == 5))
