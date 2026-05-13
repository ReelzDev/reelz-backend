// lib/services/auth_gate.dart
// يتحكم في من يحتاج تسجيل دخول ومن يمكنه المشاهدة فقط

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AuthGate {
  // الميزات التي تحتاج تسجيل دخول
  static const List<String> _protectedActions = [
    'like', 'comment', 'share', 'save', 'upload', 'follow', 'points'
  ];

  // إذا المستخدم غير مسجل وضغط على ميزة محمية
  static void requireAuth(BuildContext context, String action) {
    if (!_protectedActions.contains(action)) return;
    _showAuthBottomSheet(context);
  }

  static void _showAuthBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.textHint, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('🔐', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('سجّل للاستمتام بكل المميزات', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('اللايك، التعليق، المشاركة، النقاط وأكثر', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); context.go('/register'); },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('إنشاء حساب جديد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () { Navigator.pop(context); context.go('/login'); },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('متابعة المشاهدة فقط', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textHint)),
          ),
        ]),
      ),
    );
  }
}
