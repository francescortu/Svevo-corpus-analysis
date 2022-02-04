

############### LIBRARY ###################

library(topicmodels)
library(tm)
library(textmineR)

##################  FUNCTIONS ###################
multiple_K_coherence <- function(max_K, dtm){
  set.seed(12345)
  coher <- c(1:max_K)
  for(i in c(1:max_K)){
    model <- FitLdaModel(dtm = dtm, 
                         k = i,
                         iterations = 500, #  recommend at least 500 iterations or more
                         burnin = 180,
                         alpha = 0.1,
                         beta = 0.05,
                         optimize_alpha = TRUE,
                         calc_likelihood = TRUE,
                         calc_coherence = TRUE,
                         calc_r2 = FALSE,
                         cpus = 4) 
    coher[i] <- mean(model$coherence) 
  }
  return(coher)
}

################# IMPORT DATA-SET ############

corpus <- data.frame(read.csv("../csv/cleaned_svevo_dataset_ITA.csv"))

##############################################
#############################################


#compute document-term-matrix
dtm <- CreateDtm(doc_vec = corpus$lemmatized_tokens, # character vector of documents
                 doc_names = corpus$letter_number, # document names
                 ngram_window = c(1, 1), # minimum and maximum n-gram length
                 lower = FALSE, 
                 remove_punctuation = FALSE, 
                 stopword_vec = c(),
                 remove_numbers = FALSE, 
                 verbose = TRUE,
                 cpus = 4) # default is all available cpus on the system

### Choose the best number of topics based on the number of topics
max_K <- 20 #Max number of topics we want

coer_on_multiple_K <- multiple_K_coherence(max_K, dtm) # takes a lot of time!!!!!!!!

write.csv(coer_on_multiple_K, "coherhence.csv")

ggplot() +
  geom_point(aes(x = 5, y = coer_on_multiple_K[5]), col = "red", size = 3) +
  geom_line(aes(x = c(1:max_K), y = coer_on_multiple_K), col = "violet") + 
  xlab("K") + 
  ylab("Coherence")


plot(c(1:max_K), coer_on_multiple_K, type='l')  #plot results

coer_on_multiple_K


############### ONE MODEL ANALYSIS ###################################
#random fit
set.seed(12345)
num_topics <- 6 # MUST TAKES THE BEST OF THE COMPUTATION ABOVE
#compute LDA with fixing value of K
model <- FitLdaModel(dtm = dtm, 
                     k = num_topics,
                     iterations = 800, #  recommend at least 500 iterations or more
                     burnin = 180,
                     alpha = 0.1,
                     beta = 0.05,
                     optimize_alpha = TRUE,
                     calc_likelihood = TRUE,
                     calc_coherence = TRUE,
                     calc_r2 = TRUE,
                     cpus = 4) 


#print log-likelihood (higher is better)----TO DECIDE NUMBER OF ITERATIONS---not so important for us
plot(model$log_likelihood, type = "l")

#print summory of topic-coherence
summary(model$coherence)

# Get the prevalence of each topic
# You can make this discrete by applying a threshold, say 0.05, for
# topics in/out of docuemnts. 
model$prevalence <- colSums(model$theta) / sum(model$theta) * 100

# prevalence should be proportional to alpha
plot(model$prevalence, model$alpha, xlab = "prevalence", ylab = "alpha")
model$top_terms <- GetTopTerms(phi = model$phi, M = 10)

# textmineR has a naive topic labeling tool based on probable bigrams
model$labels <- LabelTopics(assignments = model$theta > 0.05, 
                            dtm = dtm,
                            M = 1)

head(model$labels)

# put them together, with coherence into a summary table
model$summary <- data.frame(topic = rownames(model$phi),
                            label = model$labels,
                            coherence = round(model$coherence, 3),
                            prevalence = round(model$prevalence,3),
                            top_terms = apply(model$top_terms, 2, function(x){
                              paste(x, collapse = ", ")
                            }),
                            stringsAsFactors = FALSE)

#print summary table
model$summary[ order(model$summary$prevalence, decreasing = TRUE) , ][ 1:10 , ]

