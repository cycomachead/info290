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


def pctNaN(col):
    return len(returnNaNs(col))/len(col)

q7c = None
def question7(data):
    global q7c
    i = 0
    realCol = 0
    while i < data.shape[1]:
        row = data[:, i]
        pct = pctNaN(row)
        print(pct)
        if pct > 0.35:
            # The last 1 specifies to delete a column not a row
            print(str.format('Deleting column {0}, w/ {1} NaN values', realCol, round(pct * 100)))
            data = np.delete(data, i, 1)
        else:
            i += 1
        realCol += 1
    print(realCol)
    print(data.shape)
    data = na_rm(data)
    print(data.shape)
    with open('q7b.feature', 'w+') as f:
        file_writer = csv.writer(f)
        file_writer.writerow(['num_clusters', 'sum_win_var_clust'])
        for i in range(2, 9):
            try:
                clustering = get_clustering(i, data)
                cluster_fits[i] = clustering
                values = {}
                sums = {}
                for j in range(i):
                    values[j] = data[cluster_fits[i].labels_ == j,:]
                    mean = sum(values[j])/len(values[j])
                    iterim = map(lambda x: (x-mean)**2, values[j])
                    ssd  = sum(iterim)
                    if i in sums:
                        sums[i] += [ssd]
                    else:
                        print('new item arr ', i)
                        sums[i] = [ssd]
                print('I: ', i, ' Len of Sums: ', len(sums[i]))
                print('SUM: ', sums[i])
                file_writer.writerow([i, sum(sum(sums[i]))])
            except Exception as e:
                print(str(i) + " clusters had a problem:")
                print(e)

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
        q7c = cluster_fits

### Question 5
# cool, funny, useful
# best_clustering = get_clustering(8, D4)
# a
# for i in range(8):
#    print("C%i: %i"%(i, np.sum(best_clustering.labels_ == i)))

# b
# print(best_clustering.cluster_centers_)
# the fifth cluster has a much higher funny rating than useful rating

# c
# the sixth cluster has the most evenly distributed votes
    # print(np.sum(best_clustering.labels_ == 5))


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

#question2()
#question3()
#question4()
#question6()
question7(D18)
