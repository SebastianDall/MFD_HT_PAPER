tab <- data.table::fread(file = "../Amplicon_data/zotutable_notax.txt") %>%
  dplyr::rename(OTU = 1) %>%
  mutate(across(OTU, ~str_replace(., "Zotu", "ASV")))

tax <- data.table::fread(file = "../Amplicon_data/sintax_out_trimmed.txt",
                         col.names = c("OTU", "tax"),
                         select = c(1, 4)) %>%
  mutate(across(OTU, ~str_replace(., "Zotu", "ASV"))) %>%
  mutate(across(tax, ~str_replace_all(., ":", "__"))) %>%
  separate(tax, into = c("Kingdom","Phylum","Class","Order","Family","Genus","Species"), sep = ",") %>%
  mutate(across(Kingdom:Species, ~replace_na(., "")))

# Load metadata.
meta <- readxl::read_excel("../Metadata/2022-10-13_metadata_beadbeating_exp.xlsx", sheet = 1, na = "NA") %>%
  mutate(across(Integrity, ~as.numeric(.))) %>%
  mutate(across(3:7, ~as.factor(.))) %>%
  filter(!RPM == 1000) %>%
  mutate(Beadbeating = str_c(RPM, Time, sep = ",")) %>%
  mutate(across(SeqID, ~str_replace(., "_", "-")))

otutable <- merge(tab, tax, by = "OTU") %>%
  select(OTU, intersect(meta %>% pull(SeqID), colnames(.)), Kingdom:Species) %>%
  filter(rowSums(across(where(is.numeric)))!=0)

# Merge into ampvis object.
datraw <- amp_load(
  otutable = otutable,
  metadata = meta,
  pruneSingletons = T)

rm(tab,tax)
