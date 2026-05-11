# Spotify Dimensionality Reduction - PCA Analysis

library(dplyr)

# Load cleaned normalized data
data <- readRDS("data/cleaned_data_normalized.rds")

# Audio features for analysis
audio_cols <- c("danceability", "energy", "loudness", "speechiness",
                "acousticness", "instrumentalness", "liveness", "valence", "tempo")

# Extract normalized audio features
audio_data <- data %>% select(all_of(audio_cols))

message("Input data: ", nrow(data), " songs × ", length(audio_cols), " audio features")

# ========== PCA (Principal Component Analysis) ==========
pca_result <- prcomp(audio_data, center = FALSE, scale. = FALSE)

# Calculate explained variance
explained_var <- pca_result$sdev^2
cumulative_var <- cumsum(explained_var) / sum(explained_var)

message("\n📊 PCA Analysis:")
message("PC1: ", round(cumulative_var[1] * 100, 1), "% variance")
message("PC1+PC2: ", round(cumulative_var[2] * 100, 1), "% variance")
message("PC1+PC2+PC3: ", round(cumulative_var[3] * 100, 1), "% variance")

# Select top 2-3 components for visualization
n_components <- 3
pca_scores <- as.data.frame(pca_result$x[, 1:n_components])
pca_scores <- cbind(data[, c("track_name", "artist_name", "genre")], pca_scores)

# Save PCA results
saveRDS(pca_scores, "output/pca_scores.rds")
write.csv(pca_scores, "output/pca_scores.csv", row.names = FALSE)

# Feature importance (loadings)
loadings <- pca_result$rotation[, 1:2]
importance_df <- data.frame(
  feature = rownames(loadings),
  PC1 = loadings[, 1],
  PC2 = loadings[, 2]
)

write.csv(importance_df, "output/pca_loadings.csv", row.names = FALSE)

message("\n📈 Feature Importance (Top contributors to PC1 & PC2):")
print(importance_df %>%
  mutate(importance = abs(PC1) + abs(PC2)) %>%
  arrange(desc(importance)))

message("\n✓ PCA complete")
message("  Reduced dimensions: ", n_components)
message("  Output files: pca_scores.csv, pca_loadings.csv")
