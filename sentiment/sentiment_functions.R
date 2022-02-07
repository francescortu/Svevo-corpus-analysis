# This file contains functions which are used to perform and
# simplify sentimentiment analysis on our corpus

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
    summarise(polarity = sum(polarity)) #%>%
    #mutate(polarity = (polarity/sum(polarity)) * 100)
  
  docs <- dcast(docs, letter_number ~ sentiments)
  docs <- replace(docs,is.na(docs),0)
  docs$date <- format(as.Date(corpus$date, format="%d/%m/%Y"),"%Y")
  docs$pair <- corpus$pair
  
  return(docs)
}