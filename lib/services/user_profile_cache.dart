import 'package:flutter/foundation.dart';

class UserProfileCache {
  UserProfileCache._();
  static final UserProfileCache instance = UserProfileCache._();

  final ValueNotifier<String?> photoUrl = ValueNotifier<String?>(null);
  final ValueNotifier<String> userName = ValueNotifier<String>('User');
  
  // ✅ Bumps every time photo is updated — forces re-fetch even if URL is same
  final ValueNotifier<int> photoVersion = ValueNotifier<int>(0);

  void setFromUserDetails(Map<String, dynamic> data) {
    final photo = data['employee']?['photoUrl']?.toString();
    final name = (data['name'] ?? 'User').toString();

    photoUrl.value = photo;
    userName.value = name;
    photoVersion.value++; // ✅ Always increment to trigger rebuild
  }
}