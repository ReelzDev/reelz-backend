import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _isSearching = false;
  String _query = '';

  final _trending = ['ربح من الإنترنت', 'تعلم Flutter', 'مشاريع صغيرة', 'استثمار', 'فريلانس'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (v) => setState(() { _query = v; _isSearching = v.isNotEmpty; }),
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo', fontSize: 15),
          decoration: InputDecoration(
            hintText: 'ابحث عن فيديوهات أو مبدعين...',
            hintStyle: const TextStyle(color: AppColors.textHint, fontFamily: 'Cairo'),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textHint, size: 18),
                    onPressed: () { _controller.clear(); setState(() { _query = ''; _isSearching = false; }); })
                : null,
          ),
        ),
      ),
      body: _isSearching ? _SearchResults(query: _query) : _Discover(trending: _trending),
    );
  }
}

class _Discover extends StatelessWidget {
  final List<String> trending;
  const _Discover({required this.trending});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('الأكثر بحثاً', style: TextStyle(
          fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: trending.map((t) => GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Text(t, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textPrimary)),
              ]),
            ),
          )).toList(),
        ).animate().fadeIn(),

        const SizedBox(height: 24),
        const Text('تصفح حسب التصنيف', style: TextStyle(
          fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _CatCard(emoji: '📚', label: 'تعلم وتطور', color: AppColors.tagLearn),
            _CatCard(emoji: '💰', label: 'ربح ومال', color: AppColors.gold),
            _CatCard(emoji: '🎬', label: 'ترفيه', color: AppColors.tagEntertain),
            _CatCard(emoji: '🌍', label: 'محتوى محلي', color: AppColors.accent),
          ],
        ).animate(delay: 100.ms).fadeIn(),
      ],
    );
  }
}

class _CatCard extends StatelessWidget {
  final String emoji, label;
  final Color color;
  const _CatCard({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    // Mock results — replace with real API call
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('نتائج: "$query"', style: const TextStyle(
          fontFamily: 'Cairo', fontSize: 14, color: AppColors.textHint)),
        const SizedBox(height: 16),
        ...List.generate(5, (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 56, height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_circle_outline, color: AppColors.textHint, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$query — نتيجة ${i + 1}', maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('@creator_name', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textHint)),
              const SizedBox(height: 4),
              const Text('12K مشاهدة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textHint)),
            ])),
          ]),
        ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.1)),
      ],
    );
  }
}
