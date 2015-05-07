#!/usr/bin/Rscript

load("freq_terms")
all.beers <- read.csv("all_beers_style_only.csv", row.names = NULL, header = FALSE)

beer <- commandArgs()[6]

style <- all.beers$V2[all.beers$V1 == beer]
style <- gsub(" ", "_", style)
#print(style)
words <- freq.terms[[style]]
for (w in words) {
    if (!is.na(w)) {
        print(w)
    }
}
