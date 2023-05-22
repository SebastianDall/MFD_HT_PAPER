# Ordination function
plotAmpliconOrdinationSoil <- function(df, soil_filter, ord_type = "CA", rel_ab_filter = 0.1) {
  df %>%
    amp_subset_samples(soil_type == soil_filter) %>%
    amp_ordinate(
      filter_species = 0.1,
      type = ord_type,
      constrain = "lib_volume",
      transform = "hellinger",
      distmeasure = "bray",
      sample_colorframe = "lib_volume",
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


plotDiffRelabund_amp <- function(df, filter_soil_type) {
  soiltypeTitle <- df %>%
    filter(soil_type == filter_soil_type) %>%
    distinct(soil_type)
  
  df_sub <- df %>%
    filter(soil_type == filter_soil_type)
  
  gg <- df_sub %>%
    ggplot(aes(x = `Full-scale`, y = `Small-scale`, color = Bias)) +
    geom_point(size = 4, alpha = 0.5, position = position_jitter()) +
    coord_cartesian(xlim = c(0, max(df_sub$max_abundance)), ylim = c(0, max(df_sub$max_abundance))) +
    scale_color_manual(values = c("grey", colors[5], colors[3]), 
                       limits = c("Equally detected",
                                  "More abundant with 2 x 25 µL", 
                                  "More abundant with 2 x 5 µL")) +
    geom_abline(linewidth = 0.5) +
    articletheme +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 0)
    ) +
    labs(title = paste0(soiltypeTitle$soil_type[1]),
         x = "Average relative abundance within replicates [%], 2 x 25 µL",
         y = "Average relative abundance within replicates [%], 2 x 5 µL"
    )
  
  return(gg)
}


plotDiffRelabund_meta <- function(df, filter_soil_type) {
  soiltypeTitle <- df %>%
    filter(soil_type == filter_soil_type) %>%
    distinct(soil_type)
  
  df_sub <- df %>%
    filter(soil_type == filter_soil_type)
  
  gg <- df_sub %>%
    ggplot(aes(x = `Full-scale`, y = `Small-scale`, color = Bias)) +
    geom_point(size = 4, alpha = 0.5, position = position_jitter()) +
    coord_cartesian(xlim = c(0, max(df_sub$max_abundance)), ylim = c(0, max(df_sub$max_abundance))) +
    scale_color_manual(values = c("grey", colors[5], colors[3]), 
                       limits = c("Equally detected",
                                  "More abundant with 1 x 50 µL", 
                                  "More abundant with 1 x 5 µL")) +
    geom_abline(linewidth = 0.5) +
    articletheme +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 0)
    ) +
    labs(title = paste0(soiltypeTitle$soil_type[1]),
         x = "Average relative abundance within replicates [%], 1 x 50 µL",
         y = "Average relative abundance within replicates [%], 1 x 5 µL"
    )
  
  return(gg)
}



plotDiffRelabund2 <- function(df, filter_soil_type) {
  soiltypeTitle <- df %>%
    filter(soil_type == filter_soil_type) %>%
    distinct(soil_type)
  
  gg <- df %>%
    filter(soil_type == filter_soil_type) %>%
    ggplot(aes(x = `Amplicon`, y = `Metagenome`, color = Bias)) +
    geom_point(size = 4, alpha = 0.5, position = position_jitter()) +
    scale_color_manual(values = c("grey", colors[5], colors[3]), 
                       limits = c("Equally detected",
                                  "More abundant in amplicons", 
                                  "More abundant in metagenomes")) +
    geom_abline(linewidth = 0.5) +
    #scale_x_continuous(limits = c(0, 15)) +
    #scale_y_continuous(limits = c(0, 15)) +
    articletheme +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 0)
    ) +
    labs(
      x = "Relative Abundance [%], Amplicons",
      y = "Relative Abundance [%], Metagenomes",
      title = paste0(soiltypeTitle$soil_type[1])
    ) 
  
  return(gg)
}


deseq_function <- function(soil, dat_types) {
  deseqmatrix <- dat_types %>%
    amp_subset_samples(soil_type == soil)
  
  dds <- DESeqDataSetFromMatrix(
    countData = deseqmatrix$abund,
    colData = deseqmatrix$metadata,
    design = ~lib_volume
  )
  
  deseq <- DESeq(dds)
  res <- as.data.frame(results(deseq, cooksCutoff = FALSE, independentFiltering = FALSE)) %>%
    rownames_to_column("OTU")
  res$soil_type <- soil
  
  return(res)
}

