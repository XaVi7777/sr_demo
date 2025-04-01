import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sr_demo/config/app_config.dart';
import 'package:sr_demo/models/image_model.dart';

/// Exception thrown when image data cannot be fetched from the API.
class ImageFetchException implements Exception {
  final String message;
  
  /// Creates a new ImageFetchException with the given message.
  ImageFetchException(this.message);
  
  @override
  String toString() => 'ImageFetchException: $message';
}

/// Service responsible for fetching image data from the external API.
class ImageService {
  final http.Client _client;
  
  /// Creates a new ImageService with the given HTTP client.
  /// 
  /// If no client is provided, a new one will be created.
  ImageService({http.Client? client}) : _client = client ?? http.Client();
  
  /// Fetches a list of images from the API.
  /// 
  /// [page] specifies which page of results to fetch (starting from 1).
  /// [limit] specifies how many images to fetch per page.
  /// 
  /// Returns a list of [ImageModel] objects.
  /// 
  /// Throws [ImageFetchException] if the API request fails.
  Future<List<ImageModel>> fetchImages({
    int page = AppConfig.defaultPage,
    int limit = AppConfig.defaultPageSize,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.imagesEndpoint}?page=$page&limit=$limit');
      final response = await _client.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ImageModel.fromJson(json)).toList();
      } else {
        throw ImageFetchException('Failed to load images. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw ImageFetchException('Failed to fetch images: ${e.toString()}');
    }
  }
  
  /// Closes the HTTP client when the service is no longer needed.
  void dispose() {
    _client.close();
  }
} 