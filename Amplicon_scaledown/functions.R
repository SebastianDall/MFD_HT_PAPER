# Ordination function
plotAmpliconOrdinationSoil <- function(df, soil_filter, ord_type = "CA", rel_ab_filter = 0.1) {
    df %>%
        amp_subset_samples(Soil_type == soil_filter) %>%
        amp_ordinate(
            filter_species = 0.1,
            type = ord_type,
            constrain = "Protocol",
            transform = "hellinger",
            distmeasure = "bray",
            sample_colorframe = "Protocol",
            # species_nlabels = 5,
            # species_label_taxonomy = "Phylum",
            species_plot = T
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





plotDiffRelabund <- function(df, filter_soil_type) {
    soiltypeTitle <- df %>%
        filter(Soil_type == filter_soil_type) %>%
        distinct(Soil_type)

    gg <- df %>%
        filter(Soil_type == filter_soil_type) %>%
        ggplot(aes(x = Fullscale, y = Downscaled, color = Bias)) +
        geom_point(size = 4, alpha = 0.5, position = position_jitter()) +
        scale_color_manual(values = c("grey", "red", "blue")) +
        geom_abline(linewidth = 0.5) +
        articletheme +
        theme(
            legend.position = "none",
            axis.text.x = element_text(angle = 0)
        ) +
        labs(
            x = "Relative Abundance [%], 2 x 25 µL",
            y = "Relative Abundance [%], 2 x 5 µL",
            title = paste0(soiltypeTitle$Soil_type[1])
        )

    return(gg)
}


deseq_function <- function(soil) {
    deseqmatrix <- dat_types %>%
        amp_subset_samples(Soil_type == soil)

    dds <- DESeqDataSetFromMatrix(
        countData = deseqmatrix$abund,
        colData = deseqmatrix$metadata,
        design = ~Protocol
    )

    deseq <- DESeq(dds)
    res <- as.data.frame(results(deseq, cooksCutoff = FALSE, independentFiltering = FALSE)) %>%
        rownames_to_column("OTU")
    res$Soil_type <- soil

    return(res)
}



combine_otu_w_metadata <- function(metadata, otu) {
    otu_long <- otu %>%
        t() %>%
        as.data.frame() %>%
        rownames_to_column("SeqID") %>%
        pivot_longer(-SeqID, names_to = "OTU", values_to = "abund")

    metadata_otu_combined <- metadata %>%
        select(SeqID, Soil_type, Protocol) %>%
        left_join(otu_long)

    return(metadata_otu_combined)
}

summarise_triplicates <- function(df) {
    df_summarised <- df %>%
        group_by(Soil_type, Protocol, OTU) %>%
        summarise(abund = round(mean(abund)))

    return(df_summarised)
}

calculate_relative_abundance <- function(df) {
    df_relAbund <- df %>%
        group_by(Soil_type, Protocol) %>%
        mutate(
            total_abund = sum(abund, na.rm = TRUE),
            rel_abund = abund / total_abund * 100
        ) %>%
        select(-abund, -total_abund)

    return(df_relAbund)
}

filter_double_zeros <- function(df) {
    df_filtered <- df %>%
        relocate(OTU, .before = Protocol) %>%
        pivot_wider(names_from = Protocol, values_from = rel_abund) %>%
        dplyr::rename(Downscaled = `2 x 5 uL`, Fullscale = `2 x 25 uL`) %>%
        rowwise() %>%
        filter(sum(Fullscale, Downscaled) > 0)


    return(df_filtered)
}
