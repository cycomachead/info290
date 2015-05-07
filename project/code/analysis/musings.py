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

def nullColumns(fileHeaders, allKeys):
    """
    Return a set of column names that don't exist in the file.
    """
    pass

def walkDir(base):
    """
    Generate a single list of all the files in a directory
    DFS, and include the full path relative to base.

    """
    files = list(os.walk(base))
    files = files[1:]
    files = reduce(lambda x,y: x + y)
    files = filter(lambda x: x.find('.txt') != -1, file)
    return files

def makeNormalizedCSV(data, mewCol):
    pass

def keysUnion(data):
    """
    Data is a list of dictionary. Return the union of all keys.
    """
    return set(reduce(lambda x, y: x + y,
                  map(lambda d: d.keys, data) ) )


def writeCSV(name, data):
    pass

def doWordCount(files):
    """

    """
    for file in files:
        data = parseCSV(file)
        cols = keysUnion(data)
        data = makeNormalizedCSV(data, cols)
        out = file.replace('data', 'processed')
        writeCSV(out, data)

def normalizeFiles(files):
    """

    """
    pass

if __name__ == '__main__':
    files = walkDir(INPUT)
    doWordCount(files)
    out = walkDir(OUTPUT)
    normalizeFiles(out)

    # For each new CSV
    # append columns to normalize
