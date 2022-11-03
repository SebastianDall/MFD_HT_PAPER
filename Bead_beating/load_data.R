library(tidyverse)
library(readxl)
library(ampvis2)

# Load data, mutate and filter
meta <- read_excel("../Metadata/2022-10-13_metadata_beadbeating_exp.xlsx", sheet = 1, na = "NA") %>%
  mutate(across(Soil_type, ~str_replace(., "Organic", "Peat"))) %>%
  mutate(across(Integrity, ~as.numeric(.))) %>%
  mutate(across(3:7, ~as.factor(.))) %>%
  filter(!RPM == 1000) %>%
  mutate(Beadbeating = str_c(RPM, Time, sep = ","))

#tax <- read_delim("", delim = "\t", col_names = c("OTU", "Tax_string", "Strand", "Taxonomy")) %>%
#  select(-Strand, -Tax_string) %>%
#  separate(Taxonomy, into = paste0("tax", 1:7), sep = ",", extra = "merge", fill = "right") %>%
#  rename(Kingdom = tax1,
#         Phylum = tax2,
#         Class = tax3,
#         Order = tax4,
#        Family = tax5,
#        Genus = tax6,
#        Species = tax7)

otutable <- read_delim("Amplicon_output_old/zotutable.R1.txt") %>%
  mutate(across(OTU, ~str_replace(., "Zotu", "ASV")))
  #rename(OTU = 1) %>%
  #mutate(across(OTU, ~str_sort(., numeric = TRUE)))

# create ampvis object
ampvis.data <- amp_load(otutable = otutable,
                        #"Amplicon_output/zotutable.R1.txt",
                        #taxonomy = tax,
                        metadata = meta,
                        pruneSingletons = TRUE)

rm(list=setdiff(ls(), c("ampvis.data", "meta")))
