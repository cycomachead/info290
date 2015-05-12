library(parallel)

n.cores <- detectCores()
C <- makeCluster(n.cores)

M <- matrix(runif(1000000), nrow = 10000, ncol = 100)

t <- proc.time()
M1 <- apply(M, 1, function(x) x / mean(x))
print(proc.time() - t)

t <- proc.time()
M2 <- parRapply(C, M, function(x) x / mean(x))
print(proc.time() - t)
