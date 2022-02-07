
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
wordcloud(corpus$tokens, scale = c(3, 1), min.freq = 100, colors = rainbow(30))


model <- readRDS("LDA/LDA_model_ita.rds")
model

plot(model$hclust)

set.seed(1234)
wordcloud(model$top_terms, scale = c(2,1), min.freq = 1000000, colors = rainbow(20))
wordcloud(words = model$top_terms, size = 1.6, scale=c(3.5,0.25), min.freq = 1,max.words=200,random.order=FALSE,rot.per=0.35,colors=brewer.pal(8,"Dark2"))


library(wordcloud2)

wordcloud2(data=model, size = 0.7, shape = 'pentagon')




negative <- read.table("negative.txt")
positive <- read.delim("positive.txt")

negative
negative <- as.vector(negative)

negative <- c(negative)
negative
for (x in model$top_terms) {
  if(x %in% negative){
    print("negative")
  }
}

if(is.element("polvere", negative)){
  print("negative")
}


for (x in 1:nrow(negative)) {
  if(negative[x,] == "abbandono"){
    print("negative")
  }
}

words <- model$top_terms
words


words <- as.data.frame(words)

sent <- words
for(x in sent){
  x <- "Neutral"
}

for (i in 1:nrow(sent)) {
  for (j in 1:ncol(sent)) {
    for (x in 1:nrow(negative)) {
      if(sent[i,j] == negative[x,]){
        sent[i,j] <- "Negative"
      }
    }
    for (x in 1:nrow(positive)) {
      if(sent[i,j] == positive[x,]){
        sent[i,j] <- "Positive"
      }
    }
    if(sent[i,j] != "Negative" && sent[i,j] != "Positive" ){
      sent[i,j] <- "Neutral"
    }
  }
}


for (x in sent) {
  for (i in 1:nrow(positive)) {
    if(x == positive[i,]){
      print("positive")
    }
  }
}


### Some plot on sentiments

df <- read.csv("../csv/cleaned_svevo_dataset_ITA.csv")

df$sadness


library(ggplot2)

ggplot() + 
  geom_line(data = df, aes(x = year, y = sadness, colour = "Sadness"), group = 1) +
  geom_smooth(data = df, aes(x = year, y = sadness, colour = "Sadness"), group = 1) +
  geom_line(data = df, aes(x = year, y = joy, colour = "Joy"), group = 1) +
  geom_smooth(data = df, aes(x = year, y = joy, colour = "Joy"), group = 1) +
  geom_line(data = df, aes(x = year, y = fear, colour = "Fear"), group = 1) +
  geom_smooth(data = df, aes(x = year, y = fear, colour = "Fear"), group = 1) +
  geom_line(data = df, aes(x = year, y = anger, colour = "Anger"), group = 1) +
  geom_smooth(data = df, aes(x = year, y = anger, colour = "Anger"), group = 1) +
  labs(color = "Emotions")


ggplot() + 
  geom_line(data = df, aes(x = year, y = positive, colour = "Positive"), group = 1) +
  geom_line(data = df, aes(x = year, y = negative, colour = "Negative"), group = 1) 



sad <- sum(df$sadness)

joy <- sum(df$joy)

fear <- sum(df$fear)

anger <- sum(df$anger)


tot <- sum(sad, joy, fear, anger)


data <- data.frame(
  group=c("Sadness", "Joy", "Fear", "Anger"),
  value=c(sad/tot*100,joy/tot*100,fear/tot*100,anger/tot*100)
)

length(data$value)
for (i in 1:length(data$value)) {
  data$value[i] = round(data$value[i], digits = 1)
}

mycols <- c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF")

data <- data %>%
  arrange(desc(group)) %>%
  mutate(lab.ypos = cumsum(value) - 0.5*value)
data

ggplot(data, aes(x="", y=value, fill=group)) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0)+
  labs(fill = "Emotions")+
  geom_text(aes(y = lab.ypos, label = value), color = "white", size = 9)+
  scale_fill_manual(values = mycols) +
  theme_void()





