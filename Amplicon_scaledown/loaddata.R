load_datraw <- function() {
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
  meta <- readxl::read_xlsx("2022-10-13_metadata_library_scale.xlsx") %>%
    mutate(across(SeqID, ~ str_replace(., "_", "-"))) %>%
    mutate(across(Experiment, ~ str_replace(., "Benchmarking_old", "2 x 25 µL"))) %>%
    mutate(across(Experiment, ~ str_replace(., "Benchmarking", "2 x 5 µL"))) %>%
    dplyr::rename(Protocol = Experiment)

  otutable <- merge(tab, tax, by = "OTU") %>%
    select(OTU, intersect(meta %>% pull(SeqID), colnames(.)), Kingdom:Species) %>%
    filter(rowSums(across(where(is.numeric))) != 0)

  # Merge into ampvis object.
  datraw <- amp_load(
    otutable = otutable,
    metadata = meta,
    pruneSingletons = T
  )

  return(datraw)
}

load_ampLibConc <- function() {
  d <- readxl::read_xlsx("./data/2022.11.28_amp_lib_conc.xlsx")
  return(d)
}
