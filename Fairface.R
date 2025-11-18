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

Fairfaceresults = rbind(Fairfaceresults,Race28)

# join data
FinalData = image_label%>%
  left_join(Fairfaceresults,by = c("ID"))%>%
  write.csv(paste0(path,"/fairfacefinal.csv"))

#dateien kopieren
fehlendeBilder = read.csv("D:/Uni/Ulm/Master/Hiwi-Forschung-und-Lehre/FairFace/no_fairface_classification.csv")%>%
  rename(ID = player_id_sofascore)

source_dir <- "D:/Uni/Ulm/Master/Hiwi-Forschung-und-Lehre/HiWi_Kiesl/Bilder_all"
target_dir <- "D:/Uni/Ulm/Master/Hiwi-Forschung-und-Lehre/FairFace/Bilder_input"

# Stelle sicher, dass das Zielverzeichnis existiert
if(!dir.exists(target_dir)){
  dir.create(target_dir, recursive = TRUE)
}

# Hole alle Dateien im Source-Ordner (mit jeglicher Endung)
all_files <- list.files(source_dir, full.names = TRUE)

# Für jede ID prüfen, ob ein Dateiname (ohne Endung) passt und dann kopieren
for(id in fehlendeBilder$ID){
  matches <- all_files[grepl(paste0("^", id, "\\."), basename(all_files))]
  
  if(length(matches) > 0){
    file.copy(from = matches, to = target_dir, overwrite = TRUE)
  }
}

library(magick)

# Pfad zum Ordner anpassen
input_dir <- "D:/Uni/Ulm/Master/Hiwi-Forschung-und-Lehre/FairFace/Bilder_input"
output_dir <- "D:/Uni/Ulm/Master/Hiwi-Forschung-und-Lehre/FairFace/Bilder_all_jpg"   # neuer Ordner für JPGs

# Ordner für Ausgabe anlegen (falls nicht vorhanden)
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Liste aller Bilddateien (beliebige Formate)
files <- list.files(input_dir, pattern = "\\.(png|jpeg|jpg|tiff|bmp|gif|webp)$",
                    ignore.case = TRUE, full.names = TRUE)

for (file in files) {
  img <- image_read(file)
  
  # Neuen Dateinamen erstellen
  base <- tools::file_path_sans_ext(basename(file))
  out_file <- file.path(output_dir, paste0(base, ".jpg"))
  
  # Als JPG speichern
  image_write(img, out_file, format = "jpg")
}

cat("Fertig! Alle Bilder wurden gespeichert.\n")

# letze Datei formatieren
extract_id <- function(x) {
  # x: character vector (z. B. Spalte im Dataframe)
  sub(".*\\/([0-9]+)_face.*", "\\1", x)
}

Race28 = read.csv("D:/Uni/Ulm/Master/Hiwi-Forschung-und-Lehre/FairFace/output_csv/Race28.csv")
Race28$face_name_align = as.factor(extract_id(Race28$face_name_align))
Race28 = Race28%>% mutate(ID = face_name_align)%>%
  select(c("ID","race4"))
write.csv(Race28, "D:/Uni/Ulm/Master/Hiwi-Forschung-und-Lehre/FairFace/output_csv/Race28.csv")
