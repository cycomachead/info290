
#D <- read.csv("../../data/American_Pale_Ale_(APA)/220_44896", as.is = TRUE)
#D <- read.csv("../../data/American_Pale_Ale_(APA)/140_276", as.is = TRUE)
common.words <- strsplit(readLines("common-english-words.txt"), ",")[[1]]

#files <- list.files("../../data/American_Pale_Ale_(APA)/", full.names = TRUE)

all.beers <- list.dirs("../../data/")
all.beers <- all.beers[2:length(all.beers)]
all.beers.names.only <- sapply(strsplit(all.beers, "//"), function(x) x[2])
n.beers <- length(all.beers)

for (j in 1:n.beers) {

  files <- list.files(all.beers[j], full.names = TRUE)
  
  t <- proc.time()
  
  n.files <- length(files) - 1
  word.freqs <- vector("list", n.files)
  for (i in 1:n.files) {
    D <- tryCatch(
                  {
                    read.csv(files[i], as.is = TRUE, row.names = NULL)
                  }, error = function(e) {
                    print(paste("error with file:", files[i]))
                    next
                  })
    

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
    word.freqs[[i]] <- counts
  }

  save(word.freqs, file = paste("word_frequencies_by_beer", all.beers.names.only[j], sep = "/"))
  
}

print(proc.time() - t)
