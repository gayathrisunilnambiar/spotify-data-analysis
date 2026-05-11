# Spotify Data Cleaning

library(dplyr)

# Load raw data
data <- readRDS("data/raw_data.rds")

message("Original data shape: ", nrow(data), " rows, ", ncol(data), " columns")

# Remove duplicates
data <- data %>% distinct()
message("✓ Duplicates removed")

# Handle missing values
missing_count <- sum(is.na(data))
if (missing_count > 0) {
  data <- na.omit(data)
  message("✓ Missing values removed: ", missing_count)
} else {
  message("✓ No missing values found")
}

# Remove rows with invalid audio features (0 values across most features)
audio_features <- c("danceability", "energy", "acousticness", "instrumentalness",
                    "liveness", "valence", "tempo")
data <- data %>%
  filter(rowSums(.[, audio_features] == 0) < length(audio_features) - 2)

message("Data shape after cleaning: ", nrow(data), " rows, ", ncol(data), " columns")

# Extract audio features for normalization
audio_cols <- c("danceability", "energy", "loudness", "speechiness",
                "acousticness", "instrumentalness", "liveness", "valence", "tempo")

# Normalize audio features (z-score)
data_normalized <- data %>%
  mutate(across(all_of(audio_cols), scale, .names = "{.col}"))

# Save cleaned data
saveRDS(data, "data/cleaned_data.rds")
saveRDS(data_normalized, "data/cleaned_data_normalized.rds")

message("✓ Data cleaning complete")
message("  Audio features normalized (z-score)")
message("  Files saved: cleaned_data.rds, cleaned_data_normalized.rds")
