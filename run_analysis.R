# this script requires the download of https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# and for it to be unzipped in the same directory as this script

# load libraries
library(dplyr)
library(janitor)

# global variables
subject_name <- "subject_id"
activity_name <- "activity"
files_directory <- "UCI HAR Dataset/"
# a function that loads data from txt files
# and merges the files together and returns one data table
assemble_data <- function() {
    # load the features list
    features <- read_txt("features.txt", c("code", "features"))
    # column names from features list
    feature_names <- features[[2]]
    # load train data
    feature_train <- read_txt("train/X_train.txt", feature_names)
    # load train subject data
    subject_train <- read_txt("train/subject_train.txt", subject_name)
    # load train activity data
    activity_train <- read_txt("train/y_train.txt", activity_name)
    
    # load test data
    feature_test <- read_txt("test/X_test.txt", feature_names)
    # load test subjects
    subject_test <- read_txt("test/subject_test.txt", subject_name)
    # load test activity
    activity_test <- read_txt("test/y_test.txt", activity_name)
    
    # bind all three train tables
    dt_train <- cbind(subject_train, activity_train, feature_train)
    # bind all three train tables
    dt_test <- cbind(subject_test, activity_test, feature_test)
    
    #merge train and test data tables rows
    dt <- rbind(dt_train, dt_test)
    
    return(dt)
}
# helper function for loading data using read.table
read_txt <- function(file, names) {
    file <- paste0(files_directory, file)
    dt <- read.table(file,
                     sep = "",
                     header = FALSE,
                     col.names = names)
    return(dt)
}
# remove un-needed columns and tidy column names
select_columns <- function(dt) {
    # Extract only the measurements on the mean and standard deviation for each measurement.
    pattern <- paste0("mean|std|", subject_name, "|", activity_name)
    dt <- dt[, grep(pattern, colnames(dt))]
    
    # Drop columns with 'meanFreq'
    dt <- dt[, -grep("meanFreq", colnames(dt))]
    
    return(dt)
}
# function for factoring the activity variable using the labels in activity_labels.txt
factor_activities <- function(dt) {
    # load activity labels
    activity_labels <- read_txt("activity_labels.txt", c("code", "label"))
    # factor activities
    dt$activity <- factor(dt$activity,
                          levels = activity_labels[, 1],
                          labels = tolower(activity_labels[, 2]))
    return(dt)
}
# tidy column names
tidy_columns <- function(dt) {
    # tidy column names
    colnames(dt) <- make_clean_names(colnames(dt))
    colnames(dt) <- gsub("^t_", "time_", colnames(dt))
    colnames(dt) <- gsub("^f_", "freq_", colnames(dt))
    
    return(dt)
}
# creates data set with
# the average of each variable for each activity and each subject.
get_averages <- function(dt) {
    dt <- dt %>%
        group_by(subject_id, activity) %>%
        summarise_all(mean)
    return(dt)
}
# function to run the analysis and return 2 tidy data tables in a list
run_analysis <- function(export = FALSE) {
    main_data_table <- assemble_data()
    main_data_table <- select_columns(main_data_table)
    main_data_table <- factor_activities(main_data_table)
    main_data_table <- tidy_columns(main_data_table)
    averages_by_subject_activity <- get_averages(main_data_table)
    
    tables <- list(tidy_data = main_data_table,
                   averages_by_subject_activity = averages_by_subject_activity)
    # if save_csv == TRUE we save tables to csv
    if (export) {
        write.table(tables$tidy_data, "tidy_data.txt", row.name = FALSE)
        write.table(tables$averages_by_subject_activity,
                  "averages_by_subject_activity.txt", row.name = FALSE)
    }
    
    return(tables)
}