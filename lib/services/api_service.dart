import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'reelz-backend-production-1590.up.railway.app';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Dio get _dio {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));
    return dio;
  }

  // ── AUTH ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> loginWithFirebase({
    required String firebaseUid, String? email, String? phone,
    String? displayName, String? avatarUrl,
  }) async {
    final res = await _dio.post('/auth/firebase', data: {
      'firebase_uid': firebaseUid, 'email': email,
      'phone': phone, 'display_name': displayName, 'avatar_url': avatarUrl,
    });
    if (res.data['success'] == true) {
      await _storage.write(key: 'auth_token', value: res.data['token']);
    }
    return res.data;
  }

  static Future<void> updateInterests(List<String> interests) async =>
      await _dio.put('/auth/interests', data: {'interests': interests});

  static Future<bool> isLoggedIn() async =>
      (await _storage.read(key: 'auth_token')) != null;

  static Future<void> logout() async =>
      await _storage.delete(key: 'auth_token');

  // ── FEED ─────────────────────────────────────────────────
  static Future<List<dynamic>> getFeed({
    int limit = 10, int offset = 0,
    String? category, bool focusMode = false, bool localOnly = false,
  }) async {
    final res = await _dio.get('/videos/feed', queryParameters: {
      'limit': limit, 'offset': offset,
      if (category != null) 'category': category,
      'focus_mode': focusMode, 'local_only': localOnly,
    });
    return res.data['videos'] ?? [];
  }

  // ── VIDEO ACTIONS ────────────────────────────────────────
  static Future<void> recordView(String id, {int watchedSeconds = 0, bool completed = false}) async {
    try { await _dio.post('/videos/$id/view', data: {'watched_seconds': watchedSeconds, 'completed': completed}); } catch (_) {}
  }

  static Future<Map<String, dynamic>> toggleLike(String id) async =>
      (await _dio.post('/videos/$id/like')).data;

  static Future<Map<String, dynamic>> toggleSave(String id) async =>
      (await _dio.post('/videos/$id/save')).data;

  // ── UPLOAD ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> uploadVideo({
    required File videoFile, File? thumbnailFile,
    required String title, required String description,
    required String category, required String type,
    String? productLink,
  }) async {
    final formData = FormData.fromMap({
      'title': title, 'description': description,
      'category': category, 'type': type,
      if (productLink != null) 'product_link': productLink,
      'video': await MultipartFile.fromFile(
        videoFile.path,
        filename: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      ),
      if (thumbnailFile != null)
        'thumbnail': await MultipartFile.fromFile(
          thumbnailFile.path,
          filename: 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
    });

    final res = await _dio.post('/videos', data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
    return res.data;
  }

  static Future<void> deleteVideo(String id) async =>
      await _dio.delete('/videos/$id');

  // ── COMMENTS ─────────────────────────────────────────────
  static Future<List<dynamic>> getComments(String videoId) async =>
      ((await _dio.get('/videos/$videoId/comments')).data['comments'] ?? []);

  static Future<Map<String, dynamic>> addComment(String videoId, String text, {String? parentId}) async =>
      (await _dio.post('/videos/$videoId/comments', data: {'text': text, if (parentId != null) 'parent_id': parentId})).data;

  static Future<void> deleteComment(String id) async =>
      await _dio.delete('/comments/$id');

  // ── USERS ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile(String username) async =>
      (await _dio.get('/users/$username')).data;

  static Future<void> updateProfile({String? displayName, String? bio, String? country}) async =>
      await _dio.put('/users/me', data: {
        if (displayName != null) 'display_name': displayName,
        if (bio != null) 'bio': bio,
        if (country != null) 'country': country,
      });

  static Future<Map<String, dynamic>> toggleFollow(String userId) async =>
      (await _dio.post('/users/$userId/follow')).data;

  static Future<Map<String, dynamic>> getMyPoints() async =>
      (await _dio.get('/users/me/points')).data;

  static Future<Map<String, dynamic>> getCreatorStats() async =>
      (await _dio.get('/users/me/creator-stats')).data;
}
