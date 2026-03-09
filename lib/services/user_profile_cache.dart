import 'package:flutter/foundation.dart';

/// Singleton cache holding user profile data in reactive notifiers to trigger UI rebuilds when profile or photo changes.
class UserProfileCache {
  UserProfileCache._();
  static final UserProfileCache instance = UserProfileCache._();

  /// Reactive notifier for the user's profile photo URL; triggers rebuild when photo is updated.
  final ValueNotifier<String?> photoUrl = ValueNotifier<String?>(null);
  /// Reactive notifier for the user's display name; triggers rebuild when name changes.
  final ValueNotifier<String> userName = ValueNotifier<String>('User');
  
  /// Incremented every time photo is updated to force re-fetch even if URL remains the same (cache busting).
  final ValueNotifier<int> photoVersion = ValueNotifier<int>(0);

  /// Updates cache with new profile data from API and increments photoVersion to trigger image reload.
  void setFromUserDetails(Map<String, dynamic> data) {
    final photo = data['employee']?['photoUrl']?.toString();
    final name = (data['name'] ?? 'User').toString();

    photoUrl.value = photo;
    userName.value = name;
    photoVersion.value++; // ✅ Always increment to trigger rebuild
  }
}