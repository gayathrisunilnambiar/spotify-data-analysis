# Time Series Analysis & Forecasting
# Analyze how music characteristics change over time

library(dplyr)
library(ggplot2)

message("Building time series models...\n")

# Load data
data <- readRDS("data/cleaned_data.rds")

audio_cols <- c("danceability", "energy", "loudness", "speechiness",
                "acousticness", "instrumentalness", "liveness", "valence", "tempo")

# ===== 1. TEMPORAL TRENDS ANALYSIS =====
message("📊 1. TEMPORAL TRENDS\n")

# Create time series by year
yearly_trends <- data %>%
  group_by(year) %>%
  summarise(
    avg_energy = mean(energy),
    avg_danceability = mean(danceability),
    avg_acousticness = mean(acousticness),
    avg_valence = mean(valence),
    avg_popularity = mean(popularity),
    avg_tempo = mean(tempo),
    song_count = n(),
    .groups = "drop"
  ) %>%
  arrange(year)

message("Yearly Audio Feature Trends:\n")
print(yearly_trends)

# ===== 2. FEATURE EVOLUTION OVER TIME =====
message("\n📊 2. FEATURE EVOLUTION ANALYSIS\n")

# Calculate year-over-year changes
feature_changes <- yearly_trends %>%
  mutate(
    energy_change = c(NA, diff(avg_energy)),
    dance_change = c(NA, diff(avg_danceability)),
    acoustic_change = c(NA, diff(avg_acousticness)),
    valence_change = c(NA, diff(avg_valence)),
    popularity_change = c(NA, diff(avg_popularity))
  ) %>%
  select(year, energy_change, dance_change, acoustic_change, valence_change, popularity_change)

print(feature_changes)

# ===== 3. GENRE-SPECIFIC TRENDS =====
message("\n📊 3. GENRE-SPECIFIC TEMPORAL TRENDS\n")

genre_trends <- data %>%
  group_by(year, genre) %>%
  summarise(
    avg_energy = mean(energy),
    avg_danceability = mean(danceability),
    avg_popularity = mean(popularity),
    count = n(),
    .groups = "drop"
  ) %>%
  arrange(year, desc(count))

# Top genres by year
top_genres_by_year <- genre_trends %>%
  group_by(year) %>%
  arrange(desc(count)) %>%
  slice(1:3) %>%
  select(year, genre, count)

message("Top 3 Genres by Year:\n")
print(top_genres_by_year)

# ===== 4. POPULARITY FORECASTING (Simple Linear Trend) =====
message("\n📊 4. POPULARITY FORECASTING\n")

# Fit linear regression model for popularity over time
popularity_model <- lm(avg_popularity ~ year, data = yearly_trends)

# Get model statistics
model_summary <- summary(popularity_model)
r_squared <- round(model_summary$r.squared, 4)
slope <- round(coef(popularity_model)[2], 4)
intercept <- round(coef(popularity_model)[1], 4)

message("Popularity Trend Model:")
message("Popularity = ", intercept, " + ", slope, " * Year")
message("R-squared: ", r_squared, " (Model fit quality)\n")

# Forecast future popularity
future_years <- data.frame(year = 2024:2026)
popularity_forecast <- predict(popularity_model, newdata = future_years, interval = "confidence")

forecast_df <- data.frame(
  year = 2024:2026,
  predicted_popularity = round(popularity_forecast[, 1], 2),
  lower_bound = round(popularity_forecast[, 2], 2),
  upper_bound = round(popularity_forecast[, 3], 2)
)

message("Popularity Forecast (2024-2026):\n")
print(forecast_df)

# ===== 5. ENERGY & DANCEABILITY TRENDS =====
message("\n📊 5. ENERGY & DANCEABILITY FORECAST\n")

# Model for energy trends
energy_model <- lm(avg_energy ~ year, data = yearly_trends)
energy_forecast <- predict(energy_model, newdata = future_years)

# Model for danceability trends
dance_model <- lm(avg_danceability ~ year, data = yearly_trends)
dance_forecast <- predict(dance_model, newdata = future_years)

feature_forecast <- data.frame(
  year = 2024:2026,
  forecast_energy = round(energy_forecast, 3),
  forecast_danceability = round(dance_forecast, 3),
  energy_trend = ifelse(slope > 0, "Increasing", "Decreasing"),
  dance_trend = ifelse(slope > 0, "Increasing", "Decreasing")
)

print(feature_forecast)

# ===== 6. EXPONENTIAL SMOOTHING (Simple Forecast) =====
message("\n📊 6. EXPONENTIAL SMOOTHING FORECAST\n")

# Simple exponential smoothing for popularity
alpha <- 0.3  # Smoothing factor
smoothed_popularity <- c(yearly_trends$avg_popularity[1])

