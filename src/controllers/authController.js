const jwt = require('jsonwebtoken');
const db = require('../config/db');
const { awardPoints } = require('../services/pointsService');

const generateToken = (userId) =>
  jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '30d' });

// POST /api/auth/firebase
// Login or register with Firebase token
const firebaseAuth = async (req, res) => {
  try {
    const { firebase_uid, email, phone, display_name, avatar_url, interests = [] } = req.body;

    if (!firebase_uid) {
      return res.status(400).json({ success: false, message: 'firebase_uid مطلوب' });
    }

    // Check if user exists
    let result = await db.query('SELECT * FROM users WHERE firebase_uid = $1', [firebase_uid]);

    let user;
    let isNew = false;

    if (result.rows.length === 0) {
      // New user — create account
      const username = (display_name || 'user')
        .toLowerCase()
        .replace(/\s+/g, '_')
        .replace(/[^a-z0-9_]/g, '') + '_' + Math.floor(Math.random() * 9999);

      const insertResult = await db.query(
        `INSERT INTO users 
          (firebase_uid, username, display_name, email, phone, avatar_url, interests)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING *`,
        [firebase_uid, username, display_name || username, email, phone, avatar_url, interests]
      );

      user = insertResult.rows[0];
      isNew = true;

      // Award welcome points
      await awardPoints(user.id, 'daily_login', { type: 'welcome' });
    } else {
      user = result.rows[0];

      // Check daily login points
      const today = new Date().toDateString();
      const lastLogin = await db.query(
        `SELECT created_at FROM points_transactions 
         WHERE user_id = $1 AND reason = 'daily_login' 
         ORDER BY created_at DESC LIMIT 1`,
        [user.id]
      );

      if (
        lastLogin.rows.length === 0 ||
        new Date(lastLogin.rows[0].created_at).toDateString() !== today
      ) {
        await awardPoints(user.id, 'daily_login');
      }
    }

    const token = generateToken(user.id);

    res.json({
      success: true,
      is_new: isNew,
      token,
      user: {
        id: user.id,
        username: user.username,
        display_name: user.display_name,
        avatar_url: user.avatar_url,
        total_points: user.total_points,
        is_creator: user.is_creator,
        interests: user.interests,
        country: user.country,
      },
    });
  } catch (err) {
    console.error('Auth error:', err);
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// PUT /api/auth/interests
const updateInterests = async (req, res) => {
  try {
    const { interests } = req.body;
    await db.query('UPDATE users SET interests = $1 WHERE id = $2', [interests, req.user.id]);
    res.json({ success: true, message: 'تم تحديث الاهتمامات' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

// GET /api/auth/me
const getMe = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM users WHERE id = $1', [req.user.id]);
    const user = result.rows[0];
    res.json({ success: true, user });
  } catch (err) {
    res.status(500).json({ success: false, message: 'خطأ في الخادم' });
  }
};

module.exports = { firebaseAuth, updateInterests, getMe };
