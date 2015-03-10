import numpy as np
import pandas as pd
import neurolab as nl

train = pd.read_csv("lab5_train.csv", quotechar = '"')
test = pd.read_csv("lab5_test.csv", quotechar = '"')

# question 1
def question1():
    maj_class = "Obama" if np.mean(train.CAND_ID == "Obama") > 0.5 else "Romney"
    baseline_train_accuracy = np.mean(train.CAND_ID == maj_class)
    baseline_test_accuracy = np.mean(test.CAND_ID == maj_class)
    print(baseline_train_accuracy)
    print(baseline_test_accuracy)

# question 2
train.CAND_ID = (train.CAND_ID == "Romney").astype('int')
test.CAND_ID = (test.CAND_ID == "Romney").astype('int')

def question2train(goal):
    """ Training the neural net can take a long time, so we save the output for later.
    Also, it may be useful to look into changing the error tolerance. """
    net = nl.net.newff([[np.min(train.TRANSACTION_AMT), np.max(train.TRANSACTION_AMT)]], [10, 1])
    err = net.train(train.loc[:,["TRANSACTION_AMT"]], train.loc[:,["CAND_ID"]], show = 1, goal = goal, epochs = 20)
    net.save("question2NN.net")
    return net

def question2load():
    return(nl.load("question2NN.net"))

def question2(retrain = False, goal = 0.1):
    if retrain:
        return question2train(goal)
    return question2load()

net = question2(retrain = True, goal = 0.1)

q2_train_error = np.mean(np.round(net.sim(train.loc[:,["TRANSACTION_AMT"]])[:,0]) == train.CAND_ID)
q2_test_error = np.mean(np.round(net.sim(test.loc[:,["TRANSACTION_AMT"]])[:,0]) == test.CAND_ID)





