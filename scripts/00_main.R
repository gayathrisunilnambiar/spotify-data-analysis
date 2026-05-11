# Spotify Analysis Pipeline
# Run this script to execute the entire analysis workflow

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("..")

message("🎵 Starting Spotify Music Analysis Pipeline...\n")

# Step 1: Data Collection
message("========== STEP 1: COLLECT DATA ==========")
source("scripts/01_collect_data.R")

# Step 2: Data Cleaning
message("\n========== STEP 2: CLEAN DATA ==========")
source("scripts/02_clean_data.R")

# Step 3: Dimensionality Reduction (PCA)
message("\n========== STEP 3: DIMENSIONALITY REDUCTION (PCA) ==========")
source("scripts/03_dimensionality_reduction.R")

# Step 4: Visualizations
message("\n========== STEP 4: CREATE VISUALIZATIONS ==========")
source("scripts/04_visualize_results.R")

# Step 5: Clustering & Insights
message("\n========== STEP 5: CLUSTERING & INSIGHTS ==========")
source("scripts/05_clustering_insights.R")

# Step 6: Association Rules
message("\n========== STEP 6: ASSOCIATION ANALYSIS ==========")
source("scripts/06_association_rules.R")

# Step 7: Accuracy Metrics
message("\n========== STEP 7: ACCURACY EVALUATION ==========")
source("scripts/07_accuracy_metrics.R")

# Step 8: Recommendation System
message("\n========== STEP 8: RECOMMENDATION SYSTEM ==========")
source("scripts/08_recommendation_system.R")

# Step 9: Time Series Model
message("\n========== STEP 9: TIME SERIES FORECASTING ==========")
source("scripts/09_time_series_model.R")

message("\n" %+% strrep("=", 55))
message("✅ COMPLETE SPOTIFY ANALYSIS PIPELINE FINISHED!")
message("=" %+% strrep("=", 55))
message("\n📁 Output files created:")
message("   📊 Visualizations: 6 PNG charts")
message("   📈 Analysis Results: 17 CSV files")
message("   🔗 Association Rules: 5 CSV + summary")
message("   📋 Accuracy Metrics: 3 CSV + report")
message("   💡 Recommendations: 5 CSV + report")
message("   📈 Time Series: 8 CSV + report")
message("   📝 Total Reports: 4 text summaries")
message("")
