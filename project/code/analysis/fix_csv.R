dirs <- list.dirs("../../data")
for (d in dirs) {
  files <- list.files(d, full.names=TRUE)
  for (file in files) {
    D <- tryCatch(
                  {
                    read.csv(file, as.is = TRUE, row.names = NULL)
                  }, error = function(e) {
                    print(paste("error with file:", file))
                    print(e)
                    return(NULL)
                  })
    if (!is.null(D)) {
      
      write.table(D, file, qmethod = "escape", row.names = FALSE, sep = ",", quote = TRUE, na = "NA")
    }
  }
}
