## This code creates tidy.txt for the Getting and Cleaning Data Week 4 Project

# Clean workspace
rm(list=ls())

# Libraries
library(reshape2)

# Global Options
options(stringsAsFactors=F)

# Download and Unzip the data
filename <- "dataset.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Read Labels and Features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
names(activityLabels)<-c('activityID', 'activityLabel')
features <- read.table("UCI HAR Dataset/features.txt")
names(features)<-c('featureID', 'feature')

# Only want mean and standard deviation from features
featuresWanted <- grep(".*mean.*|.*std.*", features$feature)

# Set up descriptive variable names
names(featuresWanted) <- features$feature[featuresWanted]
names(featuresWanted) = gsub('-mean', 'Mean', names(featuresWanted))
names(featuresWanted) = gsub('-std', 'Std', names(featuresWanted))
names(featuresWanted) <- gsub('[-()]', '', names(featuresWanted))

# Load training data 
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)
names(train)<-c("subject", "activity", names(featuresWanted))
remove(trainActivities)
remove(trainSubjects)

# Load test data
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)
names(test)<-c("subject", "activity", names(featuresWanted))
remove(testActivities)
remove(testSubjects)

# Combine train and test datasets
Data <- rbind(train, test)

# Convert activity and subject into factors
# Use descriptive activityLabels to identify each activity
Data$activity <- factor(Data$activity, levels = activityLabels$activityID, labels = activityLabels$activityLabel)
Data$subject <- as.factor(Data$subject)

# Use cleaned data to find mean of each variable
Data.melted <- melt(Data, id = c("subject", "activity"))
tidyData <- dcast(Data.melted, subject + activity ~ variable, mean)

# Save tidyData to a text file
write.table(tidyData, "tidy.txt", row.names = FALSE, quote = FALSE)