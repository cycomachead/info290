import numpy as np
import pandas as pd
from sklearn import ensemble

train = pd.read_csv("train.csv")
test = pd.read_csv("test.csv")

rf = ensemble.RandomForestClassifier()
rf.fit(train.drop("survived", axis = 1), train[["survived"]])



