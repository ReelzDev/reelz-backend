const express = require('express');
const multer = require('multer');
const router = express.Router();

const { authMiddleware, optionalAuth } = require('../middleware/auth');
const { firebaseAuth, updateInterests, getMe } = require('../controllers/authController');
const { getFeed, getTrending, getVideo, recordView, toggleLike, toggleSave, uploadVideo, deleteVideo } = require('../controllers/videoController');
const { getComments, addComment, deleteComment } = require('../controllers/commentController');
const { getProfile, updateProfile, toggleFollow, getMyPoints, getCreatorStats } = require('../controllers/userController');
const { getNotifications, getUnreadCount } = require('../controllers/notificationController');
const { search, getTrendingKeywords } = require('../controllers/searchController');

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 500 * 1024 * 1024 } });

// AUTH
router.post('/auth/firebase', firebaseAuth);
router.put('/auth/interests', authMiddleware, updateInterests);
router.get('/auth/me', authMiddleware, getMe);

// VIDEOS
router.get('/videos/feed', authMiddleware, getFeed);
router.get('/videos/trending', optionalAuth, getTrending);
router.get('/videos/:id', optionalAuth, getVideo);
router.post('/videos/:id/view', optionalAuth, recordView);
router.post('/videos/:id/like', authMiddleware, toggleLike);
router.post('/videos/:id/save', authMiddleware, toggleSave);
router.post('/videos', authMiddleware, upload.fields([{ name: 'video', maxCount: 1 }, { name: 'thumbnail', maxCount: 1 }]), uploadVideo);
router.delete('/videos/:id', authMiddleware, deleteVideo);

// COMMENTS
router.get('/videos/:videoId/comments', optionalAuth, getComments);
router.post('/videos/:videoId/comments', authMiddleware, addComment);
router.delete('/comments/:id', authMiddleware, deleteComment);

// USERS
router.get('/users/me/points', authMiddleware, getMyPoints);
router.get('/users/me/creator-stats', authMiddleware, getCreatorStats);
router.put('/users/me', authMiddleware, updateProfile);
router.get('/users/:username', optionalAuth, getProfile);
router.post('/users/:id/follow', authMiddleware, toggleFollow);

// NOTIFICATIONS
router.get('/notifications', authMiddleware, getNotifications);
router.get('/notifications/unread-count', authMiddleware, getUnreadCount);

// SEARCH
router.get('/search', optionalAuth, search);
router.get('/search/trending', getTrendingKeywords);

module.exports = router;
