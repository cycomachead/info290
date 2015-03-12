import numpy as np
import pandas as pd
from sklearn import ensemble
from sklearn import svm

train = pd.read_csv("train.csv", header=0)
test = pd.read_csv("test.csv", header=0)
train2 = train.copy()
train2 = train2.drop("passenger_id", 1)
train2 = train2.drop("survived", 1)
train2 = train2.drop("name", 1)
train2 = train2.drop("ticket", 1)
train2 = train2.drop("embarked", 1)
train2 = train2.drop("home.dest", 1)
train2 = train2.drop("cabin", 1)
train2 = train2.replace(to_replace="female", value=0)
train2 = train2.replace(to_replace="male", value=1)

test = test.drop("passenger_id", 1)
test = test.drop("name", 1)
test = test.drop("ticket", 1)
test = test.drop("embarked", 1)
test = test.drop("home.dest", 1)
test = test.drop("cabin", 1)
test = test.replace(to_replace="female", value=0)
test = test.replace(to_replace="male", value=1)

train2 = train2.fillna(train2.mean())
test = test.fillna(test.mean())

dec = svm.SVC()
dec.fit(train2, train.get("survived"))

for index, row in test.iterrows():
    print "%s,\"%s\""%(index+785, dec.predict(row)[0])
