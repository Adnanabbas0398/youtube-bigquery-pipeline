# YouTube Trending Data — BigQuery SQL Pipeline

A multi-layer SQL data pipeline built on Google BigQuery that ingests 
YouTube trending video data, applies CTE-based transformations, and uses 
Z-score statistical analysis to flag anomalous engagement patterns — 
directly relevant to Trust & Safety data infrastructure work.

## What it does
- Ingests 40,949 YouTube trending videos into BigQuery
- Explores raw data and builds channel-level aggregations
- Applies a multi-step CTE pipeline to compute per-video benchmarks
- Calculates Z-scores across views, likes and comments in pure SQL
- Flags anomalous videos using a reusable BigQuery view
- Identified 2,010 anomalous videos (4.9% flag rate)

## Pipeline Architecture
```
raw_videos (BigQuery table)
      ↓
01_explore.sql          — raw data exploration
      ↓
02_channel_summary.sql  — channel-level aggregations
      ↓
03_pipeline_cte.sql     — multi-step CTE transformations
      ↓
04_anomaly_flags.sql    — Z-score anomaly detection
      ↓
05_create_view.sql      — persistent anomaly detection view
```

## Key Findings
- **2,010 videos flagged** out of 40,949 (4.9% flag rate)
- NFL Super Bowl halftime show appeared twice with view z-score of 6.4+
  — classic coordinated engagement spike from a viral event
- Fergie's national anthem had a comment z-score of **9.59** with 
  relatively low views — unusually high comment activity, a key 
  Trust & Safety signal for potential coordinated behaviour
- jacksfilms and SNL were the most frequently flagged channels (27 each)
  — high-volume uploaders with recurring viral outliers

## Trust & Safety Relevance
Sudden unexplained spikes in engagement metrics — especially when comments 
spike disproportionately to views — can indicate coordinated inauthentic 
behaviour, bot activity, or platform manipulation. This pipeline automates 
the detection of those signals at scale using pure SQL, making it 
deployable across any dataset size.

## SQL Techniques Used
- Common Table Expressions (CTEs) for multi-step transformations
- Window functions and channel-level benchmarking
- Z-score statistical anomaly detection in SQL
- NULLIF for safe division handling
- CREATE OR REPLACE VIEW for reusable pipeline output
- STDDEV, AVG, ROUND aggregations

## Tools
- Google BigQuery
- Standard SQL
- Python (Pandas) for data cleaning pre-load
- Dataset: YouTube Trending Videos (Kaggle)
