# Svevo-corpus-analysis

Final project for "Introduction to ML" @ UNITS-DSSC

## OUR GOAL:

- Find main **topics** of discussion in the corpus
- Find who are the **person** which each topic is more associated with
- Find how does the **interest** on different topics evolve **over the time**
- Find which are the **sentiments** expressed in the letters how are they related with persons and topics, how do they evolve over the time

**Remember that our REAL goal isn't about solution but METODOLOGY: we need to have a clear idea on how solve the problem (or possibly to justify why we have found incorrect solution)**

## Open questions

**_1\. Supervised or unsupervised ??_**

Probabilmente un approccio misto: i primi obbiettivi sembrano essere unsupervised, in quanto si tratta di trovare di pattern all'interno del nostro set. L'ultimo obbiettivo potrebbe supervised perche' il sentiment potrebbe essere la nostra response variable (e le lettere/topics potrebbero essere le covariate).

## Road map

- [ ] Main problem statement

- [ ] Pre-processing set:

  - problem statement (Why we are doing this?)
  - divide between languages
  - tokenize word
  - remove punctuation
  - to lowercase
  - remove stop words
  - stemming

- [ ] Some analysis on the dataset (?)

  - find #{letter per language}
  - provide some recap of number of send and received letters
  - find the most used words in the corpus (and, why not, for each letter)
  - generate document-term-matrix

- [ ] Find main topic on the entire corpus:

  - discuss how to deal with different languages
  - choose the technique:

    - LDA
    - text network analysis

  - use the technique in our set

  - discuss the result

- [ ] Sentiment analysis (supervised)on a single letter:

  - choose what sentiments we want find out
  - assign features to words
  - set up train and test set (we could use pre-processed set to build up the model or create our set. Which is the best option in term of cost and effectiveness?)
  - find right model (tree, svm ...)
  - evaluate model

## Brain storming

More ways to the first GOAL:

1. Consider the whole corpus and find main topics (finding the most used word ?)
2. Find the main topic on each letter and compute an average.

## 1 Pre-processing

## 2 Find main topic of the corpus

Statement  | Description
:--------- | :-----------------------------------------------------------
Input      | a set X of processed set D={d : d is a letter from/to Svevo}
Output     | an or more element T unknown
Technique  | LDA (?)
R packages | _tm_, _topicmodels_

```
Given a set X of word find the most relevant topic (topics) T
```

where a topic is :

```
A topic T is a distribution over words
```

### How LDA works (magic)

Key points are:

- Every document is a mixture of topics
- Every topics is a mixture of words
- languages do not count

#### Input

K = number of topics. **We have to discuss how to choose K and other hyper-parameters.**

M = document-term-matrix

#### Output

T = set of topics (each topics is a collection of "correlated words") Each topic has a posterior probability
