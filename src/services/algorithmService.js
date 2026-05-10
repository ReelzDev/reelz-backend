const db = require('../config/db');

/**
 * Smart feed algorithm:
 * 1. User interests (category match)
 * 2. Local content boost (same country)
 * 3. Engagement score (likes + comments + shares)
 * 4. Recency (newer = higher score)
 * 5. Already watched = excluded
 */
const getFeedVideos = async (userId, options = {}) => {
  const {
    limit = 10,
    offset = 0,
    category = null,      // filter by category
    focusMode = false,    // only learn + earn
    localOnly = false,    // only same country
    country = 'IQ',
  } = options;

  let categoryFilter = '';
  let params = [userId, limit, offset];
  let paramIndex = 4;

  if (focusMode) {
    categoryFilter = `AND v.category IN ('learn', 'earn')`;
  } else if (category) {
    categoryFilter = `AND v.category = $${paramIndex}`;
    params.push(category);
    paramIndex++;
  }

  const localFilter = localOnly ? `AND v.country = '${country}'` : '';

  const query = `
    SELECT 
      v.*,
      u.username,
      u.display_name,
      u.avatar_url,
      u.is_verified,
      u.is_creator,
      u.country as creator_country,
      CASE WHEN vl.user_id IS NOT NULL THEN true ELSE false END as is_liked,
      CASE WHEN vs.user_id IS NOT NULL THEN true ELSE false END as is_saved,
      -- Smart scoring
      (
        v.likes_count * 1.5 +
        v.comments_count * 2.0 +
        v.shares_count * 2.5 +
        v.views_count * 0.1 +
        -- Recency boost: newer videos get higher score
        GREATEST(0, 100 - EXTRACT(EPOCH FROM (NOW() - v.created_at)) / 3600) +
        -- Local content boost
        CASE WHEN v.country = '${country}' THEN 20 ELSE 0 END
      ) as score
    FROM videos v
    JOIN users u ON u.id = v.user_id
    LEFT JOIN video_likes vl ON vl.video_id = v.id AND vl.user_id = $1
    LEFT JOIN video_saves vs ON vs.video_id = v.id AND vs.user_id = $1
    -- Exclude already watched (last 24h)
    WHERE v.id NOT IN (
      SELECT video_id FROM video_views 
      WHERE user_id = $1 AND created_at > NOW() - INTERVAL '24 hours'
    )
    AND v.is_published = true
    ${categoryFilter}
    ${localFilter}
    ORDER BY score DESC
    LIMIT $2 OFFSET $3
  `;

  const result = await db.query(query, params);

  return result.rows.map(row => ({
    id: row.id,
    user_id: row.user_id,
    title: row.title,
    description: row.description,
    video_url: row.hls_url || row.video_url,
    thumbnail_url: row.thumbnail_url,
    duration_seconds: row.duration_seconds,
    category: row.category,
    type: row.type,
    likes_count: row.likes_count,
    comments_count: row.comments_count,
    shares_count: row.shares_count,
    saves_count: row.saves_count,
    views_count: row.views_count,
    product_link: row.product_link,
    course_link: row.course_link,
    is_liked: row.is_liked,
    is_saved: row.is_saved,
    created_at: row.created_at,
    country: row.country,
    creator: {
      id: row.user_id,
      username: row.username,
      display_name: row.display_name,
      avatar_url: row.avatar_url,
      is_verified: row.is_verified,
      is_creator: row.is_creator,
      country: row.creator_country,
    },
  }));
};

/**
 * Get trending videos (last 24h)
 */
const getTrendingVideos = async (country = 'IQ', limit = 10) => {
  const result = await db.query(`
    SELECT v.*, u.username, u.display_name, u.avatar_url, u.is_verified
    FROM videos v
    JOIN users u ON u.id = v.user_id
    WHERE v.created_at > NOW() - INTERVAL '24 hours'
    AND v.is_published = true
    ORDER BY (v.likes_count * 2 + v.comments_count * 3 + v.views_count * 0.1) DESC
    LIMIT $1
  `, [limit]);

  return result.rows;
};

/**
 * Generate video ideas for creator based on their top videos
 */
const getVideoIdeas = async (userId) => {
  const topVideos = await db.query(`
    SELECT category, title FROM videos 
    WHERE user_id = $1 
    ORDER BY views_count DESC 
    LIMIT 3
  `, [userId]);

  const ideas = [
    'كيف تربح 50$ يومياً من هاتفك فقط',
    '3 أدوات مجانية تغني عن برامج بآلاف الدولارات',
    'تجربتي مع الفريلانس: ما الذي تعلمته بعد سنة',
    'أسرار خوارزمية منصات الفيديو القصير',
    'كيف بنيت مشروعي بدون رأس مال',
    'مهارة واحدة تغير حياتك المالية',
  ];

  return ideas;
};

module.exports = { getFeedVideos, getTrendingVideos, getVideoIdeas };
