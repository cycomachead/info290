import numpy as np
import pandas as pd
from sklearn import ensemble

train = pd.read_csv("train.csv")
torig = pd.read_csv("test.csv")
test = pd.read_csv("test.csv")

rf = ensemble.RandomForestClassifier()
# Convert Male / Female ==> 0 / 1
train = train.replace('male', 0)
train = train.replace('female', 1)

test = test.replace('male', 0)
test = test.replace('female', 1)
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


# # Drop NaNses
test = test[np.isfinite(test['passenger_id'])]
test = test[np.isfinite(test['pclass'])]
test = test[np.isfinite(test['sex'])]
test = test[np.isfinite(test['age'])]
test = test[np.isfinite(test['sibsp'])]
test = test[np.isfinite(test['parch'])]
test = test[np.isfinite(test['fare'])]

test = test.drop("name", axis = 1)
test = test.drop("home.dest", axis = 1)
test = test.drop("embarked", axis = 1)
test = test.drop("cabin", axis = 1)
test = test.drop("ticket", axis = 1)


thing = rf.fit(modified, train[["survived"]])

tested = thing.predict(test[np.isfinite(test)])

file = 'submissions/test_predict_michael_dumb_3_10_15.csv'

data = [test['passenger_id'], tested]
rows = torig.shape[0]
pids = torig[[0]]['passenger_id']
guess = int(round(np.average(tested)))
with open(file, 'w+') as f:
    f.write('"passenger_id","survived"\n')
    counter = 0
    for pos in range(0, rows):
        line = str(pids[pos]) + ',"'
        if pos in data[0]:
            line += str(data[1][counter]) + '"\n'
            counter += 1
        else:
            line += str(guess) + '"\n'
        print('writing....')
        f.write(line)


print(thing)




