#' Script to create code books for accelerometer data and the aggregated accelerometer data
#' # REQUIRES INSTALLATION OF 
#' - codebook
#' - rio
#' - future
#' - labelled
#' - dplyr
#' - data.table
#' 
#' @description 
#' This class has x functions:
#' - create_accelerometer_codebook: A top level function, created 
#' - create_accelerometer_aggregated_codebook: A top level function, it pulls a set of data from a remote http(s) 
#' location and creates the tidy data set files in a new tidy_datasets folder.



#' This function creates the codebook data for the accelerometer tidy set. It is 
#' used by the accelerometerCodebook.Rmd to create a codebook to describe the data.
#' 
#' @examples
#' > create_accelerometer_codebook()
#'
#' @export
create_accelerometer_codebook <- function() {
  #  install.packages("codebook")
  library(codebook)
  #  install.packages("rio")
  library(rio)
  #  install.packages("future")
  library(future)
  #  install.packages("labelled")
  library(labelled)
  #  install.packages("dplyr")
  library(dplyr)
  
  #  install.packages("data.table")
  library(data.table)
  
  # CREATE THE BASE CODE BOOK
  print("CREATE THE BASE CODE BOOK")
  #codebook::new_codebook_rmd()
  codebook_data <- rio::import("tidy_datasets/accelerometer_data.csv")
  
  # ADD THE TOP LEVEL METADATA
  print("ADD THE TOP LEVEL METADATA")
  metadata(codebook_data)$name <- "Accelerometer Standard Deviation and Mean Data"
  metadata(codebook_data)$description <- "This data set contains the standard deviation and mean of the original data. See the README.txt found in the original data, \"sample_data/getdata_projectfiles_UCI_HAR_Dataset/UCI HAR Dataset/README.txt\", for more information."
  metadata(codebook_data)$creator <- "Robert de Lorimier"
  metadata(codebook_data)$citation <- "Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012"
  metadata(codebook_data)$url <- "https://github.com/rodelor97/GettingCleaningDataWeek4Project"
  metadata(codebook_data)$datePublished <- "2021-01-23"
  metadata(codebook_data)$spatialCoverage <- "Online"
  
  # ADD THE COLUMN LEVEL METADATA
  print("ADD THE COLUMN LEVEL METADATA")
  accel_data_df <- fread("tidy_datasets/accelerometer_data.csv")
  col_labels <- names(accel_data_df)
  col_descr <- lapply(col_labels, create_explanation_from_column_name)
  label_list <- create_label_description_list(col_labels, col_descr)
  var_label(codebook_data) <- label_list
  
  # CREATE THE CODEBOOK
  print("CREATE THE CODEBOOK DATA")
  if(!file.exists("codebook_source")) {
    dir.create("codebook_source")
  }
  rio::export(codebook_data, "codebook_source/accellerometer.rds")
  
  print("DONE")
}

#' This function creates the codebook data for the accelerometer tidy set 
#' grouped by student and activity and aggregated each measurement column by 
#' mean. It is used by the accelerometerGroupedCodebook.Rmd to create a codebook 
#' to describe the data.
#' 
#' @examples
#' > create_accelerometer_codebook()
#'
#' @export
create_accelerometer_grouped_codebook <- function() {
  #  install.packages("codebook")
  library(codebook)
  #  install.packages("rio")
  library(rio)
  #  install.packages("future")
  library(future)
  #  install.packages("labelled")
  library(labelled)
  #  install.packages("dplyr")
  library(dplyr)
  
  #  install.packages("data.table")
  library(data.table)
  
  # CREATE THE BASE CODE BOOK
  print("CREATE THE BASE CODE BOOK")
  #codebook::new_codebook_rmd()
  codebook_data <- rio::import("tidy_datasets/accelerometer_activity_subject_means.csv")
  
  # ADD THE TOP LEVEL METADATA
  print("ADD THE TOP LEVEL METADATA")
  metadata(codebook_data)$name <- "Grouped Accelerometer Standard Deviation and Mean Data by Student and Activity"
  metadata(codebook_data)$description <- "This data set contains the standard deviation and mean of the original data. See the README.txt found in the original data, \"sample_data/getdata_projectfiles_UCI_HAR_Dataset/UCI HAR Dataset/README.txt\", for more information."
  metadata(codebook_data)$creator <- "Robert de Lorimier"
  metadata(codebook_data)$citation <- "Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012"
  metadata(codebook_data)$url <- "https://github.com/rodelor97/GettingCleaningDataWeek4Project"
  metadata(codebook_data)$datePublished <- "2021-01-23"
  metadata(codebook_data)$spatialCoverage <- "Online"
  
  # ADD THE COLUMN LEVEL METADATA
  print("ADD THE COLUMN LEVEL METADATA")
  accel_data_df <- fread("tidy_datasets/accelerometer_activity_subject_means.csv")
  col_labels <- names(accel_data_df)
  col_descr <- lapply(col_labels, create_explanation_from_column_name)
  label_list <- create_label_description_list(col_labels, col_descr)
  var_label(codebook_data) <- label_list
  
  # CREATE THE CODEBOOK
  print("CREATE THE CODEBOOK DATA")
  if(!file.exists("codebook_source")) {
    dir.create("codebook_source")
  }
  rio::export(codebook_data, "codebook_source/accellerometer_grouped.rds")
  
  print("DONE")
}

