#!/bin/bash
# ══════════════════════════════════════════════════════
# Reelz Backend - Railway Deployment Script
# شغّل هذا الملف مرة واحدة فقط
# ══════════════════════════════════════════════════════

set -e
echo ""
echo "🚀 Reelz Backend — Railway Deployment"
echo "══════════════════════════════════════"
echo ""

# 1. Check Railway CLI
if ! command -v railway &> /dev/null; then
    echo "📦 تثبيت Railway CLI..."
    npm install -g @railway/cli
fi

# 2. Login
echo "🔐 تسجيل الدخول لـ Railway..."
echo "سيفتح المتصفح — سجّل دخولك ثم ارجع هنا"
railway login

# 3. Init project
echo ""
echo "📁 إنشاء مشروع Railway..."
railway init --name reelz-backend

# 4. Add PostgreSQL
echo ""
echo "🗄️  إضافة قاعدة البيانات..."
railway add postgresql

# 5. Set environment variables
echo ""
echo "⚙️  إعداد المتغيرات..."
railway variables set \
    NODE_ENV=production \
    JWT_SECRET=$(openssl rand -hex 32) \
    POINTS_WATCH_VIDEO=5 \
    POINTS_LIKE=2 \
    POINTS_COMMENT=3 \
    POINTS_SHARE=4 \
    POINTS_DAILY_LOGIN=10

echo ""
echo "⚠️  الآن أضف يدوياً في Railway Dashboard:"
echo "   AWS_ACCESS_KEY_ID=مفتاحك"
echo "   AWS_SECRET_ACCESS_KEY=سريتك"
echo "   AWS_BUCKET_NAME=reelz-videos"
echo "   AWS_REGION=me-south-1"
echo ""
read -p "اضغط Enter عند الانتهاء..."

# 6. Deploy
echo ""
echo "🚂 رفع المشروع على Railway..."
railway up

# 7. Run migrations
echo ""
echo "🗄️  إنشاء جداول قاعدة البيانات..."
railway run npm run migrate

# 8. Get URL
echo ""
echo "🌐 رابط API الخاص بك:"
railway open
echo ""
echo "✅ تم النشر بنجاح!"
echo ""
echo "الخطوة التالية:"
echo "افتح lib/services/api_service.dart"
echo "وغيّر baseUrl برابط Railway الظاهر أعلاه"
