# invoke the library package
library(ExomeDepth)
args <- commandArgs(trailingOnly = TRUE)
myCount.dafr <- read.csv(args[1])
print(head(myCount.dafr))
