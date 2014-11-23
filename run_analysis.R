# Steve Burch
#
# Nov 19, 2014
# 
# load activity and column names
#
# load TEST data
#   subject_text (people)
#   X_test       (observations)
#   y_test       (activity)
#
# do a horizontal merge
# 
# load TRAIN data
#   subject_text (people)
#   X_train      (observations)
#   y_train      (activity)
#
# do a horizontal merge
# 
# rbind() TEST and TRAIN
#
# apply column names, activity labels, discard columns I don't want
# Group and apply mean()
#


# set working dir
setwd("E:/MyStuff/Myfiles/Coursera/3_GettingCleaningData/Course Project/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset")

# need dplyr for later on
library(dplyr)

# 
# load Activity Labels and Observation Column Labels
# 

# load activity "lookup table"
fil_activity_labels_text <- "activity_labels.txt"
df_activity_labels <- read.table(fil_activity_labels_text, header = FALSE)

# rename V1 column to "ActivityID", and V2 to "Activity"
colnames(df_activity_labels)[1] <- "ActivityID"
colnames(df_activity_labels)[2] <- "Activity"

# load observation (column) names
fil_features_text <- "features.txt"
df_features <- read.table(fil_features_text, header = FALSE)

# convert observation names to vector to use as column names()
featureColNames <- df_features[,2]

#
# we will add ID to each of the 3 tables to facilitate a horizonal merge()
#
# 
# WORK ON TEST DATA
# 

# load activities
fil_ytest_text <- "./test/y_test.txt"
df_activity <- read.table(fil_ytest_text, header = FALSE)

# rename V1 column to "ActivityID"
colnames(df_activity)[1] <- "ActivityID"

# add ID column to df_activity and populate it
numObs <- nrow(df_activity)
df_activity$ID <- seq(1, numObs)

# add Activity column and default to "NA", will fill in later
df_activity$Activity <- "NA"

##

# load subjects (people)
fil_subject_text <- "./test/subject_test.txt"
df_subjects <- read.table(fil_subject_text, header = FALSE)

# add ID column to df_subjects and populate it
numObs <- nrow(df_subjects)
df_subjects$ID <- seq(1, numObs)

# rename V1 column to "Subject"
colnames(df_subjects)[1] <- "Subject"

##

# load test observations
fil_xtest_text <- "./test/x_test.txt"
df_Obs <- read.table(fil_xtest_text, header = FALSE)

# apply feature column names
names(df_Obs) <- featureColNames

# add ID column to df_features and populate it
numObs <- nrow(df_Obs)
df_Obs$ID <- seq(1, numObs)

##

# merge Subject and Activity tables on ID column
df_allTest <- merge(df_subjects, df_activity, by="ID")

# merge that to Observation table on ID column
df_allTest <- merge(df_allTest, df_Obs, by="ID")


# 
# WORK ON TRAIN DATA
# 

# load activities (re-use df_activity)
df_activity <- NULL
fil_ytrain_text <- "./train/y_train.txt"
df_activity <- read.table(fil_ytrain_text, header = FALSE)

# rename V1 column to "ActivityID"
colnames(df_activity)[1] <- "ActivityID"

# add ID column to df_activity and populate it
numObs <- nrow(df_activity)
df_activity$ID <- seq(1, numObs)

# add Activity column and default to "NA", will fill in later
df_activity$Activity <- "NA"


##

# load subjects (people) (re-use df_subjects)
fil_subject_text <- "./train/subject_train.txt"
df_subjects <- read.table(fil_subject_text, header = FALSE)

# add ID column to df_subjects and populate it
numObs <- nrow(df_subjects)
df_subjects$ID <- seq(1, numObs)

# rename V1 column to "Subject"
colnames(df_subjects)[1] <- "Subject"

##

# load train observations (reuse df_Obs)
fil_xtrain_text <- "./train/x_train.txt"
df_Obs <- read.table(fil_xtrain_text, header = FALSE)

# apply feature column names
names(df_Obs) <- featureColNames

# add ID column to df_features and populate it
numObs <- nrow(df_Obs)
df_Obs$ID <- seq(1, numObs)

##

# merge Subject and Activity tables on ID column
df_allTrain <- merge(df_subjects, df_activity, by="ID")

# merge that to Observation table on ID column
df_allTrain <- merge(df_allTrain, df_Obs, by="ID")

##

# remove ID column, since no longer needed, from Train and Test, then rbind()
df_allTest$ID <- NULL
df_allTrain$ID <- NULL

# now rbind() the two into 1 big DF!
df_ALL <- rbind(df_allTest, df_allTrain)

# use dplyr to select() the colummns we wish to keep

## from the Course Blog, by David Hood, TA
## 
# "Based on column names in the features is an open question as to is the the entries 
#  that include mean() and std() at the end, or does it include entries with mean in 
#  an earlier part of the name as well. There are no specific marking critieria on the 
#  number of columns. It is up to you to make a decision and explain what you did to 
#  the data. Make it easy for people to give you marks by explaining your reasoning."

# in the end, I decided to keep the columns suchs as ...-mean(), and ...-meanFreq(), etc.

df_ALL <- select(df_ALL, Subject, ActivityID, Activity, contains("-mean"), contains("-std") )


# now update Activity column to the correct value, using ActivityID
df_ALL$Activity[df_ALL$ActivityID == 1] <- "WALKING"
df_ALL$Activity[df_ALL$ActivityID == 2] <- "WALKING_UPSTAIRS"
df_ALL$Activity[df_ALL$ActivityID == 3] <- "WALKING_DOWNSTAIRS"
df_ALL$Activity[df_ALL$ActivityID == 4] <- "SITTING"
df_ALL$Activity[df_ALL$ActivityID == 5] <- "STANDING"
df_ALL$Activity[df_ALL$ActivityID == 6] <- "LAYING"

# no longer need ActivityID column, since joins are done, so remove it
df_ALL$ActivityID <- NULL


# now Group and Summarize!
df_ALLSummarized <- df_ALL %>% group_by(Subject, Activity) %>% summarise_each(funs(mean))

# load new and improved Column Names I prepared, and re-label columns
# please see Code Book for steps/logic I used to rename
fil_newColNames <- "newCols.txt"
newColNames <- read.table(fil_newColNames, header = FALSE)
featureColNames <- newColNames[,1]
names(df_ALLSummarized) <- featureColNames


# write df out to a txt file
write.table(df_ALLSummarized, "run_analysis.txt", row.names=FALSE)


# END
