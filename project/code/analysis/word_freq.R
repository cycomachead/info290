
#D <- read.csv("../../data/American_Pale_Ale_(APA)/220_44896", as.is = TRUE)
#D <- read.csv("../../data/American_Pale_Ale_(APA)/140_276", as.is = TRUE)
common.words <- strsplit(readLines("common-english-words.txt"), ",")[[1]]

files <- list.files("../../data/American_Pale_Ale_(APA)/", full.names = TRUE)

t <- proc.time()

D <- read.csv(files[1], as.is = TRUE)

text <- D$review_text

text <- gsub("[[:punct:]]", "", text)

text <- tolower(text)

text <- strsplit(text, split = "\\s+")

text <- Reduce(c, text, c())
text <- text[text != ""]

counts <- rle(sort(text)) # generates word counts
counts <- data.frame(word = counts$value, count = counts$lengths)
counts <- counts[!is.element(counts$word, common.words),] # filters out common words

sorted.indices <- order(counts$count, decreasing = TRUE)
counts <- counts[sorted.indices,] # put in decreasing order
counts$percent <- counts$count / sum(counts$count)
#head(counts, 50)

print(proc.time() - t)
