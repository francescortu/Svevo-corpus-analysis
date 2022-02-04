library(tm)
library(dplyr)
library(tidytext)
library(textstem)
library(data.table)


# the following function performs all the steps needed to preprocess the whole corpus
#adjust columns, lower text, remove punctuation and numbers, then remove stop-words
sw_list_ita <- scan("stopwords_ita.txt", what="", sep="\n")
sw_list_eng <- scan("stopwords_eng.txt", what="", sep="\n")
clean_text <- function(corpus) {
  
  corpus$n <- corpus$n + 1
  names(corpus)[names(corpus) == 'n'] <- 'letter_number'
  
  names(corpus)[names(corpus) == 'corpus'] <- 'pair'
  corpus$pair <- gsub("Schmitz","Svevo", corpus$pair)
  
  corpus$tokens <- NA
  
  
  
  for(i in 1:nrow(corpus)) {
    #remove punctuation
    corpus$tokens[i] <- gsub("[^a-zA-Z]+"," ", tolower(corpus$text[i]))
    #remove words shorter than 3 chars
    corpus$tokens[i] <- gsub('\\b\\w{1,2}\\b',"", tolower(corpus$tokens[i]))
    
    #remove stop words
    if (grepl("ENG",corpus$mainLanguage[i])) {
      lang = "english"
      corpus$tokens[i] <- removeWords(corpus$tokens[i], c(stopwords(lang),  sw_list_eng))
    }
    if (grepl("ITA",corpus$mainLanguage[i])) {
      lang = "italian"
      corpus$tokens[i] <- removeWords(corpus$tokens[i], c(stopwords(lang), sw_list_ita))
    }
    if (grepl("FRE",corpus$mainLanguage[i])) {
      lang = "french"
      corpus$tokens[i] <- removeWords(corpus$tokens[i], stopwords(lang))
    }
    if (grepl("GER",corpus$mainLanguage[i])) {
      lang = "german"
      corpus$tokens[i] <- removeWords(corpus$tokens[i], stopwords(lang))
    }
    
    
  }
  
  return(corpus)
}

# read corpus
corpus <- read.csv("../csv/svevo_letters.csv", sep=";", encoding = "UTF-8")

# clean corpus and save csv
corpus <- clean_text(corpus)
fwrite(corpus, paste0("../csv/cleaned_svevo_dataset.csv"),col.names = TRUE)

# call python script to lemmatize tokens wrt the language used in each letter
system('python lemmatize.py')

####
corpus <- read.csv("../csv/cleaned_svevo_dataset.csv", sep=",", encoding = "UTF-8")

corpus_ita <- corpus[which(corpus$mainLanguage == "ITA"),]
for(i in c(1:nrow(corpus_ita))){
  corpus_ita$tokens[i] <- removeWords(corpus_ita$tokens[i], c(stopwords("italian"), sw_list_ita))
}
fwrite(corpus_ita, paste0("../csv/cleaned_svevo_dataset_ITA.csv"),col.names = TRUE)