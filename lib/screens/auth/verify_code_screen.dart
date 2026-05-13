import 'package:flutter/material.dart';
import '../../core/session.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final code = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("رمز التحقق")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("أدخل رمز التحقق المرسل إليك"),
            TextField(controller: code),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("تأكيد"),
              onPressed: () {
                AppSession.isLoggedIn = true;
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            )
          ],
        ),
      ),
    );
  }
}