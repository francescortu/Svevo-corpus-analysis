# This file contains functions which are used to perform and
# simplify topic modeling on the given corpus using LDA

library(textmineR)
library(cluster)
library(factoextra)
library(topicmodels)
library(tm)
library(doParallel)
library(ggplot2)
library(scales)

#return best value of K based on coherence and save a csv with all values
evaluate_coherence <- function(max_K, corpus, save_results){
  dtm <- CreateDtm(doc_vec = corpus$lemmatized_tokens, # character vector of documents
                   doc_names = corpus$letter_number, # document names
                   ngram_window = c(1, 1), # minimum and maximum n-gram length
                   lower = FALSE, 
                   remove_punctuation = FALSE, 
                   stopword_vec = c(),
                   remove_numbers = FALSE, 
                   verbose = TRUE,
                   cpus = 4) # default is all available cpus on the system
  set.seed(12345)
  coher <- c(1:max_K)
  sil <- NULL
  pb <- txtProgressBar(0, max_K, style = 3)
  for(i in c(2:max_K)){
    setTxtProgressBar(pb, i)
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
                                              cpus = 1) 
    coher[i] <- mean(model$coherence)
    s <-summary(compute_silhouette_score(model, display_plot = FALSE))
    sil[i] <- as.numeric(s$si.summary[4])
  }
  close(pb)
  
  
  if(save_results == TRUE){
    write.csv(coher, "csv/coherence.csv")
    write.csv(sil, "csv/silhouette.csv")
  }
  
  return(which.max(coher))
}

#return a data-frame with values of perplexity
evaluate_perplexity <- function(corpus, save_results){
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
  k_max <- 30
  splitfolds <- sample(1:folds, n, replace = TRUE)
  candidate_k <- seq(2,k_max,2) # candidates for how many topics
  clusterExport(cluster, c("full_data", "burnin", "iter", "keep", "splitfolds", "folds", "candidate_k"))

  system.time({
    results <- foreach(j = 1:length(candidate_k), .combine = rbind) %dopar%{
      k <- candidate_k[j]
      results_1k <- matrix(0, nrow = folds, ncol = 2)
      colnames(results_1k) <- c("k", "perplexity")
      pb <- txtProgressBar(1, folds, style = 3)
      for(i in 1:folds){
        setTxtProgressBar(pb, i)
        train_set <- full_data[splitfolds != i , ]
        valid_set <- full_data[splitfolds == i, ]

        fitted <- LDA(train_set, k = k, method = "Gibbs",
                      control = list(burnin = burnin, iter = iter, keep = keep) )
        results_1k[i,] <- c(k, perplexity(fitted, newdata = valid_set))
      }
      close(pb)
      return(results_1k)
    }
  })

  stopCluster(cluster)
  results_df <- as.data.frame(results)
  if(save_results == TRUE){
    write.csv(results_df, "csv/perplexity.csv")
  }
  return(results_df)
}

#return LDA model
one_model_analysis <- function(num_topics, corpus, save_results){
  dtm <- CreateDtm(doc_vec = corpus$tokens, # character vector of documents
                   doc_names = corpus$letter_number, # document names
                   ngram_window = c(1, 1), # minimum and maximum n-gram length
                   lower = FALSE, 
                   remove_punctuation = FALSE, 
                   stopword_vec = c(),
                   remove_numbers = FALSE, 
                   verbose = TRUE,
                   cpus = 4) # default is all available cpus on the system
  set.seed(1254)
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
  s <-summary(compute_silhouette_score(model, display_plot = FALSE))
  model$silhuette <- as.numeric(s$si.summary[4])
  model$prevalence <- colSums(model$theta) / sum(model$theta) * 100
  model$top_terms <- GetTopTerms(phi = model$phi, M = 20)
  model$labels <- LabelTopics(assignments = model$theta > 0.05, 
                              dtm = dtm,
                              M = 1)
  model$summary <- data.frame(topic = rownames(model$phi),
                              label = model$labels,
                              coherence = round(model$coherence, 3),
                              prevalence = round(model$prevalence,3),
                              top_terms = apply(model$top_terms, 2, function(x){
                                paste(x, collapse = ", ")
                              }),
                              stringsAsFactors = FALSE)
  if(save_results == TRUE){
    saveRDS(model, file = "LDA/LDA_corpus_topic_model.rds")
  }
  return(model)
}

#return silhouette score for the model taken in input. If display_plot==TRUE will be diplayed a plot.
# compute_silhouette_score <- function(model, display_plot){ 
#   
#   x<-as.data.frame(model$theta)
#   
#   # Hard clustering of documents assign to each document the most likely topic
#   cluster <- NULL
#   for(i in c(1:nrow(x))){
#     cluster[i] <- which.max(x[i,])
#   }
#   
#   #Compute siluette
#   sil<-silhouette(cluster,CalcHellingerDist(model$theta))
#   
#   #plot
#   if(display_plot == TRUE){
#     print(fviz_silhouette(sil))
#   }
#   
#   return(sil) 
# }

compute_silhouette_score <- function(model, display_plot){ 
  
  x<-as.data.frame(model$gamma)
  
  # Hard clustering of documents assign to each document the most likely topic
  cluster <- NULL
  for(i in c(1:ncol(x))){
    cluster[i] <- which.max(x[,i])
  }
  
  #Compute siluette
  sil<-silhouette(cluster,CalcHellingerDist(model$gamma, by_rows=FALSE))
  
  #plot
  if(display_plot == TRUE){
    print(fviz_silhouette(sil))
  }
  
  return(sil) 
}

topic_trend_over_time <- function(corpus, model) {
  
  topic_time <- data.frame(model$theta)
  topic_time$date <- format(as.Date(corpus$date, format="%d/%m/%Y"),"%Y")
  
  #remove NA
  topic_time<-na.omit(topic_time)
  return(topic_time)
}

topic_trend_over_people <- function(corpus, model) {
  
  topic_people <- data.frame(model$theta)
  # add pair of sender-receiver wrt to letter number
  topic_people$pair <- corpus$pair

  #remove NA
  topic_people <- na.omit(topic_people)
  return(topic_people)
}

