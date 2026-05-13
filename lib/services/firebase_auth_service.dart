import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Google Sign In ────────────────────────────────────────
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // فتح نافذة اختيار حساب Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // المستخدم أغلق النافذة

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // تسجيل الدخول في Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) return null;

      // إرسال بيانات المستخدم للـ Backend
      final result = await ApiService.loginWithFirebase(
        firebaseUid: user.uid,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: user.photoURL,
      );

      return result;
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  // ── Phone Sign In ─────────────────────────────────────────
  static Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // تحقق تلقائي (Android فقط)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'فشل التحقق');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  // ── Verify OTP ────────────────────────────────────────────
  static Future<Map<String, dynamic>?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) return null;

      final result = await ApiService.loginWithFirebase(
        firebaseUid: user.uid,
        phone: user.phoneNumber,
      );

      return result;
    } catch (e) {
      print('OTP Error: $e');
      return null;
    }
  }

  // ── Sign Out ──────────────────────────────────────────────
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await ApiService.logout();
  }

  // ── Current User ──────────────────────────────────────────
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  // ── Auth State Stream ─────────────────────────────────────
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}
