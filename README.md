# Reelz Backend — Node.js + PostgreSQL

## هيكل المشروع
```
reelz-backend/
├── src/
│   ├── index.js                    ← الخادم الرئيسي
│   ├── config/
│   │   ├── db.js                   ← اتصال PostgreSQL
│   │   └── migrate.js              ← إنشاء الجداول
│   ├── middleware/
│   │   └── auth.js                 ← التحقق من JWT
│   ├── controllers/
│   │   ├── authController.js       ← تسجيل الدخول
│   │   ├── videoController.js      ← الفيديوهات
│   │   ├── commentController.js    ← التعليقات
│   │   └── userController.js       ← المستخدمون
│   ├── services/
│   │   ├── pointsService.js        ← نظام النقاط
│   │   ├── algorithmService.js     ← الخوارزمية الذكية
│   │   └── storageService.js       ← رفع الملفات AWS S3
│   └── routes/
│       └── index.js                ← كل الـ API routes
├── .env.example
└── package.json
```

## إعداد وتشغيل

### 1. المتطلبات
- Node.js 18+
- PostgreSQL 14+
- Redis (اختياري)
- AWS S3 bucket

### 2. تثبيت
```bash
cd reelz-backend
npm install
cp .env.example .env
# عدّل .env بمعلوماتك
```

### 3. قاعدة البيانات
```bash
# إنشاء قاعدة البيانات
createdb reelz_db

# تشغيل الـ migrations (إنشاء الجداول)
npm run migrate
```

### 4. تشغيل
```bash
# تطوير
npm run dev

# إنتاج
npm start
```

## API المتاحة

### المصادقة
| Method | Route | الوصف |
|--------|-------|-------|
| POST | /api/auth/firebase | تسجيل دخول بـ Firebase |
| PUT | /api/auth/interests | تحديث الاهتمامات |
| GET | /api/auth/me | بيانات المستخدم الحالي |

### الفيديوهات
| Method | Route | الوصف |
|--------|-------|-------|
| GET | /api/videos/feed | الفيد الذكي |
| GET | /api/videos/trending | الأكثر رواجاً |
| GET | /api/videos/:id | فيديو محدد |
| POST | /api/videos | رفع فيديو جديد |
| POST | /api/videos/:id/view | تسجيل مشاهدة |
| POST | /api/videos/:id/like | لايك / إلغاء لايك |
| POST | /api/videos/:id/save | حفظ / إلغاء حفظ |
| DELETE | /api/videos/:id | حذف فيديو |

### التعليقات
| Method | Route | الوصف |
|--------|-------|-------|
| GET | /api/videos/:videoId/comments | جلب التعليقات |
| POST | /api/videos/:videoId/comments | إضافة تعليق |
| DELETE | /api/comments/:id | حذف تعليق |

### المستخدمون
| Method | Route | الوصف |
|--------|-------|-------|
| GET | /api/users/:username | ملف مستخدم |
| PUT | /api/users/me | تعديل الملف |
| POST | /api/users/:id/follow | متابعة / إلغاء متابعة |
| GET | /api/users/me/points | النقاط والتاريخ |
| GET | /api/users/me/creator-stats | إحصائيات المبدع |

## نظام النقاط
| الحدث | النقاط |
|-------|--------|
| مشاهدة فيديو كاملة | +5 |
| لايك | +2 |
| تعليق | +3 |
| مشاركة | +4 |
| دخول يومي | +10 |
| رفع فيديو | +20 |
