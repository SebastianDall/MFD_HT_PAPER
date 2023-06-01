library(tidyverse)

forward_files <- list.files("sintax_forward_out", pattern = ".sintax", full.names = T)
reverse_files <- list.files("sintax_reverse_out", pattern = ".sintax", full.names = T)

files <- c(forward_files, reverse_files)

#metadata <- data.table::fread("/path/to/metadata.csv", sep = ",", header = TRUE) %>%
#  select(fieldsample_barcode, library_id)


colnames <- c("Read_name", "Tax_string", "V4", "Taxonomy", "library_id")

key <- setNames(do.call(rbind, Map(cbind, lapply(files, data.table::fread, sep = "\t", header = FALSE, fill = TRUE), V5 = basename(files))), colnames) %>%
  select(Read_name, library_id) %>%
  mutate(library_id = str_remove(library_id, "arc_bac_")) %>%
  mutate(library_id = str_remove(library_id, "-MJ.*$")) %>%
  mutate(library_id = str_replace(library_id, "S-[^-]*$", "S")) %>%
  mutate(library_id = str_replace(library_id, "F-[^-]*$", "F")) %>%
  mutate(Read_name = str_remove(Read_name, "\\s.*"))


data <- data.table::fread("/path/to/sintax_combined.csv", sep = ",", header = TRUE)

phylotable <- data %>%
  merge(key) %>%
  select(library_id, everything()) %>%
  select(-Read_name) %>%
  unite(col = "Taxonomy", 2:8, sep = ",") %>%
  select(library_id, Taxonomy) %>%
  group_by(library_id, Taxonomy) %>%
  summarise(Count = n()) %>%
  spread(., library_id, Count, fill = 0) %>%
  select(-Taxonomy, Taxonomy) %>%
  ungroup() %>%
  separate(Taxonomy, into = paste0("tax", 1:7), sep = ",", extra = "merge", fill = "right") %>%
  rename(Domain = tax1,
         Phylum = tax2,
         Class = tax3,
         Order = tax4,
         Family = tax5,
         Genus = tax6,
         Species = tax7) %>%
  mutate(OTU = paste0("Phylotype_", 1:nrow(.))) %>%
  select(OTU, everything())


out_path <- paste0(getwd(), "/otu_out/")


data.table::fwrite(phylotable, sep = ",", row.names = FALSE, col.names = TRUE, quote = FALSE,
       paste0(out_path, format(Sys.time(), "%Y-%m-%d"), "_small_v_full_phylotabel.csv"))
       
