library(dplyr)
library(tidyverse)
library(tidytext)
library(textmineR)
library(tm)
library(topicmodels)

# Load dataset with lemmatized words

corpus_ita <- read.csv("csv/cleaned_svevo_dataset_ITA.csv", sep=",", encoding = "UTF-8")


#Build LDA model, with k = 5.

#compute document-term-matrix
dtm <- CreateDtm(doc_vec = corpus_ita$lemmatized_tokens, # character vector of documents
                 doc_names = corpus_ita$letter_number, # document names
                 ngram_window = c(1, 1), # minimum and maximum n-gram length
                 lower = FALSE, 
                 remove_punctuation = FALSE, 
                 stopword_vec = c(),
                 remove_numbers = FALSE, 
                 verbose = TRUE,
                 cpus = 4) # default is all available cpus on the system


#random fit
set.seed(12345)
num_topics <- 5
#compute LDA with fixing value of K
lda <- FitLdaModel(dtm = dtm, 
                       k = num_topics,
                       iterations = 2000, #  recommend at least 500 iterations or more
                       burnin = 180,
                       alpha = 0.1,
                       beta = 0.05,
                       optimize_alpha = TRUE,
                       calc_likelihood = TRUE,
                       calc_coherence = TRUE,
                       calc_r2 = TRUE,
                       cpus = 4) 

#Analysis of main topics obtained.

lda$prevalence <- colSums(lda$theta) / sum(lda$theta) * 100

lda$top_terms <- GetTopTerms(phi = lda$phi, M = 30)

# textmineR has a naive topic labeling tool based on probable bigrams
lda$labels <- LabelTopics(assignments = lda$theta > 0.05, 
                              dtm = dtm,
                              M = 1)


# put them together, with coherence into a summary table
lda$summary <- data.frame(topic = rownames(lda$phi),
                              label = lda$labels,
                              coherence = round(lda$coherence, 3),
                              prevalence = round(lda$prevalence,3),
                              top_terms = apply(lda$top_terms, 2, function(x){
                                paste(x, collapse = ", ")
                              }),
                              stringsAsFactors = FALSE)

#print summary table
lda$summary[ order(lda$summary$prevalence, decreasing = TRUE) , ]

SummarizeTopics(lda)





