
all.files <- list.files("word_frequencies_by_beer", full.names = TRUE)
all.beers.names.only <- sapply(strsplit(all.files, "/"), function(x) x[2])

all.words <- function(files) {
  words <- NULL

  for (file in files) {
    print(file)
    load(file)
    current.words <- Reduce(function(agg, df) union(agg, df$word[df$count > 1]), word.freqs, NULL) # count > 1 is a simple (though probably overly aggressive) way to remove weird words
    words <- union(words, current.words)
  }
  return(words)
}

words <- all.words(all.files)
save(words, file = "all_words")
#counts.by.beer <- as.data.frame(setNames(replicate(length(words),numeric(0), simplify = F), words))

library("Matrix")

counts.by.beer <- Matrix(0, nrow = 104 * 50, ncol = length(words))
beer.names <- NULL

for (i in 1:length(all.files)) {
  file <- all.files[i]
  beers <- list.files(paste("../../data", all.beers.names.only[i], sep = "/"))
  beer.names <- c(beer.names, beers)
  print(file)
  load(file)
  for (j in 1:length(word.freqs)) {
    current <- word.freqs[[j]]
    current.beer <- beers[j]
    shared.words <- intersect(words, current$word)
    columns <- which(is.element(words, shared.words))
    shared.counts <- current[is.element(current$word, shared.words),"count"]
    counts.by.beer[50 * (i - 1) + j, columns] <- shared.counts
    
  }
}

save(counts.by.beer, file = "counts_matrix")
#counts.by.beer <- as.data.frame(counts.by.beer)
#names(counts.by.beer) <- words
#save(counts.by.beer, file = "counts_data_frame")


style.labels <- name.labels <- NULL
for (i in 1:length(all.files)) {
  beers <- list.files(paste("../../data", all.beers.names.only[i], sep = "/"))
  style.labels <- c(style.labels, rep(all.beers.names.only[i], length(beers)))
  name.labels <- c(name.labels, beers[1:length(beers)-1])
}
  
  
