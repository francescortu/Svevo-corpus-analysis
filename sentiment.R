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
wordcloud(corpus$tokens, scale = c(2, 1), min.freq = 100, colors = rainbow(30))


model <- readRDS("../LDA/LDA_model_ita.rds")
model

plot(model)

