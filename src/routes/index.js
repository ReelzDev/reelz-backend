require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');

const app = express();

// ── Middlewares ─────────────────────────────
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));
app.use(compression());
app.use(express.json());

// ── Routes ───────────────────────────────────
const apiRoutes = require('./routes'); // تأكد هذا المسار صحيح عندك

app.use('/api', apiRoutes);

// ── Health Check ─────────────────────────────
app.get('/', (req, res) => {
  res.status(200).send('🚀 Reelz API is running');
});

// ── Server ───────────────────────────────────
const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Running on port ${PORT}`);
});
