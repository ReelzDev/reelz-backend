// ══════════════════════════════════════════════════════════
// إعداد Firebase للمشروع — خطوة بخطوة
// ══════════════════════════════════════════════════════════

/*
الخطوة 1: إنشاء مشروع Firebase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. افتح: https://console.firebase.google.com
2. اضغط "Add project"
3. اسم المشروع: reelz-app
4. فعّل Google Analytics (اختياري)
5. اضغط "Create project"

الخطوة 2: إضافة تطبيق Android
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. اضغط أيقونة Android
2. Package name: com.reelz.app
3. App nickname: Reelz Android
4. اضغط "Register app"
5. حمّل google-services.json
6. ضعه في: android/app/google-services.json

الخطوة 3: تفعيل Authentication
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. اذهب لـ Authentication → Sign-in method
2. فعّل "Google" ← للدخول بحساب جوجل
3. فعّل "Phone" ← للدخول برقم الهاتف
4. اضغط Save

الخطوة 4: تفعيل Cloud Messaging
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. اذهب لـ Cloud Messaging
2. انسخ Server Key
3. أضفها في Railway: FIREBASE_SERVER_KEY=...

الخطوة 5: إعداد Firestore (اختياري)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. اذهب لـ Firestore Database
2. اضغط "Create database"
3. اختر "Start in test mode"
4. اختر أقرب منطقة
*/

// ── firebase_options.dart ──────────────────────────────────
// هذا الملف يُنشأ تلقائياً بعد تشغيل: flutterfire configure
// لكن هنا مثال على شكله:

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  // ← استبدل هذه القيم بقيمك الحقيقية من Firebase Console
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'reelz-app',
    storageBucket: 'reelz-app.appspot.com',
  );
}
