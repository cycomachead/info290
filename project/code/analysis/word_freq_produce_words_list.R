
all.files <- list.files("word_frequencies_by_beer", full.names = TRUE)
all.beers.names.only <- sapply(strsplit(all.files, "//"), function(x) x[2])

all.words <- function(files) {
  words <- NULL

  for (file in all.files) {
    print(file)
    load(file)
    current.words <- Reduce(function(agg, df) union(agg, df$word[df$count > 1]), word.freqs, NULL) # count > 1 is a simple (though probably overly aggressive) way to remove weird words
    words <- union(words, current.words)
  }
  return(words)
}

words <- all.words(all.files)

#counts.by.beer <- as.data.frame(setNames(replicate(length(words),numeric(0), simplify = F), words))

counts.by.beer <- matrix(0, nrow = 104 * 50, ncol = length(words))
beer.names <- NULL

for (i in 1:length(all.files)) {
  file <- all.files[i]
  beers <- list.files(paste("../../data", all.beers.names.only[i], sep = "/"))
  beer.names <- c(beer.names, beers)
  print(file)
  load(file)
  for (j in 1:length(word.freqs)) {
    print(j)
    print(length(word.freqs))
    current <- word.freqs[[j]]
    current.beer <- beers[j]
    shared.words <- intersect(words, current$word)
    columns <- which(is.element(words, shared.words))
    shared.counts <- current[is.element(current$word, shared.words),"count"]
    counts.by.beer[50 * (i - 1) + j, shared.words] <- shared.counts
    
  }
}

counts.by.beer <- as.data.frame(counts.by.beer)
names(counts.by.beer) <- words

