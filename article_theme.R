library(ggplot2)

# theme
articletheme <- theme_bw(base_size = 10) +
    theme(
        axis.text.x = element_text(angle = 90, face = "bold", vjust = 0.5, size = 10, hjust = 1),
        axis.text.y = element_text(face = "bold", size = 10),
        plot.margin = unit(c(0, 1, 0, 0), "cm"),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
        strip.text.x = element_text(size = 7, face = "bold"),
        strip.text.y = element_text(size = 7, face = "bold"),
        legend.title = element_text(face = "bold"),
        legend.text = element_text(face = "bold", size = 10)
    )

articlethemex0 <- articletheme + theme(axis.text.x = element_text(angle = 0, face = "bold", vjust = 0, size = 10, hjust = 0.5))


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
