## this is a batch program to go through several samples agains a reference
# invoke the library package
# enter all the reference

library(ExomeDepth)
#args <- commandArgs(trailingOnly = TRUE)
#myCount.dafr <- read.csv(args[1])

# print(head(myCount.dafr))
# to get all the elements of an vector except the first vector[-1]
# to get user input use readline


# A list is a generic vector containing other objects. 
# > n = c(2, 3, 5) 
# > s = c("aa", "bb", "cc", "dd", "ee") 
# > b = c(TRUE, FALSE, TRUE, FALSE, FALSE) 
# > x = list(n, s, b, 3)   # x contains copies of n, s, b 

print("enter data file")
data <- scan(file = "", what = "", nmax =1)
myCount.dafr <- read.csv(data)


print("which samples do you want to use as reference?")
my.file <- scan(file = "", what = "", nmax =30)
con<-file(my.file,"rt")
my.ref.samples <- readLines(con)

#my.ref.samples <- readLines(con = stdin(),n = -1L, ok = TRUE, warn = TRUE,encoding = "unknown")
#my.ref.samples <- scan(file = "", what = "", nmax =30)


print(my.ref.samples)

print("enter test sample list")

test.sample <- scan(file = "", what = "", nmax = 1)


my.test <- myCount.dafr[, test.sample]

my.reference.set <- as.matrix(myCount.dafr[, my.ref.samples])
my.choice <- select.reference.set (test.counts = my.test, reference.counts = my.reference.set, bin.length = (myCount.dafr$end - myCount.dafr$start)/1000, n.bins.reduced = 10000)

print(my.choice[[1]])

my.matrix <- as.matrix(myCount.dafr[, my.choice$reference.choice, drop = FALSE])
my.reference.selected <- apply(X = my.matrix, MAR = 1, FUN = sum)

all.exons <- new('ExomeDepth', test = my.test, reference = my.reference.selected, formula = 'cbind(test, reference) ~ 1')
all.exons <- CallCNVs(x = all.exons, transition.probability = 10^-4, chromosome = myCount.dafr$space, start = myCount.dafr$start, end = myCount.dafr$end, name = myCount.dafr$names)
print("enter output dir")
output.dir <- scan(file = "", what = "", nmax = 1)
sample <- substring(test.sample,1,5)
output.file <-paste(output.dir, sample, '.csv', sep = '')
write.csv(file = output.file, x = all.exons@CNV.calls, row.names = FALSE)
