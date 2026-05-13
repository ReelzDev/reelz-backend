import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class CommentsScreen extends StatefulWidget {
  final String videoId;
  const CommentsScreen({super.key, required this.videoId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  final List<CommentModel> _comments = _mockComments();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'التعليقات',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_comments.length}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFF2A2A40)),

              // Comments list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _comments.length,
                  itemBuilder: (context, i) {
                    final c = _comments[i];
                    return _CommentItem(comment: c);
                  },
                ),
              ),

              // Input
              Container(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.bgCard,
                  border: Border(top: BorderSide(color: Color(0xFF2A2A40))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo', fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'اكتب تعليقاً...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_commentController.text.isNotEmpty) {
                          setState(() {
                            _comments.insert(
                              0,
                              CommentModel(
                                id: DateTime.now().toIso8601String(),
                                videoId: widget.videoId,
                                user: UserModel(id: 'me', username: 'me', displayName: 'أنت', country: 'IQ'),
                                text: _commentController.text,
                                createdAt: DateTime.now(),
                              ),
                            );
                            _commentController.clear();
                          });
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentModel comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              comment.user.displayName[0],
              style: const TextStyle(color: AppColors.primaryLight, fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.user.displayName,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  comment.text,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'منذ قليل',
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textHint),
                    ),
                    const SizedBox(width: 16),
                    Text('رد', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.favorite_border_rounded, size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text('${comment.likesCount}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<CommentModel> _mockComments() {
  final u = (String name) => UserModel(id: name, username: name, displayName: name, country: 'IQ');
  return [
    CommentModel(id: '1', videoId: '1', user: u('سارة'), text: 'محتوى رائع جداً! استفدت كثيراً', likesCount: 24, createdAt: DateTime.now()),
    CommentModel(id: '2', videoId: '1', user: u('علي'), text: 'هل تنجح هذه الطريقة في العراق؟', likesCount: 8, createdAt: DateTime.now()),
    CommentModel(id: '3', videoId: '1', user: u('فاطمة'), text: 'شكراً على المشاركة، استمر', likesCount: 15, createdAt: DateTime.now()),
  ];
}
