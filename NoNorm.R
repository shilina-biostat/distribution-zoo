# ============================================================
# DISTRIBUTION ZOO
# Real-world data rarely look perfectly normal
# ============================================================

# Packages
library(ggplot2)
library(patchwork)


# ============================================================
# PART 1. DISTRIBUTION ZOO
# ============================================================

set.seed(7)

n <- 5000


# ------------------------------------------------------------
# 1. Generate different types of data
# ------------------------------------------------------------

data_list <- list(
  
  "Normal\n(bell curve)" =
    rnorm(n, mean = 50, sd = 10),
  
  "Right-skewed\n(biomarkers, costs)" =
    rlnorm(n, meanlog = 3.3, sdlog = 1.0),
  
  "Count data\n(number of visits)" =
    rnbinom(n, size = 1.5, prob = 0.15),
  
  "Time-to-event\n(time to relapse)" =
    rweibull(n, shape = 0.7) * 15,
  
  "Bimodal\n(two subgroups)" =
    c(
      rnorm(n / 2, mean = 15, sd = 4),
      rnorm(n / 2, mean = 85, sd = 4)
    ),
  
  "Heavy tails\n(extreme values)" =
    rt(n, df = 1.5) * 8 + 50
)


clip_range <- function(x, lo, hi) x[x >= lo & x <= hi]

data_list[["Right-skewed\n(biomarkers, costs)"]] <-
  clip_range(data_list[["Right-skewed\n(biomarkers, costs)"]], 0, 400)

data_list[["Count data\n(number of visits)"]] <-
  clip_range(data_list[["Count data\n(number of visits)"]], 0, 60)

data_list[["Heavy tails\n(extreme values)"]] <-
  clip_range(data_list[["Heavy tails\n(extreme values)"]], -150, 250)



# ------------------------------------------------------------
# 2. Colors
# ------------------------------------------------------------

colors <- c(
  "#00d4ff",
  "#ff4d6d",
  "#ffb703",
  "#39ff88",
  "#c77dff",
  "#ff5c8a"
)


# ------------------------------------------------------------
# 3. Common dark theme
# ------------------------------------------------------------

dark_theme <- theme_minimal(base_size = 13) +
  
  theme(
    
    plot.background = element_rect(
      fill = "#0e0e10",
      color = NA
    ),
    
    panel.background = element_rect(
      fill = "#161618",
      color = NA
    ),
    
    plot.title = element_text(
      color = "white",
      face = "bold",
      size = 12,
      hjust = 0.5
    ),
    
    axis.text = element_text(
      color = "#aaaaaa"
    ),
    
    axis.title = element_blank(),
    
    axis.text.y = element_blank(),
    
    panel.grid = element_blank(),
    
    axis.line.x = element_line(
      color = "#555555"
    )
  )


# ------------------------------------------------------------
# 4. Function for one histogram
# ------------------------------------------------------------

make_histogram <- function(data, title, color) {
  
  ggplot(
    data.frame(x = data),
    aes(x = x)
  ) +
    
    geom_histogram(
      aes(y = after_stat(density)),
      bins = 55,
      fill = color,
      color = "#0e0e10",
      linewidth = 0.1
    ) +
    
    geom_density(
      color = "white",
      linewidth = 0.8
    ) +
    
    labs(title = title) +
    
    dark_theme
}


# ------------------------------------------------------------
# 5. Create six histograms
# ------------------------------------------------------------

histograms <- lapply(
  seq_along(data_list),
  function(i) {
    
    make_histogram(
      data = data_list[[i]],
      title = names(data_list)[i],
      color = colors[i]
    )
  }
)


# ------------------------------------------------------------
# 6. Combine histograms
# ------------------------------------------------------------

distribution_plot <-
  wrap_plots(
    histograms,
    ncol = 3
  ) +
  
  plot_annotation(
    
    title = "DISTRIBUTION ZOO",
    
    subtitle =
      "The bell curve is not the only shape",
    
    theme = theme(
      
      plot.background = element_rect(
        fill = "#0e0e10",
        color = NA
      ),
      
      plot.title = element_text(
        color = "white",
        face = "bold",
        size = 16,
        hjust = 0.5
      ),
      
      plot.subtitle = element_text(
        color = "#999999",
        face = "italic",
        hjust = 0.5
      )
    )
  )


# Display
distribution_plot


# Save
ggsave(
  "distribution_zoo_dark.png",
  plot = distribution_plot,
  width = 15,
  height = 8.5,
  dpi = 200
)


# ============================================================
# PART 2. BOXPLOT VS RAINCLOUD
# ============================================================

set.seed(7)

# ------------------------------------------------------------
# 7. Generate skewed data
# ------------------------------------------------------------
skewed_data <- rlnorm(400, meanlog = 2.6, sdlog = 0.9)
skewed_data <- skewed_data[skewed_data < 120]

# ------------------------------------------------------------
# 8. Generate data with extreme observations
# ------------------------------------------------------------
extreme_values <- c(95, 98, 102, 4, 8, 110)
outlier_data <- c(rnorm(394, mean = 50, sd = 6), extreme_values)

