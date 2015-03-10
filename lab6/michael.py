import numpy as np
import pandas as pd
from sklearn import ensemble

train = pd.read_csv("train.csv")
test = pd.read_csv("test.csv")

rf = ensemble.RandomForestClassifier()
# Convert Male / Female ==> 0 / 1
train = train.replace('male', 0)
train = train.replace('female', 1)
# Drop NaNs
train = train[np.isfinite(train['passenger_id'])]
train = train[np.isfinite(train['pclass'])]
train = train[np.isfinite(train['sex'])]
train = train[np.isfinite(train['age'])]
train = train[np.isfinite(train['sibsp'])]
train = train[np.isfinite(train['parch'])]
train = train[np.isfinite(train['fare'])]


modified = train.drop("survived", axis = 1)
modified = modified.drop("name", axis = 1)
modified = modified.drop("home.dest", axis = 1)
modified = modified.drop("embarked", axis = 1)
modified = modified.drop("cabin", axis = 1)
modified = modified.drop("ticket", axis = 1)





thing = rf.fit(modified, train[["survived"]])

print(thing)




