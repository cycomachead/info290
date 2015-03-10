import numpy as np
import pandas as pd
from sklearn import ensemble

train = pd.read_csv("train.csv")
test = pd.read_csv("test.csv")

rf = ensemble.RandomForestClassifier()
modified = train.drop("survived", axis = 1)
modified = modified.drop("name", axis = 1)
modified = modified.drop("home.dest", axis = 1)
modified = modified.drop("embarked", axis = 1)
modified = modified.drop("cabin", axis = 1)
modified = modified.drop("ticket", axis = 1)
# Convert Male / Female ==> 0 / 1
modified = modified.replace('male', 0)
modified = modified.replace('female', 1)

rf.fit(modified, train[["survived"]])

print(rf)




