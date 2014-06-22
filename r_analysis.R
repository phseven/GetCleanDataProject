#! /usr/bin/Rscript
#
# Input: Dataset.zip file containing subject, activity and accelerometer data
# Output: Tidysams.csv, a file containing subjectId, activityName and average
# mean and standard deviation data for each subjectId and activityName.
#
# The input file will be read from current directory and the output file will
# be written to the current directory.
#
# The program unzips the input zip file into the current directory.
# It merges the training and test datasets and replaces activityId by
# activity name. It averages the mean & standard deviation data for each 
# subjectId and activityName. Meaningful column names are added and the final 
# output is written to a ".csv" format file.
# 

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

# Unzip the Dataset.zip file in current directory (and remove the original path information)

unzip("Dataset.zip", junkpaths=TRUE, exdir=".")

# Read the subject ids

sub.tst <- read.table("subject_test.txt", col.names= "Subject")
sub.trn <- read.table("subject_train.txt", col.names= "Subject")

# Task1a: Merge the training and the test subjects to create one data set.

sub.tot <- rbind(sub.trn, sub.tst)

s.cnt <- length(sub.tot$Subject)

# Read the activity labels

act.lbl <- read.table("activity_labels.txt", 
                      col.names= c("A.Id", "A.Name"))

# Error checking : check for duplicates

a.id.cnt <- length(act.lbl$A.Id)
a.uid.cnt <- length(unique(act.lbl$A.Id))
a.ulbl.cnt <- length(unique(act.lbl$A.Name))

stopifnot(a.id.cnt == a.uid.cnt)
stopifnot(a.id.cnt == a.ulbl.cnt)

# Read the activity ids

act.tst <- read.table("y_test.txt", col.names= "A.Id")
act.trn <- read.table("y_train.txt", col.names= "A.Id")

# Task1b: Merge the training and the test activity data to create one data set.

act.tot <- rbind(act.trn, act.tst)

# Task3: Use descriptive activity names to name the activities in the data set
# (i.e. replace activity id with activity name)

# The original row order of act.tot will be maintained in join() output

act.nm <- data.frame(
	join(act.tot, act.lbl, by= "A.Id", match= "first")[, "A.Name"])

names(act.nm) <- "Activity"
act.id.cnt <- length(act.nm$Activity)

# Error checking

stopifnot(all(!is.na(act.nm$Activity)))

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

# Task2: Extract only the measurements on the mean and standard deviation 
# for each measurement.

x.sub <- x.tot[, v.mscols]

# Bind subject and activity name columns matched by rownum

sa <- cbind(sub.tot, act.nm)

# Bind (subject, activityname) with mean and standard deviation feature
# data columns, matched by rownum

sams <- cbind(sa, x.sub)

# Task4a: Appropriately label the data set with descriptive variable names 

names(sams) <- c("Subject", "Activity", tidy.mscols)

# Task5: Create a second, independent tidy data set with the average 
# of each variable for each activity and each subject; i.e. group by 
# subject and activity to get averages for each mean and standard
# deviation column of the dataframe

sams.avg <- ddply(sams, .(Subject, Activity), 
	.fun = function(x) {sapply(x[,3:ncol(x)], mean)})

# Task4b: Add "avg." prefix to mean and standard deviation columnnames

names(sams.avg) <- c("Subject", "Activity", paste0("avg.", tidy.mscols))

# Save the tidy dataset
write.csv(sams.avg, file="Tidysams.csv", row.names=FALSE)
