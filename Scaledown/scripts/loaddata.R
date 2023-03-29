library(tidyverse)
library(ampvis2)

# Load full Metadata and filter for metagenome scale-down test
metadata.metagenome <- read_csv("../Metadata/2023-03-13_combined-metadata.csv") %>%
  filter(experiment == "Small_v_full_metagenome") %>%
  dplyr::rename(seq_name = seq_id) %>%
  mutate(seq_id = str_c(sample_id, replicat, sep = "-"), .before = "seq_id") %>%
  mutate(across(seq_id, ~str_replace(., "Plate1-PCR-NEG-F1", "MFD004-PCR-NEG-F"))) %>%
  mutate(across(seq_id, ~str_replace(., "Plate1-PCR-POS-F1", "MFD004-PCR-POS-F"))) %>%
  mutate(across(seq_id, ~str_replace(., "Plate1-PCR-NEG-S1", "MFD004-PCR-NEG-S"))) %>%
  mutate(across(seq_id, ~str_replace(., "Plate1-PCR-POS-S1", "MFD004-PCR-POS-S"))) %>%
  select(seq_id, everything())

# Load full Metadata and filter for amplicon scale-down test
metadata.amplicon <- read_csv("../Metadata/2023-03-13_combined-metadata.csv") %>%
  filter(experiment == "Small_v_full_amplicon") %>%
  dplyr::rename(seq_name = seq_id) %>%
  mutate(seq_id = str_c(sample_id, replicat, sep = "-"), .before = "seq_id") %>%
  mutate(across(seq_id, ~str_replace(., "Plate1-PCR-NEG-F1", "MFD004-PCR-NEG-F"))) %>%
  mutate(across(seq_id, ~str_replace(., "Plate1-PCR-POS-F1", "MFD004-PCR-POS-F"))) %>%
  mutate(across(seq_id, ~str_replace(., "Plate1-PCR-NEG-S1", "MFD004-PCR-NEG-S"))) %>%
  mutate(across(seq_id, ~str_replace(., "Plate1-PCR-POS-S1", "MFD004-PCR-POS-S"))) %>%
  select(seq_id, everything())

# Load metagenome phylotable - has both counts and taxonomy
OTU.metagenome <- read_csv("../Metagenome_data/2023-03-15_small_v_full_phylotabel.csv") %>%
  mutate(across(OTU, ~str_replace(., "Phylotype", "OTU"))) %>%
  dplyr::rename(Kingdom = Domain) %>%
  filter(!is.na(Kingdom)) %>%
  mutate(across(where(is.character), ~str_remove(., ".:")))

# Load ASV taxonomy
tax.amplicon <- read_delim("../Amplicon_data/sintax_out_trimmed.txt", col_names = c("OTU", "Tax_string", "Strand", "Tax")) %>% 
  select(1, 4) %>%
  mutate(across(OTU, ~str_replace(., "Zotu", "ASV"))) %>%
  mutate(across(Tax, ~str_replace_all(., "__", ":"))) %>%
  separate(Tax, into = c("Kingdom","Phylum","Class","Order","Family","Genus","Species"), sep = ",") %>%
  mutate(across(where(is.character), ~str_remove(., ".:")))

# Create renaming vector
names <- metadata.amplicon %>%
  select(seq_id, seq_name) %>%
  pivot_wider(names_from = "seq_id", values_from = "seq_name")

# Load ASV table and combine with ASV taxonomy
OTU.amplicon <- read_delim(file = "../Amplicon_data/zotutable_notax.txt") %>%
  dplyr::rename(OTU = 1) %>%
  select(OTU, intersect(metadata.amplicon$seq_name, colnames(.))) %>%
  mutate(across(OTU, ~str_replace(., "Zotu", "ASV"))) %>%
  dplyr::rename(!!!names) %>%
  left_join(tax.amplicon) %>%
  filter(!is.na(Kingdom))

# Load metagenomic seq-metadata
seq_meta <- read_csv("../Metagenome_data/2023-03-15_small_v_full_seq_metadata.csv")

# Create ampvis object for metagenomes
ampvis.metagenome <- amp_load(otutable = OTU.metagenome, metadata = metadata.metagenome) %>%
  amp_filter_taxa(tax_vector = c("o:Chloroplast", "f:Mitochondria"), remove = TRUE)

# Create ampvis object for amplicons
ampvis.amplicon <- amp_load(otutable = OTU.amplicon, metadata = metadata.amplicon) %>%
  amp_filter_taxa(tax_vector = c("o:Chloroplast", "f:Mitochondria"), remove = TRUE)

# Remove temp files
rm(names, tax.amplicon, OTU.amplicon, OTU.metagenome)
