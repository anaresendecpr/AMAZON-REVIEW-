# -*- coding: utf-8 -*-
"""review.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/17tRUxYnndYJKq6py68Wj8xM7H-Ubl6e0
"""

#Basic libraries
import pandas as pd 
import numpy as np 
import ast
import csv 
import seaborn as sns
from google.colab import drive
drive.mount("/content/drive", force_remount = True)
reviews = pd.read_csv ("/content/drive/MyDrive/Takeaway/reviews_Clothing_Shoes_and_Jewelry_5.csv")

"""## **Data Exploration and Cleasing**"""

clean_reviews=reviews.copy()

clean_reviews.head()

clean_reviews.info()

clean_reviews.describe()

clean_reviews.isnull().sum()

#Treating null values and dropping unnecessary collumns
clean_reviews['reviewText']=clean_reviews['reviewText'].fillna('Missing')
clean_reviews['reviewerName']=clean_reviews['reviewerName'].fillna('Unknown')
clean_reviews['summary']=clean_reviews['summary'].fillna('Missing')

clean_reviews = clean_reviews.rename(columns={'overall':'productRating'})

#Assigning sentiment to rating of the product

def feedback(row):
      
    if row['productRating'] <= 2.0:
        val = 'Negative' 
    elif row['productRating'] == 3.0:
        val = 'Neutral' 
    elif row['productRating'] >= 4.0:
        val = 'Positive'
    else:
        val = -1
    return val

clean_reviews['productFeedback'] = clean_reviews.apply(feedback, axis=1)
clean_reviews.head()

#Genarating rate from helpfulness rating of the review
def rate(val):
    values = ast.literal_eval(val)
    if values[1] != 0:
          return values[0]/values[1]
    else:
        return 0
  

clean_reviews['helpRate'] = reviews.helpful.map(rate)
clean_reviews['helpRate']= clean_reviews['helpRate'].round(2) 
clean_reviews['numOfWords'] = clean_reviews['reviewText'].map(lambda x: len(x.split()))
clean_reviews['review_len'] = clean_reviews['reviewText'].map(len)

#Assigning sentiment to rate from helpfulness rating of the review

def helpfulness(row):
      
    if row['helpRate'] <= 0.20:
        val = 'Not Helpfull' 
    
    elif row['helpRate'] >= 0.50:
        val = 'Helpfull'
    else:
        val = -1
    return val
    
clean_reviews['helpfulness'] = clean_reviews.apply(helpfulness, axis=1)

#Processing variable date

newDate = clean_reviews['reviewTime'].str.split(",", n = 1, expand = True) 
newDate["date"] = newDate[0] + newDate[1]
newDate['date'] = newDate['date'].str.replace(' ', '/')
clean_reviews["date"] = newDate['date']
clean_reviews["date"]= pd.to_datetime(clean_reviews["date"])

clean_reviews=clean_reviews.drop(['helpful','unixReviewTime','reviewTime'], axis=1)
clean_reviews = clean_reviews.drop(clean_reviews.columns[[0]], axis=1)
clean_reviews['reviews']=clean_reviews['reviewText']+ clean_reviews['summary']
clean_reviews=clean_reviews.drop(['reviewText', 'summary'], axis=1)

pd.DataFrame(clean_reviews.groupby('productFeedback')['helpRate'].mean())

clean_reviews.head()

clean_reviews.to_csv(r'/content/drive/MyDrive/Takeaway/clean_reviews.csv', index = False, sep=';', decimal=',')