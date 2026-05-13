import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _videoFile;
  String? _selectedCategory;
  String? _selectedType;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isUploading = false;
  final _picker = ImagePicker();

  final List<Map<String, dynamic>> categories = [
    {'id': 'learn',     'label': 'تعليمي',  'emoji': '📚', 'color': AppColors.tagLearn},
    {'id': 'earn',      'label': 'ربحي',    'emoji': '💰', 'color': AppColors.gold},
    {'id': 'entertain', 'label': 'ترفيهي',  'emoji': '🎬', 'color': AppColors.tagEntertain},
    {'id': 'local',     'label': 'محلي',    'emoji': '🌍', 'color': AppColors.accent},
  ];

  final types      = ['educational', 'profitable', 'experience'];
  final typeLabels = ['شرح وتعليم', 'ربح ومال', 'تجربة شخصية'];

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _videoFile = File(picked.path));
  }

  Future<void> _recordVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.camera);
    if (picked == null) return;
    setState(() => _videoFile = File(picked.path));
  }

  Future<void> _upload() async {
    if (_videoFile == null || _selectedCategory == null || _titleController.text.isEmpty) return;
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('تم رفع الفيديو! 🎉', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      context.go('/feed');
    }
  }

  String _buttonHint() {
    if (_videoFile == null) return 'اختر فيديو أولاً';
    if (_titleController.text.isEmpty) return 'أضف عنواناً';
    if (_selectedCategory == null) return 'اختر التصنيف';
    return 'نشر الفيديو';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canUpload = _videoFile != null && _selectedCategory != null && _titleController.text.isNotEmpty && !_isUploading;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('رفع فيديو جديد'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.go('/feed'))),
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Video picker
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: _videoFile != null ? AppColors.primary.withOpacity(0.08) : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _videoFile != null ? AppColors.primary : AppColors.textHint.withOpacity(0.25), width: _videoFile != null ? 2 : 1),
                ),
                child: _videoFile != null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 42),
                        const SizedBox(height: 8),
                        const Text('تم اختيار الفيديو ✓', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700)),
                        const Text('اضغط لتغييره', style: TextStyle(fontFamily: 'Cairo', color: Colors.white60, fontSize: 12)),
                      ])
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.cloud_upload_outlined, color: AppColors.textHint, size: 48),
                        const SizedBox(height: 12),
                        const Text('اضغط لاختيار فيديو', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: _recordVideo,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.primary.withOpacity(0.5)), borderRadius: BorderRadius.circular(20)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.videocam_rounded, color: AppColors.primaryLight, size: 16),
                              SizedBox(width: 6),
                              Text('أو سجّل الآن', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primaryLight, fontSize: 13)),
                            ]),
                          ),
                        ),
                      ]),
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 20),

            const Text('عنوان الفيديو *', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
              decoration: const InputDecoration(hintText: 'عنوان جذاب يوضح الفائدة...'),
            ).animate(delay: 80.ms).fadeIn(),

            const SizedBox(height: 14),

            const Text('الوصف', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
              decoration: const InputDecoration(hintText: 'ماذا سيتعلم أو يكسب المشاهد؟'),
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 20),

            const Text('تصنيف الفيديو *', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.0,
              children: categories.map((c) {
                final active = _selectedCategory == c['id'];
                final color = c['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c['id'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: active ? color.withOpacity(0.15) : AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: active ? color : Colors.transparent, width: 1.5),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(c['emoji'] as String, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(c['label'] as String, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? color : AppColors.textSecondary)),
                    ]),
                  ),
                );
              }).toList(),
            ).animate(delay: 130.ms).fadeIn(),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: canUpload ? _upload : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.rocket_launch_rounded, size: 20),
                const SizedBox(width: 10),
                Text(canUpload ? 'نشر الفيديو' : _buttonHint(), style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 32),
          ],
        ),

        if (_isUploading)
          Container(
            color: Colors.black87,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 48),
                  const SizedBox(height: 16),
                  const Text('جاري رفع الفيديو...', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: AppColors.primary),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}