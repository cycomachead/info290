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
from functools import reduce

INPUT = '../../data/'
# Assume the damn directory exists.
OUTPUT = '../../processed/'
RESULTS = 'word-freq-review/'

# review column in CSV
REVIEW_HEADER = 'review_text'

# Contains all the words ever found while processing the data.
GLOBAL_WORDS_SET = set()

# Array of common words to filter from a review text.
COMMON = []

def getCommonWords():
    global COMMON
    # Filter whitespace and empty string
    COMMON.append(' ')
    COMMON.append('')
    file = 'common-english-words.txt'
    with open(file, 'r') as f:
        words = f.read()
    words = words.split(',')
    COMMON += words
    return True


def normalizeString(string):
    """
    - Lowercase a string
    - remove punctuation
    - filter common english words.
    """
    string = string.lower()
    for char in punctuation:
        string = string.replace(char, '')
    return string

def wordCount(string):
    global COMMON
    string = normalizeString(string)
    tokens = re.split('\s+', string)
    tokens = filter(lambda w: w not in COMMON, tokens)
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
            print(text)
            data = wordCount(text)
            print(data)
            addWords(data.keys())
            reviews.append(data)
            print(reviews)
    return reviews

def nullColumns(fileHeaders, allKeys):
    """
    Return a set of column names that don't exist in the file.
    """
    s1 = set(fileHeaders)
    s2 = set(allKeys)
    return s2.difference(s1)

def walkDir(base):
    """
    Generate a single list of all the files in a directory
    DFS, and include the full path relative to base.

    """
    files = list(os.walk(base))
    files = files[1:]
    paths = []
    for group in files:
        for f in group[2]:
            paths.append(group[0] + '/' + f)
    paths = list(filter(lambda x: x.find('.txt') == -1, paths))
    return paths

def makeNormalizedData(data, newCol, defaultVal = 0):
    """
    Ensure that all of the labels in newCol exist in data
    """
    for item in data:
        for key in newCol:
            if (key not in item):
                item[key] = defaultVal
    return data

def keysUnion(data):
    """
    Data is a list of dictionary. Return the union of all keys.
    """
    items = []
    allKeys = map(lambda d: d.keys(), data)
    for k in allKeys:
        items += k
    return set(items)


def writeCSV(name, data):
    header = data[0].keys()
    with open(name, 'w') as file:
        # Trim the first ,
        file.write(','.join(header)[1:])
        file.write('\n')
        for item in data:
            item = map(str, item)
            file.write(','.join(item)[1:])
            file.write('\n')
    return True


def doWordCount(files):
    """

    """
    for file in files:
        data = parseCSV(file)
        cols = keysUnion(data)
        data = makeNormalizedData(data, cols)
        out = file.replace('data', 'processed')
        writeCSV(out, data)
        print('Wrote: %s', file)

def normalizeFiles(files):
    """

    """
    pass

if __name__ == '__main__':
    getCommonWords()
    files = walkDir(INPUT)
    doWordCount(files)
    # out = walkDir(OUTPUT)
    # normalizeFiles(out)
