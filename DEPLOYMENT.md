# دليل النشر الكامل — Reelz

## المرحلة 1: نشر Backend على Railway (أسهل وأسرع)

### الخطوات:
```bash
# 1. إنشاء حساب على railway.app

# 2. تثبيت Railway CLI
npm install -g @railway/cli

# 3. تسجيل الدخول
railway login

# 4. داخل مجلد reelz-backend
cd reelz-backend
railway init

# 5. إضافة PostgreSQL
railway add postgresql

# 6. رفع المشروع
railway up

# 7. احصل على رابط الـ API
railway open
```

### إعداد متغيرات البيئة في Railway:
```
JWT_SECRET=اختر_مفتاح_سري_قوي
AWS_ACCESS_KEY_ID=مفتاحك_من_AWS
AWS_SECRET_ACCESS_KEY=المفتاح_السري_من_AWS
AWS_REGION=me-south-1
AWS_BUCKET_NAME=reelz-videos
```

### تشغيل قاعدة البيانات:
```bash
# بعد النشر، شغّل الـ migration
railway run npm run migrate
```

---

## المرحلة 2: إعداد AWS S3 لتخزين الفيديوهات

```bash
# 1. إنشاء حساب AWS

# 2. إنشاء S3 Bucket
# - اسم: reelz-videos
# - المنطقة: me-south-1 (الشرق الأوسط)
# - إيقاف تشفير الوصول العام

# 3. Bucket Policy (اجعل الفيديوهات عامة)
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::reelz-videos/*"
  }]
}

# 4. إنشاء IAM User للتطبيق
# - منح صلاحية AmazonS3FullAccess
# - نسخ Access Key و Secret Key
```

---

## المرحلة 3: إعداد Firebase

```bash
# 1. إنشاء مشروع على console.firebase.google.com

# 2. تفعيل Authentication
# - Google Sign-In
# - Phone Authentication

# 3. تحميل google-services.json
# - ضعه في: android/app/

# 4. تحميل GoogleService-Info.plist
# - ضعه في: ios/Runner/

# 5. تفعيل Cloud Messaging (للإشعارات)
```

---

## المرحلة 4: ربط Flutter بالـ Backend

```dart
// في lib/services/api_service.dart
// غيّر هذا السطر:
static const String baseUrl = 'https://YOUR_RAILWAY_URL/api';

// مثال:
static const String baseUrl = 'https://reelz-production.up.railway.app/api';
```

---

## المرحلة 5: بناء APK للأندرويد

```bash
cd reelz

# بناء release APK
flutter build apk --release

# الملف يكون في:
# build/app/outputs/flutter-apk/app-release.apk

# لرفعه على Play Store، بناء AAB:
flutter build appbundle --release
```

### إعداد التوقيع (Signing):
```bash
# إنشاء keystore
keytool -genkey -v -keystore reelz-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias reelz

# أضف في android/key.properties:
storePassword=كلمة_المرور
keyPassword=كلمة_المرور
keyAlias=reelz
storeFile=../reelz-key.jks
```

---

## المرحلة 6: نشر على Google Play Store

```
1. إنشاء حساب مطور: play.google.com/console
   (رسوم تسجيل: 25$ مرة واحدة)

2. إنشاء تطبيق جديد

3. رفع AAB file

4. ملء معلومات التطبيق:
   - الاسم: Reelz
   - الوصف (بالعربي والإنجليزي)
   - لقطات شاشة (4 على الأقل)
   - أيقونة 512×512

5. اختيار التسعير: مجاني

6. نشر على Internal Testing أولاً
   ثم Production
```

---

## المرحلة 7: نشر على App Store (iOS)

```
1. حساب Apple Developer: developer.apple.com
   (رسوم سنوية: 99$)

2. Xcode → Archive

3. رفع على App Store Connect

4. مراجعة Apple (3-7 أيام)
```

---

## تكاليف التشغيل الشهرية (مبدئي)

| الخدمة | التكلفة |
|--------|---------|
| Railway (Backend) | $5/شهر |
| AWS S3 (10GB فيديو) | $1-3/شهر |
| Firebase (مجاني للبداية) | $0 |
| النطاق (Domain) | $10/سنة |
| **الإجمالي** | **~$10/شهر** |

---

## ترتيب الخطوات (المقترح)

1. ✅ إنشاء حسابات: Railway + AWS + Firebase
2. ✅ نشر Backend على Railway
3. ✅ إعداد AWS S3
4. ✅ ربط Flutter بـ API
5. ✅ اختبار على هاتفك (APK مباشر)
6. ✅ نشر على Play Store
7. ✅ نشر على App Store
