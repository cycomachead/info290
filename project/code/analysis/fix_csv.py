import re, os
FIELDS = "user_score,rdev,look_score,smell_score,taste_score,feel_score,overall_score,review_text,username,timestamp".split(",")

def fix_line(line):
    strings = line.split(",")
    end_index = -3
    if strings[-1].startswith('"0') or strings[-1].startswith('"Beers'):
        end_index = -2
    elif "AM" in strings[-1] or "PM" in strings[-1]:
        end_index = -2
    return ",".join(strings[7:end_index])
        

data = "../../data/"
for folder in os.listdir(data):
    if folder.endswith("txt"):
        continue
    for f in os.listdir(data + folder):
        print f
        filename = data + folder + "/" + f
        if filename.endswith("reviews") or filename.endswith("txt"):
            continue
        with open(filename) as fin:
            with open(filename + "_reviews", "w") as fout:
                fout.writelines("review_text")
                for line in fin.readlines():
                    improved_row = fix_line(line)
                    fout.writelines(improved_row + "\n")
            
