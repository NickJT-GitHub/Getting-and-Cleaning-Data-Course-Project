#set working directory
setwd("~/R Files/final")

#download zip file and unzip it
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfile <- "UCIDataSet.zip"
download.file(Url, zipfile)
unzip(zipfile)

library(dplyr)

#bring the text files into R
features <- read.table("./UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
Xtest <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
Ytest <- read.table("./UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
Xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
Ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt", col.names = "code")

#combine data sets
train <- cbind(subject_train, Ytrain, Xtrain)
test <- cbind(subject_test, Ytest, Xtest)
TrainTest <- rbind(train, test)

#remove all non used tables
rm(subject_test, Xtest, Ytest, subject_train, Xtrain, Ytrain, train, test)

#only keeping approprate columns
TrainTest <- TrainTest[, grepl("subject|code|mean|std", colnames(TrainTest), ignore.case = TRUE)]

#clean-up names
names(TrainTest)<-gsub("Acc", "Accelerometer", names(TrainTest))
names(TrainTest)<-gsub("Gyro", "Gyroscope", names(TrainTest))
names(TrainTest)<-gsub("BodyBody", "Body", names(TrainTest))
names(TrainTest)<-gsub("Mag", "Magnitude", names(TrainTest))
names(TrainTest)<-gsub("^t", "Time", names(TrainTest))
names(TrainTest)<-gsub("^f", "Frequency", names(TrainTest))
names(TrainTest)<-gsub("tBody", "TimeBody", names(TrainTest))
names(TrainTest)<-gsub("-mean()", "Mean", names(TrainTest), ignore.case = TRUE)
names(TrainTest)<-gsub("-std()", "STD", names(TrainTest), ignore.case = TRUE)
names(TrainTest)<-gsub("-freq()", "Frequency", names(TrainTest), ignore.case = TRUE)
names(TrainTest)<-gsub("angle", "Angle", names(TrainTest))
names(TrainTest)<-gsub("gravity", "Gravity", names(TrainTest))

#adding description for activities
TrainTest <- merge(TrainTest, activities, by='code', all.x=TRUE)

#summarizing the data
TrainTestMeans <- TrainTest %>% 
    group_by(subject, activity) %>%
    summarise_each(list(mean))

write.table(TrainTestMeans, "tidydata.txt", row.names = FALSE)

