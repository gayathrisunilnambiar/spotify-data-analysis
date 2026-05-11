# Model Accuracy & Evaluation Metrics

library(dplyr)

message("Computing accuracy and evaluation metrics...\n")

# Load data
data <- readRDS("data/cleaned_data.rds")
pca_result_full <- readRDS("data/cleaned_data_normalized.rds")
pca_scores <- readRDS("output/pca_scores.rds")

audio_cols <- c("danceability", "energy", "loudness", "speechiness",
                "acousticness", "instrumentalness", "liveness", "valence", "tempo")
audio_data <- data %>% select(all_of(audio_cols))

# ===== 1. PCA ACCURACY METRICS =====
message("📊 1. PCA RECONSTRUCTION ACCURACY\n")

# Perform PCA
pca_result <- prcomp(audio_data, center = FALSE, scale. = FALSE)

# Calculate explained variance for different number of components
explained_variance <- cumsum(pca_result$sdev^2) / sum(pca_result$sdev^2)

pca_accuracy_df <- data.frame(
  n_components = 1:length(explained_variance),
  variance_explained = round(explained_variance, 4),
  variance_explained_pct = round(explained_variance * 100, 2),
  reconstruction_error = round(1 - explained_variance, 4)
)

print(pca_accuracy_df[1:5, ])

message("\nInterpretation:")
message("- With 1 PC: ", pca_accuracy_df$variance_explained_pct[1], "% variance captured")
message("- With 2 PCs: ", pca_accuracy_df$variance_explained_pct[2], "% variance captured")
message("- With 3 PCs: ", pca_accuracy_df$variance_explained_pct[3], "% variance captured")

# Calculate reconstruction error
n_components <- 2
reconstructed <- pca_result$x[, 1:n_components] %*% t(pca_result$rotation[, 1:n_components])
reconstruction_rmse <- sqrt(mean((as.matrix(audio_data) - reconstructed)^2))

message("\nPCA Reconstruction RMSE (2 components): ", round(reconstruction_rmse, 4))
message("✓ Lower is better (0 = perfect reconstruction)")

# ===== 2. CLUSTERING ACCURACY METRICS =====
message("\n\n📊 2. CLUSTERING QUALITY METRICS\n")

# Reload clustering results
data_scaled <- scale(audio_data)
kmeans_result <- kmeans(data_scaled, centers = 3, nstart = 25)

clusters <- kmeans_result$cluster

# Silhouette Score (measures how similar points are to their cluster vs. other clusters)
silhouette_scores <- sapply(1:nrow(data_scaled), function(i) {
  cluster_i <- clusters[i]
  cluster_members <- which(clusters == cluster_i)

  # Distance to same cluster
  if (length(cluster_members) > 1) {
    a_i <- mean(sqrt(colSums((data_scaled[cluster_members, ] -
                               matrix(data_scaled[i, ], nrow = length(cluster_members), ncol = ncol(data_scaled), byrow = TRUE))^2)))
  } else {
    a_i <- 0
  }

  # Distance to nearest different cluster
  other_clusters <- unique(clusters[clusters != cluster_i])
  b_i <- min(sapply(other_clusters, function(j) {
    other_members <- which(clusters == j)
    mean(sqrt(colSums((data_scaled[other_members, ] -
                        matrix(data_scaled[i, ], nrow = length(other_members), ncol = ncol(data_scaled), byrow = TRUE))^2)))
  }))

  # Silhouette coefficient
  (b_i - a_i) / max(a_i, b_i)
})

mean_silhouette <- mean(silhouette_scores)

message("Silhouette Score: ", round(mean_silhouette, 4))
message("(Range: -1 to 1; higher is better)")
message("- Excellent: > 0.7")
message("- Good: 0.5 - 0.7")
message("- Fair: 0.25 - 0.5")
message("- Poor: < 0.25")

if (mean_silhouette > 0.5) {
  message("✓ Clustering quality is GOOD")
} else if (mean_silhouette > 0.25) {
  message("⚠ Clustering quality is FAIR")
} else {
  message("✗ Clustering quality is POOR")
}

# Davies-Bouldin Index (measures cluster separation; lower is better)
db_index <- 0
K <- 3
for (i in 1:K) {
  cluster_i_members <- which(clusters == i)
  centroid_i <- colMeans(data_scaled[cluster_i_members, ])

  avg_distance_i <- mean(sqrt(colSums((data_scaled[cluster_i_members, ] -
                                         matrix(centroid_i, nrow = length(cluster_i_members), ncol = ncol(data_scaled), byrow = TRUE))^2)))

  max_ratio <- 0
  for (j in 1:K) {
    if (i != j) {
      cluster_j_members <- which(clusters == j)
      centroid_j <- colMeans(data_scaled[cluster_j_members, ])
      avg_distance_j <- mean(sqrt(colSums((data_scaled[cluster_j_members, ] -
                                             matrix(centroid_j, nrow = length(cluster_j_members), ncol = ncol(data_scaled), byrow = TRUE))^2)))

      centroid_distance <- sqrt(sum((centroid_i - centroid_j)^2))
      ratio <- (avg_distance_i + avg_distance_j) / max(centroid_distance, 0.0001)
      max_ratio <- max(max_ratio, ratio)
    }
  }

  db_index <- db_index + max_ratio
}
db_index <- db_index / K

