
                                        #D <- read.csv("../../data/American_Pale_Ale_(APA)/220_44896", as.is = TRUE)
                                        #D <- read.csv("../../data/American_Pale_Ale_(APA)/140_276", as.is = TRUE)
common.words <- strsplit(readLines("common-english-words.txt"), ",")[[1]]

                                        #files <- list.files("../../data/American_Pale_Ale_(APA)/", full.names = TRUE)

all.beers <- list.dirs("../../data/")
all.beers <- all.beers[2:length(all.beers)]
all.beers.names.only <- sapply(strsplit(all.beers, "//"), function(x) x[2])
n.beers <- length(all.beers)

style.start <- beer.start <- 1
args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
    style.start <- args[1]
}
if (length(args) > 1) {
    beer.start <- args[2]
}

for (j in style.start:n.beers) {
    files <- list.files(all.beers[j], full.names = TRUE)
    
    t <- proc.time()
    
    n.files <- length(files) - 1
    word.freqs <- vector("list", n.files)
    for (i in beer.start:n.files) {
        D <- tryCatch(
            {
                read.csv(files[i], as.is = TRUE, row.names = NULL)
            }, error = function(e) {
                print(paste("error with file:", files[i]))
                print(e)
                return(NULL)
            })

        if (is.null(D)) {
            next
        }

        if (nrow(D) > 0) {
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
        } else {
            counts <- data.frame(word = character(0), count = numeric(0),
                                 percent = numeric(0))
        }
        
        word.freqs[[i]] <- counts
    }

    save(word.freqs, file = paste("word_frequencies_by_beer", all.beers.names.only[j], sep = "/"))
    
}

print(proc.time() - t)
