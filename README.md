# question-classification
Identify Question Type : Given a question, the aim is to identify the category it belongs to.

##Steps to run 
` perl run.pl`   
` run R script - model.R in R console/ RStudio`   

## Input files
[I have used training data from following link] (http://cogcomp.cs.illinois.edu/Data/QA/QC/train_5500.label)
The data is further split into train and test data.

### Data Description
Training data comprises of different questions, categories and sub-categories.     

For eg : 

|Category | Sub-category | Question                                         |
| DESC    | manner       | How did serfdom develop in and then leave Russia ? | 
| ENTY    | cremat       | What films featured the character Popeye Doyle ?   |

Each question can be classified into following six categories

|CLASS	        |DEFINITION	|
| ------------- |:-------------:|
|ABBREVIATION	|abbreviation	|
|ENTITY	        |entities	|
|DESCRIPTION	|description and abstract concepts|
|HUMAN	        |human beings	|
|LOCATION	|locations	|
|NUMERIC	|numeric values	|

## Model
I have created a document matrix of the data and removed stopwords, punctuation, whitespaces and implemented stemming to prepare data for training model.  
Then, I have extracted top n terms in each topic to understand the data.  
After preparing the data, data is randomly split into test and training data.
Further, I have trained two models to classify the questions.  
First is random forest based model and Second is boosted multiclass logistic regression.
Both the models have an accuracy of ~72%. 

## Results
`Accuracy for RandomForest Model is 72.69%`    
Refer to randomForestPredictions.csv for the predictions on testdata.  

`Accuracy for Boosted Multiclass Logistic Regression is 71.35%`  
Refer to xgboostPredictions.csv for the predictions on testdata.

####
