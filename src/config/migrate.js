require('dotenv').config();
const db = require('./db');

const migrate = async () => {
  const client = await db.getClient();

  try {
    await client.query('BEGIN');

    // ── USERS ─────────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        firebase_uid VARCHAR(128) UNIQUE,
        username VARCHAR(50) UNIQUE NOT NULL,
        display_name VARCHAR(100) NOT NULL,
        avatar_url TEXT,
        bio TEXT,
        country VARCHAR(10) DEFAULT 'IQ',
        phone VARCHAR(20),
        email VARCHAR(255),
        is_verified BOOLEAN DEFAULT false,
        is_creator BOOLEAN DEFAULT false,
        total_points INTEGER DEFAULT 0,
        followers_count INTEGER DEFAULT 0,
        following_count INTEGER DEFAULT 0,
        interests TEXT[] DEFAULT '{}',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // ── VIDEOS ────────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS videos (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(200) NOT NULL,
        description TEXT,
        video_url TEXT NOT NULL,
        hls_url TEXT,
        thumbnail_url TEXT,
        duration_seconds INTEGER DEFAULT 0,
        category VARCHAR(20) CHECK (category IN ('learn','earn','entertain','local')),
        type VARCHAR(20) CHECK (type IN ('educational','profitable','experience')),
        product_link TEXT,
        course_link TEXT,
        country VARCHAR(10) DEFAULT 'IQ',
        likes_count INTEGER DEFAULT 0,
        comments_count INTEGER DEFAULT 0,
        shares_count INTEGER DEFAULT 0,
        saves_count INTEGER DEFAULT 0,
        views_count INTEGER DEFAULT 0,
        is_published BOOLEAN DEFAULT true,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // ── VIDEO LIKES ───────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS video_likes (
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        PRIMARY KEY (user_id, video_id)
      );
    `);

    // ── VIDEO SAVES ───────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS video_saves (
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        PRIMARY KEY (user_id, video_id)
      );
    `);

    // ── COMMENTS ──────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS comments (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        video_id UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
        text TEXT NOT NULL,
        likes_count INTEGER DEFAULT 0,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // ── FOLLOWS ───────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS follows (
        follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
        following_id UUID REFERENCES users(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        PRIMARY KEY (follower_id, following_id)
      );
    `);

    // ── POINTS TRANSACTIONS ───────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS points_transactions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        reason VARCHAR(50) NOT NULL,
        points INTEGER NOT NULL,
        meta JSONB DEFAULT '{}',
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // ── VIDEO VIEWS ───────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS video_views (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        video_id UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
        user_id UUID REFERENCES users(id) ON DELETE SET NULL,
        watched_seconds INTEGER DEFAULT 0,
        completed BOOLEAN DEFAULT false,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // ── NOTIFICATIONS ─────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        type VARCHAR(50) NOT NULL,
        title VARCHAR(200),
        body TEXT,
        data JSONB DEFAULT '{}',
        is_read BOOLEAN DEFAULT false,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // ── INDEXES ───────────────────────────────────────────────
    await client.query(`CREATE INDEX IF NOT EXISTS idx_videos_user_id ON videos(user_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_videos_category ON videos(category);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_videos_country ON videos(country);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_videos_created ON videos(created_at DESC);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_comments_video ON comments(video_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_points_user ON points_transactions(user_id);`);

    await client.query('COMMIT');
    console.log('✅ All tables created successfully!');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', err);
  } finally {
    client.release();
    process.exit(0);
  }
};

migrate();
