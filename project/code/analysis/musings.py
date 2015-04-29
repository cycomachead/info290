#! /usr/bin/env python3

"""
To be run from code/analysis


"""

import sys
import os
import csv
import re
from collections import Counter
from string import punctuation

INPUT = '../../data/'
# Assume the damn directory exists.
OUTPUT = '../../processed/'
RESULTS = 'word-freq-review/'

# review column in CSV
REVIEW_HEADER = 'review_text'

# Contains all the words ever found while processing the data.
GLOBAL_WORDS_SET = set()


def normalizeString(string):
    """
    - Lowercase a string
    - remove punctuation
    - ?
    """
    string = string.lower()
    for char in punctuation:
        string = string.replace(char, '')
    return string

def wordCount(string):
    string = normalizeString(string)
    tokens = re.splist('\s+', string)
    return Counter(tokens)

def addWords(lst):
    """
    Add a a bunch of new words to the global
    """
    global GLOBAL_WORDS_SET
    GLOBAL_WORDS_SET |= set(lst)

def parseCSV(fileName):
    reviews = []
    with open(fileName, 'r+') as file:
        beer_data = csv.reader(file)
        header = next(beer_data)
        col = header.index(REVIEW_HEADER)
        for row in beer_data:
            text = row[col]
            data = wordCount(normalize(text))
            addWords(data.keys())
            reviews.append(data)
    return reviews

if __name__ == '__main__':
    # Iterate over data directory
        # parse review in each beer
        # write new CSV
    # For each new CSV
        # append columns to normalize
