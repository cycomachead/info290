from __future__ import print_function

from sklearn import cluster, metrics
from numpy import recfromcsv
import numpy as np

from file_utils import reviewers

D = recfromcsv(reviewers(), delimiter='|')
D2 = np.array(D[["q4", "q5", "q6"]].tolist())

### Question 2
cluster_fits = {}
silhouettes = {}
def get_clustering(n, data):
    clusterer = cluster.KMeans(n_clusters = n)
    clustering = clusterer.fit(data)
    return clustering

for i in range(1, 9):
    try:
        clustering = get_clustering(i, D2)
        cluster_fits[i] = clustering
        m = metrics.silhouette_score(D2, clustering.labels_, metric='euclidean', sample_size = 500)
        silhouettes[i] = m
    except Exception as e:
        print(str(i) + " clusters had a problem:")
        print(e.message)


