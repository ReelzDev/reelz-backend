import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController    = TextEditingController();
  final _secondNameController   = TextEditingController();
  final _thirdNameController    = TextEditingController();
  final _usernameController     = TextEditingController();
  final _phoneEmailController   = TextEditingController();
  final _passwordController     = TextEditingController();
  final _confirmPassController  = TextEditingController();
  final _otpController          = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  bool _otpSent        = false;
  bool _usernameAvailable = true;
  bool _passwordMatch  = true;
  String _errorMsg     = '';

  int _step = 1; // 1=بيانات شخصية, 2=رمز التأكيد

  // تحقق من المعرف
  void _checkUsername(String value) {
    // سيُرسل للـ API للتحقق من التكرار
    setState(() {
      _usernameAvailable = value.length >= 3 && !value.contains(' ');
    });
  }

  // تحقق من تطابق كلمة السر
  void _checkPassword(String value) {
    setState(() {
      _passwordMatch = _confirmPassController.text.isEmpty ||
          _passwordController.text == _confirmPassController.text;
    });
  }

  bool get _step1Valid =>
      _firstNameController.text.isNotEmpty &&
      _usernameController.text.length >= 3 &&
      _phoneEmailController.text.isNotEmpty &&
      _passwordController.text.length >= 6 &&
      _passwordMatch &&
      _usernameAvailable;

  Future<void> _sendOtp() async {
    if (!_step1Valid) {
      setState(() => _errorMsg = 'يرجى تعبئة جميع الحقول بشكل صحيح');
      return;
    }
    setState(() { _isLoading = true; _errorMsg = ''; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLoading = false; _otpSent = true; _step = 2; });
  }

  Future<void> _verifyAndRegister() async {
    if (_otpController.text.length < 4) {
      setState(() => _errorMsg = 'أدخل رمز التأكيد المرسل');
      return;
    }
    setState(() { _isLoading = true; _errorMsg = ''; });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/interests');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _usernameController.dispose();
    _phoneEmailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(_step == 1 ? 'إنشاء حساب جديد' : 'تأكيد الهوية'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => _step == 2 ? setState(() => _step = 1) : context.go('/feed'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _step == 1 ? _buildStep1() : _buildStep2(),
        ),
      ),
    );
  }

  // ── الخطوة 1: البيانات الشخصية ──────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Progress
        _StepIndicator(current: 1, total: 2),
        const SizedBox(height: 24),

        const Text('معلوماتك الشخصية', style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('أدخل اسمك الثلاثي كما في وثيقة الهوية', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 28),

        // الاسم الأول
        _FieldLabel('الاسم الأول *'),
        _InputField(controller: _firstNameController, hint: 'مثال: أحمد', icon: Icons.person_outline),
        const SizedBox(height: 14),

        // الاسم الثاني
        _FieldLabel('الاسم الثاني'),
        _InputField(controller: _secondNameController, hint: 'مثال: محمد', icon: Icons.person_outline),
        const SizedBox(height: 14),

        // الاسم الثالث
        _FieldLabel('الاسم الثالث'),
        _InputField(controller: _thirdNameController, hint: 'مثال: العراقي', icon: Icons.person_outline),
        const SizedBox(height: 14),

        // المعرف
        _FieldLabel('المعرف (اسم المستخدم) *'),
        TextField(
          controller: _usernameController,
          onChanged: (v) { _checkUsername(v); setState(() {}); },
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
          decoration: InputDecoration(
            hintText: 'مثال: ahmed_iraq',
            prefixIcon: const Icon(Icons.alternate_email, color: AppColors.textHint),
            suffixIcon: _usernameController.text.length >= 3
                ? Icon(_usernameAvailable ? Icons.check_circle : Icons.cancel,
                    color: _usernameAvailable ? AppColors.accent : AppColors.error)
                : null,
          ),
        ),
        if (_usernameController.text.isNotEmpty && !_usernameAvailable)
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 4),
            child: Text('المعرف يجب أن يكون 3 أحرف على الأقل وبدون مسافات', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.error)),
          ),
        const SizedBox(height: 14),

        // رقم الهاتف أو البريد
        _FieldLabel('رقم الهاتف أو البريد الإلكتروني *'),
        _InputField(
          controller: _phoneEmailController,
          hint: '+964 7XX XXX XXXX أو example@email.com',
          icon: Icons.contact_phone_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),

        // كلمة السر
        _FieldLabel('كلمة السر *'),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePass,
          onChanged: _checkPassword,
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
          decoration: InputDecoration(
            hintText: '6 أحرف على الأقل',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: AppColors.textHint),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // تأكيد كلمة السر
        _FieldLabel('تأكيد كلمة السر *'),
        TextField(
          controller: _confirmPassController,
          obscureText: _obscureConfirm,
          onChanged: (v) => setState(() => _passwordMatch = _passwordController.text == v),
          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
          decoration: InputDecoration(
            hintText: 'أعد كتابة كلمة السر',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint),
            suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
              if (_confirmPassController.text.isNotEmpty)
                Icon(_passwordMatch ? Icons.check_circle : Icons.cancel,
                    color: _passwordMatch ? AppColors.accent : AppColors.error, size: 20),
              IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: AppColors.textHint),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ]),
          ),
        ),
        if (!_passwordMatch && _confirmPassController.text.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 4),
            child: Text('كلمة السر غير متطابقة', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.error)),
          ),

        const SizedBox(height: 12),

        // رسالة خطأ
        if (_errorMsg.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.error.withOpacity(0.3))),
            child: Text(_errorMsg, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.error, fontSize: 13)),
          ),

        const SizedBox(height: 24),

        // زر التالي
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtp,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: _isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('التالي — إرسال رمز التأكيد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
        ),

        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('لديك حساب؟', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 13)),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('سجّل الدخول', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 8),
      ],
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  // ── الخطوة 2: رمز التأكيد ─────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIndicator(current: 2, total: 2),
        const SizedBox(height: 24),

        const Text('تأكيد الهوية', style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(
          'أرسلنا رمز تأكيد إلى\n${_phoneEmailController.text}',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: AppColors.textSecondary, height: 1.6),
        ),

        const SizedBox(height: 40),

        // OTP input
        const Text('رمز التأكيد', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Cairo',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 12,
          ),
          decoration: const InputDecoration(
            hintText: '------',
            counterText: '',
            hintStyle: TextStyle(letterSpacing: 8, fontSize: 24),
          ),
        ),

        const SizedBox(height: 16),

        // إعادة إرسال
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('لم تستلم الرمز؟', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, fontSize: 13)),
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(seconds: 1));
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('تم إعادة إرسال الرمز', style: TextStyle(fontFamily: 'Cairo')),
                backgroundColor: AppColors.accent,
              ));
            },
            child: const Text('إعادة الإرسال', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
          ),
        ]),

        if (_errorMsg.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.error.withOpacity(0.3))),
            child: Text(_errorMsg, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.error, fontSize: 13)),
          ),
        ],

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _isLoading ? null : _verifyAndRegister,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: _isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('تأكيد وإنشاء الحساب', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

// ── Widgets مساعدة ────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(total, (i) {
      final active = i < current;
      final isCurrent = i == current - 1;
      return Expanded(
        child: Container(
          margin: EdgeInsets.only(left: i < total - 1 ? 8 : 0),
          height: 4,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }));
  }
}

Widget _FieldLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
);

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textHint),
      ),
    );
  }
}
