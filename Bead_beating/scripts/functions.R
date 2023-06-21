# Ordination function
colors <- c("grey", "darkgoldenrod2", "royalblue4", "seagreen", "salmon")

plotAmpliconOrdinationSoil <- function(df, soil_filter, ord_type = "CA", rel_ab_filter = 0.1) {
  df %>%
    amp_subset_samples(soil_type == soil_filter) %>%
    amp_ordinate(
      filter_species = 0.1,
      type = ord_type,
      constrain = "sample_target",
      transform = "hellinger",
      distmeasure = "bray",
      sample_colorframe = "sample_target",
      # species_nlabels = 5,
      # species_label_taxonomy = "Phylum",
      species_plot = T,
      species_nlabels = 5,
      species_label_taxonomy = "Phylum"
    ) +
    labs(
      title = paste0(soil_filter, ": ", ord_type, " of microbial diversity")
    ) +
    articletheme +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 0, hjust = 0, vjust = 0)
    )
}

plotDiffRelabund_scale <- function(df, filter_soil_type) {
  soiltypeTitle <- df %>%
    filter(soil_type == filter_soil_type) %>%
    distinct(soil_type)
  
  df_sub <- df %>%
    filter(soil_type == filter_soil_type)
  
  tmp <- df_sub %>%
    filter(Bias == "Equally detected")
  
  tmp2 <- df_sub %>%
    filter(!Bias == "Equally detected")
  
  gg <- ggplot() +
    geom_point(data = tmp, aes(x = `125`, y = `50`, fill = Bias), alpha = 0.2, 
               color = "black", size = 4, position = position_jitter(width = 0.001, height = 0.001), shape = 21) +
    geom_point(data = tmp2, aes(x = `125`, y = `50`, fill = Bias), alpha = 0.8, 
               color = "black", size = 4, position = position_jitter(width = 0.001, height = 0.001), shape = 21) +
    coord_cartesian(xlim = c(0, max(df_sub$max_abundance)), ylim = c(0, max(df_sub$max_abundance))) +
    scale_fill_manual(values = c("grey", colors[5], colors[3]), 
                       limits = c("Equally detected",
                                  "More abundant with 125 mg", 
                                  "More abundant with 50 mg")) +
    geom_abline(linewidth = 0.5) +
    articlethemex0 +
    theme(
      legend.position = "none",
    ) +
    labs(title = paste0(soiltypeTitle$soil_type[1]),
         x = "Average relative abundance within replicates [%], 125 mg",
         y = "Average relative abundance within replicates [%], 50 mg"
    )
  
  return(gg)
}

plotDiffRelabund_rpm_1800 <- function(df, filter_soil_type) {
  soiltypeTitle <- df %>%
    filter(soil_type == filter_soil_type) %>%
    distinct(soil_type)
  
  df_sub <- df %>%
    filter(soil_type == filter_soil_type)
  
  tmp <- df_sub %>%
    filter(Bias == "Equally detected")
  
  tmp2 <- df_sub %>%
    filter(!Bias == "Equally detected")
  
  gg <- ggplot() +
    geom_point(data = tmp, aes(x = `4`, y = `6`, fill = Bias), alpha = 0.2, 
               color = "black", size = 4, position = position_jitter(width = 0.001, height = 0.001), shape = 21) +
    geom_point(data = tmp2, aes(x = `4`, y = `6`, fill = Bias), alpha = 0.8, 
               color = "black", size = 4, position = position_jitter(width = 0.001, height = 0.001), shape = 21) +
    coord_cartesian(xlim = c(0, max(df_sub$max_abundance)), ylim = c(0, max(df_sub$max_abundance))) +
    scale_fill_manual(values = c("grey", colors[5], colors[3]), 
                       limits = c("Equally detected",
                                  "More abundant with 4 minutes", 
                                  "More abundant with 6 minutes")) +
    geom_abline(linewidth = 0.5) +
    articlethemex0 +
    theme(
      legend.position = "none",
    ) +
    labs(
      x = "Relative Abundance [%], 4 minutes",
      y = "Relative Abundance [%], 6 minutes",
      title = paste0(soiltypeTitle$soil_type[1], "- 1800 RPM")
    ) 
  
  return(gg)
}

