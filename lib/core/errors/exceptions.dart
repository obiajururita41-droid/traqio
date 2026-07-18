/// Thrown at the data layer (datasources), caught in repositories,
/// and converted into Failures before reaching domain/presentation.
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error occurred.']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication error occurred.']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error occurred.']);
}
