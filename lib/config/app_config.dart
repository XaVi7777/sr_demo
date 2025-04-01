/// Application configuration constants
class AppConfig {
  /// Base URL for the Picsum Photos API
  static const String apiBaseUrl = 'https://picsum.photos';
  
  /// Endpoint for retrieving a list of images
  static const String imagesEndpoint = '/v2/list';
  
  /// Default page size for image pagination
  static const int defaultPageSize = 20;
  
  /// Default page number to start with
  static const int defaultPage = 1;
} 