for (i in 2:nrow(yearly_trends)) {
  new_smoothed <- alpha * yearly_trends$avg_popularity[i] +
                  (1 - alpha) * smoothed_popularity[i - 1]
  smoothed_popularity <- c(smoothed_popularity, new_smoothed)
}

smoothing_df <- data.frame(
  year = yearly_trends$year,
  actual_popularity = yearly_trends$avg_popularity,
  smoothed_popularity = round(smoothed_popularity, 3),
  smoothing_error = round(abs(yearly_trends$avg_popularity - smoothed_popularity), 3)
)

message("Exponential Smoothing Results (Alpha = 0.3):\n")
print(smoothing_df)

mean_error <- round(mean(smoothing_df$smoothing_error), 3)
message("\nMean Absolute Error: ", mean_error)
message("Model Accuracy: ", round((1 - mean_error / mean(yearly_trends$avg_popularity)) * 100, 1), "%")

# ===== 7. ACOUSTIC VS ELECTRONIC TREND =====
message("\n📊 7. ACOUSTIC vs ELECTRONIC TREND\n")

acoustic_trend <- data %>%
  group_by(year) %>%
  summarise(
    avg_acousticness = mean(acousticness),
    acoustic_songs = sum(acousticness > 0.5),
    electronic_songs = sum(acousticness < 0.3),
    total_songs = n(),
    acoustic_pct = round(acoustic_songs / total_songs * 100, 1),
    electronic_pct = round(electronic_songs / total_songs * 100, 1),
    .groups = "drop"
  )

print(acoustic_trend)

# ===== 8. GENRE POPULARITY EVOLUTION =====
message("\n📊 8. GENRE POPULARITY EVOLUTION\n")

genre_popularity_trend <- data %>%
  group_by(year, genre) %>%
  summarise(
    avg_popularity = mean(popularity),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = genre, values_from = avg_popularity)

print(genre_popularity_trend)

# ===== 9. SEASONALITY & PATTERNS =====
message("\n📊 9. TEMPORAL PATTERNS\n")

pattern_analysis <- data.frame(
  pattern = c(
    "Energy trend (2015-2023)",
    "Danceability trend",
    "Acousticness trend",
    "Valence trend",
    "Popularity trend"
  ),
  change_direction = c(
    ifelse(tail(yearly_trends$avg_energy, 1) > head(yearly_trends$avg_energy, 1), "↑ Increasing", "↓ Decreasing"),
    ifelse(tail(yearly_trends$avg_danceability, 1) > head(yearly_trends$avg_danceability, 1), "↑ Increasing", "↓ Decreasing"),
    ifelse(tail(yearly_trends$avg_acousticness, 1) > head(yearly_trends$avg_acousticness, 1), "↑ Increasing", "↓ Decreasing"),
    ifelse(tail(yearly_trends$avg_valence, 1) > head(yearly_trends$avg_valence, 1), "↑ Increasing", "↓ Decreasing"),
    ifelse(tail(yearly_trends$avg_popularity, 1) > head(yearly_trends$avg_popularity, 1), "↑ Increasing", "↓ Decreasing")
  ),
  magnitude = c(
    round(tail(yearly_trends$avg_energy, 1) - head(yearly_trends$avg_energy, 1), 3),
    round(tail(yearly_trends$avg_danceability, 1) - head(yearly_trends$avg_danceability, 1), 3),
    round(tail(yearly_trends$avg_acousticness, 1) - head(yearly_trends$avg_acousticness, 1), 3),
    round(tail(yearly_trends$avg_valence, 1) - head(yearly_trends$avg_valence, 1), 3),
    round(tail(yearly_trends$avg_popularity, 1) - head(yearly_trends$avg_popularity, 1), 3)
  ),
  interpretation = c(
    ifelse(tail(yearly_trends$avg_energy, 1) > head(yearly_trends$avg_energy, 1),
           "Music getting more energetic", "Music getting calmer"),
    ifelse(tail(yearly_trends$avg_danceability, 1) > head(yearly_trends$avg_danceability, 1),
           "Music getting more danceable", "Music getting less danceable"),
    ifelse(tail(yearly_trends$avg_acousticness, 1) > head(yearly_trends$avg_acousticness, 1),
           "More acoustic instruments", "More electronic sounds"),
    ifelse(tail(yearly_trends$avg_valence, 1) > head(yearly_trends$avg_valence, 1),
           "Music getting happier", "Music getting sadder"),
    ifelse(tail(yearly_trends$avg_popularity, 1) > head(yearly_trends$avg_popularity, 1),
           "Songs getting more popular", "Songs getting less popular")
  )
)

print(pattern_analysis)

# ===== 10. SAVE TIME SERIES RESULTS =====

