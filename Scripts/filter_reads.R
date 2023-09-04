#library(tidyverse)
library(dplyr)
library(stringr)

setwd("/path/to/mfd_ht_paper/16S_table")

read_hmm <- function(path) {
  colnames <- c("target_name", "accession", "query_name", "model", "hmmfrom", "hmm_to", "alifrom", 
                "ali_to", "envfrom", "env_to", "sq_len", "strand", "E-value", "score", "bias", "description_of_target")
  
  df <- readr::read_delim(path, delim = "\t", skip = 2, col_names = FALSE) %>%
    mutate(across(X1, ~str_replace_all(., "\\s\\s*", ","))) %>%
    filter(!str_detect(X1, '#')) %>%
    tidyr::separate(X1, into = colnames, sep = ",") %>%
    mutate(across(score, ~as.numeric(.)))
  
  return(df)
}

## Import hmm outputs
forward_files <- list.files("hmm_forward_out", pattern = ".txt", full.names = T)
reverse_files <- list.files("hmm_reverse_out", pattern = ".txt", full.names = T)

colnames <- c("target_name", "accession", "query_name", "model", "hmm_from", "hmm_to", "ali_from", 
              "ali_to", "env_from", "env_to", "sq_len", "strand", "E-value", "score", "bias", "description_of_target")

# Forward
forward <- do.call(rbind, Map(cbind, lapply(forward_files, data.table::fread, sep = "\t", header = FALSE, fill = TRUE), 
                              file_name = basename(forward_files))) %>%
  mutate(across(V1, ~str_replace_all(., "\\s\\s*", ","))) %>%
  filter(!str_detect(V1, '#')) %>%
  tidyr::separate(V1, into = colnames, sep = ",") %>%
  mutate(across(c(hmm_from:sq_len, `E-value`:bias), ~as.numeric(.))) %>%
  mutate(across(score, ~as.numeric(.))) %>%
  mutate(target_name = str_remove(target_name, "\\s.*"),
         source = str_remove(file_name, "_.*"))

#forward_reads.samples <- forward %>%
#  filter(!str_detect(file_name, paste0(c("C3", "F3", "C10", "F10", "D12", "E12", "F12"), collapse = "|")))

# Reverse
reverse <- do.call(rbind, Map(cbind, lapply(reverse_files, data.table::fread, sep = "\t", header = FALSE, fill = TRUE), 
                              file_name = basename(reverse_files))) %>%
  mutate(across(V1, ~str_replace_all(., "\\s\\s*", ","))) %>%
  filter(!str_detect(V1, '#')) %>%
  tidyr::separate(V1, into = colnames, sep = ",") %>%
  mutate(across(c(hmm_from:sq_len, `E-value`:bias), ~as.numeric(.))) %>%
  mutate(across(score, ~as.numeric(.))) %>%
  mutate(target_name = str_remove(target_name, "\\s.*"),
         source = str_remove(file_name, "_.*"))
  
#reverse_reads.samples <- reverse %>%
#  filter(!str_detect(file_name, paste0(c("C3", "F3", "C10", "F10", "D12", "E12", "F12"), collapse = "|")))

# Combine
df.all <- rbind(forward, reverse) %>%
  #select(target_name) %>%
  distinct()

#all_reads.samples <- rbind(forward_reads.samples, reverse_reads.samples) %>%
#  select(target_name) %>%
#  distinct()

rm(forward, reverse)
gc()

# Filter for best hmm hit
df.all_filtered <- df.all %>%
  group_by(target_name) %>%
  filter(score == max(score)) %>%
  mutate(duplicate = n()) %>%
  ungroup()

rm(df.all)

single <- df.all_filtered %>%
  filter(duplicate == 1)
  #select(target_name, source)

multi <- df.all_filtered %>%
  filter(duplicate == 2) %>%
  #select(target_name, source) %>%
  #distinct() %>%
  group_by(target_name) %>%
  #filter(2 > n())
  slice_head(n = 1)

undetermined <- df.all_filtered %>%
  filter(duplicate > 2)

# Filtered read names
arc_reads <- single %>%
  filter(source == "arc") %>%
  rbind(multi %>% filter(source == "arc")) %>%
  #filter(hmm_from >= 20 & hmm_to <= 1000) %>%
  select(target_name)

#arc_reads.samples <- all_reads.samples %>%
#  filter(target_name %in% arc_reads$target_name)

bac_reads <- single %>%
  filter(source == "bac") %>%
  rbind(multi %>% filter(source == "bac")) %>%
  #filter(hmm_from >= 27 & hmm_to <= 1391) %>%
  select(target_name)

#bac_reads.samples <- all_reads.samples %>%
#  filter(target_name %in% bac_reads$target_name)

euk_reads <- single %>%
  filter(source == "euk") %>%
  rbind(multi %>% filter(source == "euk")) %>%
  select(target_name) %>%
  group_by(target_name)

#euk_reads.samples <- all_reads.samples %>%
#  filter(target_name %in% euk_reads$target_name)

# Test
nrow(single)+nrow(multi)

rbind(single, multi) %>% distinct() %>% nrow()

nrow(arc_reads)+nrow(bac_reads)+nrow(euk_reads)

rbind(arc_reads, bac_reads, euk_reads) %>% distinct() %>% nrow()

intersect(arc_reads, bac_reads)
intersect(arc_reads, euk_reads)
intersect(bac_reads, euk_reads)

#nrow(all_reads.samples) # should be more than the next line

#nrow(arc_reads.samples)+nrow(bac_reads.samples)+nrow(euk_reads.samples)

#rbind(arc_reads.samples, bac_reads.samples, euk_reads.samples) %>% distinct() %>% nrow()

# Write reads output
readr::write_delim(arc_reads, "output/ARC_reads.txt", col_names = FALSE, delim = ",")
readr::write_delim(bac_reads, "output/BAC_reads.txt", col_names = FALSE, delim = ",")
readr::write_delim(euk_reads, "output/EUK_reads.txt", col_names = FALSE, delim = ",")

rm(list = ls())
gc()
