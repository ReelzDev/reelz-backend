const db = require('../config/db');
const { getPointsSummary, getPointsHistory } = require('../services/pointsService');
const { getVideoIdeas } = require('../services/algorithmService');

// GET /api/users/:username
const getProfile = async (req, res) => {
  try {
    const { username } = req.params;
    const viewerId = req.user?.id;

    const result = await db.query(`
      SELECT u.*,
        CASE WHEN f.follower_id IS NOT NULL THEN true ELSE false END as is_following
      FROM users u
      LEFT JOIN follows f ON f.follower_id = $2 AND f.following_id = u.id
      WHERE u.username = $1
    `, [username, viewerId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'المستخدم غير موجود' });
    }

    const user = result.rows[0];
    delete user.firebase_uid;

    // Get user videos
    const videosResult = await db.query(
      'SELECT * FROM videos WHERE user_id = $1 AND is_published = true ORDER BY created_at DESC LIMIT 12',
      [user.id]
    );

    res.json({ success: true, user, videos: videosResult.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// PUT /api/users/me
const updateProfile = async (req, res) => {
  try {
    const { display_name, bio, country } = req.body;
    const userId = req.user.id;

    const result = await db.query(
      `UPDATE users SET 
        display_name = COALESCE($1, display_name),
        bio = COALESCE($2, bio),
        country = COALESCE($3, country),
        updated_at = NOW()
       WHERE id = $4 RETURNING *`,
      [display_name, bio, country, userId]
    );

    res.json({ success: true, user: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// POST /api/users/:id/follow
const toggleFollow = async (req, res) => {
  try {
    const { id: targetId } = req.params;
    const followerId = req.user.id;

    if (followerId === targetId) {
      return res.status(400).json({ success: false, message: 'لا يمكنك متابعة نفسك' });
    }

    const existing = await db.query(
      'SELECT 1 FROM follows WHERE follower_id = $1 AND following_id = $2',
      [followerId, targetId]
    );

    let following;
    if (existing.rows.length > 0) {
      await db.query('DELETE FROM follows WHERE follower_id = $1 AND following_id = $2', [followerId, targetId]);
      await db.query('UPDATE users SET followers_count = followers_count - 1 WHERE id = $1', [targetId]);
      await db.query('UPDATE users SET following_count = following_count - 1 WHERE id = $1', [followerId]);
      following = false;
    } else {
      await db.query('INSERT INTO follows (follower_id, following_id) VALUES ($1, $2)', [followerId, targetId]);
      await db.query('UPDATE users SET followers_count = followers_count + 1 WHERE id = $1', [targetId]);
      await db.query('UPDATE users SET following_count = following_count + 1 WHERE id = $1', [followerId]);
      following = true;
    }

    res.json({ success: true, following });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// GET /api/users/me/points
const getMyPoints = async (req, res) => {
  try {
    const summary = await getPointsSummary(req.user.id);
    const history = await getPointsHistory(req.user.id);
    res.json({ success: true, summary, history });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// GET /api/users/me/creator-stats
const getCreatorStats = async (req, res) => {
  try {
    const userId = req.user.id;

    const stats = await db.query(`
      SELECT 
        COUNT(*) as total_videos,
        COALESCE(SUM(views_count), 0) as total_views,
        COALESCE(SUM(likes_count), 0) as total_likes,
        COALESCE(SUM(comments_count), 0) as total_comments
      FROM videos WHERE user_id = $1
    `, [userId]);

    const topVideos = await db.query(
      `SELECT id, title, views_count, likes_count, created_at 
       FROM videos WHERE user_id = $1 
       ORDER BY views_count DESC LIMIT 5`,
      [userId]
    );

    const ideas = await getVideoIdeas(userId);

    res.json({
      success: true,
      stats: stats.rows[0],
      top_videos: topVideos.rows,
      video_ideas: ideas,
      best_posting_times: ['08:00', '12:00', '18:00', '21:00'],
    });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

module.exports = { getProfile, updateProfile, toggleFollow, getMyPoints, getCreatorStats };
