library(tidyverse)
library(haven)
library(data.table)
library(readxl)

#path
path = dirname(rstudioapi::getActiveDocumentContext()$path)
path_output = paste0(path,"/output_csv/")

# function: read and append csv's from output folder
read_and_bind_csv <- function(folder_path){
  files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)
  if (length(files) == 0) {
    stop("Keine CSV-Dateien im angegebenen Ordner gefunden.")
  }
  df_list <- lapply(files, read.csv, stringsAsFactors = TRUE)
  combined_df <- do.call(rbind, df_list)
  return(combined_df)
}

# function: extract the image ID from the path-string
add_id_from_path <- function(df, colname, newcol = "id") {
  if (!colname %in% names(df)) {
    stop(paste("Spalte", colname, "nicht gefunden."))
  }
  df[[newcol]] <- as.factor(sub(".*\\\\([0-9]+)_face.*$", "\\1", df[[colname]]))
  return(df)
}

# read ground truth label
image_label = read.csv(paste0(path,"/manual.classification.csv"))%>%
  mutate(ID = as.factor(player_id_sofascore),
         Skin3 = as.factor(skin_color_dim3))%>%
  select(c("ID","black","Skin3"))

# read FairFace results
Fairfaceresults = add_id_from_path(read_and_bind_csv(path_output),"face_name_align","ID") %>%
  select(c("ID","race4"))

# join data
FinalData = Fairfaceresults%>%
  left_join(image_label,by = c("ID"))%>%
  select(-c("face_name_align"))%>%
  write.csv(paste0(path,"/fairfacefinal.csv"))
