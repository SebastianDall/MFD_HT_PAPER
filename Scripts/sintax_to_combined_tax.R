library(tidyverse)

# Import data
forward_files <- list.files("sintax_forward_out", pattern = ".sintax", full.names = T)
reverse_files <- list.files("sintax_reverse_out", pattern = ".sintax", full.names = T)

forward <- lapply(forward_files, data.table::fread, sep = "\t", header = FALSE, fill = TRUE) %>%
  bind_rows(.) %>%
  rename(Read_name = 1, Tax_string = 2, Strand = 3, Taxonomy = 4) %>%
  mutate(Read_name = str_remove(Read_name, "\\s.*")) %>%
  select(-Strand)

reverse <- lapply(reverse_files, data.table::fread, sep = "\t", header = FALSE, fill = TRUE) %>%
  bind_rows(.) %>%
  rename(Read_name = 1, Tax_string = 2, Strand = 3, Taxonomy = 4) %>%
  mutate(Read_name = str_remove(Read_name, "\\s.*")) %>%
  select(-Strand)

names_common <- Reduce(intersect, list(forward$Read_name, reverse$Read_name))

# Create subsets 
lst_df <- lst(forward, reverse)

lst_df.tax <- lst_df %>%
  lapply(., select, c(1,3))

tmp_uncommon <- lst_df.tax %>%
  bind_rows(.id = 'Source') %>%
  filter(!Read_name %in% names_common)

tmp_common <- lst_df.tax %>%
  bind_rows(.id = 'Source') %>%
  filter(Read_name %in% names_common)

tmp_common.long <- tmp_common %>%
  group_by(Read_name) %>%
  distinct(Taxonomy, .keep_all = TRUE) %>%
  mutate(duplicate = n()) %>%
  ungroup()

# Agreement between names
same_name <- tmp_common.long %>%
  filter(!duplicate == 2) %>% 
  select(-duplicate)

# Disagreement between names - select best
diff_name <- tmp_common.long %>%
  filter(!duplicate == 1) %>% 
  select(-duplicate) %>%
  mutate(rowsum = rowSums(is.na(.))) %>%
  group_by(Read_name) %>%
  slice(which.min(rowsum)) %>%
  select(-rowsum) %>%
  ungroup() %>%
  mutate(Source = "combined")

# Unique reads forward
unique_forward <- tmp_uncommon %>%
  spread(Source, Taxonomy, drop = FALSE) %>%
  filter(!is.na(forward)) %>%
  mutate(unique_forward = ifelse(is.na(reverse), yes = TRUE, no = FALSE)) %>%
  filter(unique_forward == TRUE) %>%
  select(-unique_forward) %>%
  discard(~all(is.na(.) | . == "")) %>%
  rename(Taxonomy = forward) %>%
  mutate(Source = "unique_forward") %>%
  select(Source, Read_name, Taxonomy)

# Unique reads reverse
unique_reverse <- tmp_uncommon %>%
  spread(Source, Taxonomy, drop = FALSE) %>%
  filter(!is.na(reverse)) %>%
  mutate(unique_reverse = ifelse(is.na(forward), yes = TRUE, no = FALSE)) %>%
  filter(unique_reverse == TRUE) %>%
  select(-unique_reverse) %>%
  discard(~all(is.na(.) | . == "")) %>%
  rename(Taxonomy = reverse) %>%
  mutate(Source = "unique_reverse") %>%
  select(Source, Read_name, Taxonomy)

# Combine outputs and minimize
df_combined <- bind_rows(same_name, diff_name, unique_forward, unique_reverse) %>%
  separate(Taxonomy, into = paste0("tax", 1:7), sep = ",", extra = "merge", fill = "right") %>%
  rename(Domain = tax1,
         Phylum = tax2,
         Class = tax3,
         Order = tax4,
         Family = tax5,
         Genus = tax6,
         Species = tax7) %>%
  filter(!is.na(Domain) | Domain == "") %>%
  select(-Source)

out_path <- paste0(getwd(), "/sintax_combined_out/")

data.table::fwrite(df_combined, sep = ",", row.names = FALSE, col.names = TRUE, quote = FALSE,
       paste0(out_path, format(Sys.time(), "%Y-%m-%d"), "_sintax_combined.csv"))




