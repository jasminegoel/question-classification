# run.pl 
# run the perl script to parse train data
# train data : http://cogcomp.cs.illinois.edu/Data/QA/QC/train_5500.label

train <- read.csv('train.csv', header=FALSE, stringsAsFactors = FALSE,sep=";")
dim(train)
colnames(train) <- c('question','subtype','input')
train$question = as.factor(train$question)
str(train$question)
train$subtype = as.factor(train$subtype)

#load the required packages

require("tm")
require("SnowballC")
require(lda)
require(topicmodels)
require(ggplot2)
require(wordcloud)
require(stringdist)
require(caTools)
require(randomForest)
require(caret)
require(e1071)
require(xgboost)

# create corpus vector. Remove stopwords, numbers, punctuation and stemming.

j <- Corpus(VectorSource(train$input))
c <- tm_map(j, removeWords, stopwords('english'))
c <- tm_map(c, removeNumbers)
c <- tm_map(c, removePunctuation)
c <- tm_map(c, stripWhitespace)
c <- tm_map(c, content_transformer(tolower))
c <- tm_map(c, stemDocument)

#create document term matrix from corpus
dtm <- DocumentTermMatrix(c)
#dtm <- DocumentTermMatrix(c, control=list(weighting = function(x) weightTfIdf(x, normalize = FALSE)))
dim(dtm)
inspect(dtm[1:5, 1:20])

# Organize terms by their frequency:
freq <- colSums(as.matrix(dtm))
length(freq)
ord <- order(freq)

#plot high freq terms
wf <- data.frame(word=names(freq), freq=freq)   
head(wf)  
p <- ggplot(subset(wf, freq>100), aes(word, freq))    
p <- p + geom_bar(stat="identity")   
p <- p + theme(axis.text.x=element_text(angle=45, hjust=1))

findFreqTerms(dtm, lowfreq=20)

#remove sparse terms
sdtm = removeSparseTerms(dtm, 0.995)
questionssparse = as.data.frame(as.matrix(sdtm))
questionssparse$question = train$question

#populate column names
colnames(questionssparse) = make.names(colnames(questionssparse))

#Set parameters for Gibbs sampling
burnin <- 4000
#iter <- 2000
iter <- 100
thin <- 500
seed <-list(2003,5,63,100001,765)
nstart <- 5
best <- TRUE

#Number of topics
k <- 5

#Run LDA using Gibbs sampling
ldaOut <-LDA(dtm,k, method="Gibbs", control=NULL)
str(ldaOut)

#top n terms in each topic
ldaOut.terms <- as.matrix(terms(ldaOut,10))
write.csv(ldaOut.terms,file=paste("LDAGibbsTopicsToTerms.csv"))
ldaOut.terms

#probabilities associated with each topic assignment
topicProbabilities <- as.data.frame(ldaOut@gamma)
write.csv(topicProbabilities,file=paste("LDAGibbsTopicProbabilities.csv"))
topicProbabilities

#Find relative importance of top 2 topics
topic1ToTopic2 <- lapply(1:nrow(dtm),function(x)
  sort(topicProbabilities[x,])[k]/sort(topicProbabilities[x,])[k-1])
topic1ToTopic2

#Find relative importance of second and third most important topics
topic2ToTopic3 <- lapply(1:nrow(dtm),function(x)
  sort(topicProbabilities[x,])[k-1]/sort(topicProbabilities[x,])[k-2])
topic2ToTopic3

# Split the data into train and test data
set.seed(123)
split = sample.split(questionssparse$question, SplitRatio = 0.7)
trainSparse = subset(questionssparse, split==TRUE)
testSparse = subset(questionssparse, split==FALSE)
table(trainSparse$question)
table(testSparse$question)

# Train randomForest model 
rf1 = randomForest(question ~ . , data=trainSparse)
predictrf = predict(rf1, newdata = testSparse)

write.csv(predictrf, file = "randomForestPredictions.csv", row.names = FALSE)

confusionMatrix(predictrf,testSparse$question)

table(predictrf, testSparse$question)
(11+312+191+269+207+200)/1637
# 0.7269395
#Plot Importance Matrix
varImp(rf1)
varImpPlot(rf1)

# Train Boosted Multiclass logistic regression
# prepare data for xgboost

ytr = as.numeric(trainSparse$question)
yte = as.numeric(testSparse$question)
tr = trainSparse
te = testSparse
tr$question = NULL
te$question = NULL
tr = as.matrix(tr)
te =as.matrix(te)

#xgboost classes start from 0 instead of 1
ytr <- ytr -1
yte <- yte -1

# tune your model
param <- list("objective" = "multi:softmax",    # multiclass classification
"eval_metric" = "merror",    # evaluation metric
"nthread" = 3,   # number of threads to be used
"max_depth" = 8,    # maximum depth of tree
"eta" = 0.1,    # step size shrinkage
"gamma" = 0,    # minimum loss reduction
"subsample" = 1,    # part of data instances to grow tree
"colsample_bytree" = 1,  # subsample ratio of columns when constructing each tree
"min_child_weight" = 12,  # minimum sum of instance weight needed in a child
"num_class" = 6  # minimum sum of instance weight needed in a child
)

#train xgboost model
set.seed(9257)
system.time( xg1 <- xgboost(param=param, data=tr, label=ytr,nfold=10, nrounds=50, prediction=TRUE, verbose=TRUE) )
predictxg <- predict(xg1, te)
(178+298+235+279+178)/1637
# 0.7135003

predictxg = gsub("0","ABBR",predictxg)
predictxg = gsub("1","DESC",predictxg)
predictxg = gsub("2","ENTY",predictxg)
predictxg = gsub("3","HUM",predictxg)
predictxg = gsub("4","LOC",predictxg)
predictxg = gsub("5","NUM",predictxg)

write.csv(predictxg, file = "xgboostPredictions.csv", row.names = FALSE)
