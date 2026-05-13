const db = require('../config/db');

// Send notification to a user via Socket.IO
const sendNotification = async (io, userId, type, title, body, data = {}) => {
  try {
    // Save to DB
    const result = await db.query(
      `INSERT INTO notifications (user_id, type, title, body, data)
       VALUES ($1, $2, $3, $4, $5) RETURNING id`,
      [userId, type, title, body, JSON.stringify(data)]
    );

    // Send real-time via socket
    if (io) {
      io.to(`user:${userId}`).emit('notification', {
        id: result.rows[0].id,
        type, title, body, data,
        created_at: new Date().toISOString(),
      });
    }
  } catch (err) {
    console.error('Notification error:', err);
  }
};

// GET /api/notifications
const getNotifications = async (req, res) => {
  try {
    const result = await db.query(
      `SELECT * FROM notifications WHERE user_id = $1
       ORDER BY created_at DESC LIMIT 30`,
      [req.user.id]
    );

    // Mark all as read
    await db.query(
      'UPDATE notifications SET is_read = true WHERE user_id = $1',
      [req.user.id]
    );

    res.json({ success: true, notifications: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// GET /api/notifications/unread-count
const getUnreadCount = async (req, res) => {
  try {
    const result = await db.query(
      'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false',
      [req.user.id]
    );
    res.json({ success: true, count: parseInt(result.rows[0].count) });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

module.exports = { sendNotification, getNotifications, getUnreadCount };
