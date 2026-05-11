# Spotify Song Clustering & Insights

library(dplyr)
library(ggplot2)

# Load data
data <- readRDS("data/cleaned_data.rds")
pca_scores <- readRDS("output/pca_scores.rds")

message("Analyzing song clusters...")

# ===== K-Means Clustering =====
audio_cols <- c("danceability", "energy", "loudness", "speechiness",
                "acousticness", "instrumentalness", "liveness", "valence", "tempo")
audio_data <- data %>% select(all_of(audio_cols))

# Normalize for clustering
audio_scaled <- scale(audio_data)

# Find optimal clusters using elbow method
inertias <- sapply(1:5, function(k) {
  kmeans(audio_scaled, centers = k, nstart = 10)$tot.withinss
})

optimal_k <- 3  # Usually 3-4 clusters work well for music
kmeans_result <- kmeans(audio_scaled, centers = optimal_k, nstart = 25)

# Add cluster to data
data$cluster <- as.factor(kmeans_result$cluster)
pca_scores$cluster <- as.factor(kmeans_result$cluster)

message("✓ K-Means clustering with ", optimal_k, " clusters")

# ===== Cluster Analysis =====
cluster_analysis <- data %>%
  group_by(cluster) %>%
  summarise(
    songs = n(),
    avg_energy = mean(energy),
    avg_danceability = mean(danceability),
    avg_valence = mean(valence),
    avg_acousticness = mean(acousticness),
    top_genre = names(sort(table(genre), decreasing = TRUE)[1])
  )

message("\n📊 Cluster Profiles:")
print(cluster_analysis)

# ===== Visualization: Clusters in PCA Space =====
p_clusters <- ggplot(pca_scores, aes(x = PC1, y = PC2, color = cluster, shape = genre)) +
  geom_point(alpha = 0.6, size = 3) +
  theme_minimal() +
  labs(title = "Song Clusters in PCA Space",
       x = "PC1", y = "PC2",
       color = "Cluster", shape = "Genre") +
  theme(legend.position = "right") +
  scale_color_brewer(palette = "Set1")

ggsave("output/06_song_clusters.png", p_clusters, width = 10, height = 6)

# ===== Save Results =====
write.csv(cluster_analysis, "output/cluster_profiles.csv", row.names = FALSE)
write.csv(data %>% select(track_name, artist_name, genre, cluster),
          "output/songs_with_clusters.csv", row.names = FALSE)

message("\n✓ Clustering complete")
message("  Output files:")
message("  - cluster_profiles.csv (cluster characteristics)")
message("  - songs_with_clusters.csv (song assignments)")
message("  - 06_song_clusters.png (visualization)")
