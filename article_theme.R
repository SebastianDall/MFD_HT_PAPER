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
