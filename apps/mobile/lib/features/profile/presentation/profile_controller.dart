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
      error = e.toString();
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
    await _repository.updateMe(
      fullName: fullName,
      bio: bio,
      avatarUrl: avatarUrl,
      preferredPositions: preferredPositions,
    );
    await fetch();
  }

  Future<String> uploadMedia(XFile file) {
    return _repository.uploadMedia(file);
  }

  Future<void> createStory({required String mediaUrl, String? caption, bool isHighlighted = false}) async {
    await _repository.createStory(mediaUrl: mediaUrl, caption: caption, isHighlighted: isHighlighted);
    await fetch();
  }

  Future<void> createPost({required String content, String? imageUrl}) async {
    await _repository.createPost(content: content, imageUrl: imageUrl);
    await fetch();
  }

  Future<void> setStoryHighlight({required String storyId, required bool isHighlighted}) async {
    await _repository.setStoryHighlight(storyId: storyId, isHighlighted: isHighlighted);
    await fetch();
  }
}