plotDiffRelabund_rpm_1600 <- function(df, filter_soil_type) {
  soiltypeTitle <- df %>%
    filter(soil_type == filter_soil_type) %>%
    distinct(soil_type)
  
  df_sub <- df %>%
    filter(soil_type == filter_soil_type)
  
  tmp <- df_sub %>%
    filter(Bias == "Equally detected")
  
  tmp2 <- df_sub %>%
    filter(!Bias == "Equally detected")
  
  gg <- ggplot() +
    geom_point(data = tmp, aes(x = `4`, y = `6`, fill = Bias), alpha = 0.2, 
               color = "black", size = 4, position = position_jitter(width = 0.001, height = 0.001), shape = 21) +
    geom_point(data = tmp2, aes(x = `4`, y = `6`, fill = Bias), alpha = 0.8, 
               color = "black", size = 4, position = position_jitter(width = 0.001, height = 0.001), shape = 21) +
    geom_point(size = 4, alpha = 0.5, position = position_jitter()) +
    coord_cartesian(xlim = c(0, max(df_sub$max_abundance)), ylim = c(0, max(df_sub$max_abundance))) +
    scale_fill_manual(values = c("grey", colors[5], colors[3]), 
                       limits = c("Equally detected",
                                  "More abundant with 4 minutes", 
                                  "More abundant with 6 minutes")) +
    geom_abline(linewidth = 0.5) +
    articlethemex0 +
    theme(
      legend.position = "none",
    ) +
    labs(
      x = "Relative Abundance [%], 4 minutes",
      y = "Relative Abundance [%], 6 minutes",
      title = paste0(soiltypeTitle$soil_type[1], "- 1600 RPM")
    ) 
  
  return(gg)
}


deseq_function_scale <- function(soil, dat_types) {
  deseqmatrix <- dat_types %>%
    amp_subset_samples(soil_type == soil)
  
  dds <- DESeqDataSetFromMatrix(
    countData = deseqmatrix$abund,
    colData = deseqmatrix$metadata,
    design = ~sample_target
  )
  
  deseq <- DESeq(dds)
  res <- as.data.frame(results(deseq, cooksCutoff = FALSE, independentFiltering = FALSE)) %>%
    rownames_to_column("OTU")
  res$soil_type <- soil
  
  return(res)
}

deseq_function_1800 <- function(soil, dat_types) {
  deseqmatrix <- dat_types %>%
    amp_subset_samples(soil_type == soil, rpm == "1800", time_minutes %in% c("4", "6"))
  
  dds <- DESeqDataSetFromMatrix(
    countData = deseqmatrix$abund,
    colData = deseqmatrix$metadata,
    design = ~time_minutes
  )
  
  deseq <- DESeq(dds)
  res <- as.data.frame(results(deseq, cooksCutoff = FALSE, independentFiltering = FALSE)) %>%
    rownames_to_column("OTU")
  res$soil_type <- soil
  
  return(res)
}

deseq_function_1600 <- function(soil, dat_types) {
  deseqmatrix <- dat_types %>%
    amp_subset_samples(soil_type == soil, rpm == "1600", time_minutes %in% c("4", "6"))
  
  dds <- DESeqDataSetFromMatrix(
    countData = deseqmatrix$abund,
    colData = deseqmatrix$metadata,
    design = ~time_minutes
  )
  
  deseq <- DESeq(dds)
  res <- as.data.frame(results(deseq, cooksCutoff = FALSE, independentFiltering = FALSE)) %>%
    rownames_to_column("OTU")
  res$soil_type <- soil
  
  return(res)
}


combine_otu_w_metadata_scale <- function(metadata, otu) {
  otu_long <- otu %>%
    t() %>%
    as.data.frame() %>%
    rownames_to_column("seq_id") %>%
    pivot_longer(-seq_id, names_to = "OTU", values_to = "abund")
  
  metadata_otu_combined <- metadata %>%
    select(seq_id, soil_type, sample_target) %>%
    left_join(otu_long)
  
  return(metadata_otu_combined)
}

