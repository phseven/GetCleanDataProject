---
title: "r_analysis.rmd"
output: html_document
---

This program unzips an input Dataset.zip file into the current directory.
It merges the training and test datasets and replaces activity Id by
activity name. It averages the mean & standard deviation data for each 
subjectId and activityName. Meaningful column names are added and the final 
output is written to a ".csv" format file.

Input: Dataset.zip file containing subject, activity and accelerometer data
Output: Tidysams.csv, a file containing subjectId, activityName and average
mean and standard deviation data for each subjectId and activityName.

The input file will be read from current directory and the output file will
be written to the current directory.

1. Initialize column name vectors

```{r}
library("plyr")

# Mean and standard deviation feature columns

v.mscols <- c(
 "V1"
,"V2"
,"V3"
,"V4"
,"V5"
,"V6"
,"V41"
,"V42"
,"V43"
,"V44"
,"V45"
,"V46"
,"V81"
,"V82"
,"V83"
,"V84"
,"V85"
,"V86"
,"V121"
,"V122"
,"V123"
,"V124"
,"V125"
,"V126"
,"V161"
,"V162"
,"V163"
,"V164"
,"V165"
,"V166"
,"V201"
,"V202"
,"V214"
,"V215"
,"V227"
,"V228"
,"V240"
,"V241"
,"V253"
,"V254"
,"V266"
,"V267"
,"V268"
,"V269"
,"V270"
,"V271"
,"V294"
,"V295"
,"V296"
,"V345"
,"V346"
,"V347"
,"V348"
,"V349"
,"V350"
,"V373"
,"V374"
,"V375"
,"V424"
,"V425"
,"V426"
,"V427"
,"V428"
,"V429"
,"V452"
,"V453"
,"V454"
,"V503"
,"V504"
,"V513"
,"V516"
,"V517"
,"V526"
,"V529"
,"V530"
,"V539"
,"V542"
,"V543"
,"V552"
)

# Pretty names for mean and standard deviation feature columns for tidy data

tidy.mscols <- c(
 "tBodyAcc.mean.X"
,"tBodyAcc.mean.Y"
,"tBodyAcc.mean.Z"
,"tBodyAcc.std.X"
,"tBodyAcc.std.Y"
,"tBodyAcc.std.Z"
,"tGravityAcc.mean.X"
,"tGravityAcc.mean.Y"
,"tGravityAcc.mean.Z"
,"tGravityAcc.std.X"
,"tGravityAcc.std.Y"
,"tGravityAcc.std.Z"
,"tBodyAccJerk.mean.X"
,"tBodyAccJerk.mean.Y"
,"tBodyAccJerk.mean.Z"
,"tBodyAccJerk.std.X"
,"tBodyAccJerk.std.Y"
,"tBodyAccJerk.std.Z"
,"tBodyGyro.mean.X"
,"tBodyGyro.mean.Y"
,"tBodyGyro.mean.Z"
,"tBodyGyro.std.X"
,"tBodyGyro.std.Y"
,"tBodyGyro.std.Z"
,"tBodyGyroJerk.mean.X"
,"tBodyGyroJerk.mean.Y"
,"tBodyGyroJerk.mean.Z"
,"tBodyGyroJerk.std.X"
,"tBodyGyroJerk.std.Y"
,"tBodyGyroJerk.std.Z"
,"tBodyAccMag.mean"
,"tBodyAccMag.std"
,"tGravityAccMag.mean"
,"tGravityAccMag.std"
,"tBodyAccJerkMag.mean"
,"tBodyAccJerkMag.std"
,"tBodyGyroMag.mean"
,"tBodyGyroMag.std"
,"tBodyGyroJerkMag.mean"
,"tBodyGyroJerkMag.std"
,"fBodyAcc.mean.X"
,"fBodyAcc.mean.Y"
,"fBodyAcc.mean.Z"
,"fBodyAcc.std.X"
,"fBodyAcc.std.Y"
,"fBodyAcc.std.Z"
,"fBodyAcc.meanFreq.X"
,"fBodyAcc.meanFreq.Y"
,"fBodyAcc.meanFreq.Z"
,"fBodyAccJerk.mean.X"
,"fBodyAccJerk.mean.Y"
,"fBodyAccJerk.mean.Z"
,"fBodyAccJerk.std.X"
,"fBodyAccJerk.std.Y"
,"fBodyAccJerk.std.Z"
,"fBodyAccJerk.meanFreq.X"
,"fBodyAccJerk.meanFreq.Y"
,"fBodyAccJerk.meanFreq.Z"
,"fBodyGyro.mean.X"
,"fBodyGyro.mean.Y"
,"fBodyGyro.mean.Z"
,"fBodyGyro.std.X"
,"fBodyGyro.std.Y"
,"fBodyGyro.std.Z"
,"fBodyGyro.meanFreq.X"
,"fBodyGyro.meanFreq.Y"
,"fBodyGyro.meanFreq.Z"
,"fBodyAccMag.mean"
,"fBodyAccMag.std"
,"fBodyAccMag.meanFreq"
,"fBodyBodyAccJerkMag.mean"
,"fBodyBodyAccJerkMag.std"
,"fBodyBodyAccJerkMag.meanFreq"
,"fBodyBodyGyroMag.mean"
,"fBodyBodyGyroMag.std"
,"fBodyBodyGyroMag.meanFreq"
,"fBodyBodyGyroJerkMag.mean"
,"fBodyBodyGyroJerkMag.std"
,"fBodyBodyGyroJerkMag.meanFreq"
)

```

