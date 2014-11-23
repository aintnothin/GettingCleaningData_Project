## Course Assignment Week 3
### Code Book for Getting and Cleaning Data

Submitted by:  Steven Burch
November 23, 2014

#### Study Design ####
The data was collected and organized by a team at the University of Irvine.  There are essentially 3 groupings of data:
 
1. Activity Names and Observations Names, contained in activity\_labels.txt and features.txt, respectively.
2. Test data, consisting of Activities, Subjects (people), and Observations, contained in y\_test.txt, subject\_test.txt, and x\_test.txt, respectively.
3. Training data, also consisting of Activities, Subjects (people), and Observations, contained in y\_train.txt, subject\_train.txt, and x\_train.txt, respectively.

A more detailed explanation by the UCI team can be found [here.](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

Activities, Subjects, and Observations for Test (and Training) data needed to be combined (horizontally merged) in order to produce one file from the Test data and one from the Training data.
 
Each set of Test tables - Activities, Subject, and Observations (and similarly for Training) has the same number of rows, and their logical connection is their ordinal position (1 through N) in the file.  To facilitate the horizontal merge I temporarily add an ID column to each data frame that the source files are loaded into.

After merging the Test files into one data frame, and then the Training files into one data frame, I then vertically joined them with rbind().

The result is a dataframe with the following structure:

1. ID (integer):		Observation number/row id
2. Subject (integer):	Subject’s identifier
3. ActivityID (integer):	ActivityID for this Subject/Observation
4. Activity (string):		Activity Description
5. and, 561 columns of measurements (Real)

This then sets the stage for completing the tidying up the data.

##### Steps Taken – Test Data #####

1. df\_activity\_labels is loaded with activity_labels.txt; column 1 renamed to “ActivityID”; column 2 renamed to “Activity”
2. df\_features is loaded with features.txt; the values in column 2 are loaded into vector featureColumns to be used as column names for Test and Train observations
3. df\_activity is loaded with TEST activities, y_test.txt; column 1 renamed to “ActivityID”; add column Activity and temporarily populate with “NA”
4. df\_subjects is loaded with TEST subjects, subject_text.txt; add column ID and populate with ordinal row number; rename column V1 to “Subject”
5. df\_Obs is loaded with TEST observation measurements, x_test.txt; apply featureColumn to name columns; add column ID and populate with ordinal row number
6. Merge (using ID) df\_subjects and df\_activity and put in df\_allTest, then merge df\_allTest and df\_Obs and put (overwrite) into df\_allTest.

##### Steps Taken – Train Data #####

1. df\_activity is loaded with TRAIN activities, y\_train.txt; column 1 renamed to “ActivityID”; add column Activity and temporarily populate with “NA”
2. df\_subjects is loaded with TRAIN subjects, subject\_train.txt; add column ID and populate with ordinal row number; rename column V1 to “Subject”
3. df\_Obs is loaded with TRAIN observation measurements, x\_train.txt; apply featureColumn names; add column ID and populate with ordinal row number
4. Merge (using ID) df\_subjects and df\_activity and put in df\_allTrain, then merge df\_allTrain and df\_Obs and put (overwrite) into df\_allTrain.

#### Final Steps ####

1. Remove ID column from df\_allTest and df\_allTrain
2. rbind() df\_allTest and df\_allTrain
3. Use dplyr select() to keep columns Subject, ActivityID, Activity, and any measurement column that contains the string “-mean” or “-std”.  The result is a total of 81 columns, and 10,299 rows.  This result is put into df\_ALL.
4. Column df\_ALL$Activity (which was initialized to “NA”) is updated to the activity description based on the row’s ActivityID and the values in df\_activity\_labels.
5. Column df\_ALL$ActivityID is no longer needed and is removed.
6. Using group\_by and summarise\_each, group df\_ALL by Subject, Activity, and apply the function mean() to the other columns (which are measurements), and put the result into df\_ALLSummarized.
7. From newCols.txt, load the improved column names I prepared (see relevant section below) into newColNames, and then pull column 2 into the vector featureColNames and use to rename the columns in df\_ALLSummarized.
8. Use write.table to dump df\_ ALLSummarized to file run_analysis.txt.

### Code Book ###
#### Script Variables ####
##### Key Data Frames #####
| Data Frame	            | File/Purpose                                      |
| ------------------------- | ------------------------------------------------- |
| df\_activity	            | Is loaded by y\_test.txt, y\_train.txt              |
| df\_subjects	            | Is loaded by subject\_test.txt, subject\_train.txt  |
| df\_Obs	                | Is loaded by x\_test.txt, y\_test.txt               |
| df\_activity_labels	    | Is loaded by activity\_lablels.txt                  |
| df\_features	            | Is loaded by features.txt                         |
| df\_allTest	            | Merge of Test Subject, Activity, Observations     |
| df\_allTrain	            | Merge of Training Subject, Activity, Observations | 
| d\f_All	                | rbind() of df\_allTest and df\_allTrain             |
| df\_AllSummarized	        | Final Output                                      |

##### Additional Variables #####
| Variable	        | Data Type	          | Purpose                         |
| ------------------| ------------------- | ------------------------------- |
| featureColNames   | Character vector    | Used to apply column names      |
| fil\_<zzzz\>\_text | Character	          | Several of these used for file names for read.table(), to load source data |
| numObs            | integer             | Used to hold row counts          | 
| newColNames       | Data Frame          | Used to load improved column names. |

##### Additional File(s) Required #####
| File Name	        | Purpose                                 |
| ----------------- | --------------------------------------- |
| newCols.txt       | My modified column names.               |

##### Additional Libaries Required #####
| Library Name      | Purpose                                 |
| ----------------- | --------------------------------------- |
| dplyr             | Need for select()                       |





### Description of Observation Variables ###

Below is the UCI download file’s  features_info.txt, and describes the variables (all 561 of them) and the logic used in naming them.  Not all details of the authors were obvious to me, but at least some cleaning up of the column names could be decided upon.

 <blockquote style="font-size:14px;">
Feature Selection
 
 The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. 
 These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. 
 
 Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 
 
 Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 
 
 Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 
 
 These signals were used to estimate variables of the feature vector for each pattern:  
 '-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.
 
 tBodyAcc-XYZ
 tGravityAcc-XYZ
 tBodyAccJerk-XYZ
 tBodyGyro-XYZ
 tBodyGyroJerk-XYZ
 tBodyAccMag
 tGravityAccMag
 tBodyAccJerkMag
 tBodyGyroMag
 tBodyGyroJerkMag
 fBodyAcc-XYZ
 fBodyAccJerk-XYZ
 fBodyGyro-XYZ
 fBodyAccMag
 fBodyAccJerkMag
 fBodyGyroMag
 fBodyGyroJerkMag
 
 The set of variables that were estimated from these signals are: 
 
 mean(): Mean value
 
 std(): Standard deviation
 
 mad(): Median absolute deviation 
 
 max(): Largest value in array
 
 min(): Smallest value in array
 
 sma(): Signal magnitude area
 
 energy(): Energy measure. Sum of the squares divided by the number of values.
  
 iqr(): Interquartile range 
 
 entropy(): Signal entropy
 
 arCoeff(): Autorregresion coefficients with Burg order equal to 4
 
 correlation(): correlation coefficient between two signals
 
 maxInds(): index of the frequency component with largest magnitude
 
 meanFreq(): Weighted average of the frequency components to obtain a mean frequency
 
 skewness(): skewness of the frequency domain signal
  
 kurtosis(): kurtosis of the frequency domain signal
  
 bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
 
 angle(): Angle between to vectors.
 
 Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:
 
 gravityMean
 
 tBodyAccMean
 
 tBodyAccJerkMean
 
 tBodyGyroMean
 
 tBodyGyroJerkMean
 
 The complete list of variables of each feature vector is available in 'features.txt'
 </blockquote>


So, the following edits were done to the column names originally contained in vector featureColNames (see Step 2 from “Steps Taken – Test Data”, above):

1. mean() was changed to MEAN
2.	std() was changed to STD
3.	names beginning with ‘t’ were changed to have prefix Time
4.	names beginning with ‘f’ were changed to have prefix FFT
5.	All names (except for Activity and Subject) were prefixed with AvgOf-, since the result set contains averages.
6.	BodyBody was changed to Body

This text file was then saved to newCols.txt, and used to label the columns of df_ALLSummarized.

