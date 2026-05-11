require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { createServer } = require('http');
const { Server } = require('socket.io');

const routes = require('./routes');

const app = express();
const httpServer = createServer(app);

// ── Socket.IO ────────────────────────────────────────────────
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

io.on('connection', (socket) => {
  socket.on('join', (userId) => {
    if (userId) socket.join(`user:${userId}`);
  });

  socket.on('disconnect', () => {});
});

app.set('io', io);

// ── Security & Middleware ─────────────────────────────────────
app.use(helmet());
app.use(compression());

app.use(cors({
  origin: '*',
  credentials: true,
}));

app.use(morgan('dev'));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Rate Limit ────────────────────────────────────────────────
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'طلبات كثيرة، حاول لاحقاً' },
});

app.use('/api', limiter);

// ── Routes ────────────────────────────────────────────────────
if (!routes) {
  console.error('❌ routes file not found');
} else {
  app.use('/api', routes);
}

// ── Health Check ──────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
});

// ── 404 Handler ───────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'المسار غير موجود',
  });
});

// ── Error Handler ─────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('❌ Server error:', err);

  res.status(500).json({
    success: false,
    message: 'خطأ في الخادم',
  });
});

// ── Start Server ──────────────────────────────────────────────
const PORT = process.env.PORT || 3000;

// مهم لـ Railway
httpServer.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Reelz backend running on port ${PORT}`);
});

// ── Safety error catching (مهم جدًا في Railway) ───────────────
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
});

process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Rejection:', err);
});

module.exports = app;