2. Unzip the Dataset.zip file in current directory.

```{r}
unzip("Dataset.zip", junkpaths=TRUE, exdir=".")
```

3. Read the subject ids from test and train datasets and merge them.

```{r}
# Read the subject ids

sub.tst <- read.table("subject_test.txt", col.names= "Subject")
sub.trn <- read.table("subject_train.txt", col.names= "Subject")

# Task1a: Merge the training and the test subjects to create one data set.

sub.tot <- rbind(sub.trn, sub.tst)

s.cnt <- length(sub.tot$Subject)
```

4. Read the activity labels data (format = (Id, Name), eg. (1 WALKING))

```{r}
# Read the activity labels

act.lbl <- read.table("activity_labels.txt", 
                      col.names= c("A.Id", "A.Name"))

# Error checking : check for duplicates

a.id.cnt <- length(act.lbl$A.Id)
a.uid.cnt <- length(unique(act.lbl$A.Id))
a.ulbl.cnt <- length(unique(act.lbl$A.Name))

stopifnot(a.id.cnt == a.uid.cnt)
stopifnot(a.id.cnt == a.ulbl.cnt)
```

5. Read activity Ids from test and training datasets and merge.

```{r}
# Read the activity ids

act.tst <- read.table("y_test.txt", col.names= "A.Id")
act.trn <- read.table("y_train.txt", col.names= "A.Id")

# Task1b: Merge the training and the test activity data to create one data set.

act.tot <- rbind(act.trn, act.tst)

```

6. Join with activity labels data by activity Id to get corresponding activity name. 
   Replace activity Id by activity name. Adavantage of using join() over merge() is, 
   join() preserves the original row ordering of the first argument dataframe, whereas
   merge() does not.

```{r}
# Task3: Use descriptive activity names to name the activities in the data set
# (i.e. replace activity id with activity name)

# The original row order of act.tot will be maintained in join() output

act.nm <- data.frame(
  join(act.tot, act.lbl, by= "A.Id", match= "first")[, "A.Name"])

names(act.nm) <- "Activity"
act.id.cnt <- length(act.nm$Activity)

# Error checking

stopifnot(all(!is.na(act.nm$Activity)))

```

7. Read the test and training datasets for all the features and merge them.

```{r}
# Read the feature test and training data

x.tst <- read.table("X_test.txt")
x.trn <- read.table("X_train.txt")

# Task1c: Merge the training and the test feature data sets to create one data set.

x.tot <- rbind(x.trn, x.tst)

x.cnt <- length(x.tot$V1)

# Error checking : no. of rows for x.tot, sub.tot and act.nm must match as
# they are logically vertical partitions of a single dataset 

stopifnot(x.cnt == s.cnt)
stopifnot(x.cnt == act.id.cnt)
```

8. Extract all the columns from the total feature dataset that contain mean and standard 
   deviation data.


```{r}
# Task2: Extract only the measurements on the mean and standard deviation 
# for each measurement.

x.sub <- x.tot[, v.mscols]
```

9. Combine subject Id, activity name and the mean and standard deviation data by row number.


```{r}
# Bind subject and activity name columns matched by rownum

sa <- cbind(sub.tot, act.nm)

# Bind (subject, activityname) with mean and standard deviation feature
# data columns, matched by rownum

sams <- cbind(sa, x.sub)
```

10. Change to more meaningful column names.


```{r}
# Task4a: Appropriately label the data set with descriptive variable names 

names(sams) <- c("Subject", "Activity", tidy.mscols)
```

11. Compute the columnwise average for mean and standard deviation column
    for each subject and activity name combination. Here, ddply is splitting
    the sams dataframe into smaller pieces based on unique (Subject, Activity)
    combinations and calling sapply for each piece. Sapply, in turn, is 
    calculating columnwise mean for each piece of the dataframe it is receiving.
    Finally ddply is combining all the output from sapply into a single dataframe.

```{r}
# Task5: Create a second, independent tidy data set with the average 
# of each variable for each activity and each subject; i.e. group by 
# subject and activity to get averages for each mean and standard
# deviation column of the dataframe

sams.avg <- ddply(sams, .(Subject, Activity), 
  .fun = function(x) {sapply(x[,3:ncol(x)], mean)})
```

12. Add "avg." prefix to all the mean and standard deviation column names to reflect
    the fact that now these columns are average values.

```{r}
# Task4b: Add "avg." prefix to mean and standard deviation columnnames

names(sams.avg) <- c("Subject", "Activity", paste0("avg.", tidy.mscols))
```

13. Save the dataframe as a csv file in the current directory.

```{r}
# Save the tidy dataset
write.csv(sams.avg, file="Tidysams.csv", row.names=FALSE)
```

14. Done. Output .csv file has 81 columns ( Subject Id + Activity name + 79 average mean / 
    standard deviation data columns) and 181 rows ( 30 subjects * 6 activities + 1 header row)


