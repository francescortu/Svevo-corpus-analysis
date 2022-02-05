############### LIBRARY ###################

library(topicmodels)
library(tm)
library(textmineR)
library(broom)

##################  FUNCTIONS ###################
multiple_K_coherence <- function(max_K, dtm){
  set.seed(12345)
  coher <- c(1:max_K)
  for(i in c(1:max_K)){
    model <- TmParallelApply(dtm, FitLdaModel(dtm = dtm, 
                         k = i,
                         iterations = 500, #  recommend at least 500 iterations or more
                         burnin = 180,
                         alpha = 0.1,
                         beta = 0.05,
                         optimize_alpha = TRUE,
                         calc_likelihood = TRUE,
                         calc_coherence = TRUE,
                         calc_r2 = FALSE,
                         cpus = 2) )
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
max_K <- 50 #Max number of topics we want

coer_on_multiple_K <- multiple_K_coherence(max_K, dtm) # takes a lot of time!!!!!!!!

write.csv(coer_on_multiple_K, "../csv/coherence.csv")

coer_on_multiple_K <- read.csv("../csv/coherence.csv", sep=",", encoding = "UTF-8")
colnames(coer_on_multiple_K) <- c("k", "coherence")
ggplot(coer_on_multiple_K) +
  geom_point(aes(x = 26, y = coer_on_multiple_K$coherence[26]), col = "red", size = 3) +
  geom_line(aes(x = k, y = coherence), col = "violet") + 
  xlab("K") + 
  ylab("Coherence")

ggsave("../plots/coherence.png", width = 20, height = 8, dpi = 150)

which.max(coer_on_multiple_K$coherence) # find out which is the value which provides the best coherence


############### ONE MODEL ANALYSIS ###################################
#random fit
set.seed(12345)
num_topics <- 26 # MUST TAKES THE BEST OF THE COMPUTATION ABOVE
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
augment(model)
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

# Save model to a file
saveRDS(model, file = "LDA_corpus_topic_model.rds")


##############################
##############################
## Perplexity index

library(topicmodels)
library(doParallel)
library(ggplot2)
library(scales)

C <- Corpus(VectorSource(corpus$tokens))
tdm <- DocumentTermMatrix(C, control = list(bounds = list(global = c(5, Inf))))

burnin = 1000
iter = 1000
keep = 50
# define our "full data"
full_data  <- tdm
n <- nrow(full_data)


cluster <- makeCluster(detectCores(logical = TRUE) - 1) 
registerDoParallel(cluster)
clusterEvalQ(cluster, {
  library(topicmodels)
})

folds <- 5
splitfolds <- sample(1:folds, n, replace = TRUE)
candidate_k <- seq(2,50,2) # candidates for how many topics
clusterExport(cluster, c("full_data", "burnin", "iter", "keep", "splitfolds", "folds", "candidate_k"))

system.time({
  results <- foreach(j = 1:length(candidate_k), .combine = rbind) %dopar%{
    k <- candidate_k[j]
    results_1k <- matrix(0, nrow = folds, ncol = 2)
    colnames(results_1k) <- c("k", "perplexity")
    for(i in 1:folds){
      train_set <- full_data[splitfolds != i , ]
      valid_set <- full_data[splitfolds == i, ]
      
      fitted <- LDA(train_set, k = k, method = "Gibbs",
                    control = list(burnin = burnin, iter = iter, keep = keep) )
      results_1k[i,] <- c(k, perplexity(fitted, newdata = valid_set))
    }
    return(results_1k)
  }
})

stopCluster(cluster)
results_df <- as.data.frame(results)

write.csv(results_df, "../csv/perplexity.csv")


ggplot(results_df, aes(x = k, y = perplexity)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  ggtitle("5-fold cross-validation of topic modelling",
          "(The points represent five different models fit for each candidate number of topics)") +
  labs(x = "K", y = "Perplexity when fitting the trained model to the hold-out set")


ggsave("../plots/perplexity.png", width = 20, height = 8, dpi = 150)