combine_otu_w_metadata_time <- function(metadata, otu) {
  otu_long <- otu %>%
    t() %>%
    as.data.frame() %>%
    rownames_to_column("seq_id") %>%
    pivot_longer(-seq_id, names_to = "OTU", values_to = "abund")
  
  metadata_otu_combined <- metadata %>%
    select(seq_id, soil_type, time_minutes) %>%
    left_join(otu_long)
  
  return(metadata_otu_combined)
}

summarise_triplicates_scale <- function(df) {
  df_summarised <- df %>%
    group_by(soil_type, sample_target, OTU) %>%
    summarise(abund = round(mean(abund), digits = 4))
  
  return(df_summarised)
}

summarise_triplicates_time <- function(df) {
  df_summarised <- df %>%
    group_by(soil_type, time_minutes, OTU) %>%
    summarise(abund = round(mean(abund), digits = 4))
  
  return(df_summarised)
}

calculate_relative_abundance_scale <- function(df) {
  df_relAbund <- df %>%
    group_by(soil_type, sample_target) %>%
    mutate(
      total_abund = sum(abund, na.rm = TRUE),
      rel_abund = abund / total_abund * 100
    ) %>%
    select(-abund, -total_abund)
  
  return(df_relAbund)
}

calculate_relative_abundance_time <- function(df) {
  df_relAbund <- df %>%
    group_by(soil_type, time_minutes) %>%
    mutate(
      total_abund = sum(abund, na.rm = TRUE),
      rel_abund = abund / total_abund * 100
    ) %>%
    select(-abund, -total_abund)
  
  return(df_relAbund)
}

filter_double_zeros_scale <- function(df) {
  df_filtered <- df %>%
    relocate(OTU, .before = sample_target) %>%
    pivot_wider(names_from = "sample_target", values_from = "rel_abund") %>%
    rowwise() %>%
    filter(sum(`125`, `50`) > 0)
  
  
  return(df_filtered)
}

filter_double_zeros_time <- function(df) {
  df_filtered <- df %>%
    relocate(OTU, .before = time_minutes) %>%
    pivot_wider(names_from = "time_minutes", values_from = "rel_abund") %>%
    rowwise() %>%
    filter(sum(`4`, `6`) > 0)
  
  
  return(df_filtered)
}


# Bray distance
calculate_bray_distance <- function(ampdata) {
  metadata <- ampdata$metadata %>%
    select(seq_id, sample_id, sample_target, soil_type)
  
  otutable <- ampdata$abund %>%
    t()
  
  bray_distance <- as.matrix(vegan::vegdist(otutable)) %>%
    as.data.frame() %>%
    rownames_to_column("seq_id")
  
  metadata_renamed <- metadata %>%
    dplyr::rename(
      comparison = seq_id,
      compared_soil = soil_type,
      compared_protocol = sample_target
    ) %>%
    select(-sample_id)
  
  bray_with_metadata <- metadata %>%
    left_join(bray_distance, by = "seq_id") %>%
    pivot_longer(!seq_id:soil_type, names_to = "comparison", values_to = "value") %>%
    left_join(metadata_renamed, by = "comparison")
  
  return(bray_with_metadata)
}

calculate_bray_distancerpm_6 <- function(ampdata) {
  metadata <- ampdata$metadata %>%
    select(seq_id, sample_id, experiment, soil_type)
  
  otutable <- ampdata$abund %>%
    t()
  
  bray_distance <- as.matrix(vegan::vegdist(otutable)) %>%
    as.data.frame() %>%
    rownames_to_column("seq_id")
  
  metadata_renamed <- metadata %>%
    dplyr::rename(
      comparison = seq_id,
      compared_soil = soil_type,
      compared_protocol = experiment
    ) %>%
    select(-sample_id)
  
  bray_with_metadata <- metadata %>%
    left_join(bray_distance, by = "seq_id") %>%
    pivot_longer(!seq_id:soil_type, names_to = "comparison", values_to = "value") %>%
    left_join(metadata_renamed, by = "comparison")
  
  return(bray_with_metadata)
}

# number of annotated reads
num_annotated <- function(x) {
  length(x)-sum(is.na(x))
}


