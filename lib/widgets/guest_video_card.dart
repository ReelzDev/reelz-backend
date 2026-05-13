// هذا الملف يُستخدم لإضافة حماية على أزرار التفاعل
// ضعه في: lib/widgets/guest_video_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

// دالة للتحقق من تسجيل الدخول قبل أي إجراء
Future<bool> requireLogin(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  
  if (token != null) return true; // مسجّل ← اكمل
  
  // غير مسجّل ← اعرض popup
  if (context.mounted) _showLoginPrompt(context);
  return false;
}

void _showLoginPrompt(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.bgCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(color: AppColors.textHint, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          const Text('🔐', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'سجّل للاستمتاع بكل المميزات',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'اللايك • التعليق • المشاركة • النقاط • رفع الفيديو',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // زر إنشاء حساب
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/register');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'إنشاء حساب مجاني',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 10),

          // زر تسجيل الدخول
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 8),

          // متابعة المشاهدة
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'متابعة المشاهدة فقط',
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.textHint, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
