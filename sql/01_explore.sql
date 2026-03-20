-- Get a feel for what we're working with
SELECT 
    video_id,
    trending_date,
    title,
    channel_title,
    views,
    likes,
    dislikes,
    comment_count
FROM `youtube_pipeline.raw_videos`
ORDER BY views DESC
LIMIT 20
