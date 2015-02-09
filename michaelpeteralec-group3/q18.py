# INFO 290T
# Lab 2, exercise 18
# Group 3 - Michael Ball, Alec Guertin, Peter Sujan

import csv

totals = {}
with open('yelp_reviews.txt', 'r') as f:
    file_reader = csv.DictReader(f, delimiter = '|')
    for row in file_reader:
        user_id = row['user_id']
        rating = float(row['stars'])
        votes_useful = float(row['votes.useful'])
        if rating > 3.5:
            current = [0, 0, votes_useful, 1]
        else:
            current = [votes_useful, 1, 0, 0]
            
        if user_id not in totals:
            totals[user_id] = current
        else:
            totals[user_id] = [totals[user_id][i] + current[i] for i in range(4)]


with open('q18.feature', 'w+') as f:
    file_writer = csv.writer(f)
    file_writer.writerow(['user_id', 'nice_reviews_more_useful'])
    for user_id in totals:
        t1, c1, t2, c2 = totals[user_id]
        if c1 > 0 and c2 > 0:
            value = int((t1/c1) < (t2/c2))
        else:
            value = int(c1 == 0)
        file_writer.writerow([user_id, value])

