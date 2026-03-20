-- This is a multi-step pipeline:
-- Step 1: Calculate per-video stats
-- Step 2: Add channel-level benchmarks
-- Step 3: Compute how each video performs vs its channel average

WITH video_stats AS (
    -- Step 1: clean base stats per video
    SELECT
        video_id,
        title,
        channel_title,
        trending_date,
        views,
        likes,
        comment_count,
        ROUND(likes / NULLIF(views, 0) * 100, 2) AS engagement_rate
    FROM `youtube_pipeline.raw_videos`
),

channel_benchmarks AS (
    -- Step 2: calculate average stats per channel
    SELECT
        channel_title,
        AVG(views)          AS channel_avg_views,
        AVG(likes)          AS channel_avg_likes,
        AVG(comment_count)  AS channel_avg_comments,
        STDDEV(views)       AS channel_std_views
    FROM video_stats
    GROUP BY channel_title
),

final_pipeline AS (
    -- Step 3: join and compute performance ratios
    SELECT
        v.video_id,
        v.title,
        v.channel_title,
        v.trending_date,
        v.views,
        v.likes,
        v.comment_count,
        v.engagement_rate,
        ROUND(c.channel_avg_views, 0)   AS channel_avg_views,
        ROUND(c.channel_std_views, 0)   AS channel_std_views,
        -- How many times above channel average is this video?
        ROUND(v.views / NULLIF(c.channel_avg_views, 0), 2) AS views_vs_channel_avg,
        -- Z-score: same method as our Python project but in SQL
        ROUND((v.views - c.channel_avg_views) / NULLIF(c.channel_std_views, 0), 2) AS view_zscore
    FROM video_stats v
    LEFT JOIN channel_benchmarks c
        ON v.channel_title = c.channel_title
)

SELECT * FROM final_pipeline
ORDER BY view_zscore DESC
LIMIT 50
