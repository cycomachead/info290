process.text <- function(filename, shortname) {
    all.text <- NULL
    files <- list.files(filename, full.names = TRUE)
    for (j in 1:(length(files) - 1)) {
        D <- tryCatch(
            {
                read.csv(files[j], as.is = TRUE, row.names = NULL)
            }, error = function(e) {
                print(paste("error with file:", files[j]))
                print(e)
            })
        
        if (is.null(D) || nrow(D) == 0) {
            next
        }
        
        text <- D$review_text
        text <- gsub("\\.", " ", text)
        text <- gsub("[[:punct:]]", "", text)
        text <- tolower(text)
        text <- strsplit(text, split = "\\s+")
        text <- Reduce(c, text, c())
        text <- text[text != ""]
        all.text <- c(all.text, text)
    }
    write(all.text, file = paste("combined_text", paste(shortname, ".txt", sep = ""), sep = "/"))
    return(all.text)
}

all.files <- list.files("../../data", full.names = TRUE)
all.beers.names.only <- sapply(strsplit(all.files, "/"), function(x) x[4])

for(i in 1:length(all.beers.names.only)){
    if (length(grep(all.beers.names.only[i], dir("combined_text"))) == 0) {
        print(i)
        process.text(all.files[i], all.beers.names.only[i])
    }
}
