library(tidyverse)
library(ggpubr)
library(RColorBrewer)


# Ordination function
plotAmpliconOrdination <- function(df, ord_type = "CA", rel_ab_filter = 0.1) {
    df %>%
        amp_ordinate(
            # sample_color_by = "Soil_type",
            sample_shape_by = "Kit",
            filter_species = rel_ab_filter,
            type = ord_type,
            transform = "hellinger",
            distmeasure = "bray",
            sample_colorframe = F,
            species_plot = T
        ) +
        ggforce::geom_mark_ellipse(aes(fill = Soil_type, group = Soil_type), alpha = 0.5, color = "black") + # ggtitle("PCoA of microbial diversity", subtitle = bquote(atop(c("PERMANOVA", "Soil type:" ~R^2~ "= 0.54, p-value = 0.001", "Protocol:" ~R^2~ "= 0.02, p-value = 0.214")))) +
        labs(
            title = paste0(ord_type, " of microbial diversity"),
            fill = "Sample type",
            shape = "Extraction kit"
        ) +
        articletheme +
        theme(
            legend.position = "none",
            axis.text.x = element_text(angle = 0)
        )
}

addTableColor <- function(table, df, filter_col, column) {
    NA_vector <- df %>%
        filter(variable == filter_col, is.na(value))

    new_tab <- table_cell_font(table, row = NA_vector$rownumber, column = column, face = "italic", color = "red")
    return(new_tab)
}



createGGMetricsPlotForCombined <- function(df, metric_filter, plot_legend = "none") {
    colors <- c("grey", "darkgoldenrod2", "royalblue4", "seagreen", "salmon", "purple", "#0a6faa")

    ggobj <- df %>%
        filter(metric == metric_filter) %>%
        ggplot(aes(x = kit, y = value, color = fct_rev(soil_type_fct), group = interaction(soil_type_fct, kit))) +
        geom_point(aes(shape = benchmark), size = 5, alpha = 0.5, position = position_dodge(width = 0.75)) +
        scale_color_manual(values = colors) +
        scale_fill_manual(values = colors) +
        articletheme +
        theme(lengend.position = "none")
    return(ggobj)
}
