const db = require('../config/db');

const POINTS = {
  watch_video: parseInt(process.env.POINTS_WATCH_VIDEO) || 5,
  like: parseInt(process.env.POINTS_LIKE) || 2,
  comment: parseInt(process.env.POINTS_COMMENT) || 3,
  share: parseInt(process.env.POINTS_SHARE) || 4,
  daily_login: parseInt(process.env.POINTS_DAILY_LOGIN) || 10,
  upload_video: 20,
  get_followed: 5,
};

const awardPoints = async (userId, reason, meta = {}) => {
  const points = POINTS[reason];
  if (!points) return null;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // Insert transaction
    await client.query(
      `INSERT INTO points_transactions (user_id, reason, points, meta) VALUES ($1, $2, $3, $4)`,
      [userId, reason, points, JSON.stringify(meta)]
    );

    // Update user total
    const result = await client.query(
      `UPDATE users SET total_points = total_points + $1 WHERE id = $2 RETURNING total_points`,
      [points, userId]
    );

    await client.query('COMMIT');

    return {
      points_awarded: points,
      total_points: result.rows[0].total_points,
      reason,
    };
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Points error:', err);
    return null;
  } finally {
    client.release();
  }
};

const getPointsSummary = async (userId) => {
  const result = await db.query(
    `SELECT 
      total_points,
      (SELECT COALESCE(SUM(points), 0) FROM points_transactions WHERE user_id = $1 AND created_at > NOW() - INTERVAL '7 days') as weekly_points,
      (SELECT COUNT(*) FROM points_transactions WHERE user_id = $1) as total_transactions
    FROM users WHERE id = $1`,
    [userId]
  );
  return result.rows[0];
};

const getPointsHistory = async (userId, limit = 20, offset = 0) => {
  const result = await db.query(
    `SELECT id, reason, points, meta, created_at 
     FROM points_transactions 
     WHERE user_id = $1 
     ORDER BY created_at DESC 
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  return result.rows;
};

module.exports = { awardPoints, getPointsSummary, getPointsHistory, POINTS };
