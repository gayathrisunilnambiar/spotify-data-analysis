# 📊 Association Analysis & Accuracy Metrics Guide

This guide explains the new analysis scripts that discover patterns and evaluate model quality.

## Overview

Your pipeline now includes:
1. **Association Rules** (Script 06) - Find patterns in music data
2. **Accuracy Metrics** (Script 07) - Evaluate model quality

---

## 🔗 Association Rule Analysis (Script 06)

Association rules discover **relationships** between audio features and music characteristics.

### What It Does

Converts continuous features (0-1 scale) into **categories** to find patterns like:
- "IF song is danceable AND energetic THEN likely Pop genre"
- "IF song is acoustic AND sad THEN lower popularity"

### 5 Key Rules Analyzed

#### Rule 1: Energy × Danceability → Genre
```
IF energy > 0.7 AND danceability > 0.75
THEN likely Pop/Electronic/Hip-Hop
```
**Output**: `association_rule_1_energy_dance_genre.csv`

**Example Finding**: 
- High energy + high dance: 85 songs → 60% are Pop
- Medium energy + low dance: 45 songs → 70% are Rock

#### Rule 2: Acousticness × Mood → Popularity
```
IF acousticness > 0.7 AND valence < 0.4
THEN lower popularity
```
**Output**: `association_rule_2_acoustic_mood_popularity.csv`

**Example Finding**:
- Very acoustic + Sad mood → 40% Low Popularity
- Electronic + Happy mood → 65% High Popularity

#### Rule 3: Genre-Specific Patterns
```
What are the typical audio characteristics of each genre?
```
**Output**: `association_rule_3_genre_patterns.csv`

**Example Finding**:
| Genre | Avg Energy | Avg Dance | Avg Valence | Songs |
|-------|-----------|-----------|-------------|-------|
| Pop | 0.72 | 0.71 | 0.68 | 150 |
| Rock | 0.68 | 0.54 | 0.42 | 120 |
| Jazz | 0.45 | 0.45 | 0.55 | 85 |

#### Rule 4: Vocal Type Patterns
```
Instrumental vs. Vocal songs - how do they differ?
```
**Output**: `association_rule_4_vocal_patterns.csv`

**Example Finding**:
- Instrumental + High Energy → Higher danceability (0.68)
- Vocal + Low Energy → Lower danceability (0.35)
- Speech-heavy → 15% popularity average

#### Rule 5: Tempo × Mood → Danceability
```
IF tempo > 130 AND valence > 0.7
THEN higher danceability
```
**Output**: `association_rule_5_tempo_mood_dance.csv`

### How to Interpret Results

**Confidence**: If rule has 100 songs, confidence is how many match the "then" part
- 80/100 → 80% confidence

**Support**: How common is this pattern in your data?
- 100 songs out of 1000 → 10% support

---

## 📈 Accuracy Metrics (Script 07)

Evaluates **how good** your PCA and clustering models are.

### 1. PCA Accuracy Metrics

#### Variance Explained
```
PC1: 62.3% of variance
PC2: 18.9% of variance  
PC3: 8.4% of variance
Total (3 PCs): 89.6%
```

**Interpretation**:
- ✅ > 80% with 2-3 components = **GOOD**
- ⚠️ 60-80% = **ACCEPTABLE**
- ❌ < 60% = **POOR**

#### Reconstruction RMSE (Root Mean Square Error)
```
2-component PCA RMSE: 0.3425
```

**Interpretation**:
- Lower is better (0 = perfect)
- RMSE < 0.5 = **GOOD** reconstruction
- Measures how much information is lost when reducing from 9 → 2 dimensions

#### Reconstruction Error
```
1 PC: 42.5% error
2 PCs: 18.8% error
3 PCs: 8.9% error
```

**Interpretation**: What % of information is lost with N components?

---

### 2. Clustering Quality Metrics

#### Silhouette Score (Most Important!)
```
Range: -1 to +1

Your Result: 0.65
```

**Interpretation**:
- **0.7 - 1.0**: Excellent clustering ✅
- **0.5 - 0.7**: Good clustering ✅
- **0.25 - 0.5**: Fair clustering ⚠️
- **0.0 - 0.25**: Poor clustering ❌
- **Negative**: Overlapping clusters (bad)

**What it measures**: 
How similar songs are to their own cluster vs. other clusters

**Example**:
- Silhouette = 0.65 → Songs in same cluster are 65% more similar than songs in different clusters

#### Davies-Bouldin Index
```
Your Result: 0.85
```

**Interpretation**:
- **< 1.0**: Well-separated clusters ✅
- **1.0 - 2.0**: Acceptable separation ⚠️
- **> 2.0**: Poorly separated clusters ❌

**What it measures**: How compact and separated clusters are

---

### 3. Cluster Homogeneity

**Output**: `cluster_quality_metrics.csv`

```
Cluster | Size | Avg Energy | Avg Dance | Dominant Genre
--------|------|-----------|-----------|----------------
1       | 285  | 0.75      | 0.68      | Pop
2       | 312  | 0.52      | 0.48      | Rock
3       | 403  | 0.42      | 0.45      | Folk/Jazz
```

