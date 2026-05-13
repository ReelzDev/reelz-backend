import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _idx(String loc) {
    if (loc.startsWith('/feed'))     return 0;
    if (loc.startsWith('/search'))  return 1;
    if (loc.startsWith('/upload'))  return 2;
    if (loc.startsWith('/creator')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _idx(loc);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07), width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _N(icon: Icons.home_rounded,            label: 'الرئيسية', a: idx == 0, onTap: () => context.go('/feed')),
                _N(icon: Icons.search_rounded,          label: 'بحث',      a: idx == 1, onTap: () => context.go('/search')),
                _Upload(onTap: () => context.go('/upload')),
                _N(icon: Icons.bar_chart_rounded,       label: 'المبدع',   a: idx == 3, onTap: () => context.go('/creator')),
                _N(icon: Icons.person_outline_rounded,  label: 'حسابي',    a: idx == 4, onTap: () => context.go('/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _N extends StatelessWidget {
  final IconData icon; final String label; final bool a; final VoidCallback onTap;
  const _N({required this.icon, required this.label, required this.a, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap, behavior: HitTestBehavior.opaque,
    child: SizedBox(width: 52, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: a ? AppColors.primary : AppColors.textHint, size: 26),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
        color: a ? AppColors.primary : AppColors.textHint,
        fontWeight: a ? FontWeight.w700 : FontWeight.w400)),
    ])),
  );
}

class _Upload extends StatelessWidget {
  final VoidCallback onTap;
  const _Upload({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50, height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
    ),
  );
}
