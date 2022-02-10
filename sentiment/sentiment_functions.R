# This file contains functions which are used to perform and
# simplify sentimentiment analysis on our corpus
library(tidyr)
library(dplyr)
library(lubridate)


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


get_emotions_time <- function(dfEmotion){
  
  countYear <- dfEmotion %>% 
    group_by(year) %>%
    count()
  
  dfEmotion <- dfEmotion %>% 
    group_by(year) %>%
    summarise(across(everything(), sum))
  
  dfEmotion$countYear <- countYear$n
  dfEmotion[,3:8] <- round(dfEmotion[,3:8]/dfEmotion$countYear, digits = 1)
  
  return(dfEmotion)
}


get_emotions_pair <- function(dfEmotion){
  
  countYear <- dfEmotion %>% 
    group_by(year) %>%
    count()
  
  dfEmotion <- dfEmotion %>% 
    group_by(year) %>%
    summarise(across(everything(), sum))
  
  dfEmotion$countYear <- countYear$n
  dfEmotion[,3:8] <- round(dfEmotion[,3:8]/dfEmotion$countYear, digits = 1)
  
  return(dfEmotion)
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

#TO-MERGE
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



