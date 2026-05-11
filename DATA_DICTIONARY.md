# 📖 Data Dictionary - Spotify Audio Features

## Input Data (raw_data.csv)

| Column | Type | Range | Description |
|--------|------|-------|-------------|
| `track_id` | String | - | Unique identifier for each song |
| `track_name` | String | - | Name of the song |
| `artist_name` | String | - | Name of the artist |
| `genre` | Categorical | pop, rock, hip-hop, etc. | Music genre classification |
| **AUDIO FEATURES** | | | |
| `danceability` | Numeric | 0.0 - 1.0 | How suitable the track is for dancing<br/>0.0 = not danceable, 1.0 = very danceable |
| `energy` | Numeric | 0.0 - 1.0 | Intensity and activity level<br/>0.0 = calm/quiet, 1.0 = intense/loud |
| `loudness` | Numeric | Negative (dB) | Overall loudness in decibels<br/>Typically -20 to 0 dB |
| `speechiness` | Numeric | 0.0 - 1.0 | Presence of spoken words<br/>0.0 = music only, 1.0 = audiobook/speech |
| `acousticness` | Numeric | 0.0 - 1.0 | How acoustic vs. electric<br/>0.0 = electronic, 1.0 = acoustic instruments |
| `instrumentalness` | Numeric | 0.0 - 1.0 | Absence of vocals<br/>0.0 = mostly vocals, 1.0 = instrumental |
| `liveness` | Numeric | 0.0 - 1.0 | Presence of audience/live recording<br/>0.0 = studio, 1.0 = live concert |
| `valence` | Numeric | 0.0 - 1.0 | Musical "happiness"<br/>0.0 = sad/angry, 1.0 = happy/cheerful |
| `tempo` | Numeric | 60 - 180 | Speed of the song in beats per minute (BPM) |
| **METADATA** | | | |
| `popularity` | Numeric | 0 - 100 | Current Spotify popularity score |
| `year` | Numeric | 2015 - 2023 | Year the song was released |

---

## Output Data Files

### 1. pca_scores.csv
**After dimensionality reduction using PCA**

| Column | Description |
|--------|-------------|
| `track_name` | Original song name |
| `artist_name` | Original artist |
| `genre` | Music genre |
| `PC1` | First principal component score<br/>(-3 to +3 typical range) |
| `PC2` | Second principal component score |
| `PC3` | Third principal component score |

**Interpretation:**
- Each row is one song
- PC1 explains ~60% of variance
- PC2 explains ~20% of variance
- Together PC1+PC2 explain ~80% of total variation

---

### 2. pca_loadings.csv
**Feature importance for each principal component**

| Column | Description |
|--------|-------------|
| `feature` | Original audio feature name |
| `PC1` | How much this feature contributes to PC1<br/>(Range: -1 to +1) |
| `PC2` | How much this feature contributes to PC2 |

**Interpretation:**
- **High positive value**: Feature increases with that PC
- **High negative value**: Feature decreases with that PC
- **Near zero**: Feature doesn't affect that PC

**Example:**
- If `energy` has PC1 = 0.85: Energy is the main driver of PC1
- If `acousticness` has PC1 = -0.72: Acoustic songs are opposite to high PC1

---

### 3. cluster_profiles.csv
**Characteristics of each identified cluster**

| Column | Description |
|--------|-------------|
| `cluster` | Cluster number (1, 2, 3, etc.) |
| `songs` | How many songs in this cluster |
| `avg_energy` | Average energy level |
| `avg_danceability` | Average danceability |
| `avg_valence` | Average musical happiness |
| `avg_acousticness` | Average acoustic level |
| `top_genre` | Most common genre in cluster |

**Example Interpretation:**
```
Cluster 1: 150 songs
- High energy (0.8), High danceability (0.75), Low acousticness (0.2)
- Top genre: Pop/Electronic
→ These are upbeat, danceable, electronic songs
```

---

### 4. songs_with_clusters.csv
**Every song with its assigned cluster**

| Column | Description |
|--------|-------------|
| `track_name` | Song name |
| `artist_name` | Artist name |
| `genre` | Genre |
| `cluster` | Which cluster (1, 2, or 3) this song belongs to |

---

## Normalized Data (cleaned_data_normalized.rds)

After z-score normalization, each audio feature has:
- **Mean = 0**
- **Standard Deviation = 1**

Formula: `(value - mean) / std_dev`

**Why normalize?**
- Puts all features on same scale
- Prevents loud/tempo from dominating (large values)
- Required for fair PCA analysis

---

## Quick Reference: What Each Feature Means

### Energy & Intensity
- **High Energy + High Valence** = Happy, energetic songs (e.g., upbeat pop)
- **High Energy + Low Valence** = Intense, angry songs (e.g., metal, rap)

### Acousticness & Instrumentalness
- **High Acousticness** = Guitars, vocals, live instruments
- **High Instrumentalness** = No singing, purely instrumental

### Danceability & Tempo
- **Danceability 0.7+** = Good for dancing
- **Tempo 120-130 BPM** = Most danceable

### Speech vs Music
- **Speechiness 0.66+** = Mostly spoken (podcasts, audiobooks)
- **Speechiness 0.0-0.33** = Pure music

### Valence (Mood)
- **Valence 0.0-0.3** = Sad, melancholic (minor keys)
- **Valence 0.7-1.0** = Happy, cheerful (major keys)

---

## Example: Interpreting a Song's Profile

**Song: "Blinding Lights" by The Weeknd**
```
danceability: 0.80  → Very danceable
energy: 0.73        → High energy
loudness: -5.8      → Moderately loud
speechiness: 0.05   → Pure singing
acousticness: 0.10  → Mostly electronic
instrumentalness: 0.00 → Vocals present
liveness: 0.15      → Studio recording
valence: 0.33       → Melancholic/sad mood
tempo: 103          → Moderate pace
```

**Interpretation:**
"An energetic, danceable electronic song with sad/melancholic vocals"

---

## Statistical Terms in Output

| Term | Meaning |
|------|---------|
| **Mean** | Average value |
| **SD/Std Dev** | How spread out values are |
| **Variance** | Spread squared |
| **Cumulative Variance** | Total variation explained up to that PC |
| **Loading** | How much a feature contributes to a PC |
| **Score** | Value of a sample on a PC |

---

## Units Reference

| Feature | Unit |
|---------|------|
| Danceability | Dimensionless (0-1 scale) |
| Energy | Dimensionless (0-1 scale) |
| Loudness | Decibels (dB) |
| Tempo | Beats Per Minute (BPM) |
| Others | Dimensionless (0-1 scale) |

---

**Created for**: Third-year Engineering Project  
**Last Updated**: May 2026
