from sklearn import cluster, metrics
from numpy import recfromcsv
import numpy as np

D = recfromcsv('yelp_reviewers.txt', delimiter='|')
D2 = np.array(D[["q4", "q5", "q6"]].tolist())

### Question 2
cluster_fits = {}
def get_clustering(n):
    clusterer = cluster.KMeans(n_clusters = 3)
    clustering = clusterer.fit(D2)
    m = metrics.silhouette_score(D2, clustering.labels_, metric='euclidean', sample_size = 500)
    return [clustering, m]

for i in range(1, 9):
    try:
        cluster_fits[i] = get_clustering(i)
    except Exception as e:
        print str(i) + " clusters had a problem:"
        print e.message


