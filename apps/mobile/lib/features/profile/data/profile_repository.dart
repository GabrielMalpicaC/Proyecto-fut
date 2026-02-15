import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_fut_app/core/network/api_client.dart';

class ProfileRepository {
  ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getMe() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/profile/me');
    return res.data ?? {};
  }

  Future<List<dynamic>> getFeed() async {
    final res = await _apiClient.dio.get<List<dynamic>>('/profile/feed');
    return res.data ?? [];
  }

  Future<void> updateMe({
    String? fullName,
    String? bio,
    String? avatarUrl,
    List<String>? preferredPositions,
  }) async {
    await _apiClient.dio.patch('/profile/me', data: {
      if (fullName != null) 'fullName': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (preferredPositions != null) 'preferredPositions': preferredPositions,
    });
  }

  Future<String> uploadMedia(XFile file) async {
    final bytes = await file.readAsBytes();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
    });

    final response = await _apiClient.dio.post<Map<String, dynamic>>('/profile/upload', data: formData);
    return response.data?['url']?.toString() ?? '';
  }

  Future<void> createStory({required String mediaUrl, String? caption, bool isHighlighted = false}) async {
    await _apiClient.dio.post('/profile/stories', data: {
      'mediaUrl': mediaUrl,
      'caption': caption,
      'isHighlighted': isHighlighted,
    });
  }

  Future<void> setStoryHighlight({required String storyId, required bool isHighlighted}) async {
    await _apiClient.dio.patch('/profile/stories/$storyId/highlight', data: {
      'isHighlighted': isHighlighted,
    });
  }

  Future<void> createPost({required String content, String? imageUrl}) async {
    await _apiClient.dio.post('/profile/posts', data: {
      'content': content,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    });
  }
}
