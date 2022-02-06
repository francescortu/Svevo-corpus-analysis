import pandas as pd
from feel_it import EmotionClassifier, SentimentClassifier


data = pd.read_csv("https://gist.githubusercontent.com/vinid/2286d0ae3d0e39153257b7b6607bf189/raw/0073d5c037dd1daf13991a44a148d957b885d9cd/italian_emotion_classification.csv")

print(emotion_classifier.predict(data["sono molto felice"].values.tolist()))