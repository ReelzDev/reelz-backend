const db = require('../config/db');

// GET /api/search?q=keyword&type=videos|users
const search = async (req, res) => {
  try {
    const { q, type = 'videos', limit = 20, offset = 0 } = req.query;

    if (!q || q.trim().length < 2) {
      return res.status(400).json({ success: false, message: 'كلمة البحث قصيرة جداً' });
    }

    const keyword = `%${q.trim()}%`;

    if (type === 'videos') {
      const result = await db.query(`
        SELECT v.*, u.username, u.display_name, u.avatar_url, u.is_verified
        FROM videos v
        JOIN users u ON u.id = v.user_id
        WHERE v.is_published = true
          AND (v.title ILIKE $1 OR v.description ILIKE $1)
        ORDER BY v.views_count DESC
        LIMIT $2 OFFSET $3
      `, [keyword, limit, offset]);

      return res.json({ success: true, results: result.rows, type: 'videos' });
    }

    if (type === 'users') {
      const result = await db.query(`
        SELECT id, username, display_name, avatar_url, is_verified,
               followers_count, is_creator
        FROM users
        WHERE username ILIKE $1 OR display_name ILIKE $1
        ORDER BY followers_count DESC
        LIMIT $2 OFFSET $3
      `, [keyword, limit, offset]);

      return res.json({ success: true, results: result.rows, type: 'users' });
    }

    res.status(400).json({ success: false, message: 'نوع بحث غير صالح' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// GET /api/search/trending
const getTrendingKeywords = async (req, res) => {
  try {
    // أكثر الكلمات بحثاً — يمكن تخزينها في Redis لاحقاً
    const trending = [
      'ربح من الإنترنت',
      'تعلم Flutter',
      'مشاريع صغيرة ناجحة',
      'استثمار للمبتدئين',
      'فريلانس عربي',
      'تصميم جرافيك',
      'تداول العملات',
      'يوتيوب وتيك توك',
    ];

    res.json({ success: true, trending });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

module.exports = { search, getTrendingKeywords };
