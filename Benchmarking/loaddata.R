tab <- data.table::fread(file = "../Amplicon_data/zotutable_notax.txt") %>%
  dplyr::rename(OTU = 1) %>%
  mutate(across(OTU, ~ str_replace(., "Zotu", "ASV")))

tax <- data.table::fread(
  file = "../Amplicon_data/sintax_out_trimmed.txt",
  col.names = c("OTU", "tax"),
  select = c(1, 4)
) %>%
  mutate(across(OTU, ~ str_replace(., "Zotu", "ASV"))) %>%
  mutate(across(tax, ~ str_replace_all(., ":", "__"))) %>%
  separate(tax, into = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"), sep = ",") %>%
  mutate(across(Kingdom:Species, ~ replace_na(., "")))

# Load metadata.
meta <- readxl::read_xlsx("../Metadata/2022-10-13_metadata_benchmarking_exp.xlsx") %>%
  mutate(across(SeqID, ~ str_replace(., "_", "-")))

otutable <- merge(tab, tax, by = "OTU") %>%
  select(OTU, intersect(meta %>% pull(SeqID), colnames(.)), Kingdom:Species) %>%
  filter(rowSums(across(where(is.numeric))) != 0)

# Merge into ampvis object.
datraw <- amp_load(
  otutable = otutable,
  metadata = meta,
  pruneSingletons = T
)

rm(tab, tax, meta, otutable)

amplicon_metadata <- readxl::read_excel("./data/Amplicon_metadata.xlsx") %>%
  mutate(
    Kit = str_replace(Kit, ", Ref", ""),
    Kit = str_replace(Kit, ", ", " "),
    Kit = str_replace(Kit, "Midas", "MIDAS"),
    Soil_type = str_replace(Soil_type, "BLANK", "Blank"),
    Soil_type = str_replace(Soil_type, "-clay", "-Clay"),
    Soil_type = str_replace(Soil_type, " sand", " Sand")
  )

soil_properties <- readxl::read_excel("./data/soil_characteristics.xlsx") %>% 
  select(-c(pH, Subsamples))
