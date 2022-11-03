
# Load ASV table.
tab <- fread("data/otutab.txt") %>%
  .[,OTU := gsub("Zotu", "ASV", OTU)]
  
# Load taxonomy.
tax <- fread("data/tax.txt",
  sep       = "\t",
  header    = F,
  col.names = c("OTU","tax"),
  select    = c(1,4)) %>%
  .[,tax := gsub(":","__",tax)] %>%
  .[,c("Kingdom","Phylum","Class","Order","Family","Genus","Species") := tstrsplit(tax,",")] %>%
  .[,tax:= NULL] %>%
  .[,lapply(.SD,function(x){ifelse(is.na(x),"",x)})] %>%
  .[,OTU := gsub("Zotu", "ASV", OTU)]

# Merge table and taxonomy.
otutable <- merge(tab,tax,by = "OTU",all.x = T)

# Load metadata.
meta1 <- read_xlsx("../Metadata/2022-10-13_metadata_benchmarking_exp.xlsx") %>%
  mutate(SeqID = sub("-", "_", x = SeqID))
#meta2 <- read_xlsx("data/IDconversion.xlsx") %>%
#  mutate(SeqID = sub("-", "_", x = SeqID))

#meta <- left_join(meta2,meta1,by = c("SeqID")) %>%
#  select(SeqID,everything())

# Merge into ampvis object.
datraw <- amp_load(
  otutable = otutable,
  metadata = meta1)

rm(tab,tax,otutable,meta1,meta2,meta)