write.csv(yearly_trends, "output/time_series_yearly_trends.csv", row.names = FALSE)
write.csv(feature_changes, "output/time_series_feature_changes.csv", row.names = FALSE)
write.csv(genre_trends, "output/time_series_genre_trends.csv", row.names = FALSE)
write.csv(forecast_df, "output/time_series_popularity_forecast.csv", row.names = FALSE)
write.csv(feature_forecast, "output/time_series_feature_forecast.csv", row.names = FALSE)
write.csv(smoothing_df, "output/time_series_exponential_smoothing.csv", row.names = FALSE)
write.csv(acoustic_trend, "output/time_series_acoustic_vs_electronic.csv", row.names = FALSE)
write.csv(pattern_analysis, "output/time_series_patterns.csv", row.names = FALSE)

# Create time series report
ts_report <- sprintf("
=========================================
TIME SERIES ANALYSIS & FORECASTING REPORT
=========================================

DATASET: Spotify Songs (2015-2023)
Models: Linear Regression, Exponential Smoothing
Forecast: 2024-2026

1. POPULARITY FORECAST
   Formula: Popularity = %.2f + %.4f * Year
   R-squared: %.4f
   2024 Forecast: %.2f
   2025 Forecast: %.2f
   2026 Forecast: %.2f

2. ENERGY TREND
   Current Direction: %s
   Total Change (2015-2023): %.3f
   Interpretation: Music is %s over time

3. DANCEABILITY TREND
   Current Direction: %s
   Total Change (2015-2023): %.3f
   Interpretation: Music is %s over time

4. ACOUSTICNESS TREND
   Current Direction: %s
   Total Change (2015-2023): %.3f
   Interpretation: Music preference shift %s

5. VALENCE (HAPPINESS) TREND
   Current Direction: %s
   Total Change (2015-2023): %.3f
   Interpretation: Music mood is %s over time

6. EXPONENTIAL SMOOTHING ACCURACY
   Model Type: Simple Exponential Smoothing (α=0.3)
   Mean Absolute Error: %.3f
   Accuracy: %.1f%%

7. KEY FINDINGS
   - Tracked %d years of music data
   - Analyzed %d songs across %d genres
   - Genre popularity varies: Top genre has %.1f%% share
   - Acoustic vs Electronic: %.1f%% vs %.1f%%

8. RECOMMENDATIONS
   - Popularity trend: %s
   - Energy trend: %s
   - Danceability trend: %s
   → Use forecasts for playlist curation

=========================================
",
intercept, slope, r_squared,
forecast_df$predicted_popularity[1],
forecast_df$predicted_popularity[2],
forecast_df$predicted_popularity[3],
pattern_analysis$change_direction[1],
pattern_analysis$magnitude[1],
ifelse(pattern_analysis$magnitude[1] > 0, "becoming more energetic", "becoming calmer"),
pattern_analysis$change_direction[2],
pattern_analysis$magnitude[2],
ifelse(pattern_analysis$magnitude[2] > 0, "becoming more danceable", "becoming less danceable"),
pattern_analysis$change_direction[3],
pattern_analysis$magnitude[3],
ifelse(pattern_analysis$magnitude[3] > 0, "towards acoustic", "towards electronic"),
pattern_analysis$change_direction[4],
pattern_analysis$magnitude[4],
ifelse(pattern_analysis$magnitude[4] > 0, "getting happier", "getting sadder"),
mean_error,
round((1 - mean_error / mean(yearly_trends$avg_popularity)) * 100, 1),
nrow(yearly_trends),
nrow(data),
length(unique(data$genre)),
max(yearly_trends$song_count) / sum(yearly_trends$song_count) * 100,
mean(acoustic_trend$acoustic_pct),
mean(acoustic_trend$electronic_pct),
ifelse(slope > 0, "Increasing (good for music industry)", "Decreasing (concerning)"),
ifelse(tail(yearly_trends$avg_energy, 1) > head(yearly_trends$avg_energy, 1),
       "Increasing (more energetic music)", "Decreasing (calmer music)"),
ifelse(tail(yearly_trends$avg_danceability, 1) > head(yearly_trends$avg_danceability, 1),
       "Increasing (more danceable music)", "Decreasing (less danceable music)")
)

write(ts_report, "output/time_series_analysis_report.txt")

message("\n✓ Time series analysis complete")
message("  Output files (8 CSV + 1 report):")
message("  - time_series_yearly_trends.csv")
message("  - time_series_feature_changes.csv")
message("  - time_series_genre_trends.csv")
message("  - time_series_popularity_forecast.csv")
message("  - time_series_feature_forecast.csv")
message("  - time_series_exponential_smoothing.csv")
message("  - time_series_acoustic_vs_electronic.csv")
message("  - time_series_patterns.csv")
message("  - time_series_analysis_report.txt")
