library(tidyverse)
library(jsonlite)

source("scripts/log_small_v_full.R")

df <- rbind(`df.small_v_full`) %>%
  mutate(across(seq_run, ~as.factor(.)))

rm(list=setdiff(ls(), c("df")))

data <- df %>%
  #right_join(df_meta) %>%
  mutate(seq_lane = str_extract(seq_id, "(\\d+)[^-]*$")) #%>%
  #relocate(fieldsample_barcode,
  #         project_id,
  #         seq_id,
  #         seq_lane,
  #         before_total_reads:extraction_method,
  #         library_id,
  #         library_plate:sampling_comment) %>%
  #filter(!is.na(fieldsample_barcode) & !is.na(library_id)) %>%
  #arrange(fieldsample_barcode)

# Sample metadata
df.meta <- read_csv("../Metadata/2023-03-13_combined-metadata.csv") %>%
  filter(experiment == "Small_v_full_metagenome") %>%
  left_join(data)

out_path <- paste0(getwd(), "/")

# save a csv-file in the analysis folder under mdf_metadata and add timestamp
write.csv(data, paste0(out_path, format(Sys.time(), "%Y-%m-%d"), "_small_v_full_seq_metadata.csv"), row.names = F)

write.csv(df.meta, paste0(out_path, format(Sys.time(), "%Y-%m-%d"), "_small_v_full_combined_metadata.csv"), row.names = F)


rm(list = ls())