# ------------------------------------------------------------
# 9. Boxplot function
# ------------------------------------------------------------
make_boxplot <- function(data, label, y_limits) {
  
  med <- median(data)
  box_width <- 0.5          # explicit width -> known edge position
  edge <- 1 + box_width / 2 # right edge of the box = 1.25
  
  ggplot(data.frame(x = "Group", y = data), aes(x = x, y = y)) +
    
    geom_boxplot(
      width = box_width,
      fill = "#3a3a3d",
      color = "white",
      outlier.colour = "#ffb703",
      outlier.size = 2,
      linewidth = 0.8
    ) +
    
    annotate(
      "segment",
      x = edge, xend = edge + 0.35,
      y = med, yend = med,
      color = "#ff4d6d", linewidth = 0.7
    ) +
    
    annotate(
      "label",
      x = edge + 0.4, y = med, label = label, hjust = 0,
      color = "#ff4d6d", fill = "#0e0e10",
      label.size = 0, fontface = "bold", size = 3.3
    ) +
    
    coord_cartesian(ylim = y_limits, clip = "off") +
    
    scale_x_discrete(expand = expansion(mult = c(0.25, 0.8))) +
    
    labs(x = NULL, y = NULL) +   # kill stray "x"/"y" titles by default
    
    dark_theme +
    
    theme(
      plot.margin = margin(t = 10, r = 130, b = 10, l = 10),
      axis.title.x = element_blank(),
      axis.text.y = element_text(color = "#aaaaaa")   # добавить эту строку
    )
}




# ------------------------------------------------------------
# 10. Raincloud plot function
# ------------------------------------------------------------
make_raincloud <- function(data, label, fill_color, point_color, y_limits) {
  
  df <- data.frame(x = "Group", y = data)
  df$x_jitter <- 0.75 + runif(nrow(df), min = -0.08, max = 0.08)
  
  med <- median(data)
  edge <- 1.15  # violin tapers well before this at median density, safe leader-line start
  
  ggplot(df, aes(x = x, y = y)) +
    
    geom_violin(fill = fill_color, color = NA, alpha = 0.45, width = 0.8) +
    
    geom_boxplot(
      width = 0.1, fill = "#161618", color = "white",
      linewidth = 0.7, outlier.shape = NA
    ) +
    
    geom_point(aes(x = x_jitter, y = y), color = point_color, alpha = 0.6, size = 1.4) +
    
    annotate(
      "segment",
      x = edge, xend = edge + 0.4,
      y = med, yend = med,
      color = "#39ff88", linewidth = 0.7
    ) +
    
    annotate(
      "label",
      x = edge + 0.45, y = med, label = label, hjust = 0,
      color = "#39ff88", fill = "#0e0e10",
      label.size = 0, fontface = "bold", size = 3.3
    ) +
    
    coord_cartesian(ylim = y_limits, clip = "off") +
    
    scale_x_discrete(expand = expansion(mult = c(0.25, 0.8))) +
    
    labs(x = NULL, y = NULL) +
    
    dark_theme +
    
    theme(
      plot.margin = margin(t = 10, r = 130, b = 10, l = 10),
      axis.title.x = element_blank(),
      axis.text.y = element_text(color = "#aaaaaa")
    )
}

# ------------------------------------------------------------
# 11. Create four plots
# ------------------------------------------------------------

p1 <- make_boxplot(skewed_data, "Tail = outliers?", c(-10, 130)) +
  labs(title = "Boxplot") + ylab("Skewed data")

p2 <- make_raincloud(skewed_data, "The shape matters", "#00d4ff", "#00d4ff", c(-10, 130)) +
  labs(title = "Raincloud plot")

p3 <- make_boxplot(outlier_data, "6 suspicious points", c(-10, 130)) +
  labs(title = "Boxplot") + ylab("Extreme observations")

p4 <- make_raincloud(outlier_data, "Rare observations", "#c77dff", "#ff9f4d", c(-10, 130)) +
  labs(title = "Raincloud plot")

# ------------------------------------------------------------
# 12. Combine boxplot and raincloud plots
# ------------------------------------------------------------

boxplot_comparison <-
  (p1 | p2) / (p3 | p4) +
  plot_annotation(
    title = "TAIL OR SHAPE?",
    subtitle = "A boxplot does not show everything",
    theme = theme(
      plot.background = element_rect(fill = "#0e0e10", color = NA),
      plot.title = element_text(color = "white", face = "bold", size = 16, hjust = 0.5),
      plot.subtitle = element_text(color = "#999999", hjust = 0.5)
    )
  )

boxplot_comparison

ggsave(
  "boxplot_vs_raincloud_dark.png",
  plot = boxplot_comparison,
  width = 14, height = 11.5, dpi = 300,
  bg = "#0e0e10"
)

# ============================================================
# PART 3. WHAT CAN WE DO WITH DIFFERENT DATA?
# ============================================================


guidance <- data.frame(
  
  Distribution = c(
    "Normal",
    "Right-skewed",
    "Count data",
    "Time-to-event",
    "Bimodal",
    "Heavy tails"
  ),
  
  Example = c(
    "Continuous measurements",
    "Biomarkers, healthcare costs",
    "Number of visits or events",
    "Time to relapse",
    "Possible subgroups",
    "Extreme observations"
  ),
  
  What_to_check = c(
    "Model assumptions",
    "Skewness and positive values",
    "Dispersion and zero counts",
    "Censoring and event structure",
    "Subgroups and mixture structure",
    "Data quality and influential values"
  ),
  
  Possible_approach = c(
    "Linear models if assumptions are satisfied",
    "Log transformation or Gamma GLM",
    "Poisson or Negative Binomial",
    "Survival analysis",
    "Investigate subgroups",
    "Robust methods and sensitivity analysis"
  )
)


# Display table

print(guidance)


# Save table

write.csv(
  guidance,
  "distribution_guidance.csv",
  row.names = FALSE,
  fileEncoding = "UTF-8"
)
