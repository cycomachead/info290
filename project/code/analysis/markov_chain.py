import pandas as pd
import numpy as np
from collections import defaultdict
from functools import reduce
from operator import add
import os

folder = "../../data/American_Adjunct_Lager/"
files = os.listdir(folder)
review_text = []
for f in files:
    print f
    if f.endswith(".txt"):
        print "skipping..."
        continue
    reviews_current = pd.read_csv(folder + f, quotechar = '"')
    review_text_current = reviews_current["review_text"]
    review_text_current = review_text_current[pd.notnull(review_text_current)]
    #review_text_current = filter(lambda x: x.strip() != "", reduce(add, map(lambda x: x.split("."), review_text_current)))
    review_text_current = ["BEGIN NOW " + t + " END" for t in review_text_current]
    review_text += review_text_current



def get_trigrams(line):
    trig = []
    line = line.split()
    for i in range(len(line) - 2):
        trig.append(tuple(line[i:(i+3)]))
    return trig

chain = {}

for rev in review_text:
    trigrams = get_trigrams(rev)
    for trig in trigrams:
        start = trig[:-1]
        end = trig[-1]
        if start not in chain:
            chain[start] = defaultdict(lambda: 0.0)
        chain[start][end] += 1


def get_sentence(chain):
    word1 = "BEGIN"
    word2 = "NOW"
    sent = []

    while (word2 != "END"):
        current = chain[(word1, word2)]
        word1, word2 = word2, np.random.choice(current.keys(), p = np.array(current.values()) / sum(current.values()))
        sent.append(word1)

    return ' '.join(sent[1:])
