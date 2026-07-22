import 'dart:convert';
import 'package:kingdom_heir/core/logging/structured_logger.dart';
import 'package:kingdom_heir/core/storage/cache_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheEntry {
  const CacheEntry({
    required this.payload,
    required this.createdAt,
    required this.expiresAt,
    required this.schemaVersion,
    required this.source,
  });

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      payload: json['payload'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      schemaVersion: json['schemaVersion'] as int,
      source: json['source'] as String? ?? 'unknown',
    );
  }

  final dynamic payload;
  final DateTime createdAt;
  final DateTime? expiresAt; // null means no TTL expiration
  final int schemaVersion;
  final String source;

  Map<String, dynamic> toJson() => {
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'schemaVersion': schemaVersion,
        'source': source,
      };
}

/// The centralized, single source of truth for all caching logic.
/// Enforces TTL, schema versioning, and cache invalidation.
class CacheManager {
  CacheManager(this._prefs);

  final SharedPreferences _prefs;

  // The current schema version of the cache.
  // Must be incremented whenever the underlying JSON structures of the app change
  // to ensure stale caches are completely wiped across app upgrades.
  static const int currentSchemaVersion = 2;

  /// Performs schema migration on bootstrap.
  /// If the stored schema version does not match [currentSchemaVersion],
  /// the entire cache is cleared and the new version is persisted.
  Future<void> initializeAndMigrate() async {
    final storedVersion = _prefs.getInt(CacheKeys.schemaVersionKey);

    if (storedVersion != currentSchemaVersion) {
      StructuredLogger.logEvent({
        'event': 'schema_migration',
        'old_version': storedVersion,
        'new_version': currentSchemaVersion,
      });

      // Completely clear SharedPreferences
      await _prefs.clear();

      // Persist the new schema version
      await _prefs.setInt(CacheKeys.schemaVersionKey, currentSchemaVersion);
    }
  }

  /// Writes a cache entry with metadata.
  Future<void> write({
    required String key,
    required dynamic payload,
    required String feature,
    required String repository,
    Duration? ttl,
  }) async {
    final now = DateTime.now();
    final entry = CacheEntry(
      payload: payload,
      createdAt: now,
      expiresAt: ttl != null ? now.add(ttl) : null,
      schemaVersion: currentSchemaVersion,
      source: repository,
    );

    await _prefs.setString(key, jsonEncode(entry.toJson()));

    StructuredLogger.cacheWrite(
      feature: feature,
      repository: repository,
    );
  }

  /// Reads a cache entry.
  /// Returns null if the entry does not exist, has expired, or is an old schema version.
  dynamic read({
    required String key,
    required String feature,
    required String repository,
  }) {
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) {
      StructuredLogger.cacheMiss(feature: feature, repository: repository);
      return null;
    }

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      // If it doesn't have the CacheEntry structure, it's likely legacy.
      if (!json.containsKey('schemaVersion')) {
        _prefs.remove(key);
        StructuredLogger.cacheMiss(feature: feature, repository: repository);
        return null;
      }

      final entry = CacheEntry.fromJson(json);

      // Check schema version
      if (entry.schemaVersion != currentSchemaVersion) {
        _prefs.remove(key);
        StructuredLogger.cacheMiss(feature: feature, repository: repository);
        return null;
      }

      // Check expiration
      if (isExpired(entry)) {
        _prefs.remove(key);
        StructuredLogger.cacheMiss(feature: feature, repository: repository);
        return null;
      }

      final age = DateTime.now().difference(entry.createdAt);
      StructuredLogger.cacheHit(
        feature: feature,
        repository: repository,
        cacheAge: '${age.inMinutes} minutes',
      );

      return entry.payload;
    } catch (_) {
      // Parsing failed for cache entry, remove it
      _prefs.remove(key);
      StructuredLogger.cacheMiss(feature: feature, repository: repository);
      return null;
    }
  }

  bool isExpired(CacheEntry entry) {
    if (entry.expiresAt == null) return false;
    return DateTime.now().isAfter(entry.expiresAt!);
  }

  Future<void> invalidate(String key, {required String feature, required String repository}) async {
    await _prefs.remove(key);
    StructuredLogger.cacheInvalidated(feature: feature, repository: repository, key: key);
  }

  Future<void> invalidateByPrefix(String prefix, {required String feature, required String repository}) async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
    StructuredLogger.cacheInvalidated(feature: feature, repository: repository);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
    await _prefs.setInt(CacheKeys.schemaVersionKey, currentSchemaVersion);
  }
}
