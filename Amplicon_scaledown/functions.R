
# theme
articletheme <- theme_bw(base_size = 10) +
    theme(
        axis.text.x = element_text(angle = 90, face = "bold", vjust = 0.5, size = 10, hjust = 1),
        axis.text.y = element_text(face = "bold", size = 10),
        plot.margin = unit(c(0, 1, 0, 0), "cm"),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 10),
        strip.text.x = element_text(size = 7, face = "bold"),
        strip.text.y = element_text(size = 7, face = "bold"),
        legend.title = element_text(face = "bold"),
        legend.text = element_text(face = "bold", size = 10)
    )


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
        theme(legend.position = "none")
}



abundance_filter <- function(df, abundance_threshold = 0.1, verbose = F) {
    n_before <- ncol(df)

    df_filter <- df %>%
        rownames_to_column("id") %>%
        pivot_longer(-id, names_to = "clade_name", values_to = "relative_abundance") %>%
        group_by(id) %>%
        mutate(relative_abundance = relative_abundance / sum(relative_abundance)) %>%
        group_by(clade_name) %>%
        summarise(relative_abundance = max(relative_abundance)) %>%
        filter(relative_abundance >= abundance_threshold / 100)

    df_filtered <- df %>%
        select(df_filter$clade_name)

    n_after <- ncol(df_filtered)
    if (verbose) {
        cat(paste0(
            "Species before: ", n_before, "\n",
            "Species after: ", n_after, "\n",
            "Removed species: ", n_before - n_after, "\n"
        ))
    }

    return(df_filtered)
}



plotDiffRelabund <- function(df, filter_soil_type) {
    gg <- df %>%
        filter(Soil_type == filter_soil_type) %>%
        ggplot(aes(x = Fullscale, y = Downscaled, color = Bias)) +
        geom_point(size = 4, alpha = 0.5, position = position_jitter()) +
        scale_color_manual(values = c("grey", "red", "blue")) +
        geom_abline(size = 0.5) +
        articletheme

    return(gg)
}
