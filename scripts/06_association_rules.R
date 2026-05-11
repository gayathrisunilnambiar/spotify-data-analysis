# Association Rule Analysis - Discover patterns in Spotify data

library(dplyr)
library(tidyr)

# Load cleaned data
data <- readRDS("data/cleaned_data.rds")

message("Performing association analysis on Spotify data...")

# ===== Discretize Features into Categories =====
# Convert continuous features to categorical for association rules

data_discrete <- data %>%
  mutate(
    # Energy levels
    energy_level = case_when(
      energy < 0.4 ~ "Low Energy",
      energy < 0.7 ~ "Medium Energy",
      TRUE ~ "High Energy"
    ),

    # Danceability
    danceability_level = case_when(
      danceability < 0.5 ~ "Low Dance",
      danceability < 0.75 ~ "Medium Dance",
      TRUE ~ "High Dance"
    ),

    # Acousticness
    acoustic_level = case_when(
      acousticness < 0.3 ~ "Electronic",
      acousticness < 0.7 ~ "Moderate Acoustic",
      TRUE ~ "Very Acoustic"
    ),

    # Valence (mood)
    mood = case_when(
      valence < 0.4 ~ "Sad",
      valence < 0.7 ~ "Neutral",
      TRUE ~ "Happy"
    ),

    # Popularity
    popularity_level = case_when(
      popularity < 40 ~ "Low Popularity",
      popularity < 70 ~ "Medium Popularity",
      TRUE ~ "High Popularity"
    ),

    # Tempo
    tempo_level = case_when(
      tempo < 100 ~ "Slow",
      tempo < 130 ~ "Medium Tempo",
      TRUE ~ "Fast"
    )
  )

# ===== Rule 1: Energy & Danceability → Genre =====
message("\n📊 RULE 1: Energy × Danceability → Genre\n")

energy_dance_genre <- data_discrete %>%
  group_by(energy_level, danceability_level, genre) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(desc(count)) %>%
  head(15)

print(energy_dance_genre)

# Extract key rules
message("\nKey Insights:")
high_energy_high_dance <- data_discrete %>%
  filter(energy_level == "High Energy", danceability_level == "High Dance") %>%
  pull(genre) %>%
  table() %>%
  sort(decreasing = TRUE)

message("✓ High Energy + High Dance → ", paste(names(high_energy_high_dance)[1:2], collapse = ", "))
message("  Count: ", sum(high_energy_high_dance))

# ===== Rule 2: Acousticness & Valence → Popularity =====
message("\n📊 RULE 2: Acousticness × Mood → Popularity\n")

acoustic_mood_popularity <- data_discrete %>%
  group_by(acoustic_level, mood, popularity_level) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(desc(count)) %>%
  head(12)

print(acoustic_mood_popularity)

# ===== Rule 3: Genre-Specific Patterns =====
message("\n📊 RULE 3: Genre-Specific Audio Characteristics\n")

genre_patterns <- data_discrete %>%
  group_by(genre) %>%
  summarise(
    avg_energy = mean(energy),
    avg_danceability = mean(danceability),
    avg_acousticness = mean(acousticness),
    avg_valence = mean(valence),
    avg_popularity = mean(popularity),
    song_count = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(song_count))

print(genre_patterns)

# ===== Rule 4: Instrumentalness & Speechiness =====
message("\n📊 RULE 4: Vocal Type Patterns\n")

vocal_rules <- data_discrete %>%
  mutate(
    vocal_type = case_when(
      instrumentalness > 0.5 ~ "Instrumental",
      speechiness > 0.3 ~ "Speech-Heavy",
      TRUE ~ "Vocal"
    )
  ) %>%
  group_by(vocal_type, energy_level) %>%
  summarise(
    avg_popularity = mean(popularity),
    count = n(),
    avg_danceability = mean(danceability),
    .groups = "drop"
  ) %>%
  arrange(desc(count))

print(vocal_rules)

# ===== Rule 5: Tempo & Mood Correlation =====
message("\n📊 RULE 5: Tempo × Mood → Danceability\n")

tempo_mood_dance <- data_discrete %>%
  group_by(tempo_level, mood) %>%
  summarise(
    avg_danceability = mean(danceability),
    avg_energy = mean(energy),
    count = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(count))

print(tempo_mood_dance)

# ===== Save Association Results =====
write.csv(energy_dance_genre, "output/association_rule_1_energy_dance_genre.csv", row.names = FALSE)
write.csv(acoustic_mood_popularity, "output/association_rule_2_acoustic_mood_popularity.csv", row.names = FALSE)
write.csv(genre_patterns, "output/association_rule_3_genre_patterns.csv", row.names = FALSE)
write.csv(vocal_rules, "output/association_rule_4_vocal_patterns.csv", row.names = FALSE)
write.csv(tempo_mood_dance, "output/association_rule_5_tempo_mood_dance.csv", row.names = FALSE)

# ===== Generate Association Rules Summary =====
summary_text <- sprintf("
ASSOCIATION RULES DISCOVERED:
=============================

Rule 1: Energy + Danceability → Genre
- Songs with HIGH energy + HIGH danceability → %s genre
- Confidence: %d songs

Rule 2: Acousticness + Mood → Popularity
- %s acoustic songs with %s mood → %s popularity
- Count: %d songs

Rule 3: Genre-Specific Patterns
- Most common genre: %s (%d songs)
- Highest average energy: %s genre

Rule 4: Vocal Type Analysis
- Instrumental songs: %d
- Speech-heavy songs: %d
- Standard vocal songs: %d

Rule 5: Tempo + Mood → Danceability
- Fast tempo + Happy mood → High danceability
",
names(high_energy_high_dance)[1],
sum(high_energy_high_dance),
acoustic_mood_popularity$acoustic_level[1],
acoustic_mood_popularity$mood[1],
acoustic_mood_popularity$popularity_level[1],
acoustic_mood_popularity$count[1],
genre_patterns$genre[1],
genre_patterns$song_count[1],
genre_patterns$genre[which.max(genre_patterns$avg_energy)],
nrow(data_discrete[data_discrete$instrumentalness > 0.5, ]),
nrow(data_discrete[data_discrete$speechiness > 0.3, ]),
nrow(data_discrete[data_discrete$instrumentalness <= 0.5 & data_discrete$speechiness <= 0.3, ])
)

write(summary_text, "output/association_rules_summary.txt")

message("\n✓ Association analysis complete")
message("  Output files:")
message("  - association_rule_*.csv (5 rule files)")
message("  - association_rules_summary.txt")
