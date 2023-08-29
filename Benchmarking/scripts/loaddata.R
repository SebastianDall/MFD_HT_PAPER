library(tidyverse)
library(ampvis2)

# Load full Metadata and filter for amplicon benchmarking test
metadata.amplicon <- read_csv("../Metadata/2023-03-13_combined-metadata.csv") %>%
  filter(experiment == "Benchmarking") %>%
  dplyr::rename(seq_name = seq_id) %>%
  mutate(seq_id = str_c(sample_id, replicat, sep = "-"), .before = "seq_id") %>%
  mutate(across(seq_id, ~if_else(is.na(kit), seq_id, str_c(kit, seq_id, sep = "-"))),
         across(seq_id, ~str_remove(., "-MFD004")),
         across(seq_id, ~str_replace_all(., " ", "-"))) %>%
  select(seq_id, everything())

# Load ASV taxonomy
tax.amplicon <- read_delim("../Amplicon_data/zotus.R1.sintax",
                           col_names = c("OTU", "Tax_string", "Strand", "Tax")) %>% 
  select(1, 4) %>%
  mutate(across(OTU, ~str_replace(., "Zotu", "ASV"))) %>%
  mutate(across(Tax, ~str_replace_all(., "__", ":"))) %>%
  separate(Tax, into = c("Kingdom","Phylum","Class","Order","Family","Genus","Species"), sep = ",") %>%
  mutate(across(where(is.character), ~str_remove(., ".:")))

# Create renaming vector
names <- metadata.amplicon %>%
  select(seq_name, seq_id) %>%
  pivot_wider(names_from = "seq_id", values_from = "seq_name")

# Load ASV table and combine with ASV taxonomy
OTU.amplicon <- read_delim(file = "../Amplicon_data/zotutable_notax.txt") %>%
  dplyr::rename(OTU = 1) %>%
  select(OTU, intersect(metadata.amplicon$seq_name, colnames(.))) %>%
  mutate(across(OTU, ~str_replace(., "Zotu", "ASV"))) %>%
  dplyr::rename(!!!names) %>%
  left_join(tax.amplicon) %>%
  filter(!is.na(Kingdom))

# Create ampvis object
ampvis.amplicon <- amp_load(otutable = OTU.amplicon, metadata = metadata.amplicon) %>%
  amp_filter_taxa(tax_vector = c("o:Chloroplast", "f:Mitochondria"), remove = TRUE)

# Remove temp files
rm(names, tax.amplicon, OTU.amplicon)
