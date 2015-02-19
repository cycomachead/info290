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


### Question 8

#D8 = np.array(D[['q3', 'q6', 'q17', 'q18_group6', 'q18_group7', 'q18_group14']].tolist())
#D8[:,1] = D8[:,1] / D8[:,0] # make this useful votes per review
D8 = np.array(D[['q3', 'q18_group7']].tolist())
D8 = na_rm(D8)

cluster_fits = {}
silhouettes = {}
for i in range(2, 9):
    try:
        clustering = get_clustering(i, D8)
        cluster_fits[i] = clustering
        m = metrics.silhouette_score(D8, clustering.labels_, metric='euclidean', sample_size = 500)
        silhouettes[i] = m
    except Exception as e:
        print(str(i) + " clusters had a problem:")
        print(e.message)

best_clust = get_clustering(2, D8)

D['q4'] = D['q4'] / D['q3']
D['q5'] = D['q5'] / D['q3']
D['q6'] = D['q6'] / D['q3']

D_filtered = D[~which_na(D8),:]
C0 = D_filtered[best_clust.labels_ == 0,:]
C1 = D_filtered[best_clust.labels_ == 1,:]

# plotting 
plt.scatter(D['q3'], D['q18_group7'], c = best_clust.labels_)
plt.scatter(best_clust.cluster_centers_[:,0], best_clust.cluster_centers_[:,1], c = "green")
plt.title("Clustering of Num. Reviews and Time Between Reviews")
plt.xlabel("Number of Reviews")
plt.ylabel("Average Time Between Reviews")
plt.show()


for name in D.dtype.names[1:]:
    current0 = C0[name]
    current1 = C1[name]
    m1 = np.mean(current0[~np.isnan(current0)])
    m2 = np.mean(current1[~np.isnan(current1)])
    print("%s: cluster0: %f    cluster1: %f"%(name, m1, m2))