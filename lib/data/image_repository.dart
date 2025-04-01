import 'dart:async';
import 'dart:math';
import 'package:sr_demo/data/image_service.dart';
import 'package:sr_demo/models/image_model.dart';

/// Exception thrown when there's an error toggling the like status.
class LikeOperationException implements Exception {
  final String message;
  
  /// Creates a new LikeOperationException with the given message.
  LikeOperationException(this.message);
  
  @override
  String toString() => 'LikeOperationException: $message';
}

/// Repository that manages image data from the API and the collection of liked images.
class ImageRepository {
  final ImageService _imageService;
  final Set<String> _likedImageIds = <String>{};
  List<ImageModel> _cachedImages = [];
  final Random _random = Random();
  
  /// Creates a new ImageRepository with the given image service.
  /// 
  /// If no service is provided, a new one will be created.
  ImageRepository({ImageService? imageService}) 
      : _imageService = imageService ?? ImageService();
  
  /// Fetches images from the API and updates the cached images.
  /// 
  /// Returns a list of [ImageModel] objects with their liked status correctly set.
  Future<List<ImageModel>> fetchImages({
    int page = 1, 
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) {
      _cachedImages = [];
    }
    
    if (_cachedImages.isEmpty) {
      final images = await _imageService.fetchImages(page: page, limit: limit);
      // Update with liked status
      _cachedImages = images.map((image) {
        final isLiked = _likedImageIds.contains(image.id);
        return isLiked ? image.copyWithLiked(true) : image;
      }).toList();
    }
    
    return _cachedImages;
  }
  
  /// Toggles the liked status of an image with a simulated server delay.
  /// 
  /// Has a 30% chance of failing to simulate network errors.
  /// 
  /// Returns the updated image if successful.
  /// 
  /// Throws [LikeOperationException] if the operation fails.
  Future<ImageModel> toggleLikeStatusAsync(ImageModel image) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Randomly fail 30% of the time
    if (_random.nextDouble() < 0.3) {
      throw LikeOperationException('Failed to update like status: Network error');
    }
    
    final isCurrentlyLiked = _likedImageIds.contains(image.id);
    
    // Toggle the liked status
    if (isCurrentlyLiked) {
      _likedImageIds.remove(image.id);
    } else {
      _likedImageIds.add(image.id);
    }
    
    // Update the cached image
    final newLikedStatus = !isCurrentlyLiked;
    final updatedImage = image.copyWithLiked(newLikedStatus);
    
    _updateCachedImage(updatedImage);
    
    return updatedImage;
  }
  
  /// Immediately toggles the like status without delay or failure chance.
  /// Used for tests and fallback.
  ImageModel toggleLikeStatus(ImageModel image) {
    final isCurrentlyLiked = _likedImageIds.contains(image.id);
    
    // Toggle the liked status
    if (isCurrentlyLiked) {
      _likedImageIds.remove(image.id);
    } else {
      _likedImageIds.add(image.id);
    }
    
    // Update the cached image
    final newLikedStatus = !isCurrentlyLiked;
    final updatedImage = image.copyWithLiked(newLikedStatus);
    
    _updateCachedImage(updatedImage);
    
    return updatedImage;
  }
  
  /// Returns all the images that have been liked.
  List<ImageModel> getLikedImages() {
    return _cachedImages.where((image) => _likedImageIds.contains(image.id)).toList();
  }
  
  /// Updates a cached image with a new version.
  void _updateCachedImage(ImageModel updatedImage) {
    final index = _cachedImages.indexWhere((image) => image.id == updatedImage.id);
    if (index != -1) {
      _cachedImages[index] = updatedImage;
    }
  }
  
  /// Cleans up resources when the repository is no longer needed.
  void dispose() {
    _imageService.dispose();
  }
} 