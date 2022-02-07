import pandas
import pandas as pd
import numpy
import spacy
import sys

def lemmatize():
  sett = pd.read_csv("../csv/cleaned_svevo_dataset.csv")
  sett["doc"] =""
  sett["lemmatized_tokens"] = ""


  nlp_ita = spacy.load("it_core_news_sm")
  nlp_eng = spacy.load("en_core_web_sm")
  nlp_fr = spacy.load("fr_core_news_sm")
  nlp_de = spacy.load("de_core_news_sm")

  for x in range(sett.shape[0]):
      if sett["mainLanguage"][x] == "ITA" :
          sett["doc"][x] = nlp_ita(sett["tokens"][x])
      if sett["mainLanguage"][x] == "ENG" :
          sett["doc"][x] = nlp_eng(sett["tokens"][x])
      if sett["mainLanguage"][x] == "FRE" :
          sett["doc"][x] = nlp_fr(sett["tokens"][x])
      if sett["mainLanguage"][x] == "GER" :
          sett["doc"][x] = nlp_de(sett["tokens"][x])

  pos = ['PROPN', 'NOUN', 'VERB', 'ADJ']
  
  for i in range(sett.shape[0]):
      sett["lemmatized_tokens"][i] = " ".join(token.lemma_  for token in sett["doc"][i] if(token.pos_ in pos))

  sett.to_csv("../csv/cleaned_svevo_dataset.csv")


if __name__ == "__main__":
    lemmatize()
  
