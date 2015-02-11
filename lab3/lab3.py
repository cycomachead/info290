from __future__ import print_function

from sklearn import cluster, metrics
from numpy import recfromcsv
import numpy as np

#from file_utils import reviewers
import csv

### utility functions

def na_rm(data):
    return data[~np.isnan(data).any(axis=1)]

D = recfromcsv("yelp_reviewers.txt", delimiter='|')
D2 = np.array(D[["q4", "q5", "q6"]].tolist())
D3 = np.array(D[["q8", "q9", "q10"]].tolist())
D3 = na_rm(D3)
D4 = np.array(D[["q11", "q12", "q13"]].tolist())
D4 = na_rm(D4)

### Question 2
cluster_fits = {}
silhouettes = {}
def get_clustering(n, data):
    clusterer = cluster.KMeans(n_clusters = n)
    clustering = clusterer.fit(data)
    return clustering

def question2():
    with open('q2.feature', 'w+') as f:
        file_writer = csv.writer(f)
        file_writer.writerow(['num_clusters', 'silhouette_coeff'])
        for i in range(2, 9):
            try:
                clustering = get_clustering(i, D2)
                cluster_fits[i] = clustering
                m = metrics.silhouette_score(D2, clustering.labels_, metric='euclidean', sample_size = 10000)
                silhouettes[i] = m
                file_writer.writerow([i, m])
            except Exception as e:
                print(str(i) + " clusters had a problem:")
                print(e.message)

### Question 3
def question3():
    with open('q3.feature', 'w+') as f:
        file_writer = csv.writer(f)
        file_writer.writerow(['num_clusters', 'silhouette_coeff'])
        for i in range(2, 9):
            try:
                clustering = get_clustering(i, D3)
                cluster_fits[i] = clustering
                m = metrics.silhouette_score(D3, clustering.labels_, metric='euclidean', sample_size = 10000)
                silhouettes[i] = m
                file_writer.writerow([i, m])
            except Exception as e:
                print(str(i) + " clusters had a problem:")
                print(e.message)

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

#question2()
#question3()
#question4()
