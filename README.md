---
output: 
  html_document: 
    toc: true
    self_contained: false
    highlight: tango
    theme: flatly
---
# final project for the Johns Hopskins Getting and Cleaning Data

Doron Fingold January 23, 2025 

Instructions state : "The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis."

This repo included:

-   run_analysis.R: r code to reproduce the data tidying procedure.
-   codebook_tidy_data.pdf: code book for tidy date
-   codebook_averages_by_subject_activity.pdf: code book for 2nd data set for averages by subject and activity

## Setup
### Files
Download the following zip file

-   [UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

Unzip it in the same directory as `run_analysis.R` script and `getwd()`. 
Please note the data files are a little more than 280Mb.

### Required Libraries
The following packages are required to be installed:

-   `dplyr`, used to group and summarize the data 
-   `janitor`, used to clean column names

### Global Variables
The following variables can be adjusted if needed

-   `subject_name`, set as `"subject_id"`, column name for subjects records
-   `activity_name`, set as `"activity"`, column name for activity
-   `files_directory` set as `"UCI HAR Dataset/"`, identifies the directory where the files ar

## Run Analysis

`run_analysis.R`  returns a list with 2 data tables. 

Example code:
```
source("run_analysis.R")
tables <- run_analysis()
View(tables$tidy_data)
View(tables$averages_by_subject_activity)
```
### run_analysis
The `run_analysis` function calls the other functions in order, passing the dataset from one function to the other. See code below. It returns a list with
2 data tables: `tidy_data` and `averages_by_subject_activity`. It takes 1 argument: `export` which is default `FALSE` (do nothing). `TRUE` saves the tables as txt files in the same directory.
```
    main_data_table <- assemble_data()
    
    main_data_table <- select_columns(main_data_table)
    
    main_data_table <- factor_activities(main_data_table)
    
    main_data_table <- tidy_columns(main_data_table)
    
    averages_by_subject_activity <- get_averages(main_data_table)
    
    tables <- list(tidy_data = main_data_table,
                   averages_by_subject_activity = averages_by_subject_activity)
```
### assemble_data
`load_data` function loads train and test data from the txt files, merges the files together and returns one data table.

-   Load the data from the txt files into data tables. The datasets are broken down into 6 sets. most likely for predicting activity and subject using machine learning. 
    -   `train/subject_train.txt` and `test/subject_test.txt`: subject identifiers. 1 through 30.
    -   `train/X_train.txt` and `test/X_test.txt`: all the measurements, variable names are listed in `features.txt` and are assigned to `col.names` when data is loaded. 
    -   `train/y_train.txt` and `test/y_test.txt`: the activity codes. 6 in total. the labels are listed in `activity_labels.txt`.
-   Merge columns of each train and test data tables using `cbind`.
-   Merge test and train tables rows using `rbind`.
-   Return data table.

### select_columns
Function for selecting only required columns using regex.

-   Using `grep` to identify the columns that match our requirements being only variables for mean and standard deviation (std), as well as the subject_id and activity. regex: `mean|std|subject_id|activity`.
-   Using `grep` again this time to remove column name with `meanFreq` as they filter throw our initial pattern. (the instructions were ambiguous about needing this columns or not. I decided to exclude it)
-   Return data table.

### factor_activities
Function for factoring the activity variable using the labels in activity_labels.txt

-   Load the activity labels from `activity_labels.txt` into data table.
-   Using `factor` to replace the activity codes with corresponding labels.
-   return data table.

### tidy_columns

-   Uses `janitor::make_clean_names` to reformat column names. For example: old name: `tBodyAcc-mean()-X` becomes `t_body_acc_mean_x`. symbols such as `'('` `')'` `'-'` are removed. Capital letters are assumed to be new word and `_` is added in front of it. All capital letters are transformed to lower case.
-   From the features info document, we learn that prefix 'f' indicates frequency domain signals, and 't' denotes time. `gsub` is used to replace `'t_'` with `'time_'`, and `'f_'` with `'freq_'`.
-   Return data table

### get_averages
-   Creates data set with the average of each variable for each subject and activity.
using `dplyr::group_by` to group by `subject_id` and `activity` variables. 
-   Calculating the averages of all the measurements for each group using `dplyr::summarise_all`.
-    Return the results
