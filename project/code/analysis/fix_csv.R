files <- list.files("../../data/American_Adjunct_Lager", full.names=TRUE)
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
    write.table(D[,-(1:6)], file, qmethod = "escape", row.names = FALSE, sep = ",", quote = TRUE)
  }
}
