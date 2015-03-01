
# coding: utf-8

# # Lab 4- Decision Trees

# This assignment uses 2012 data obtained from the Federal Election Commission on contributions to candidates from committees. The data dictionary is available at http://www.fec.gov/finance/disclosure/metadata/DataDictionaryContributionstoCandidates.shtml. The file we've given you has been subset to 10,000 randomly sampled rows, wth some columns removed

# In[48]:

from __future__ import division, print_function
from collections import Counter, defaultdict
from itertools import combinations 
import pandas as pd
import numpy as np
import itertools


# In[49]:

import sklearn
from sklearn.tree import DecisionTreeClassifier
from sklearn.feature_extraction import DictVectorizer #to turn categorial variables into numeric arrays
from sklearn import preprocessing #to transform the feature labels
from sklearn.feature_extraction import DictVectorizer


# In[50]:

df = pd.read_csv('lab4_candidate_contributions.csv')

#convert zip code and transaction date from floats to strings (since we wnat to treat them as categorical)
df.ZIP_CODE = df.ZIP_CODE.astype('int').astype('str')
df.TRANSACTION_DT = df.TRANSACTION_DT.astype('int').astype('str')

df.head()


# In[ ]:




# ## Calculating Gini Index

# 
# 
# **Question 1: How many rows are there in the dataset for Obama? For Romney? **
# 
# 

# In[51]:

obama = 0
romney = 0
for i in range(df.CAND_ID.size):
    if df.CAND_ID.get_value(i) == "Obama":
        obama += 1
    else:
        romney += 1
print("Obama: %d, Romney: %d"%(obama, romney))


# **Question 2: What is the Gini Index of the this dataset, using Romney and Obama as the target classes?**

# In[52]:

def gini(D):
    obama = sum(D.CAND_ID == "Obama")
    romney = sum(D.CAND_ID == "Romney")
    total = obama+romney
    return 1-((obama/total)**2+(romney/total)**2)
    
print("gini index: %f"%gini(df))


# ## Best Split of a Numeric Feature

# In[53]:

sortd = df.sort(columns="TRANSACTION_AMT")
mingini = 1
mini = 0
ob1 = 0
ob2 = sum(df.CAND_ID == "Obama")
ro1 = 0
ro2 = sum(df.CAND_ID == "Romney")
total = ob2+ro2
for i in range(df.CAND_ID.size-1):
    if sortd.CAND_ID.get_value(i) == "Obama":
        ob1 += 1
        ob2 -= 1
    else:
        ro1 += 1
        ro2 -= 1
    low = df.TRANSACTION_AMT.get_value(i)
    high = df.TRANSACTION_AMT.get_value(i+1)
    if low != high:
        tot1 = ob1+ro1
        tot2 = ob2+ro2
        gini1 = 1-((ob1/tot1)**2+(ro1/tot1)**2)
        gini2 = 1-((ob2/tot2)**2+(ro2/tot2)**2)
        ginit = gini1*((ob1+ro1)/total) + gini2*((ob2+ro2)/total)
        if ginit < mingini:
            mini = i
            mingini = ginit
            minob1 = ob1
            minob2 = ob2
            minro1 = ro1
            minro2 = ro2

print("split after: %d, gini score: %f, gini reduced by: %f, Obama below: %d, Obama above: %d, Romney below: %d, Romney above: %d"%(mini, mingini, (gini(df)-mingini), minob1, minob2, minro1, minro2))


# **Question 3: What is the best split point of the TRANSACTION_AMT feature. **

# In[54]:

mini


# **Question 4: What is the Gini Index of this best split?**

# In[55]:

mingini


# **Question 5: How much does this partitioning reduce the Gini Index over that of the overall dataset?**

# In[56]:

(gini(df)-mingini)


# **Question 6: How many Romney rows are below your best split point? Obama rows?**

# In[57]:

print("Romney Rows: ", minro1)
print("Obama Rows:", minob1)


# **Question 7: How many Romney rows are above your best split point? Obama rows?**

