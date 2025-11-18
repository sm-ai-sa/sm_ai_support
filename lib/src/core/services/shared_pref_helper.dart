import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm_ai_support/src/core/models/anonymous_session_data.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';

class SharedPrefHelper {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call SharedPrefHelper.init() first.');
    }
    return _prefs!;
  }

  // Keys for storing data
  static const String _authTokenKey = 'auth_token';
  static const String _customerIdKey = 'customer_id';
  static const String _customerNameKey = 'customer_name';
  static const String _customerEmailKey = 'customer_email';
  static const String _customerPhoneKey = 'customer_phone';
  static const String _isAuthenticatedKey = 'is_authenticated';
  static const String _anonymousSessionIdsKey = 'anonymous_session_ids';
  static const String _anonymousSessionCategoryMapKey = 'anonymous_session_category_map';

  // Auth Token Methods
  static Future<void> setAuthToken(String token) async {
    await prefs.setString(_authTokenKey, token);
    await prefs.setBool(_isAuthenticatedKey, true);
  }

  static String? getAuthToken() {
    return prefs.getString(_authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    await prefs.remove(_authTokenKey);
    await prefs.setBool(_isAuthenticatedKey, false);
  }

  // Customer Data Methods
  static Future<void> setCustomerData({
    required String id,
    String? name,
    String? email,
    required String phone,
  }) async {
    await prefs.setString(_customerIdKey, id);
    await prefs.setString(_customerPhoneKey, phone);
    
    if (name != null) {
      await prefs.setString(_customerNameKey, name);
    } else {
      await prefs.remove(_customerNameKey);
    }
    
    if (email != null) {
      await prefs.setString(_customerEmailKey, email);
    } else {
      await prefs.remove(_customerEmailKey);
    }
  }

  static String? getCustomerId() {
    return prefs.getString(_customerIdKey);
  }

  static String? getCustomerName() {
    return prefs.getString(_customerNameKey);
  }

  static String? getCustomerEmail() {
    return prefs.getString(_customerEmailKey);
  }

  static String? getCustomerPhone() {
    return prefs.getString(_customerPhoneKey);
  }

  // Authentication Status
  static bool get isAuthenticated {
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  static Future<void> setAuthenticated(bool value) async {
    await prefs.setBool(_isAuthenticatedKey, value);
  }

  // Clear All Authentication Data
  static Future<void> clearAllAuthData() async {
    await prefs.remove(_authTokenKey);
    await prefs.remove(_customerIdKey);
    await prefs.remove(_customerNameKey);
    await prefs.remove(_customerEmailKey);
    await prefs.remove(_customerPhoneKey);
    await prefs.setBool(_isAuthenticatedKey, false);
  }

  // Check if we have complete auth data
  static bool get hasValidAuthData {
    final token = getAuthToken();
    final customerId = getCustomerId();
    final phone = getCustomerPhone();
    
    return token != null && 
           token.isNotEmpty && 
           customerId != null && 
           customerId.isNotEmpty &&
           phone != null && 
           phone.isNotEmpty;
  }

  // Anonymous Session IDs Management (Legacy - for backward compatibility)
  static Future<void> addAnonymousSessionId(String sessionId) async {
    final List<String> currentIds = getAnonymousSessionIds();
    if (!currentIds.contains(sessionId)) {
      currentIds.add(sessionId);
      await prefs.setStringList(_anonymousSessionIdsKey, currentIds);
    }

    smPrint('Anonymous Session IDs: $currentIds');
  }

  static List<String> getAnonymousSessionIds() {
    return prefs.getStringList(_anonymousSessionIdsKey) ?? [];
  }

  static Future<void> clearAnonymousSessionIds() async {
    await prefs.remove(_anonymousSessionIdsKey);
  }

  static Future<void> removeAnonymousSessionId(String sessionId) async {
    final List<String> currentIds = getAnonymousSessionIds();
    currentIds.remove(sessionId);
    await prefs.setStringList(_anonymousSessionIdsKey, currentIds);
  }

  static bool hasAnonymousSessionIds() {
    return getAnonymousSessionIds().isNotEmpty;
  }

  // Anonymous Session-Category Mapping Management (Array-based with Full History)

  /// Migrate old format to new array-based format if needed
  static Future<void> _migrateOldFormatIfNeeded() async {
    final String? jsonString = prefs.getString(_anonymousSessionCategoryMapKey);
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final decoded = json.decode(jsonString);

      // Check if old format (Map<String, String>)
      if (decoded is Map && decoded.isNotEmpty) {
        final firstValue = decoded.values.first;

        if (firstValue is String) {
          // Old format detected - migrate to new array format
          smPrint('Migrating ${decoded.length} sessions from old format to new array format');
          final migratedData = <String, List<Map<String, dynamic>>>{};

          decoded.forEach((categoryId, sessionId) {
            migratedData[categoryId] = [
              AnonymousSessionData.active(
                sessionId: sessionId,
                categoryId: int.parse(categoryId),
              ).toJson(),
            ];
          });

          await prefs.setString(_anonymousSessionCategoryMapKey, json.encode(migratedData));
          smPrint('Migration completed successfully');
        }
      }
    } catch (e) {
      smPrint('Migration error (ignoring): $e');
    }
  }

  /// Add an anonymous session with its associated category ID
  /// Appends to the session history for this category
  static Future<void> addAnonymousSessionWithCategory({
    required String sessionId,
    required int categoryId,
  }) async {
    // Ensure migration happens first
    await _migrateOldFormatIfNeeded();

    final sessionData = AnonymousSessionData.active(
      sessionId: sessionId,
      categoryId: categoryId,
    );

    await addSessionForCategory(sessionData);

    // Also add to legacy list for backward compatibility with assignAnonymousSession
    await addAnonymousSessionId(sessionId);

    smPrint('Added session $sessionId for category $categoryId');
  }

  /// Add a session to the history array for a specific category
  static Future<void> addSessionForCategory(AnonymousSessionData sessionData) async {
    final allSessions = _getAllSessionsMap();
    final categoryKey = sessionData.categoryId.toString();

    if (!allSessions.containsKey(categoryKey)) {
      allSessions[categoryKey] = [];
    }

    // Add new session to the array
    allSessions[categoryKey]!.add(sessionData.toJson());

    await _saveAllSessionsMap(allSessions);
    smPrint('Session history for category ${sessionData.categoryId}: ${allSessions[categoryKey]!.length} sessions');
  }

  /// Get all sessions for a specific category, sorted by creation time (newest first)
  static List<AnonymousSessionData> getSessionsForCategory(int categoryId) {
    _migrateOldFormatIfNeeded(); // Non-blocking migration check

    final allSessions = _getAllSessionsMap();
    final categoryKey = categoryId.toString();

    if (!allSessions.containsKey(categoryKey)) {
      return [];
    }

    try {
      final sessions = (allSessions[categoryKey] as List)
          .map((json) => AnonymousSessionData.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by createdAt descending (newest first)
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return sessions;
    } catch (e) {
      smPrint('Error parsing sessions for category $categoryId: $e');
      return [];
    }
  }

  /// Get the most recent active session for a category
  /// Returns null if no active session exists
  static AnonymousSessionData? getMostRecentActiveSession(int categoryId) {
    final sessions = getSessionsForCategory(categoryId);

    // Find first active session (already sorted newest first)
    try {
      return sessions.firstWhere((s) => s.isActive);
    } catch (e) {
      return null;
    }
  }

  /// Get the most recent session for a category (any status)
  /// Returns null if no session exists
  static AnonymousSessionData? getMostRecentSession(int categoryId) {
    final sessions = getSessionsForCategory(categoryId);
    return sessions.isEmpty ? null : sessions.first;
  }

  /// Update the status of a specific session
  static Future<void> updateSessionStatus(int categoryId, String sessionId, String newStatus) async {
    final allSessions = _getAllSessionsMap();
    final categoryKey = categoryId.toString();

    if (!allSessions.containsKey(categoryKey)) {
      smPrint('No sessions found for category $categoryId');
      return;
    }

    final sessions = (allSessions[categoryKey] as List).cast<Map<String, dynamic>>();
    bool updated = false;

    for (var i = 0; i < sessions.length; i++) {
      if (sessions[i]['sessionId'] == sessionId) {
        sessions[i]['status'] = newStatus;
        updated = true;
        smPrint('Updated session $sessionId status to $newStatus');
        break;
      }
    }

    if (updated) {
      allSessions[categoryKey] = sessions;
      await _saveAllSessionsMap(allSessions);
    } else {
      smPrint('Session $sessionId not found in category $categoryId');
    }
  }

  /// Get all sessions map from storage
  static Map<String, List<dynamic>> _getAllSessionsMap() {
    final String? jsonString = prefs.getString(_anonymousSessionCategoryMapKey);
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    try {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as List<dynamic>));
    } catch (e) {
      smPrint('Error decoding sessions map: $e');
      return {};
    }
  }

  /// Save all sessions map to storage
  static Future<void> _saveAllSessionsMap(Map<String, List<dynamic>> map) async {
    final String jsonString = json.encode(map);
    await prefs.setString(_anonymousSessionCategoryMapKey, jsonString);
  }

  /// Get the session ID for a specific category (backward compatibility)
  /// Returns the most recent active session ID, or null if none exists
  static String? getAnonymousSessionIdForCategory(int categoryId) {
    final session = getMostRecentActiveSession(categoryId);
    return session?.sessionId;
  }

  /// Check if an anonymous session exists for a specific category (backward compatibility)
  static bool hasAnonymousSessionForCategory(int categoryId) {
    return getMostRecentActiveSession(categoryId) != null;
  }

  /// Get all anonymous session-category mappings (backward compatibility)
  /// Returns a Map<categoryId, sessionId> with most recent active sessions
  static Map<String, String> getAnonymousSessionCategoryMap() {
    final allSessions = _getAllSessionsMap();
    final result = <String, String>{};

    allSessions.forEach((categoryId, sessionsList) {
      final sessions = getSessionsForCategory(int.parse(categoryId));
      final activeSession = sessions.firstWhere((s) => s.isActive, orElse: () => sessions.first);
      result[categoryId] = activeSession.sessionId;
    });

    return result;
  }

  /// Remove a specific category's session mapping (backward compatibility)
  static Future<void> removeAnonymousSessionForCategory(int categoryId) async {
    final allSessions = _getAllSessionsMap();
    final categoryKey = categoryId.toString();

    if (allSessions.containsKey(categoryKey)) {
      // Get all session IDs before removing
      final sessions = getSessionsForCategory(categoryId);
      final sessionIds = sessions.map((s) => s.sessionId).toSet();

      // Remove from map
      allSessions.remove(categoryKey);
      await _saveAllSessionsMap(allSessions);

      // Also remove from legacy list if no other categories use these sessions
      final remainingSessionIds = getAllAnonymousSessionIdsFromMap();
      for (final sessionId in sessionIds) {
        if (!remainingSessionIds.contains(sessionId)) {
          await removeAnonymousSessionId(sessionId);
        }
      }

      smPrint('Removed all sessions for category $categoryId');
    }
  }

  /// Clear all anonymous session-category mappings
  static Future<void> clearAnonymousSessionCategoryMap() async {
    await prefs.remove(_anonymousSessionCategoryMapKey);
    await clearAnonymousSessionIds(); // Also clear legacy list
    smPrint('Cleared all anonymous session mappings');
  }

  /// Get all unique session IDs from the category map (backward compatibility)
  static List<String> getAllAnonymousSessionIdsFromMap() {
    final allSessions = _getAllSessionsMap();
    final sessionIds = <String>{};

    allSessions.forEach((categoryId, sessionsList) {
      final sessions = getSessionsForCategory(int.parse(categoryId));
      sessionIds.addAll(sessions.map((s) => s.sessionId));
    });

    return sessionIds.toList();
  }
}
