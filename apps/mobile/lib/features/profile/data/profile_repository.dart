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


  Future<Map<String, dynamic>> getVenueOwnerProfile() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/profile/venue-owner/me');
    return res.data ?? {};
  }

  Future<void> upsertVenueOwnerProfile({
    required String venueName,
    String? venuePhotoUrl,
    String? bio,
    required String address,
    required String contactPhone,
    required String openingHours,
    required List<Map<String, dynamic>> fields,
  }) async {
    await _apiClient.dio.patch('/profile/venue-owner/me', data: {
      'venueName': venueName,
      if (venuePhotoUrl != null && venuePhotoUrl.isNotEmpty) 'venuePhotoUrl': venuePhotoUrl,
      if (bio != null) 'bio': bio,
      'address': address,
      'contactPhone': contactPhone,
      'openingHours': openingHours,
      'fields': fields,
    });
  }

  Future<void> submitRefereeVerification(String documentUrl) async {
    await _apiClient.dio.post('/profile/referee/verification', data: {'documentUrl': documentUrl});
  }

  Future<List<dynamic>> getRefereeAssignments() async {
    final res = await _apiClient.dio.get<List<dynamic>>('/profile/referee/assignments');
    return res.data ?? [];
  }

  Future<void> createPost({required String content, String? imageUrl}) async {
    await _apiClient.dio.post('/profile/posts', data: {
      'content': content,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    });
  }
}
