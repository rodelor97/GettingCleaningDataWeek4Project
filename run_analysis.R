#' Script to package data for wearable computing measurements into a tidy dataset.
#' 
#' @description 
#' This class has 9 functions:
#' - create_tidy_data: The top level function, it pulls a set of data from a 
#' remote http(s) location and creates the tidy data set files in a new 
#' tidy_datasets folder.
#' - create_student_activity_grouped_mean_df: Take the main unaggregated set and 
#' aggregates the data by student and activity, with the mean of all measurement columns
#' - prepend_column_name_with_groupedmeans: Prepends the column name with 
#' "grouped_studentactivity_mean_of_"
#' - get_packaged_data_set: This function retrieves data from either of the 
#' folders "train" or "test", 
#' and returns a formatted data table with results, subject, and activity data,
#' formatted with appropriate headers
#' - get_subject_id_df: Retreives the subject id data from the appropriate 
#' folder and returns as a data.table
#' - get_activity_df: Retreives the activtiy id data from the parent folder and 
#' returns as a data.table
#' - get_result_set_df: Retreives the results data from the appropriate folder 
#' and returns as a data.table
#' - get_selected_column_names_and_indexes_df: Retreives the column header data 
#' for the result set from the parent folder and returns a formatted subset as a 
#' data.table
#' - rename_column: A utilitiy function that alters the name of a column string 
#' to a more readable form, used in get_selected_column_names_and_indexes_df


#' This function retrieves data from the accelerometer website and creates two 
#' tidy sets of data from it  for accelerometer data, one for the standard 
#' deviation and means data, and another for the grouped mean of each selected 
#' field, grouped by subject and activity.
#' 
#' @param data_dir A directory where the downloaded data will expanded, defaults
#' to "data"
#' @param dataZipUrl A url where the data zip file is located, defaults to 
#' "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#' @param tidy_data_folder A folder location where the tidy data comma 
#' delimited files are persisted.
#' @return A list with two dataframes, the unaggregated data "result_set", and aggregated data tables "aggregated_set"
#' @examples
#' > create_tidy_data(data_dir = "data", data_zip_url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", tidy_data_folder = "tidy_datasets")
#'
#' @export
create_tidy_data <- function(
  data_dir = "data", 
  data_zip_url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
  tidy_data_folder = "tidy_datasets"
  ) {
  print("START")
  # LIBRARIES / DEPENDENCIES
  
#  install.packages("RCurl")
  library(RCurl)
#  install.packages("data.table")
  library(data.table)
#  install.packages("dplyr")
  library(dplyr)
  
  # SET UP DATA LOCATIONS AND VARIABLES
  print("Set up data location and variables")
  unlink(data_dir, recursive = TRUE)
  dir.create(data_dir)
  downloadZipfileLocation <- paste(data_dir, "testData.zip", sep="/")
  downloadExpandedFolderLocation <- paste(data_dir, "testData", sep="/")
  dataUrl <- data_zip_url
  print(paste("Download data to ", downloadZipfileLocation, " and expand to ", downloadExpandedFolderLocation, sep=""))
  download.file(url=data_zip_url, downloadZipfileLocation, method='curl')
  unzip(downloadZipfileLocation, exdir=downloadExpandedFolderLocation)
  topRootFolder <- dir(downloadExpandedFolderLocation)[1]
  root_path <- paste(downloadExpandedFolderLocation, topRootFolder, sep="/")
  print(paste("Root folder is  ", root_path, sep=""))
  
  # EXTRACT AND PACKAGE DATA
  
  # CREATE ACTIVITY LOOKUP DATAFRAME
  print("Create activity and lookup dataframe")
  activity_lookup_df <- fread(paste(root_path, "activity_labels.txt", sep="/"))
  names(activity_lookup_df) <- c("activity_id", "activity_name")
  
  # GET STANDARD DEVIATON AND MEANS C0LUMNS INDEXES AND CREATE HUMAN READABLE COLUMN NAMES
  print("Create dataframe for results headers and indexes")
  selected_column_names_indexes_df <- get_selected_column_names_and_indexes_df(root_path)

  # GET EACH PACKAGED DATAFRAME FROM TRAIN AND TEST AND UNION THEM
  print("Get formatted result sets from test and train folders")
  testDF <- get_packaged_data_set(root_path, "test", selected_column_names_indexes_df, activity_lookup_df)
  trainDF <- get_packaged_data_set(root_path, "train", selected_column_names_indexes_df, activity_lookup_df)
  print("Create tidy set data tables")
  fullDF <- rbind(testDF, trainDF)
  aggDF <- create_student_activity_grouped_mean_df(fullDF)
  
  # Union the various test and train dataframes
  print(paste("Write tidy sets to ", tidy_data_folder, sep=""))
  unlink(tidy_data_folder, recursive = TRUE)
  dir.create(tidy_data_folder)
  fwrite(fullDF, file = paste(tidy_data_folder, "accelerometer_data.csv", sep="/"))
  write.table(fullDF, file = "data/accelerometer_send.txt", row.names = FALSE)
  fwrite(aggDF, file = paste(tidy_data_folder, "accelerometer_activity_subject_means.csv", sep="/"))
  print("END")
  return_list <- list(result_set=fullDF, aggregated_set=aggDF)
  return(return_list)
}

