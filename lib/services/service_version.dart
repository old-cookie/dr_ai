import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

// ServiceVersion class handles version checking for the application.
// It fetches the latest version from GitHub and compares it with the current version.
class ServiceVersion {
  static final ServiceVersion _instance = ServiceVersion._internal();
  factory ServiceVersion() => _instance;
  ServiceVersion._internal();

  // Cached GitHub version to avoid frequent API calls.
  String? _cachedGitHubVersion;
  // Timestamp of the last GitHub version fetch.
  DateTime? _lastFetchTime;
  // Duration for which the cached version is considered valid.
  static const _cacheValidityDuration = Duration(minutes: 30);

  // Fetches the latest release version tag from the GitHub repository.
  // Caches the result for a defined duration to minimize API calls.
  Future<String?> getLatestGitHubVersion() async {
    // Return cached version if it's still valid
    if (_cachedGitHubVersion != null && _lastFetchTime != null) {
      final age = DateTime.now().difference(_lastFetchTime!);
      if (age < _cacheValidityDuration) {
        return _cachedGitHubVersion;
      }
    }
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/old-cookie/dr_ai/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String? tagName = data['tag_name'] as String?;
        if (tagName != null) {
          _cachedGitHubVersion = tagName;
          _lastFetchTime = DateTime.now();
          return _cachedGitHubVersion;
        }
      }
      // Return null if fetching or parsing fails.
      return null;
    } catch (e) {
      // Return null in case of any exception.
      return null;
    }
  }

  // Retrieves the current version of the application from package_info.
  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return 'v${packageInfo.version}';
  }

  // Compares two version strings (e.g., "v1.0.0+1" and "1.0.1") to determine if the current version is up-to-date.
  // Handles 'v' prefix and build numbers (e.g., +1).
  bool isVersionUpToDate(String currentVersion, String latestVersion) {
    // Remove 'v' prefix if present
    currentVersion = currentVersion.startsWith('v') ? currentVersion.substring(1) : currentVersion;
    latestVersion = latestVersion.startsWith('v') ? latestVersion.substring(1) : latestVersion;
    final currentParts = currentVersion.split('+');
    final latestParts = latestVersion.split('+');
    final currentVersionNums = currentParts[0].split('.');
    final latestVersionNums = latestParts[0].split('.');
    for (var i = 0; i < 3; i++) {
      final current = int.parse(currentVersionNums[i]);
      final latest = int.parse(latestVersionNums[i]);
      if (current > latest) return true;
      if (current < latest) return false;
    }
    if (currentParts.length > 1 && latestParts.length > 1) {
      return int.parse(currentParts[1]) >= int.parse(latestParts[1]);
    }
    return true;
  }
}
