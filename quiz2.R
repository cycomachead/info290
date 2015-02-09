
# z-score
D = read.csv("yelp_reviews.txt", sep = "|", header = T)
D = D[,c(7,4)]
users.grouped = split(D$stars, D$user_id)
means = sapply(users.grouped, mean)
# m = means["mTDwQ4I2hAHz2i5AC1ab3w"]
m = means["-2jevGd5B6dqAT7AwBW6lA"] # for attempt 2

(m - mean(means))/sd(means) # -1.746696 for attempt 2

# clustering
C1 = c(3, 4, 11)
C2 = c(15, 20, 22, 26)

E1 = c(3, 4, 11, 15)
E2 = c(20, 22, 26)

# question 4
a = function(index, clust) {
    s = 0
    for (i in 1:length(clust)) {
        if (i != index) {
            s = s + abs(clust[index] - clust[i])
        }
    }
    return(s / (length(clust) - 1))
}

b = function(index, clust1, clust2) {
    mean(abs(clust1[index] - clust2))
}

s = function(index, clust1, clust2) {
    a.temp = a(index, clust1)
    b.temp = b(index, clust1, clust2)
    (b.temp - a.temp) / max(a.temp, b.temp)
}

C1.s = sapply(1:length(C1), function(i) s(i, C1, C2))
C2.s = sapply(1:length(C2), function(i) s(i, C2, C1))

# question 5
E1.s = sapply(1:length(E1), function(i) s(i, E1, E2))
E2.s = sapply(1:length(E2), function(i) s(i, E2, E1))


# question 6
sum.var.c = sum((C1 - mean(C1))^2) + sum((C2 - mean(C2))^2)

# question 7
sum.var.e = sum((E1 - mean(E1))^2) + sum((E2 - mean(E2))^2)


