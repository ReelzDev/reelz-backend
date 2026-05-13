const db = require('../config/db');
const { getFeedVideos, getTrendingVideos } = require('../services/algorithmService');
const { awardPoints } = require('../services/pointsService');
const { uploadToS3 } = require('../services/storageService');

// GET /api/videos/feed
const getFeed = async (req, res) => {
  try {
    const {
      limit = 10,
      offset = 0,
      category,
      focus_mode,
      local_only,
    } = req.query;

    const videos = await getFeedVideos(req.user.id, {
      limit: parseInt(limit),
      offset: parseInt(offset),
      category,
      focusMode: focus_mode === 'true',
      localOnly: local_only === 'true',
      country: req.user.country || 'IQ',
    });

    res.json({ success: true, videos, has_more: videos.length === parseInt(limit) });
  } catch (err) {
    console.error('Feed error:', err);
    res.status(500).json({ success: false, message: 'خطأ في تحميل الفيديوهات' });
  }
};

// GET /api/videos/trending
const getTrending = async (req, res) => {
  try {
    const videos = await getTrendingVideos(req.user?.country || 'IQ');
    res.json({ success: true, videos });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// GET /api/videos/:id
const getVideo = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user?.id;

    const result = await db.query(`
      SELECT v.*, u.username, u.display_name, u.avatar_url, u.is_verified, u.is_creator,
        CASE WHEN vl.user_id IS NOT NULL THEN true ELSE false END as is_liked,
        CASE WHEN vs.user_id IS NOT NULL THEN true ELSE false END as is_saved
      FROM videos v
      JOIN users u ON u.id = v.user_id
      LEFT JOIN video_likes vl ON vl.video_id = v.id AND vl.user_id = $2
      LEFT JOIN video_saves vs ON vs.video_id = v.id AND vs.user_id = $2
      WHERE v.id = $1 AND v.is_published = true
    `, [id, userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'الفيديو غير موجود' });
    }

    res.json({ success: true, video: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// POST /api/videos/:id/view
const recordView = async (req, res) => {
  try {
    const { id } = req.params;
    const { watched_seconds = 0, completed = false } = req.body;
    const userId = req.user?.id;

    await db.query(
      `INSERT INTO video_views (video_id, user_id, watched_seconds, completed)
       VALUES ($1, $2, $3, $4)`,
      [id, userId, watched_seconds, completed]
    );

    await db.query('UPDATE videos SET views_count = views_count + 1 WHERE id = $1', [id]);

    let pointsResult = null;
    if (userId && completed) {
      pointsResult = await awardPoints(userId, 'watch_video', { video_id: id });
    }

    res.json({ success: true, points: pointsResult });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// POST /api/videos/:id/like
const toggleLike = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const existing = await db.query(
      'SELECT 1 FROM video_likes WHERE user_id = $1 AND video_id = $2',
      [userId, id]
    );

    let liked;
    if (existing.rows.length > 0) {
      await db.query('DELETE FROM video_likes WHERE user_id = $1 AND video_id = $2', [userId, id]);
      await db.query('UPDATE videos SET likes_count = likes_count - 1 WHERE id = $1', [id]);
      liked = false;
    } else {
      await db.query('INSERT INTO video_likes (user_id, video_id) VALUES ($1, $2)', [userId, id]);
      await db.query('UPDATE videos SET likes_count = likes_count + 1 WHERE id = $1', [id]);
      liked = true;
      await awardPoints(userId, 'like', { video_id: id });
    }

    const result = await db.query('SELECT likes_count FROM videos WHERE id = $1', [id]);
    res.json({ success: true, liked, likes_count: result.rows[0].likes_count });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// POST /api/videos/:id/save
const toggleSave = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const existing = await db.query(
      'SELECT 1 FROM video_saves WHERE user_id = $1 AND video_id = $2',
      [userId, id]
    );

    let saved;
    if (existing.rows.length > 0) {
      await db.query('DELETE FROM video_saves WHERE user_id = $1 AND video_id = $2', [userId, id]);
      await db.query('UPDATE videos SET saves_count = saves_count - 1 WHERE id = $1', [id]);
      saved = false;
    } else {
      await db.query('INSERT INTO video_saves (user_id, video_id) VALUES ($1, $2)', [userId, id]);
      await db.query('UPDATE videos SET saves_count = saves_count + 1 WHERE id = $1', [id]);
      saved = true;
    }

    res.json({ success: true, saved });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// POST /api/videos
const uploadVideo = async (req, res) => {
  try {
    const { title, description, category, type, product_link, course_link } = req.body;
    const userId = req.user.id;

    if (!req.files?.video) {
      return res.status(400).json({ success: false, message: 'الفيديو مطلوب' });
    }

    // Upload video to S3
    const videoUpload = await uploadToS3(req.files.video[0].buffer, req.files.video[0].originalname, 'videos');

    // Upload thumbnail if provided
    let thumbnailUrl = null;
    if (req.files?.thumbnail) {
      const thumbUpload = await uploadToS3(req.files.thumbnail[0].buffer, req.files.thumbnail[0].originalname, 'thumbnails');
      thumbnailUrl = thumbUpload.url;
    }

    const result = await db.query(
      `INSERT INTO videos 
        (user_id, title, description, video_url, thumbnail_url, category, type, product_link, course_link, country)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        userId, title, description,
        videoUpload.url, thumbnailUrl,
        category, type,
        product_link, course_link,
        req.user.country || 'IQ',
      ]
    );

    // Award creator points
    await awardPoints(userId, 'upload_video', { video_id: result.rows[0].id });

    res.status(201).json({ success: true, video: result.rows[0] });
  } catch (err) {
    console.error('Upload error:', err);
    res.status(500).json({ success: false, message: 'خطأ في رفع الفيديو' });
  }
};

// DELETE /api/videos/:id
const deleteVideo = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query('SELECT user_id FROM videos WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'الفيديو غير موجود' });
    }
    if (result.rows[0].user_id !== req.user.id) {
      return res.status(403).json({ success: false, message: 'غير مصرح' });
    }

    await db.query('DELETE FROM videos WHERE id = $1', [id]);
    res.json({ success: true, message: 'تم حذف الفيديو' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

module.exports = { getFeed, getTrending, getVideo, recordView, toggleLike, toggleSave, uploadVideo, deleteVideo };
