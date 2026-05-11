# Spotify Data Visualization

library(ggplot2)
library(dplyr)
library(gridExtra)

# Load data
data <- readRDS("data/cleaned_data.rds")
pca_scores <- readRDS("output/pca_scores.rds")
pca_loadings <- read.csv("output/pca_loadings.csv")

message("Creating visualizations...")

# ===== 1. Audio Features Distribution =====
audio_cols <- c("danceability", "energy", "loudness", "speechiness",
                "acousticness", "instrumentalness", "liveness", "valence", "tempo")

feature_dist <- data %>%
  select(all_of(audio_cols)) %>%
  tidyr::pivot_longer(everything(), names_to = "feature", values_to = "value")

p1 <- ggplot(feature_dist, aes(x = feature, y = value, fill = feature)) +
  geom_boxplot(alpha = 0.7) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Distribution of Spotify Audio Features", x = "", y = "Value")

# ===== 2. Feature Correlation Heatmap Data =====
cor_matrix <- cor(data[, audio_cols])
cor_long <- as.data.frame(as.table(cor_matrix))

p2 <- ggplot(cor_long, aes(x = Var1, y = Var2, fill = Freq)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Audio Feature Correlation Matrix", x = "", y = "", fill = "Correlation")

# ===== 3. PCA Biplot (PC1 vs PC2) =====
p3 <- ggplot(pca_scores, aes(x = PC1, y = PC2, color = genre)) +
  geom_point(alpha = 0.6, size = 2) +
  theme_minimal() +
  labs(title = "PCA: Songs by Genre (PC1 vs PC2)",
       x = "PC1", y = "PC2", color = "Genre") +
  theme(legend.position = "right")

# ===== 4. Feature Loadings (PC1) =====
loadings_plot <- pca_loadings %>%
  arrange(desc(abs(PC1))) %>%
  head(8)

p4 <- ggplot(loadings_plot, aes(x = reorder(feature, PC1), y = PC1, fill = PC1 > 0)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "#2E86AB", "FALSE" = "#A23B72")) +
  theme_minimal() +
  labs(title = "Feature Loadings on PC1",
       x = "Audio Feature", y = "Loading Value") +
  theme(legend.position = "none")

# ===== 5. Genre Statistics =====
genre_stats <- data %>%
  group_by(genre) %>%
  summarise(
    avg_energy = mean(energy),
    avg_danceability = mean(danceability),
    avg_valence = mean(valence),
    count = n()
  )

p5 <- ggplot(genre_stats, aes(x = reorder(genre, avg_energy), y = avg_energy, fill = avg_danceability)) +
  geom_col() +
  coord_flip() +
  scale_fill_gradient(low = "#FFB703", high = "#FB5607") +
  theme_minimal() +
  labs(title = "Average Energy by Genre",
       x = "Genre", y = "Energy Level", fill = "Danceability") +
  theme(legend.position = "right")

# Save individual plots
ggsave("output/01_feature_distribution.png", p1, width = 10, height = 6)
ggsave("output/02_correlation_heatmap.png", p2, width = 10, height = 8)
ggsave("output/03_pca_biplot.png", p3, width = 10, height = 6)
ggsave("output/04_feature_loadings.png", p4, width = 8, height = 6)
ggsave("output/05_genre_statistics.png", p5, width = 10, height = 6)

message("✓ Visualizations created and saved to output/")
message("  - 01_feature_distribution.png")
message("  - 02_correlation_heatmap.png")
message("  - 03_pca_biplot.png")
message("  - 04_feature_loadings.png")
message("  - 05_genre_statistics.png")
