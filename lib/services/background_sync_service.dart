// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../config/api_config.dart';
// import 'token_manager.dart';
// import 'user_profile_cache.dart';

// /// Background sync service that checks for profile updates
// /// across all devices without requiring re-login
// ///
// /// Works by:
// /// 1. Periodically fetching latest profile (every 30 seconds)
// /// 2. Comparing photo hash/timestamp with cached version
// /// 3. Invalidating cache if changes detected
// /// 4. Notifying UI via UserProfileCache
// class BackgroundSyncService {
//   static final BackgroundSyncService _instance = 
//       BackgroundSyncService._internal();
  
//   factory BackgroundSyncService() => _instance;
//   BackgroundSyncService._internal();

//   Timer? _syncTimer;
//   String? _lastPhotoHash;
//   bool _isSyncing = false;

//   // Sync interval: checks every 30 seconds for changes
//   static const Duration syncInterval = Duration(seconds: 30);
  
//   // Force photo refresh every 5 minutes (in case server doesn't track modification time)
//   static const Duration forceRefreshInterval = Duration(minutes: 5);

//   /// Start background sync — call after user logs in
//   void startSync() {
//     if (_syncTimer != null) {
//       print('⚠️ [BackgroundSync] Sync already running');
//       return;
//     }

//     print('🔄 [BackgroundSync] Starting background sync service');
    
//     // Perform initial sync immediately
//     _performSync();
    
//     // Then schedule periodic syncs
//     _syncTimer = Timer.periodic(syncInterval, (timer) async {
//       await _performSync();
//     });
//   }

//   /// Stop background sync — call on logout
//   void stopSync() {
//     _syncTimer?.cancel();
//     _syncTimer = null;
//     _lastPhotoHash = null;
//     print('🛑 [BackgroundSync] Background sync stopped');
//   }

//   /// Perform a single sync cycle
//   Future<void> _performSync() async {
//     if (_isSyncing) return; // Prevent overlapping requests

//     _isSyncing = true;

//     try {
//       final token = TokenManager().token;
      
//       if (token == null || token.isEmpty) {
//         print('⚠️ [BackgroundSync] No token available — stopping sync');
//         stopSync();
//         return;
//       }

//       print('🔄 [BackgroundSync] Checking for profile updates...');

//       // Fetch minimal profile data (just photo info)
//       final response = await http.get(
//         Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserEndpoint}'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       ).timeout(const Duration(seconds: 10));

//       print('📥 [BackgroundSync] Response status: ${response.statusCode}');
      
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('✅ [BackgroundSync] Response received successfully');
//         await _checkForPhotoChanges(data);
//       } else if (response.statusCode == 401) {
//         // Token expired, sync will resume after TokenManager refreshes
//         print('⚠️ [BackgroundSync] Token expired, waiting for refresh...');
//       } else {
//         print('⚠️ [BackgroundSync] Sync failed: ${response.statusCode}');
//         print('⚠️ [BackgroundSync] Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('❌ [BackgroundSync] Error during sync: $e');
//     } finally {
//       _isSyncing = false;
//     }
//   }

//   /// Check if photo has changed on server
//   Future<void> _checkForPhotoChanges(Map<String, dynamic> data) async {
//     try {
//       // 🔍 DEBUG: Log the full response structure
//       print('📋 [BackgroundSync] Full response: ${jsonEncode(data)}');
      
//       // Try multiple possible paths for photo data
//       final photoUrl = data['employee']?['photoUrl']?.toString() ??
//           data['photoUrl']?.toString() ??
//           data['users']?['employee']?['photoUrl']?.toString();

//       print('📷 [BackgroundSync] Photo URL: $photoUrl');

//       if (photoUrl == null || photoUrl.isEmpty) {
//         print('⚠️ [BackgroundSync] No photo URL found in response');
//         print('   Checking all available keys...');
//         print('   Available keys: ${data.keys.toList()}');
//         if (data['employee'] != null) {
//           print('   Employee keys: ${(data['employee'] as Map).keys.toList()}');
//         }
//         if (data['users'] != null) {
//           print('   Users keys: ${(data['users'] as Map).keys.toList()}');
//         }
//         return;
//       }

//       // 🔐 Use photo URL as the change indicator (backend updates URL when photo changes)
//       print('🔐 [BackgroundSync] Current photo URL: $photoUrl');
//       print('🔐 [BackgroundSync] Last photo URL: $_lastPhotoHash');

//       // Check if photo URL has changed (indicating a new photo was uploaded)
//       if (_lastPhotoHash == null || _lastPhotoHash != photoUrl) {
//         print('📷 [BackgroundSync] ✨ Photo changed detected!');
//         print('  Old photo URL: $_lastPhotoHash');
//         print('  New photo URL: $photoUrl');

//         _lastPhotoHash = photoUrl;

//         // Update cache with new profile data
//         UserProfileCache.instance.setFromUserDetails(data);

//         // Increment photo version to force UI refresh
//         UserProfileCache.instance.photoVersion.value++;

//         print('✅ [BackgroundSync] Photo cache invalidated — UI will refresh');
//       } else {
//         print('✔️ [BackgroundSync] No changes detected (same photo URL)');
//       }
//     } catch (e) {
//       print('❌ [BackgroundSync] Error checking for photo changes: $e');
//       print('❌ [BackgroundSync] Stack trace: ${StackTrace.current}');
//     }
//   }

//   /// Manually trigger sync (useful after photo upload)
//   Future<void> syncNow() async {
//     print('🔄 [BackgroundSync] Manual sync requested...');
//     await _performSync();
//   }

//   /// Get current sync status
//   bool get isSyncing => _isSyncing;
//   bool get isActive => _syncTimer != null;
// }
