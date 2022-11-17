# Ordination function
plotAmpliconOrdination <- function(df, ord_type = "CA", rel_ab_filter = 0.1) {
    df %>%
        amp_ordinate(
            sample_color_by = "Soil_type",
            sample_shape_by = "Protocol",
            filter_species = rel_ab_filter,
            type = ord_type,
            transform = "hellinger",
            distmeasure = "bray",
            sample_colorframe = F,
            species_plot = T
        ) +
        ggforce::geom_mark_ellipse(aes(fill = Soil_type, color = Soil_type)) +
        # ggtitle("PCoA of microbial diversity", subtitle = bquote(atop(c("PERMANOVA", "Soil type:" ~R^2~ "= 0.54, p-value = 0.001", "Protocol:" ~R^2~ "= 0.02, p-value = 0.214")))) +
        labs(
            title = paste0(ord_type, " of microbial diversity"),
            fill = "Sample type"
        ) +
        articletheme +
        theme(
            legend.position = "none",
            axis.text.x = element_text(angle = 0)
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
        geom_abline(size = 0.5) +
        articletheme +
        theme(
            legend.position = "bottom",
            axis.text.x = element_text(angle = 0)
        ) +
        labs(x = "Relative Abundance [%], 2 x 25 µL", y = "Relative Abundance [%], 2 x 5 µL", title = paste0("Amplicon Read Relative Abundance for ", soiltypeTitle$Soil_type[1]))

    return(gg)
}
