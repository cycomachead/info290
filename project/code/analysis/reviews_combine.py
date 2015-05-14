from pandas import *
import os
import sys

STYLE = "American_Brown_Ale"
BEER_DIR = "../../processed/word-freq-by-review/%s/"%(STYLE)
BEER_COL = "beer_id"

beer_dfs = {}
print(STYLE)
# Create DataFrame from each beer's csv
for f in os.listdir(BEER_DIR):
    print(f)
    cur_csv = read_csv(BEER_DIR + f, header=0)

    # Delete first column with missing character
    del cur_csv[cur_csv.icol(0).name]
    beer_dfs[f] = cur_csv
    # print(cur_csv.head(1))

# Make DataFrame with all words for this style
print("Making list of all words...")
all_words = []
all_words = set(all_words)
for beer_id in beer_dfs:
    df = beer_dfs[beer_id]
    all_words = all_words | set(df.columns.values)
print("DONE: making list of all words.")

combined_df = DataFrame(columns=['beer_id'])

print("Combining DataFrame objects...")
# Add beer ids to dfs and append to main df
i = 0
for beer_id in beer_dfs:
    df = beer_dfs[beer_id]
    # print("Appending beer #%d: %s"%(i, beer_id))
    cols = df.columns.values
#    avg = 0
#    for c in cols:
#        avg += sum(df[c])
#    avg = avg/df.shape[0]
    df = df.head(500)
    col_data = [beer_id]*df.shape[0]
    df2 = DataFrame(col_data, columns=['beer_id'])
    for c in cols:
        if sum(df[c]) > 3:
            df2[c] = Series(df[c], index=df2.index)
    df2[BEER_COL] = Series(col_data, index=df.index)
    comb_cols = combined_df.columns.values
    comb_rows = combined_df.shape[0]
    cols = df2.columns.values
    for c in cols:
        if c not in comb_cols:
            combined_df[c] = Series([0]*comb_rows, index=combined_df.index)
    combined_df = combined_df.append(df2)
    print("combined_df size: %s"%(str(combined_df.shape)))
    i += 1
print("DONE: combining DataFrame objects.")

# Fill in with 0's
combined_df = combined_df.fillna(0)

combined_df.to_pickle("./%s.pkl"%(STYLE))
