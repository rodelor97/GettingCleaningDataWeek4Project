---
title: "README"
author: "Robert de Lorimier"
date: "1/16/2021"
output: html_document
---

## Overview

These data for this project is retrieved (see reference "Source Data Set") and contains data related to accelerometer experiments. The experiments were carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope. The original data captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. See the README.txt, for more details of the original data, found by default at "data/testData/UCI HAR Dataset" by the default after running the function to create the data. The folder, "sample_data" should contain the same set and is included in the project.

The data has been unified for the "tidy" data set, and only contains standard deviation and means values for the measurements for the first file, accelerometer_data.csv, and the mean of each of those measurements aggregated by student and activity in file, accelerometer_activity_subject_means.csv.

## Requirement

RStudio is required to re-Knit codebook html files. If you need to recreate the codebooks, please install RStudio.

## References

- Source Data Set: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
- Explanation of Data: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

## Tidy Data Set Replication Steps

This project includes an R script called run_analysis.R that is a script used to create the tidy datasets. To run, do these steps:

1.  From the project folder in the R command prompt, run 
  + ```source("run_analysis.R")```
2.  From the command prompt then run 
  + ```create_tidy_data()```

The function will perform these operations:

1. Download and expand the data from the website into the folder "data" by default, and creates a folder under it, "UCI HAR Dataset", with the data files.
2.  For each folder, "train" or "test" noted as ***```folder_name```***, these steps are performed:

    1.  Retrieve the main set of measurement data at ```folder_name```/X_```folder_name```.txt
    2.  Add the subject column from subject_```folder_name```/```folder_name```.txt to the main set.
    3.  Add the activity names in a column using ```folder_name```/y_```folder_name```.txt to look up the activity label in activity_labels.txt
    4.  Add the values in features.txt as the column headers, and modifying the names to more readable ones
    5.  Filter out only columns with standard deviation or means values.
    
3.  The two data sets are then unioned to create a single set of standard deviation and means values for the students and activities.
4.  A second data set is then also created, grouping by student and activity, with the mean of each measurement column.
5.  Two files are then created under the folder, "tidy_date":
  - accelerometer_data.csv for the full data set
  - accelerometer_activity_subject_means.csv, for the grouped data set by student and activity


## Codebook and Representation Generation

Codebook templates, CodeBook.Rmd and CodeBookGrouped.Rmd, are used to generate codebook representations in md and html formats. In order to create new representations, you will need to create the codebook data used in the generation process. To do this, follow these steps

1. From the RStudio command prompt in the project folder run commands to install the required libraries
   + install.packages("codebook")
   + install.packages("rio")
   + install.packages("future")
   + install.packages("labelled")
   + install.packages("dplyr")
   + install.packages("data.table")
   + For pdf: install.packages("tinytex")
2. Run the commands to create the codebook sources
   + ```source("codebookSourceCreator.R")```
   + ```create_accelerometer_codebook()```
   + ```create_accelerometer_grouped_codebook()```
   
Once the codebook source is generated, we can create the codebooks:

1. From RStudio open Codebook.Rmd for the main data set codebook, or CodebookGrouped.md, for the aggregated grouped data set
2. Choose "Knit" > "Knit to html" from the tab menu. This will create the md and html codebook representations.
  + For PDF, you can choose "Knit" > "Knit to PDF"



## License:

This original data set was used in this publication:

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.
