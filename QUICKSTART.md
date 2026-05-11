# 🚀 Quick Start Guide - Spotify Analysis

## 1️⃣ Installation (First Time Only)

```bash
# Navigate to project directory
cd r-data-analysis

# Open R and install packages
install.packages(c("dplyr", "ggplot2", "gridExtra", "tidyr", "readr"))
```

## 2️⃣ Run Full Analysis (2 Minutes)

```r
# In RStudio, open scripts/00_main.R and click "Source" 
# OR run this in console:
source("scripts/00_main.R")
```

## 3️⃣ Find Your Results

```
output/
├── pca_scores.csv                 ← Main results
├── cluster_profiles.csv           ← Cluster info
├── 01_feature_distribution.png    ← Box plots
├── 02_correlation_heatmap.png     ← Feature links
├── 03_pca_biplot.png              ← Main visualization ⭐
├── 04_feature_loadings.png        ← What drives PCA
├── 05_genre_statistics.png        ← Genre comparison
└── 06_song_clusters.png           ← Song groupings
```

## 📊 Understand Your Results

### PCA Biplot (03_pca_biplot.png) - Most Important!
- **X-axis (PC1)**: First dimension (explains ~60% variance)
- **Y-axis (PC2)**: Second dimension (explains ~20% variance)
- **Colors**: Different music genres
- **Clusters**: Songs with similar characteristics group together

### Feature Loadings (04_feature_loadings.png)
- Shows **which audio features** influence PC1
- High bar = important feature
- Positive/negative = direction on PC1

### Clusters (06_song_clusters.png)
- **3 clusters** identified automatically
- Each cluster = different song type
- Check `cluster_profiles.csv` to see what makes each cluster unique

## 🎯 Writing Your Report

### Key Numbers to Include:
```r
# Run this to get numbers for your report:

# 1. Total songs analyzed:
nrow(data)

# 2. Audio features used:
audio_cols

# 3. Variance explained by PC1 and PC2:
# Check output from step 3 console output

# 4. Cluster sizes:
read.csv("output/cluster_profiles.csv")
```

### Report Structure:
1. **Introduction** (1 page)
   - What is Spotify data?
   - Why analyze audio features?

2. **Methods** (1-2 pages)
   - Data source
   - Audio features explained (table)
   - PCA explanation
   - K-means clustering explanation

3. **Results** (2-3 pages)
   - Include all 6 visualizations
   - Explain what each shows

4. **Discussion** (1-2 pages)
   - What patterns did you find?
   - Why do clusters form?
   - Which features matter most?

5. **Conclusion** (1 page)
   - Key takeaways
   - Real-world applications

## 🔧 Customize the Analysis

### Change number of clusters:
```r
# In scripts/05_clustering_insights.R, change:
optimal_k <- 3    # Try 2, 4, or 5
```

### Analyze only one genre:
```r
# In scripts/03_dimensionality_reduction.R, add:
audio_data <- data %>%
  filter(genre == "pop") %>%
  select(all_of(audio_cols))
```

### Add a custom feature:
```r
# In scripts/01_collect_data.R, add to data frame:
data$my_feature <- runif(1000, 0, 1)
```

## ❓ Troubleshooting

**Error: "could not find function..."**
→ Run: `install.packages("package_name")`

**Output folder is empty**
→ Make sure you ran `source("scripts/00_main.R")`

**PCA plot not showing genres**
→ Make sure `genre` column exists in data

**Clusters look random**
→ Try increasing `nstart = 50` in script 05

## 💡 Tips for Your Report

✅ **DO:**
- Explain what each visualization shows
- Include actual numbers from `csv` files
- Interpret the patterns you see
- Discuss why clusters might form
- Compare to your expectations

❌ **DON'T:**
- Just copy code into report
- Skip explanations
- Leave plots without captions
- Make claims without data support

## 📚 Key Concepts to Explain

1. **Dimensionality Reduction**: Reducing 9 features → 2 (PC1, PC2)
2. **PCA**: Finding directions of maximum variance
3. **Principal Components**: Weighted combinations of original features
4. **Clustering**: Grouping similar songs together
5. **Feature Importance**: Which audio traits matter most

## 🎵 Fun Facts to Include

- Danceability + Energy → Pop music
- Acousticness + Instrumentalness → Folk/Classical  
- Valence → Happiness of song
- Speechiness → Podcast vs Music

---

**Total time**: 5-10 minutes  
**Lines of code to write**: 0 (it's all done!)  
**Visualizations generated**: 6  
**CSV files created**: 4
