# question-classification
Identify Question Type : Given a question, the aim is to identify the category it belongs to.

Steps to run 
` perl run.pl`
` run R script - model.R in R console/ RStudio`

## Input files
[I have used training data from following link] (http://cogcomp.cs.illinois.edu/Data/QA/QC/train_5500.label)

### Training Data Description
Training data comprises of different questions and categories.  
For eg : DESC:manner How did serfdom develop in and then leave Russia ?  
         ENTY:cremat What films featured the character Popeye Doyle ?  

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
I have trained two models to classify the questions.  
First is random forest based model and Second is boosted multiclass logistic regression  

## Results
`Accuracy for RandomForest Model is 72.69%`  
`Accuracy for Boosted Multiclass Logistic Regression is 71.35%`  

####
