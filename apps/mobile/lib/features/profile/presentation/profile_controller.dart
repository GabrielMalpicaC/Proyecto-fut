import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_fut_app/features/profile/data/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);

  final ProfileRepository _repository;

  bool loading = false;
  String? error;
  Map<String, dynamic> profile = {};
  List<dynamic> feed = [];

  List<dynamic> get stories => (profile['stories'] as List<dynamic>?) ?? [];
  List<dynamic> get highlightedStories => (profile['highlightedStories'] as List<dynamic>?) ?? [];
  List<dynamic> get posts => (profile['posts'] as List<dynamic>?) ?? [];
  List<String> get preferredPositions =>
      ((profile['preferredPositions'] as List<dynamic>?) ?? []).map((e) => e.toString()).toList();

  Future<void> fetch() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      profile = await _repository.getMe();
      feed = await _repository.getFeed();
    } catch (e) {
      error = _toReadableError(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
    List<String>? preferredPositions,
  }) async {
    try {
      await _repository.updateMe(
        fullName: fullName,
        bio: bio,
        avatarUrl: avatarUrl,
        preferredPositions: preferredPositions,
      );
      await fetch();
    } catch (e) {
      error = _toReadableError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<String> uploadMedia(XFile file) async {
    try {
      return await _repository.uploadMedia(file);
    } catch (e) {
      error = _toReadableError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createStory({required String mediaUrl, String? caption, bool isHighlighted = false}) async {
    try {
      await _repository.createStory(mediaUrl: mediaUrl, caption: caption, isHighlighted: isHighlighted);
      await fetch();
    } catch (e) {
      error = _toReadableError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createPost({required String content, String? imageUrl}) async {
    try {
      await _repository.createPost(content: content, imageUrl: imageUrl);
      await fetch();
    } catch (e) {
      error = _toReadableError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setStoryHighlight({required String storyId, required bool isHighlighted}) async {
    try {
      await _repository.setStoryHighlight(storyId: storyId, isHighlighted: isHighlighted);
      await fetch();
    } catch (e) {
      error = _toReadableError(e);
      notifyListeners();
      rethrow;
    }
  }

  String _toReadableError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }

      if (error.response?.statusCode == 503) {
        return 'Perfil temporalmente no disponible. Intenta nuevamente en unos minutos.';
      }

      return 'No se pudo completar la operación. Revisa tu conexión e intenta otra vez.';
    }

    return 'Ocurrió un error inesperado.';
  }
}
