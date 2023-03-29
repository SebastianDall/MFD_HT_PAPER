library(tidyverse)
library(ggpubr)
library(RColorBrewer)

# Soil specific ordination
plotAmpliconOrdinationSoil <- function(df, soil_filter, ord_type = "CA", envvector, rel_ab_filter = 0.1) {
    df %>%
        amp_subset_samples(soil_type == soil_filter) %>%
        amp_ordinate(
            filter_species = 0.1,
            type = ord_type,
            constrain = "kit",
            transform = "hellinger",
            distmeasure = "bray",
            #envfit_numeric = envvector,
            sample_colorframe = "kit",
            #envfit_numeric_arrows_scale = 0.2,
            #envfit_arrowcolor = "#4bbbe1",
            species_nlabels = 5,
            species_label_taxonomy = "Phylum",
            species_plot = T
        ) +
        # ggforce::geom_mark_ellipse(aes(fill = Kit, group = Kit), alpha = 0.5, color = "black") +
        labs(
            title = paste0(soil_filter, ": ", ord_type, " of microbial diversity")
            # fill = "Extraction Kit",
        ) +
        articletheme +
        theme(
            legend.position = "none",
            axis.text.x = element_text(angle = 0, hjust = 0, vjust = 0)
        )
}

# Add NA in red (not used anymore)

addTableColor <- function(table, df, filter_col, column) {
    NA_vector <- df %>%
        filter(variable == filter_col, is.na(value))

    new_tab <- table_cell_font(table, row = NA_vector$rownumber, column = column, face = "italic", color = "red")
    return(new_tab)
}



# For custom ordination


generateAmpliconOrdinationData <- function(df, soil_filter, ord_type = "CA", envvector, rel_ab_filter = 0.1) {
    df %>%
        amp_subset_samples(Soil_type == soil_filter) %>%
        amp_ordinate(
            filter_species = 0.1,
            type = ord_type,
            constrain = "Kit",
            transform = "hellinger",
            distmeasure = "bray",
            envfit_numeric = envvector,
            sample_colorframe = "Kit",
            # species_nlabels = 5,
            # species_label_taxonomy = "Phylum",
            detailed_output = T,
            species_plot = T
        )
}

plotMetadataOrdination <- function(df) {
    plot <- df %>%
        ggplot(aes(x = PC1, y = PC2, color = Kit, fill = Kit))

    # samplecolorframe
    plot <- plot + geom_polygon(aes(fill = Kit, group = Kit), alpha = 0.4, show.legend = FALSE)

    # Sample points
    plot <- plot + geom_point(size = 3)

    return(plot)
}

addSpeciesPlot <- function(gg, df) {
    plot <- gg +
        geom_point(data = df, aes(x = PC1, y = PC2), inherit.aes = FALSE, size = 3, alpha = 0.6, color = "grey")

    return(plot)
}


addEnvVector <- function(gg, df) {
    scale_fac <- 0.5
    pval_filter <- 0.005

    envfit_df <- data.frame(
        Name = rownames(df$vectors$arrows),
        df$vectors$arrows * sqrt(df$vectors$r) * scale_fac,
        pval = df$vectors$pvals
    ) %>%
        filter(pval < pval_filter) %>%
        mutate(Name = str_replace(Name, "p\\_{2}", ""))

    plot <- gg +
        geom_segment(
            data = envfit_df, aes(
                x = 0,
                xend = PC1,
                y = 0,
                yend = PC2
            ), inherit.aes = FALSE,
            arrow = arrow(length = unit(2, "mm")),
            colour = "#e49c00",
            linewidth = 1,
            alpha = 0.7
        ) +
        geom_text_repel(
            data = envfit_df,
            aes(
                x = PC1,
                y = PC2,
                label = Name
            ), inherit.aes = FALSE,
            colour = "black",
            size = 3,
            box.padding = 0.5,
            fontface = "bold"
        )

    return(plot)
}


addLegendPlot <- function(plotlist) {
    ggleg <- plotlist[[1]] + theme(legend.position = "right")

    leg <- list(get_legend(ggleg))

    plot_list2 <- append(plotlist, leg)

    return(plot_list2)
}