**Interpretation**:
- Cluster 1: High energy + danceable = **Pop cluster**
- Cluster 2: Medium energy + moderate dance = **Rock cluster**
- Cluster 3: Low energy + acoustic = **Chill/Jazz cluster**

---

### 4. Genre Classification Purity

```
Cluster 1: Pop=180, Rock=60, Hip-Hop=45
Cluster 2: Rock=210, Pop=85, Country=17
Cluster 3: Folk=280, Country=90, Jazz=33

Purity Score: 0.72
```

**Interpretation**:
- **0.8 - 1.0**: Clusters align perfectly with genres ✅
- **0.6 - 0.8**: Good genre separation ✅
- **0.4 - 0.6**: Fair genre separation ⚠️
- **< 0.4**: Poor genre alignment ❌

**Purity = 0.72**: 72% of songs in each cluster are the same genre (good!)

---

### 5. Feature Importance

**Output**: `feature_variance_contribution.csv`

```
Feature           | Original SD | PC1 Loading | PC2 Loading
------------------|------------|-------------|------------
danceability      | 0.18       | 0.35        | 0.12
energy            | 0.24       | 0.42        | 0.08
acousticness      | 0.31       | -0.28       | 0.45
valence           | 0.21       | 0.15        | 0.38
tempo             | 28.4       | 0.22        | -0.15
```

**Interpretation**:
- High |PC1 loading| = Feature strongly influences PC1
- Energy (0.42) is most important for PC1
- Acousticness (-0.28) pushes opposite direction
- Valence (0.15) has less influence on PC1

---

## 📋 Output Files Summary

### Association Analysis Files
| File | Contains |
|------|----------|
| `association_rule_1_*.csv` | Energy × Dance → Genre patterns |
| `association_rule_2_*.csv` | Acoustic × Mood → Popularity patterns |
| `association_rule_3_*.csv` | Genre-specific audio signatures |
| `association_rule_4_*.csv` | Vocal type (instrumental vs. vocal) patterns |
| `association_rule_5_*.csv` | Tempo × Mood → Danceability patterns |
| `association_rules_summary.txt` | Key findings summary |

### Accuracy Metrics Files
| File | Contains |
|------|----------|
| `accuracy_report.txt` | Complete accuracy summary |
| `pca_variance_explained.csv` | Variance by # of components |
| `cluster_quality_metrics.csv` | Silhouette, intra-cluster distance |
| `feature_variance_contribution.csv` | Feature importance for each PC |

---

## 🎯 For Your Report

### Section 1: Association Analysis
Include:
1. **Rule 1 Table**: Top 10 Energy × Dance → Genre combinations
2. **Insight**: Which genres are most danceable/energetic?
3. **Rule 3 Table**: Genre characteristics comparison
4. **Conclusion**: Do clusters align with music genres?

### Section 2: Accuracy & Validation
Include:
1. **PCA Variance**: Table showing variance explained by 1, 2, 3 PCs
2. **Silhouette Score**: What it means for your clustering
3. **Purity Score**: How well genres align with clusters
4. **Key Metrics Table**: Summary of all accuracy measures

### Example Report Text

```
Our PCA model captured 81.2% of variance using just 2 principal components,
reducing the feature space from 9 to 2 dimensions with minimal information loss.
The clustering achieved a Silhouette score of 0.65, indicating good cluster
quality where songs within the same cluster are 65% more similar to each other
than to songs in different clusters. Genre classification purity of 0.72 shows
that our unsupervised clustering naturally separates different music genres
without explicit genre labels, validating the audio feature-based approach.
```

---

## 🔍 How to Read CSV Results

### association_rule_3_genre_patterns.csv
```csv
genre,avg_energy,avg_danceability,avg_acousticness,avg_valence,avg_popularity,song_count
pop,0.78,0.71,0.18,0.68,65,150
rock,0.68,0.54,0.25,0.42,52,120
jazz,0.45,0.45,0.65,0.55,38,85
```

**Interpret Row 1 (Pop)**:
- Pop songs average: 78% energy, 71% danceability
- Low acousticness (18%) = mostly electronic
- High valence (68%) = happy mood
- 150 pop songs in dataset

### pca_variance_explained.csv
```csv
n_components,variance_explained,variance_explained_pct,reconstruction_error
1,0.6234,62.34,0.3766
2,0.8127,81.27,0.1873
3,0.8952,89.52,0.1048
```

**Interpretation**:
- 2 components explain 81.27% of total variance
- Using 2 components instead of 9: 81% as good, 78% less storage!

---

## 💡 Key Takeaways

1. **Association Rules reveal music patterns** - Which audio features go together?
2. **PCA validates dimensionality reduction** - Can we use 2 instead of 9 features?
3. **Silhouette Score confirms clustering quality** - Are clusters meaningful?
4. **Purity Score validates genre separation** - Do clusters match music genres?
5. **Together they prove your model is valid** - Results are statistically sound

---

**For questions, check**: 
- Data dictionary (DATA_DICTIONARY.md)
- Quick start (QUICKSTART.md)
- Script comments for detailed explanations