#' This function takes the main unaggregated set and aggregates the data by 
#' student and activity, with the mean of all measurement columns. The column 
#' header are prepended with indication that the values are aggregated means.
#' 
#' @param df The unaggregate accelerometer data table
#' @examples
#' > aggDF <- create_student_activity_grouped_mean_df(fullDF)
#' @return An aggregated data table with altered columns
#' @export
create_student_activity_grouped_mean_df <- function(df) {
  aggr_df = aggregate(x=df[,3:86], by=list(grouped_activity=df$activity_name, grouped_subject=df$subject_id), FUN=mean, na.rm=TRUE)
  col_labels <- names(aggr_df)
  altered_colnames <- lapply(col_labels, prepend_column_name_with_groupedmeans)
  names(aggr_df) <- altered_colnames
  return(aggr_df)
}

#' Prepends the column name with "grouped_studentactivity_mean_of_"
#' 
#' @param colName string of the column name
#' @examples
#' > newColName <- prepend_column_name_with_groupedmeans("timeof_body_accel_mean_x")
#' > newColName
#' [1] "grouped_studentactivity_mean_of_ timeof_body_accel_mean_x"
#' @return A new string with appended value
#' @export
prepend_column_name_with_groupedmeans <- function(col_name) {
  if(col_name == "grouped_subject" || col_name == "grouped_activity") {
    return(col_name)
  } else {
    return(paste("grouped_studentactivity_mean_of_", col_name, sep=""))
  }
}

#' This function retrieves data from either of the folders "train" or "test", 
#' and returns a formatted data table with results, subject, and activity data,
#' formatted with appropriate headers
#' 
#' @param root_path The root path under which the train and test folders are located
#' to "data"
#' @param folder_type Either "test" or "train", the two folders with result data
#' @param target_columns_df A data table with the column header labels and indices
#' to select the appropriate columns
#' @param activity_lookup_df A data table with the activity ids and label to add
#' as a column to the result set data table
#' @examples
#' > get_packaged_data_set("/path/to/data/folder", "test", target_columns_df, activity_lookup_df)
#' @return Formatted data table with headers, subject id, activity, results for 
#' selected column for mean and standard deviation
#' @export
get_packaged_data_set <- function(root_path, folder_type, target_columns_df, activity_lookup_df) {
  # CREATE SUBJECT ID DATAFRAME
  subjectIdDF <- get_subject_id_df(root_path, folder_type)
  # CREATE ACTION ID DATAFRAME
  actionDF <- get_activity_df(root_path, folder_type, activity_lookup_df)
  # CREATE RESULT DATAFRAME
  resultDF <- get_result_set_df(root_path, folder_type, target_columns_df)
  # CREATE PACKAGES DATAFRAME AND RETURN
  returnDf <- cbind(subjectIdDF, actionDF)
  returnDf <- cbind(returnDf, resultDF)
  returnDf
}

#' This function retreives the subject id data from the appropriate folder and 
#' returns as a data.table
#' 
#' @param root_path The root path under which the train and test folders are located
#' to "data"
#' @param folder_type Either "test" or "train", the two folders with result data
#' @examples
#' > get_subject_id_df("/path/to/data/folder", "test")
#' @return Formatted data table with subject id column
#' @export
get_subject_id_df <- function(root_path, folder_type) {
  subjectFileName <- paste("subject_", folder_type, ".txt", sep="")
  subjectIdDF <- fread(paste(root_path, folder_type, subjectFileName, sep = "/"))
  names(subjectIdDF) <- c("subject_id")
  subjectIdDF
}

