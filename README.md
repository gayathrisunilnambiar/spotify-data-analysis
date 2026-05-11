# Spotify Music Data Analysis & Visualization

A data analysis project analyzing Spotify tracks using dimensionality reduction (PCA) and clustering techniques. Perfect for third-year engineering students.

## 🎵 Project Overview

This project analyzes **audio features** of Spotify songs to discover patterns and relationships between musical characteristics. It demonstrates:
- **Data Collection**: Loading Spotify track data
- **Data Cleaning**: Preprocessing and normalization
- **Dimensionality Reduction**: PCA to reduce 9 audio features to 2-3 principal components
- **Clustering**: K-means clustering to group similar songs
- **Visualization**: Multiple charts showing patterns and insights

## 📁 Project Structure

```
r-data-analysis/
├── scripts/
│   ├── 00_main.R                    ⭐ RUN THIS FIRST
│   ├── 01_collect_data.R            📥 Load Spotify data
│   ├── 02_clean_data.R              🧹 Clean & normalize
│   ├── 03_dimensionality_reduction.R 📊 PCA analysis
│   ├── 04_visualize_results.R       📈 Create plots
│   ├── 05_clustering_insights.R     🎯 K-means clustering
│   ├── 06_association_rules.R       🔗 Find patterns
│   └── 07_accuracy_metrics.R        📋 Evaluate quality
├── data/                            💾 Raw & cleaned data
├── output/                          📤 Results & visualizations
├── README.md                        📖 Documentation
├── QUICKSTART.md                    🚀 Quick start guide
├── ANALYSIS_GUIDE.md                📊 Association & accuracy
└── DATA_DICTIONARY.md               📚 Feature definitions
```

## 🚀 Quick Start

### 1. Open in RStudio
```r
# Open r-data-analysis.Rproj in RStudio
```

### 2. Install Dependencies
```r
install.packages(c("dplyr", "ggplot2", "gridExtra", "tidyr"))
```

### 3. Run the Pipeline
```r
source("scripts/00_main.R")
```

That's it! The script will:
- ✅ Load Spotify data (sample data included)
- ✅ Clean and normalize features
- ✅ Perform PCA dimensionality reduction
- ✅ Create 5 visualization plots
- ✅ Cluster songs using K-means
- ✅ Generate analysis reports

## 🎼 Spotify Audio Features Analyzed

| Feature | Meaning | Range |
|---------|---------|-------|
| **Danceability** | How suitable for dancing | 0-1 |
| **Energy** | Intensity & activity | 0-1 |
| **Loudness** | Overall loudness | dB |
| **Speechiness** | Spoken words presence | 0-1 |
| **Acousticness** | How acoustic | 0-1 |
| **Instrumentalness** | Lack of vocals | 0-1 |
| **Liveness** | Audience presence | 0-1 |
| **Valence** | Musical positiveness | 0-1 |
| **Tempo** | Beats per minute | BPM |

## 📊 What You Get

### Visualizations (PNG)
1. `01_feature_distribution.png` - Boxplots of audio features
2. `02_correlation_heatmap.png` - Feature correlations
3. `03_pca_biplot.png` - Songs in 2D PCA space (colored by genre)
4. `04_feature_loadings.png` - Which features drive PC1
5. `05_genre_statistics.png` - Energy levels by genre
6. `06_song_clusters.png` - K-means clusters in PCA space

### Results Files (CSV)

**PCA & Clustering:**
- `pca_scores.csv` - Reduced song data (PC1, PC2, PC3)
- `pca_loadings.csv` - Feature importance for each component
- `cluster_profiles.csv` - Characteristics of each cluster
- `songs_with_clusters.csv` - Songs assigned to clusters

**Association Rules** (5 rule files):
- `association_rule_1_energy_dance_genre.csv` - Energy × Danceability → Genre
- `association_rule_2_acoustic_mood_popularity.csv` - Acousticness × Mood → Popularity
- `association_rule_3_genre_patterns.csv` - Genre audio signatures
- `association_rule_4_vocal_patterns.csv` - Instrumental vs. vocal patterns
- `association_rule_5_tempo_mood_dance.csv` - Tempo × Mood → Danceability

**Accuracy Metrics** (3 files + report):
- `pca_variance_explained.csv` - Variance by number of components
- `cluster_quality_metrics.csv` - Silhouette scores, homogeneity
- `feature_variance_contribution.csv` - Feature importance
- `accuracy_report.txt` - Full accuracy summary report

