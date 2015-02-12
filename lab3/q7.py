from __future__ import print_function

from sklearn import cluster, metrics
from numpy import recfromcsv
import numpy as np

#from file_utils import reviewers
import csv

### utility functions

def na_rm(data):
    data = data[~np.isnan(data).any(axis=1)]
    return data[~np.isinf(data).any(axis=1)]

def returnNaNs(data):
    return [i for i in data if np.isnan(i)]

D = recfromcsv("../yelp_reviewers.txt", delimiter='|')

D7 = np.array(D[['q8', 'q9', 'q10', 'q11', 'q12', 'q13',
                  'q18_group2', 'q18_group3', 'q18_group5', 'q18_group6',
                  'q18_group7', 'q18_group11', 'q18_group13', 'q18_group14',
                  'q18_group15', 'q18_group16_a', 'q18_group16_b',
                  'q18_group16_c', 'q18_group16_d', 'q18_group16_e',
                  'q18_group16_f', 'q18_group16_g', 'q18_group16_h']].tolist())

def get_clustering(n, data):
    clusterer = cluster.KMeans(n_clusters = n)
    clustering = clusterer.fit(data)
    return clustering

def pctNaN(col):
    return len(returnNaNs(col))/len(col)

def preprocess(data):
    i = 0
    realCol = 0
    while i < data.shape[1]:
        row = data[:, i]
        pct = pctNaN(row)
        if pct > 0.50:
            # The last 1 specifies to delete a column not a row
            data = np.delete(data, i, 1)
        else:
            i += 1
        realCol += 1
    return na_rm(data)

def question7b(data):
    with open('q7b.feature', 'w+') as f:
        file_writer = csv.writer(f)
        file_writer.writerow(['num_clusters', 'sum_win_var_clust'])
        for i in range(2, 9):
            try:
                clustering = get_clustering(i, data)
                file_writer.writerow([i, clustering.inertia_])
            except Exception as e:
                print(str(i) + " clusters had a problem:")
                print(e)

def question7a(data):
    with open('q7a.feature', 'w+') as f:
        file_writer = csv.writer(f)
        file_writer.writerow(['num_clusters', 'silhouette_coeff'])
        for i in range(2, 9):
            try:
                clustering = get_clustering(i, data)
                cluster_fits[i] = clustering
                m = metrics.silhouette_score(data, clustering.labels_, metric='euclidean', sample_size = 10000)
                silhouettes[i] = m
                file_writer.writerow([i, m])
            except Exception as e:
                print(str(i) + " clusters had a problem:")
                print(e)

D7 = preprocess(D7)
question7a(D7)
question7b(D7)
