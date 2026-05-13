import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl =
      "https://reelz-backend-production-43f4.up.railway.app/api";

  final Dio dio = Dio();
  final storage = const FlutterSecureStorage();

  Future<Dio> getClient() async {
    String? token = await storage.read(key: "token");

    dio.options = BaseOptions(
      baseUrl: baseUrl,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    return dio;
  }
}