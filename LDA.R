
#Try to do some LDA analysis of topics:
  
corpus <- data.frame(read.csv("cleaned_svevo_dataset.csv"))

library(topicmodels)
library(tm)

#create corpus object from the dataframe
Corpus_obj <- Corpus(VectorSource(corpus$tokens))

#Compute Document term matrix from the corpus object
TDM <- DocumentTermMatrix(Corpus_obj, control = list(bounds = list(global = c(5, Inf))))

#Compute the LDA
topicModel <- LDA(TDM, 5, method = "VEM")

#Print the first 10 words for each topics
terms(topicModel, 17)

#