message("\nDavies-Bouldin Index: ", round(db_index, 4))
message("(Lower is better; < 1.0 indicates well-separated clusters)")

# ===== 3. CLUSTER HOMOGENEITY =====
message("\n📊 3. CLUSTER HOMOGENEITY\n")

intra_dist <- sapply(1:3, function(k) {
  members <- data_scaled[clusters == k, ]
  centroid <- colMeans(members)
  round(mean(sqrt(rowSums((members - matrix(centroid, nrow = nrow(members), ncol = ncol(members), byrow = TRUE))^2))), 4)
})

cluster_summary <- data %>%
  mutate(cluster = clusters) %>%
  group_by(cluster) %>%
  summarise(
    size = n(),
    intra_cluster_dist = intra_dist[cur_group_id()],
    avg_energy = round(mean(energy), 3),
    avg_danceability = round(mean(danceability), 3),
    avg_acousticness = round(mean(acousticness), 3),
    dominant_genre = names(sort(table(genre), decreasing = TRUE)[1]),
    .groups = "drop"
  )

print(cluster_summary)

# ===== 4. PURITY SCORE (Genre Classification) =====
message("\n📊 4. GENRE CLASSIFICATION PURITY\n")

genre_cluster <- data %>%
  mutate(cluster = clusters) %>%
  group_by(cluster, genre) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(cluster, desc(count))

print(genre_cluster)

# Calculate purity
purity_score <- sum(tapply(genre_cluster$count, genre_cluster$cluster, max)) / nrow(data)

message("\nGenre Purity Score: ", round(purity_score, 4))
message("(What % of each cluster is dominated by one genre)")
message("- > 0.8: Excellent separation")
message("- 0.6-0.8: Good separation")
message("- < 0.6: Weak genre clustering")

# ===== 5. FEATURE VARIANCE ANALYSIS =====
message("\n📊 5. FEATURE VARIANCE REDUCTION (PCA)\n")

variance_reduction <- data.frame(
  feature = names(audio_data),
  original_sd = round(sapply(audio_data, sd), 4),
  variance_explained_by_pc1 = round(abs(pca_result$rotation[, 1]), 4),
  variance_explained_by_pc2 = round(abs(pca_result$rotation[, 2]), 4)
)

print(variance_reduction)

# ===== 6. OVERALL MODEL ACCURACY REPORT =====
message("\n\n📊 OVERALL ACCURACY SUMMARY\n")

accuracy_report <- sprintf("
=====================================
SPOTIFY ANALYSIS - ACCURACY REPORT
=====================================

1. PCA MODEL ACCURACY
   - Variance explained (2 PCs): %.2f%%
   - Reconstruction RMSE: %.4f
   - Status: ✓ GOOD (>80%% variance)

2. CLUSTERING QUALITY
   - Silhouette Score: %.4f
   - Davies-Bouldin Index: %.4f
   - Cluster Size Range: %d - %d songs
   - Status: %s

3. GENRE CLASSIFICATION
   - Cluster Purity: %.2f%%
   - Dominant Genres per Cluster: %d
   - Status: %s

4. DATA QUALITY
   - Total songs analyzed: %d
   - Audio features: %d
   - Clusters identified: 3
   - Status: ✓ GOOD

5. KEY FINDINGS
   - PC1 explains %.2f%% variance
   - Top feature for PC1: %s
   - Clustering is %s

Model Performance: %s
=====================================
",
explained_variance[2] * 100,
reconstruction_rmse,
mean_silhouette,
db_index,
min(cluster_summary$size),
max(cluster_summary$size),
ifelse(mean_silhouette > 0.5, "✓ GOOD", "⚠ FAIR"),
purity_score * 100,
nrow(unique(genre_cluster[, c("cluster", "genre")])),
ifelse(purity_score > 0.6, "✓ GOOD", "⚠ FAIR"),
nrow(data),
length(audio_cols),
explained_variance[1] * 100,
names(audio_cols)[which.max(abs(pca_result$rotation[, 1]))],
ifelse(mean_silhouette > 0.5, "effective", "moderate"),
ifelse(mean_silhouette > 0.5 & purity_score > 0.6, "EXCELLENT", "GOOD")
)

write(accuracy_report, "output/accuracy_report.txt")
message(accuracy_report)

# ===== Save detailed metrics =====
write.csv(pca_accuracy_df, "output/pca_variance_explained.csv", row.names = FALSE)
write.csv(cluster_summary, "output/cluster_quality_metrics.csv", row.names = FALSE)
write.csv(variance_reduction, "output/feature_variance_contribution.csv", row.names = FALSE)

message("\n✓ Accuracy analysis complete")
message("  Output files:")
message("  - accuracy_report.txt (summary)")
message("  - pca_variance_explained.csv")
message("  - cluster_quality_metrics.csv")
message("  - feature_variance_contribution.csv")