#' This creates a list using a vector of column labels as the list item name and 
#' descriptions as the list item value
#' 
#' @param col_labels A vector of strings values of labels
#' @param col_descr A vector of string values of descriptions
#' @return A list with two dataframes, the unaggregated data "result_set", and aggregated data tables "aggregated_set"
#' @examples
#' > label_list <- create_label_description_list(col_labels, col_descr)
#'
#' @export
create_label_description_list <- function(col_labels, col_descr) {
  lab_descr_list = list()
  i <- 0
  for (label in col_labels) {
    i <- i + 1
    lab_descr_list[label] = col_descr[i]
  }
  lab_descr_list
}

#' This function converts the column value to a more human readable description
#' 
#' @param col_name A string value of the column
#' @return A description of the column
#' @examples
#' > descr <- create_explanation_from_column_name("frequ_body_accel_jerk_mean_freq_z")
#' > descr
#' [1] "Fast fourier tranform frequecy signal, body acceleration jerk mean freq Z axis,"
#'
#' @export
create_explanation_from_column_name <- function(col_name) {
  library(stringr)
  returncolumn_name <- col_name
  
  returncolumn_name <- gsub("^grouped_studentactivity_mean_of_", "the mean of data grouped by student and activity for ", returncolumn_name)
  returncolumn_name <- gsub("timeof_", " time domains signal (50Hz const rate), ", returncolumn_name)
  returncolumn_name <- gsub("frequ", " fast fourier tranform frequecy signal, ", returncolumn_name)
  returncolumn_name <- gsub("_x", " X axis, ", returncolumn_name)
  returncolumn_name <- gsub("_y", " Y axis, ", returncolumn_name)
  returncolumn_name <- gsub("_z", " Z axis, ", returncolumn_name)
  returncolumn_name <- gsub("_std", " standard deviation ", returncolumn_name)
  returncolumn_name <- gsub("_mean", " mean ", returncolumn_name)
  returncolumn_name <- gsub("angle", " angle of ", returncolumn_name)
  returncolumn_name <- gsub("_body_body", " body to body ", returncolumn_name)
  returncolumn_name <- gsub("_magn", " euclidean norm magnitude ", returncolumn_name)
  returncolumn_name <- gsub("_gyro", " gyroscope 3-axial raw signal ", returncolumn_name)
  returncolumn_name <- gsub("_accel", " acceleration ", returncolumn_name)
  returncolumn_name <- gsub("_", " ", returncolumn_name)
  returncolumn_name <- gsub("[ ]+", " ", returncolumn_name)
  returncolumn_name <- gsub("[ ]+$", "", returncolumn_name)
  returncolumn_name <- gsub("^[ ]+", "", returncolumn_name)
  returncolumn_name <- paste(toupper(substring(returncolumn_name, 1,1)), substring(returncolumn_name, 2,str_length(returncolumn_name)), sep="")
  returncolumn_name 
}