# Recall that, to calculate the best split of this numeric field, you'll need to order your data by TRANSACTION AMT, then consider the midpoint between each pair of consecutive transaction amounts as a potential split point, then calculate the Gini Index for that partitioning. You'll want to keep track of the best split point and its Gini Index (remember that you are trying to minimize the Gini Index). 
# 
# There are a lot of ways to do this. Some are very fast, others very slow. One tip to make this run quickly is, as you consecutively step through the data and calculate the Gini Index of each possible split point, keep a running total of the number of rows for each candidate that are located above and below the split point. 
# 
# Some Python tips: 
# 
# * Counter(), from the collections module, is a special dictionary for counting values of a key
# * zip() lets you concatenate lists into a list of tuples (for example, if we have a list of the candidates and a list of transaction amounts, zip(candidate_list, transaction_amount) would give us a list of (candidate, transaction amount) pairs

# In[58]:

sortd = df.sort(columns="TRANSACTION_AMT")
mingini = 1
mini = 0
ob1 = 0
ob2 = sum(df.CAND_ID == "Obama")
ro1 = 0
ro2 = sum(df.CAND_ID == "Romney")
total = ob2+ro2
for i in range(df.CAND_ID.size-1):
    if sortd.CAND_ID.get_value(i) == "Obama":
        ob1 += 1
        ob2 -= 1
    else:
        ro1 += 1
        ro2 -= 1
    low = df.TRANSACTION_AMT.get_value(i)
    high = df.TRANSACTION_AMT.get_value(i+1)
    if low != high:
        tot1 = ob1+ro1
        tot2 = ob2+ro2
        gini1 = 1-((ob1/tot1)**2+(ro1/tot1)**2)
        gini2 = 1-((ob2/tot2)**2+(ro2/tot2)**2)
        ginit = gini1*((ob1+ro1)/total) + gini2*((ob2+ro2)/total)
        if ginit < mingini:
            mini = i
            mingini = ginit
            minob1 = ob1
            minob2 = ob2
            minro1 = ro1
            minro2 = ro2

print("split after: %d, gini score: %f, gini reduced by: %f, Obama below: %d, Obama above: %d, Romney below: %d, Romney above: %d"%(mini, mingini, (gini(df)-mingini), minob1, minob2, minro1, minro2))


# ## Best Split of a Categorial Variable

# In[59]:

