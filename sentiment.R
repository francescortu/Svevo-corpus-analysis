
library(tidytext)

corpus <- read.csv("csv/cleaned_svevo_dataset.csv", sep=",", encoding = "UTF-8")
corpus$tokens <- corpus$lemmatized_tokens # make tokens the lemmatized ones

sentiments %>% slice(sample(1:nrow(sentiments)))


summary(corpus)
corpus$tokens[which(corpus$mainLanguage == "ENG")]

#sentiments$sentiment[which((sentiments$word) == corpus$text[which(corpus$mainLanguage == "ENG"))]]


corpus$tokens[7]

for (x in corpus$tockens[7]){
  print[x]
  print(0)
}

library(wordcloud)
wordcloud(corpus$tokens, scale = c(7, 1), min.freq = 1, colors = rainbow(30))


model <- readRDS("../LDA/LDA_model_ita.rds")
model

plot(model$hclust)

set.seed(1234)
wordcloud(model$top_terms, scale = c(2,1), min.freq = 1000000, colors = rainbow(20))
wordcloud(words = model$top_terms, size = 1.6, scale=c(3.5,0.25), min.freq = 1,max.words=200,random.order=FALSE,rot.per=0.35,colors=brewer.pal(8,"Dark2"))


library(wordcloud2)

wordcloud2(data=model, size = 0.7, shape = 'pentagon')
