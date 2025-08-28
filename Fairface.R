library(tidyverse)
library(haven)
library(skimr)
library(data.table)

#path
path = dirname(rstudioapi::getActiveDocumentContext()$path)

output2 = read_csv(paste0(path,"/test_outputs.csv"))
