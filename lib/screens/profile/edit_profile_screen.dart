import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primaryLight, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.bgSurface,
                  child: const Icon(Icons.person, color: AppColors.textHint, size: 48),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _Field(label: 'الاسم', hint: 'أحمد العراقي'),
          const SizedBox(height: 14),
          _Field(label: 'اسم المستخدم', hint: '@ahmed_iraq'),
          const SizedBox(height: 14),
          _Field(label: 'نبذة', hint: 'اكتب شيئاً عنك...', maxLines: 3),
          const SizedBox(height: 14),
          _Field(label: 'البلد', hint: 'العراق'),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;

  const _Field({required this.label, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
