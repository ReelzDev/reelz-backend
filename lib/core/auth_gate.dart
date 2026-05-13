import 'package:flutter/material.dart';
import '../screens/auth/auth_screen.dart';
import 'session.dart';

Future<bool> requireAuth(BuildContext context) async {
  if (AppSession.isLoggedIn) return true;
  Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
  return false;
}