### Text Reports
- `association_rules_summary.txt` - Key pattern discoveries
- `accuracy_report.txt` - Model quality evaluation

## 🔧 Data Source Options

### Option 1: Sample Data (Easiest)
The script generates 1000 sample Spotify tracks automatically.

### Option 2: Real Kaggle Data
1. Download from: https://www.kaggle.com/datasets/rodolfolotte/spotify-12m-songs
2. Save CSV to `data/spotify_raw.csv`
3. Run the pipeline

### Option 3: Live Spotify API
Requires API credentials (optional advanced extension):
```r
library(spotifyr)
# Use Spotify Web API to fetch real-time data
```

## 📈 Key Findings You'll Discover

- **PCA Variance**: How many components explain the data variation
- **Feature Importance**: Which audio features are most important
- **Genre Patterns**: Different genres have distinct audio signatures
- **Song Clusters**: Similar songs group together naturally
- **Correlations**: Which audio features are related

## 💡 Learning Objectives

After this project, you'll understand:
- ✅ Data collection from multiple sources
- ✅ Data cleaning and normalization techniques
- ✅ PCA and dimensionality reduction
- ✅ K-means clustering algorithm
- ✅ Data visualization best practices
- ✅ Association rule mining (pattern discovery)
- ✅ Model evaluation metrics (Silhouette, Davies-Bouldin)
- ✅ Validating and interpreting results
- ✅ Writing data-driven insights for reports

## 🔗 Association Analysis

**What it discovers:**
- Which audio features appear together (e.g., high energy + danceability = pop)
- Genre-specific patterns (e.g., rock songs are less acoustic)
- Relationships between features and popularity

**5 Key Rules:**
1. **Energy × Danceability → Genre** - Identify song types
2. **Acousticness × Mood → Popularity** - Predict music appeal
3. **Genre Patterns** - What makes each genre unique
4. **Vocal Types** - Instrumental vs. vocal characteristics
5. **Tempo × Mood → Danceability** - Speed & happiness correlation

**Outputs:** 5 CSV files + summary text file with discoveries

---

## 📈 Accuracy Metrics

**What it evaluates:**

| Metric | Measures | Interpretation |
|--------|----------|-----------------|
| **Variance Explained** | How much info is captured in 2 PCs | >80% = Good |
| **Silhouette Score** | Cluster quality (how tight clusters are) | >0.5 = Good |
| **Davies-Bouldin Index** | Cluster separation | <1.0 = Good |
| **Purity Score** | Genre alignment with clusters | >0.6 = Good |
| **RMSE** | Reconstruction error from PCA | Lower = Better |

**Outputs:** 3 CSV files + comprehensive accuracy report

**Example Report:**
```
PCA: 81.3% variance in 2 components (vs. 9 original)
Silhouette: 0.65 (GOOD - well-formed clusters)
Purity: 0.72 (GOOD - clusters match genres)
→ Model validates our approach works!
```

---

## 🎯 Customization Ideas

**Easy Extensions:**
- Change number of clusters: Edit `optimal_k <- 3` in script 05
- Add more features: Uncomment features in audio_cols
- Filter by genre: Add `filter(genre == "pop")` in scripts
- Analyze popularity vs features: Add `popularity` to correlations

**Advanced:**
- Hierarchical clustering instead of K-means
- t-SNE visualization for 2D projection
- Genre classification using the reduced features
- Time-series analysis of features over years

## 📚 Dependencies

```r
# Core analysis
library(dplyr)         # Data manipulation
library(ggplot2)       # Visualization
library(gridExtra)     # Multi-plot layouts
library(tidyr)         # Data tidying
```

## ⚠️ Notes

- All visualizations are saved as PNG in `output/`
- Data is normalized before PCA (important!)
- K-means uses 25 random starts for stability
- Script includes genre-based coloring for extra insights

## 📝 Project Report Template

Use this to write your project report:

**1. Introduction**: What is Spotify data? Why analyze it?  
**2. Methods**: Data collection, cleaning, PCA, K-means  
**3. Results**: Show the 6 visualizations, explain findings  
**4. Conclusions**: What patterns did you discover?  
**5. Appendix**: Include code snippets, additional tables  

---

**Created for**: Third-year Engineering Data Analysis Project  
**Language**: R (ggplot2 + dplyr stack)  
**Difficulty**: Beginner-friendly, low-code format
