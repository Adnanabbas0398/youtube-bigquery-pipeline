-- Summarise performance by channel
-- This is a typical first transformation in a data pipeline
SELECT
    channel_title,
    COUNT(DISTINCT video_id)        AS total_videos,
    ROUND(AVG(views), 0)            AS avg_views,
    ROUND(AVG(likes), 0)            AS avg_likes,
    ROUND(AVG(comment_count), 0)    AS avg_comments,
    MAX(views)                      AS max_views,
    ROUND(AVG(likes/NULLIF(views,0))*100, 2) AS avg_engagement_rate
FROM `youtube_pipeline.raw_videos`
GROUP BY channel_title
HAVING total_videos >= 3
ORDER BY avg_views DESC
LIMIT 30
