# Spotify Music Data Collection
# Loads Spotify tracks dataset with audio features

library(readr)

# Option 1: Download from Kaggle (Spotify 1.2M Tracks)
# Link: https://www.kaggle.com/datasets/rodolfolotte/spotify-12m-songs
# Save the CSV file to data/spotify_raw.csv

download_spotify_kaggle <- function() {
  message("To get Spotify data:")
  message("1. Go to: https://www.kaggle.com/datasets/rodolfolotte/spotify-12m-songs")
  message("2. Download the CSV file")
  message("3. Save to: data/spotify_raw.csv")
  message("OR use the sample data below (first 1000 tracks)")
}

# Option 2: Use sample Spotify data (1000 popular tracks)
create_sample_spotify_data <- function() {
  set.seed(42)

  genres <- c("pop", "rock", "hip-hop", "electronic", "indie", "folk", "country", "jazz")

  data <- data.frame(
    track_id = paste0("track_", 1:1000),
    track_name = paste("Song", sample(1:5000, 1000)),
    artist_name = paste("Artist", sample(1:500, 1000, replace = TRUE)),
    genre = sample(genres, 1000, replace = TRUE),

    # Audio Features (0-1 scale mostly)
    danceability = runif(1000, 0.3, 0.95),
    energy = runif(1000, 0.2, 1.0),
    loudness = rnorm(1000, -7, 3),
    speechiness = runif(1000, 0.02, 0.5),
    acousticness = runif(1000, 0.0, 1.0),
    instrumentalness = runif(1000, 0.0, 0.5),
    liveness = runif(1000, 0.1, 1.0),
    valence = runif(1000, 0.0, 1.0),
    tempo = rnorm(1000, 120, 30),

    # Metadata
    popularity = sample(30:100, 1000, replace = TRUE),
    year = sample(2015:2023, 1000, replace = TRUE)
  )

  return(data)
}

# Load or create data
if (file.exists("data/spotify_raw.csv")) {
  message("Loading Spotify data from CSV...")
  data <- read_csv("data/spotify_raw.csv")

  # Keep only needed columns if it's the full dataset
  if (ncol(data) > 15) {
    data <- data %>%
      select(track_name, artist_name, danceability, energy, loudness,
             speechiness, acousticness, instrumentalness, liveness,
             valence, tempo, popularity, year)
  }
} else {
  message("Creating sample Spotify dataset (1000 tracks)...")
  data <- create_sample_spotify_data()
}

# Save raw data
saveRDS(data, "data/raw_data.rds")
write.csv(data, "data/raw_data.csv", row.names = FALSE)

message("✓ Data collection complete")
message("  Rows: ", nrow(data), " | Columns: ", ncol(data))
message("  Audio features: danceability, energy, loudness, speechiness,")
message("                  acousticness, instrumentalness, liveness, valence, tempo")


