import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isPhone = true;
  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // ── Google Login ──────────────────────────────────────────
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final result = await FirebaseAuthService.signInWithGoogle();
      if (result == null) {
        setState(() => _isLoading = false);
        return;
      }

      final isNew = result['is_new'] == true;
      if (mounted) {
        context.go(isNew ? '/interests' : '/feed');
      }
    } catch (e) {
      _showError('فشل تسجيل الدخول بجوجل');
      setState(() => _isLoading = false);
    }
  }

  // ── Phone Login ───────────────────────────────────────────
  Future<void> _sendCode() async {
    if (_phoneController.text.isEmpty) return;
    setState(() => _isLoading = true);

    String phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) phone = '+964$phone'; // Iraq prefix

    await FirebaseAuthService.signInWithPhone(
      phoneNumber: phone,
      onCodeSent: (id) {
        setState(() {
          _verificationId = id;
          _codeSent = true;
          _isLoading = false;
        });
      },
      onError: (err) {
        _showError(err);
        setState(() => _isLoading = false);
      },
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length < 6 || _verificationId == null) return;
    setState(() => _isLoading = true);

    final result = await FirebaseAuthService.verifyOTP(
      verificationId: _verificationId!,
      otp: _otpController.text.trim(),
    );

    if (result == null) {
      _showError('رمز التحقق غير صحيح');
      setState(() => _isLoading = false);
      return;
    }

    if (mounted) {
      context.go(result['is_new'] == true ? '/interests' : '/feed');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 24),

            // Logo
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              const Text('Reelz', style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ]).animate().fadeIn().slideX(begin: -0.1),

            const SizedBox(height: 40),

            const Text('مرحباً بك 👋', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary))
                .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),

            const Text('سجّل دخولك وابدأ رحلتك', style: TextStyle(
                fontFamily: 'Cairo', fontSize: 15, color: AppColors.textSecondary))
                .animate(delay: 150.ms).fadeIn(),

            const SizedBox(height: 36),

            // Google button
            _SocialBtn(
              label: 'المتابعة بحساب جوجل',
              onTap: _isLoading ? null : _loginWithGoogle,
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: Divider(color: AppColors.textHint.withOpacity(0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('أو', style: TextStyle(color: AppColors.textHint, fontFamily: 'Cairo')),
              ),
              Expanded(child: Divider(color: AppColors.textHint.withOpacity(0.3))),
            ]).animate(delay: 250.ms).fadeIn(),

            const SizedBox(height: 16),

            // Toggle
            Container(
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(4),
              child: Row(children: [
                _Tab(label: 'رقم الهاتف', active: _isPhone,
                    onTap: () => setState(() { _isPhone = true; _codeSent = false; })),
                _Tab(label: 'البريد الإلكتروني', active: !_isPhone,
                    onTap: () => setState(() { _isPhone = false; _codeSent = false; })),
              ]),
            ).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 20),

            // Fields
            if (_isPhone) ...[
              if (!_codeSent) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textHint),
                    hintText: '07XX XXX XXXX',
                  ),
                ).animate(delay: 350.ms).fadeIn(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendCode,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('إرسال رمز التحقق', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ] else ...[
                Text('أدخل الرمز المرسل لـ ${_phoneController.text}',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo', fontSize: 24, letterSpacing: 8),
                  decoration: const InputDecoration(counterText: '', hintText: '______'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('تحقق وادخل', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                TextButton(
                  onPressed: () => setState(() => _codeSent = false),
                  child: const Text('تغيير الرقم', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textHint)),
                ),
              ],
            ] else ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textHint),
                ),
              ).animate(delay: 350.ms).fadeIn(),
              const SizedBox(height: 12),
              TextField(
                controller: _passController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textHint),
                ),
              ).animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _loginWithGoogle,
                child: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],

            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _SocialBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textHint.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(14),
          color: AppColors.bgSurface,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: const Center(child: Text('G', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black))),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? Colors.white : AppColors.textHint)),
      ),
    ),
  );
}
