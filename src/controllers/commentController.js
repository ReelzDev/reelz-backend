const db = require('../config/db');
const { awardPoints } = require('../services/pointsService');

// GET /api/videos/:videoId/comments
const getComments = async (req, res) => {
  try {
    const { videoId } = req.params;
    const { limit = 20, offset = 0 } = req.query;

    const result = await db.query(`
      SELECT c.*, u.username, u.display_name, u.avatar_url, u.is_verified
      FROM comments c
      JOIN users u ON u.id = c.user_id
      WHERE c.video_id = $1 AND c.parent_id IS NULL
      ORDER BY c.likes_count DESC, c.created_at DESC
      LIMIT $2 OFFSET $3
    `, [videoId, limit, offset]);

    res.json({ success: true, comments: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// POST /api/videos/:videoId/comments
const addComment = async (req, res) => {
  try {
    const { videoId } = req.params;
    const { text, parent_id } = req.body;
    const userId = req.user.id;

    if (!text?.trim()) {
      return res.status(400).json({ success: false, message: 'نص التعليق مطلوب' });
    }

    const result = await db.query(
      `INSERT INTO comments (video_id, user_id, text, parent_id)
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [videoId, userId, text.trim(), parent_id || null]
    );

    await db.query('UPDATE videos SET comments_count = comments_count + 1 WHERE id = $1', [videoId]);

    // Award points
    await awardPoints(userId, 'comment', { video_id: videoId });

    const userResult = await db.query(
      'SELECT username, display_name, avatar_url, is_verified FROM users WHERE id = $1',
      [userId]
    );

    res.status(201).json({
      success: true,
      comment: { ...result.rows[0], ...userResult.rows[0] },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// DELETE /api/comments/:id
const deleteComment = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query('SELECT user_id, video_id FROM comments WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'التعليق غير موجود' });
    }
    if (result.rows[0].user_id !== req.user.id) {
      return res.status(403).json({ success: false, message: 'غير مصرح' });
    }

    await db.query('DELETE FROM comments WHERE id = $1', [id]);
    await db.query('UPDATE videos SET comments_count = comments_count - 1 WHERE id = $1', [result.rows[0].video_id]);

    res.json({ success: true, message: 'تم حذف التعليق' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

module.exports = { getComments, addComment, deleteComment };
