# This file contains functions which are used to perform and
# simplify sentimentiment analysis on our corpus
library(tidyr)
library(dplyr)
library(lubridate)
library(maditr)

get_sentiment <- function(docs, corpus) {
  sentiment_df <- read.csv("csv/pos_neg_neu.csv",  sep=",", encoding = "UTF-8") # read pre-classified set of words
  
  docs$sentiments <- "neutral"
  docs$polarity <- 0
  for(i in 1:length(docs$word)) {
    if(nrow(sentiment_df[which(sentiment_df$word == docs$word[i]),])){
      corr <-  sentiment_df[which(sentiment_df$word == docs$word[i]),][1,]
      docs$sentiments[i] <- corr$sentiment
      docs$polarity[i] <- corr$polarity * docs$n[i]
    }
  }
  
  docs <- docs %>% 
    group_by(letter_number, sentiments) %>% 
    summarise(polarity = sum(polarity)) 
  
  docs <- dcast(docs, letter_number ~ sentiments)
  docs <- replace(docs,is.na(docs),0)
  docs$date <- format(as.Date(corpus$date, format="%d/%m/%Y"),"%Y")
  docs$pair <- corpus$pair
  
  return(docs)
}

# this function returns a data frame which associates to each sentiment 
# a value for each topic in the model build using lda
get_sentiment_topic <- function() {
  # load lda model for topics
  model <- readRDS("LDA/LDA_corpus_topic_model.rds")
  
  #phi gives P(token_v|topic_k)
  k <- 5 # number of topics
  n <- 1500 # number of chosen words
  
  tokens_topic <- as.data.frame(GetTopTerms(phi = model$phi, M = n,return_matrix = TRUE))
  tokens_topic$id <- row.names(tokens_topic)
  tokens_topic <- melt(tokens_topic,id="id")[,-1]
  colnames(tokens_topic) <- c("topic", "word")
  tokens_topic$probability <- NA
  tokens_topic$positive <- 0
  tokens_topic$negative <- 0
  tokens_topic$neutral <- 0
  
  sentiment_df <- read.csv("csv/pos_neg_neu.csv",  sep=",", encoding = "UTF-8") # read pre-classified set of words
  
  for(i in 1:k) {
    for(j in 1:n) {
      word <- tokens_topic$word[(i-1)*n + j]
      tokens_topic$probability[(i-1)*n + j] <- model$phi[paste0("t_",i), word]
      
      if(nrow(sentiment_df[which(sentiment_df$word == word),])){
        
        corr <-  sentiment_df[which(sentiment_df$word == word),][1,]
        
        if(corr$sentiment == "positive") 
          tokens_topic$positive[(i-1)*n + j] <- corr$polarity*tokens_topic$probability[(i-1)*n + j]
        else if(corr$sentiment == "negative") 
          tokens_topic$negative[(i-1)*n + j] <- corr$polarity*tokens_topic$probability[(i-1)*n + j]
        else 
          tokens_topic$neutral[(i-1)*n + j] <- corr$polarity*tokens_topic$probability[(i-1)*n + j]
      }
    }
  }
  
  # sum sentiment wrt to topic
  sentiment_topic <- tokens_topic %>%
    group_by(topic) %>%
    summarise(across(sentiment_labels, sum)) 
  
  sentiment_topic <- sentiment_topic  %>% mutate(n = negative/(negative+positive+neutral), p = positive/(negative+positive+neutral),
                                                 ne = neutral/(negative+positive+neutral))
  
  sentiment_topic$negative <- sentiment_topic$n
  sentiment_topic$positive <- sentiment_topic$p
  sentiment_topic$neutral <- sentiment_topic$ne
  sentiment_topic <- sentiment_topic[, -((ncol(sentiment_topic) - 2):ncol(sentiment_topic))]
  
  sentiment_topic$topic <- c("salute", "famiglia", "libro", "pensieri", "viaggio" )
  
  return(sentiment_topic)
}

get_sentiment_topic <- function() {
  # load lda model for topics
  model <- readRDS("LDA/LDA_corpus_topic_model.rds")
  
  #phi gives P(token_v|topic_k)
  k <- 5 # number of topics
  n <- 1500 # number of chosen words
  
  tokens_topic <- GetTopTerms(phi = model$phi, M = n,return_matrix = TRUE)
  tokens_topic <- melt(tokens_topic)[,-1]
  colnames(tokens_topic) <- c("topic", "word")
  tokens_topic$probability <- NA
  tokens_topic$positive <- 0
  tokens_topic$negative <- 0
  tokens_topic$neutral <- 0
  
  sentiment_df <- read.csv("csv/pos_neg_neu.csv",  sep=",", encoding = "UTF-8") # read pre-classified set of words
  
  for(i in 1:k) {
    for(j in 1:n) {
      word <- tokens_topic$word[(i-1)*n + j]
      tokens_topic$probability[(i-1)*n + j] <- model$phi[paste0("t_",i), word]
      
      if(nrow(sentiment_df[which(sentiment_df$word == word),])){
        
        corr <-  sentiment_df[which(sentiment_df$word == word),][1,]
        
        if(corr$sentiment == "positive") 
          tokens_topic$positive[(i-1)*n + j] <- corr$polarity*tokens_topic$probability[(i-1)*n + j]
        else if(corr$sentiment == "negative") 
          tokens_topic$negative[(i-1)*n + j] <- corr$polarity*tokens_topic$probability[(i-1)*n + j]
        else 
          tokens_topic$neutral[(i-1)*n + j] <- corr$polarity*tokens_topic$probability[(i-1)*n + j]
      }
    }
  }
  
  # sum sentiment wrt to topic
  sentiment_topic <- tokens_topic %>%
    group_by(topic) %>%
    summarise(across(sentiment_labels, sum)) 
  
  sentiment_topic <- sentiment_topic  %>% mutate(n = negative/(negative+positive+neutral), p = positive/(negative+positive+neutral),
                                                 ne = neutral/(negative+positive+neutral))
  
  sentiment_topic$negative <- sentiment_topic$n
  sentiment_topic$positive <- sentiment_topic$p
  sentiment_topic$neutral <- sentiment_topic$ne
  sentiment_topic <- sentiment_topic[, -((ncol(sentiment_topic) - 2):ncol(sentiment_topic))]
  
  sentiment_topic$topic <- c("salute", "famiglia", "libro", "pensieri", "viaggio" )
  
  return(sentiment_topic)
}

get_emotions_time <- function(dfEmotion){
  
  countYear <- dfEmotion %>% 
    group_by(year) %>%
    count()
  
  dfEmotion <- dfEmotion %>% 
    group_by(year) %>%
    summarise(across(everything(), sum))
  
  dfEmotion$countYear <- countYear$n
  dfEmotion[,2:7] <- round(dfEmotion[,2:7]/dfEmotion$countYear, digits = 1)
  
  return(dfEmotion)
}


get_emotions_pair <- function(dfEmotion){
  
  countPair <- dfEmotion %>% 
    group_by(pair) %>%
    count()
  
  dfEmotion <- dfEmotion %>% 
    group_by(pair) %>%
    summarise(across(everything(), sum))
  
  dfEmotion$countPair <- countPair$n
  dfEmotion[,2:7] <- round(dfEmotion[,2:7]/dfEmotion$countPair, digits = 1)
  
  return(dfEmotion)
}