deseq_function2 <- function(soil, dat_types) {
  deseqmatrix <- dat_types %>%
    amp_subset_samples(soil_type == soil)
  
  dds <- DESeqDataSetFromMatrix(
    countData = deseqmatrix$abund,
    colData = deseqmatrix$metadata,
    design = ~experiment
  )
  
  deseq <- DESeq(dds)
  res <- as.data.frame(results(deseq, cooksCutoff = FALSE, independentFiltering = FALSE)) %>%
    rownames_to_column("Genus")
  res$soil_type <- soil
  
  return(res)
}


combine_otu_w_metadata <- function(metadata, otu) {
  otu_long <- otu %>%
    t() %>%
    as.data.frame() %>%
    rownames_to_column("seq_id") %>%
    pivot_longer(-seq_id, names_to = "OTU", values_to = "abund")
  
  metadata_otu_combined <- metadata %>%
    select(seq_id, soil_type, lib_volume) %>%
    left_join(otu_long)
  
  return(metadata_otu_combined)
}

combine_otu_w_metadata2 <- function(metadata, otu) {
  otu_long <- otu %>%
    t() %>%
    as.data.frame() %>%
    rownames_to_column("seq_id") %>%
    pivot_longer(-seq_id, names_to = "Genus", values_to = "abund")
  
  metadata_otu_combined <- metadata %>%
    select(seq_id, soil_type, experiment) %>%
    left_join(otu_long)
  
  return(metadata_otu_combined)
}

summarise_triplicates <- function(df) {
  df_summarised <- df %>%
    group_by(soil_type, lib_volume, OTU) %>%
    summarise(abund = round(mean(abund)))
  
  return(df_summarised)
}

summarise_triplicates2 <- function(df) {
  df_summarised <- df %>%
    group_by(soil_type, experiment, Genus) %>%
    summarise(abund = round(mean(abund)))
  
  return(df_summarised)
}

calculate_relative_abundance <- function(df) {
  df_relAbund <- df %>%
    group_by(soil_type, lib_volume) %>%
    mutate(
      total_abund = sum(abund, na.rm = TRUE),
      rel_abund = abund / total_abund * 100
    ) %>%
    select(-abund, -total_abund)
  
  return(df_relAbund)
}

calculate_relative_abundance2 <- function(df) {
  df_relAbund <- df %>%
    group_by(soil_type, experiment) %>%
    mutate(
      total_abund = sum(abund, na.rm = TRUE),
      rel_abund = abund / total_abund * 100
    ) %>%
    select(-abund, -total_abund)
  
  return(df_relAbund)
}

filter_double_zeros <- function(df) {
  df_filtered <- df %>%
    relocate(OTU, .before = lib_volume) %>%
    pivot_wider(names_from = "lib_volume", values_from = "rel_abund") %>%
    rowwise() %>%
    filter(sum(`Full-scale`, `Small-scale`) > 0)
  
  
  return(df_filtered)
}

filter_double_zeros2 <- function(df) {
  df_filtered <- df %>%
    relocate(Genus, .before = experiment) %>%
    pivot_wider(names_from = "experiment", values_from = "rel_abund") %>%
    rowwise() %>%
    filter(sum(`Amplicon`, `Metagenome`) > 0)
  
  
  return(df_filtered)
}


# Bray distance
calculate_bray_distance <- function(ampdata) {
  metadata <- ampdata$metadata %>%
    select(seq_id, sample_id, lib_volume, soil_type)
  
  otutable <- ampdata$abund %>%
    t()
  
  bray_distance <- as.matrix(vegan::vegdist(otutable)) %>%
    as.data.frame() %>%
    rownames_to_column("seq_id")
  
  metadata_renamed <- metadata %>%
    dplyr::rename(
      comparison = seq_id,
      compared_soil = soil_type,
      compared_protocol = lib_volume
    ) %>%
    select(-sample_id)
  
  bray_with_metadata <- metadata %>%
    left_join(bray_distance, by = "seq_id") %>%
    pivot_longer(!seq_id:soil_type, names_to = "comparison", values_to = "value") %>%
    left_join(metadata_renamed, by = "comparison")
  
  return(bray_with_metadata)
}

calculate_bray_distance2 <- function(ampdata) {
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


