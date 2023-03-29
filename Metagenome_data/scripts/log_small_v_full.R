library(jsonlite)
library(tidyverse)

json_list <- list.files("logs/log_small_v_full/json/", pattern = ".json", full.names = T)

names <- json_list %>% 
  basename() %>% 
  as.data.frame() %>% 
  rename("seq_id" = 1) %>%
  mutate(across(everything(), ~gsub("\\..*$", "", .)))

tmp <- lapply(json_list, function(x){fromJSON(x, simplifyVector = TRUE, flatten = TRUE)})

tmp1.1 <- tmp %>%
  lapply(., `[[`, 1) %>%
  lapply(., `[`, 3) %>%
  lapply(., bind_rows) %>%
  bind_rows(.) %>%
  rename_with(., ~ paste("before", .x, sep = "_"))

tmp1.2 <- tmp %>%
  lapply(., `[[`, 1) %>%
  lapply(., `[`, 4) %>%
  lapply(., bind_rows) %>%
  bind_rows(.) %>%
  rename_with(., ~ paste("after", .x, sep = "_"))

tmp2 <- tmp %>%
  lapply(., `[[`, 2) %>%
  bind_rows(.)

tmp3 <- tmp %>%
  lapply(., `[[`, 3) %>%
  lapply(., `[`, 1) %>%
  bind_rows(.) %>%
  rename(duplication_rate = rate)

tmp4 <- tmp %>%
  lapply(., `[[`, 4) %>%
  lapply(., `[`, 1) %>%
  bind_rows(.) %>%
  select(1) %>%
  mutate(across(everything(), ~replace_na(., 0)))

`df.small_v_full` <- bind_cols(names, tmp1.1, tmp1.2, tmp2, tmp3, tmp4) %>%
  mutate(across(seq_id, ~gsub("_fastp", "", .))) %>%
  #mutate(library_id = gsub("-[^-]+$", "", seq_id)) %>%
  #relocate(library_id, everything()) %>%
  mutate(seq_run = "small_v_full")