#' This function retreives the activtiy id data from a sub-folder and 
#' returns as a data.table
#' 
#' @param root_path The root path under which the train and test folders are located
#' to "data"
#' @param folder_type Either "test" or "train", the two folders with result data
#' @param activity_lookup_df data table with activity lookup ids to labels
#' @examples
#' > get_activity_df("/path/to/data/folder", "test", activity_lookup_df)
#' @return Formatted activity column data table to join with results data table
#' @export
get_activity_df <- function(root_path, folder_type, activity_lookup_df) {
  actionFileName <- paste("y_", folder_type, ".txt", sep="")
  actionIdDF <- fread(paste(root_path, folder_type, actionFileName, sep = "/"))
  names(actionIdDF) <- c("activity_id")
  actionsLabelDf <- merge(actionIdDF, activity_lookup_df, by = "activity_id")
  actionsLabelDf$activity_id = NULL
  actionsLabelDf
}

#' This function retreives the result data from a sub-folder and returns as a data.table
#' 
#' @param root_path The root path under which the train and test folders are located
#' to "data"
#' @param folder_type Either "test" or "train", the two folders with result data
#' @param target_columns_df data table headers and indexes to select columns
#' @examples
#' > get_result_set_df("/path/to/data/folder", "test", target_columns_df)
#' @return Formatted result set data table with formatted column names and only
#' standard deviation and mean columns
#' @export
get_result_set_df <- function(root_path, folder_type, target_columns_df) {
  resultFileName <- paste("X_", folder_type, ".txt", sep="")
  resultDF <- fread(paste(root_path, folder_type, resultFileName, sep = "/"))
  resultDF <- resultDF[, target_columns_df$index, with = FALSE]
  names(resultDF) <- target_columns_df$measure
  resultDF
}

#' This function retreives the column header data for the result set from the 
#' parent folder and returns a formatted subset as a data.table
#' 
#' @param root_path The root path under which the train and test folders are located
#' to "data"
#' @examples
#' > get_selected_column_names_and_indexes_df("/path/to/data/folder")
#' @return Formatted column names and indexes of only standard deviation and mean 
#' columns
#' @export
get_selected_column_names_and_indexes_df <- function(root_path) {
  resultSetcolumn_names <- fread(paste(root_path, "features.txt", sep="/"))
  names(resultSetcolumn_names) <- c("index", "meas")
  target_columns_df <- resultSetcolumn_names[grep("([Mm]ean|std)", resultSetcolumn_names$meas)]
  target_columns_df <- mutate(target_columns_df, measure=rename_column(meas))
  target_columns_df$meas = NULL
  target_columns_df
}

#' This function alters a string value to a more human readable and appropriate
#' form for a header value. It alters the name to include:
#' - Changes "f" abbreviation to "frequ" as a more readable abbreviation for frequency measurement
#' - Changes "t" abbreviation to "timeof" as a more readable abbreviation for time of measurement
#' - Changes "acc" abbreviation to "accel" as a more readable abbreviation for acceleration
#' - Changes "mag" abbreviation to "magn" as a more readable abbreviation for magnitude
#' - Changes "mag" abbreviation to "magn" as a more readable abbreviation for magnitude
#' - Formats characters not appropriate for headers, such as parentheses and commas 
#' 
#' @param column_name String value to modify
#' @examples
#' > rename_column("tBodyAcc-mean()-Y")
#' @return Formatted column name
#' @export
rename_column <- function(column_name) {
  returncolumn_name <- gsub("([A-Z])", "_\\1", column_name)
  returncolumn_name <- tolower(returncolumn_name)
  returncolumn_name <- gsub("^f", "frequ_", returncolumn_name)
  returncolumn_name <- gsub("^t", "timeof_", returncolumn_name)
  returncolumn_name <- gsub("\\(", "_", returncolumn_name)
  returncolumn_name <- gsub("\\)", "_", returncolumn_name)
  returncolumn_name <- gsub("-", "_", returncolumn_name)
  returncolumn_name <- gsub(",", "_", returncolumn_name)
  returncolumn_name <- gsub("_t_", "_timeof_", returncolumn_name)
  returncolumn_name <- gsub("acc", "_accel", returncolumn_name)
  returncolumn_name <- gsub("mag", "_magn", returncolumn_name)
  returncolumn_name <- gsub("gravity", "_gravity", returncolumn_name)
  returncolumn_name <- gsub("mean", "_mean", returncolumn_name)
  returncolumn_name <- gsub("_+", "_", returncolumn_name)
  returncolumn_name <- gsub("_+$", "", returncolumn_name)
  returncolumn_name
}
