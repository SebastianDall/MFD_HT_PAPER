#library(tidyverse)
library(dplyr)
library(stringr)

setwd("/path/to/mfd_ht_paper/16S_table")

forward_files <- list.files("sintax_forward_out", pattern = "arc_bac_", full.names = T)
reverse_files <- list.files("sintax_reverse_out", pattern = "arc_bac_", full.names = T)

files <- c(forward_files, reverse_files)

colnames <- c("Read_name", "Tax_string", "V4", "Taxonomy", "library_id")

# Generate key-pairs
key <- setNames(do.call(rbind, Map(cbind, lapply(files, data.table::fread, sep = "\t", header = FALSE, fill = TRUE), V5 = basename(files))), colnames) %>%
  select(Read_name, library_id) %>%
  mutate(library_id = str_remove(library_id, "arc_bac_")) %>%
  mutate(library_id = str_remove(library_id, "-MJ.*$")) %>%
  mutate(library_id = str_replace(library_id, "_forward.sintax", "")) %>%
  mutate(library_id = str_replace(library_id, "_reverse.sintax", "")) %>%
  mutate(Read_name = str_remove(Read_name, "\\s.*"))

# Load combined sintax file
data <- data.table::fread("sintax_combined_out/2023-08-26_arcbac_sintax_combined.csv", sep = ",", header = TRUE)

# Create phylotable
phylotable <- data %>%
  merge(key) %>%
  select(library_id, everything()) %>%
  select(-Read_name) %>%
  tidyr::unite(col = "Taxonomy", 2:8, sep = ",") %>%
  select(library_id, Taxonomy) %>%
  group_by(library_id, Taxonomy) %>%
  summarise(Count = n())
  tidyr::spread(., library_id, Count, fill = 0) %>%
  select(-Taxonomy, Taxonomy) %>%
  ungroup() %>%
  tidyr::separate(Taxonomy, into = paste0("tax", 1:7), sep = ",", extra = "merge", fill = "right") %>%
  rename(Kingdom = tax1,
         Phylum = tax2,
         Class = tax3,
         Order = tax4,
         Family = tax5,
         Genus = tax6,
         Species = tax7) %>%
  mutate(OTU = paste0("OTU_", 1:nrow(.)),
         across(Species, ~str_replace(., "NA", ""))) %>%
  select(OTU, everything())

# Print to files
data.table::fwrite(phylotable, sep = ",", row.names = FALSE, col.names = TRUE, quote = FALSE,
                   paste0("otu_out/", format(Sys.time(), "%Y-%m-%d"), "_small_v_full_phylotabel.csv"))

