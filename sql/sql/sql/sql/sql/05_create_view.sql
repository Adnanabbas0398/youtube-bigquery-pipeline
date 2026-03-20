CREATE OR REPLACE VIEW `youtube_pipeline.anomaly_detection_view` AS

WITH video_stats AS (
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
    SELECT
        channel_title,
        AVG(views)            AS channel_avg_views,
        AVG(likes)            AS channel_avg_likes,
        AVG(comment_count)    AS channel_avg_comments,
        STDDEV(views)         AS channel_std_views,
        STDDEV(likes)         AS channel_std_likes,
        STDDEV(comment_count) AS channel_std_comments
    FROM video_stats
    GROUP BY channel_title
)

SELECT
    v.video_id,
    v.title,
    v.channel_title,
    v.trending_date,
    v.views,
    v.likes,
    v.comment_count,
    v.engagement_rate,
    ROUND((v.views - c.channel_avg_views)
        / NULLIF(c.channel_std_views, 0), 2)        AS view_zscore,
    ROUND((v.likes - c.channel_avg_likes)
        / NULLIF(c.channel_std_likes, 0), 2)        AS like_zscore,
    ROUND((v.comment_count - c.channel_avg_comments)
        / NULLIF(c.channel_std_comments, 0), 2)     AS comment_zscore,
    CASE
        WHEN (v.views - c.channel_avg_views)
            / NULLIF(c.channel_std_views, 0) > 2    THEN TRUE
        WHEN (v.likes - c.channel_avg_likes)
            / NULLIF(c.channel_std_likes, 0) > 2    THEN TRUE
        WHEN (v.comment_count - c.channel_avg_comments)
            / NULLIF(c.channel_std_comments, 0) > 2 THEN TRUE
        ELSE FALSE
    END AS is_anomaly
FROM video_stats v
LEFT JOIN channel_benchmarks c
    ON v.channel_title = c.channel_title
