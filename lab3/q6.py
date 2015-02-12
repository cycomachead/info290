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

D = recfromcsv("yelp_reviewers.txt", delimiter='|')
D["q17"] = np.log(D["q17"])

D61 = np.array(D[["q8", "q9", "q10", "q11", "q12", "q13", "q16a", "q16b", "q16c", "q16d", "q16e", "q16f", "q16g", "q16h", "q16i", "q17", "q14"]].tolist())
D61 = na_rm(D61)
D6 = np.array([i[:-1] for i in D61])

def question6():
    with open('q6.feature', 'w+') as f:
        file_writer = csv.writer(f)
        file_writer.writerow(['num_clusters', 'silhouette_coeff'])
        try:
            clustering = get_clustering(5, D6)
            cluster_fits[5] = clustering
            for i in range(5):
                print("C%i: %f"%(i+1, np.mean([D61[j][-1] for j in range(len(D61)) if clustering.labels_[j] == i])))
            m = metrics.silhouette_score(D6, clustering.labels_, metric='euclidean', sample_size = 10000)
            silhouettes[5] = m
            file_writer.writerow([5, m])
        except Exception as e:
            print(str(5) + " clusters had a problem:")
            print(e.message)

question6()
