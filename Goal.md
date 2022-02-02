# OUR GOAL:

- Find main **topics** of discussion in the corpus
- Find who are the **person** which each topic is more associated with
- Find how does the **interest** on different topics evolve **over the time**
- Find which are the **sentiments** expressed in the letters how are they related with persons and topics, how do they evolve over the time

**Remember that our REAL goal isn't about solution but METODOLOGY: we need to have a clear idea on how solve the problem (or possibly to justify why we have found incorrect solution)**

# Open questions

## 1\. Supervised or unsupervised ??

Probabilmente un approccio misto: i primi obbiettivi sembrano essere unsupervised, in quanto si tratta di trovare di pattern all'interno del nostro set. L'ultimo obbiettivo potrebbe supervised perche' il sentiment potrebbe essere la nostra response variable (e le lettere/topics potrebbero essere le covariate).

# Road map

- Problem statement
- Some analysis on the dataset (?)

  - find #{letter per language}
  - provide some recap of number of send and recived

- Pre-processing set:

  - tokenize word
  - remove punctuation
  - to lowercase
  - remove stop words
  - stemming

- Find main topic on a single letter:

  - find the most frequent words -

# Brain storming

More ways to the first GOAL:

1. Consider the whole corpus and find main topics (finding the most used word ?)
2. Find the main topic on each letter and compute an average.

# Problem statement

Maybe we need formal problem statement for each GOAL.

## Find main topic of the corpus

Statement     | Description
:------------ | :----------------------------------------
Input         | a set D={d : d is a letter from/to Svevo}
Output        | an or more element T unknown
Learning data | no (?)
Dataset       | Corpus of Italo Svevo

```
Given a set of letters find the most relevant topic (topics)
```

Must define what is a relevant topic:

```
A relevant topic is a word which is more present than the other words
```

where:

```
A word is an element of a letter (already processed) d.
```
