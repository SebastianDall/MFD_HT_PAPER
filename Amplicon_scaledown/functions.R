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
        ggplot(aes(x = Fullscale, y = Downscaled, color = pval_signif)) +
        geom_point(size = 4, alpha = 0.5, position = position_jitter()) +
        scale_color_manual(values = c("grey", "red", "blue")) +
        geom_abline(linewidth = 0.5) +
        articletheme +
        theme(
            legend.position = "bottom",
            axis.text.x = element_text(angle = 0)
        ) +
        labs(x = "Relative Abundance [%], 2 x 25 µL", y = "Relative Abundance [%], 2 x 5 µL", title = paste0("Amplicon Read Relative Abundance for ", soiltypeTitle$Soil_type[1]))

    return(gg)
}
