from __future__ import print_function

from sklearn import cluster, metrics
from numpy import recfromcsv
import numpy as np

#from file_utils import reviewers
import csv

### utility functions

def na_rm(data):
    return data[~np.isnan(data).any(axis=1)]

def returnNaNs(data):
    return [i for i in data if np.isnan(i)]

cluster_fits = {}
silhouettes = {}
def get_clustering(n, data):
    clusterer = cluster.KMeans(n_clusters = n)
    clustering = clusterer.fit(data)
    return clustering

D = recfromcsv("yelp_reviewers.txt", delimiter='|')
D4 = np.array(D[["q11", "q12", "q13"]].tolist())
D4 = na_rm(D4)

def question4():
    with open('q4.feature', 'w+') as f:
        file_writer = csv.writer(f)
        file_writer.writerow(['num_clusters', 'silhouette_coeff'])
        for i in range(2, 9):
            try:
                clustering = get_clustering(i, D4)
                cluster_fits[i] = clustering
                m = metrics.silhouette_score(D4, clustering.labels_, metric='euclidean', sample_size = 10000)
                silhouettes[i] = m
                file_writer.writerow([i, m])
            except Exception as e:
                print(str(i) + " clusters had a problem:")
                print(e.message)

question4()