import functools
# question 8
entity_vals = pd.unique(df["ENTITY_TP"])
combinations = functools.reduce(lambda x,y: x+y, [list(itertools.combinations(entity_vals, r)) for r in range(1, len(entity_vals)//2 + 1)])

# question 9
mingini = 1
mincomb = None
for comb in combinations:
    indices = df["ENTITY_TP"].isin(comb)
    split1 = df.loc[indices,:]
    split2 = df.loc[~indices,:]
    cur_gini = (len(split1) * gini(split1) + len(split2) * gini(split2)) / len(df)
    if cur_gini < mingini:
        mingini = cur_gini
        mincomb = comb
        min_split1 = split1
        min_split2 = split2
    
    #print "%d, %d"%(len(split1), len(split2))



# **Question 8: How many possible splits are there of the ENTITY_TP feature?**

# In[60]:

len(combinations)
# (2**7 - 2) / 2 (because we optimize by throwing out half)


# **Question 9: Which split of ENTITY_TP best splits the Obama and Romney rows, as measured by the Gini Index?**

# In[61]:

# question 9
mincomb


# **Question 10: What is the Gini Index of this best split?**

# In[62]:

# question 10
mingini


# **Question 11: How much does this partitioning reduce the Gini Index over that of the overall data set?**

# In[63]:

# question 11
gini(df) - mingini


# **Question 12: How many Romney rows and Obama rows are in your first partition? How many Romney rows and Obama rows are in your second partition?**

# In[64]:

# question 12
print("Romney: %s, Obama: %s"%(sum(min_split1.CAND_ID == "Romney"), sum(min_split1.CAND_ID == "Obama")))
print("Romney: %s, Obama: %s"%(sum(min_split2.CAND_ID == "Romney"), sum(min_split2.CAND_ID == "Obama")))


# In this exercise, you will be partitioning the original dataset (as opposed to further partitioning the transaction amount partitions from the previous set of questions).
# 
# Python tip: the combinations function of the itertools module allows you to enumerate combinations of a list

# ## Training a decision tree

# **Question 13: Using all of the features in the original dataframe read in at the top of this notebook, train a decision tree classifier that has a depth of three (including the root node and leaf nodes). What is the accuracy of this classifier on the training data?**

# In[65]:

from random import sample
def trainingSample(n, size):
    rows = sample(range(n), size)
    return rows

def separateRows(training_rows, data):
    """ Return (training set, prediction set) with n% of rows in training set"""
    training = data.ix[training_rows]
    prediction = data.drop(training_rows)
    return (training, prediction)


# In[66]:

from datetime import datetime
from sklearn import preprocessing
from sklearn.feature_extraction import DictVectorizer

classifier = DecisionTreeClassifier(criterion='gini', splitter='best', max_depth=3, min_samples_split=2, min_samples_leaf=1, max_features=None, random_state=None, min_density=None, compute_importances=None, max_leaf_nodes=None)
df_new = df.copy()
df_new.TRANSACTION_DT = df_new.TRANSACTION_DT.apply(lambda x: x if len(x) == 8 else "0" + x)
df_new.TRANSACTION_DT = df_new.TRANSACTION_DT.apply(lambda x: datetime.strptime(x, "%m%d%Y").toordinal())

CAND_ID = df_new.CAND_ID
X = df_new.drop("CAND_ID", axis = 1)

vec = DictVectorizer()
X = pd.DataFrame(vec.fit_transform(X.to_dict("records")).toarray())
X.columns = vec.get_feature_names()

train_size = 0.75
training_rows = trainingSample(X.shape[0], int(train_size * X.shape[0]))
train_rows, pred_rows = separateRows(training_rows, X)
train_Y, pred_Y = separateRows(training_rows, CAND_ID)


train_Y = train_Y == 'Obama'
train_Y = train_Y.astype(int)
pred_Y = pred_Y == 'Obama'
pred_Y = pred_Y.astype(int)



# In[67]:

clf = classifier.fit(train_rows, train_Y)


# In[68]:

classifier.score(train_rows, train_Y)


# In[69]:

classifier.score(pred_rows, pred_Y)


# 

# **Question 14: Export your decision tree to graphviz. Please submit a png file of this graphic to bcourses. In your write-up, write down the interpretation of the rule at each node (for example, 'Root node: rows from state AL go the the left, rows from all other states go to the right. Left child of root node: ... etc**

# In[70]:

from sklearn.externals.six import StringIO
with open("obama_romney.dot", 'w') as f:
    f = sklearn.tree.export_graphviz(clf, out_file=f)


# In[71]:

print(train_rows.columns[2768])
print(train_rows.columns[7])
print(train_rows.columns[745])
print(train_rows.columns[706])
print(train_rows.columns[810])
print(train_rows.columns[2745])


# The topmost split depends on the date of the contribution. The next highest are whether a contribution was from Akron, and whether CMTE_ID equals C90011156 (which we think has to do with who the contributor is). The final row splits on whether CMTE_ID equals C00521013, whether the donor is an individual, and whether the state is North Carolina.

# **Question 15: For each of your leaf nodes, specify the percentage of Obama rows in that node (out of the total number of rows at that node).**

# In[72]:

print(3419 / (3079 + 3419))
print(135 / (0 + 135))
print(75 / (56 + 75))
print(68/ (1 + 68))
print(364 / (17 + 364))
print(9 / (7 + 9))


# See this notebook for the basics of training a decision tree in scikit-learn and exporting the outputs to view in graphviz: http://nbviewer.ipython.org/gist/tebarkley/b68c04d9b31e64ce6023
# 
# Scikit-learn classifiers require class labels and features to be in numeric arrays. As such, you will need to turn your categorical features into numeric arrays using DictVectorizer. This is a helpful notebook for understanding how to do this: http://nbviewer.ipython.org/gist/sarguido/7423289. You can turn a pandas dataframe of features into a dictionary of the form needed by DictVectorizer by using df.to_dict('records'). Make sure you remove the class label first (in this case, CAND_ID). If you use the class label as a feature, your classifier will have a training accuracy of 100%! The example notebook link also shows how to turn your class labels into a numeric array using sklearn.preprocessing.LabelEncoder().
# 
# We already did this for you at the top of the notebook, but before you convert your features into numeric arrays, you should always make sure they are of the correct type (ie zip code should be a string, not a float, because it is a categorical variable). 
# 
# Question 14 asks you to interpret the rules at each decision tree node using the graphviz output. The graphviz output looks cryptic (ie it might tell you that X[1014] < 0.5 is the best split for a particular node. To figure out what feature that corresponds to, use the .get_feature_names() function of your DictVectorizer object. If that returns something like 'CITY=PHOENIX', then you know that the left child of the node contains rows not in Phoenix ('CITY=PHOENIX' ==0) and the right child of the node contains rows in Phoenix ('CITY=PHOENIX' == 1).

# In[162]:



