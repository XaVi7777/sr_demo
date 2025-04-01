import 'package:equatable/equatable.dart';
import 'package:sr_demo/models/image_model.dart';

/// Base class for all image-related states.
abstract class ImageState extends Equatable {
  const ImageState();
  
  @override
  List<Object?> get props => [];
}

/// State when images are being loaded.
class ImageLoadingState extends ImageState {}

/// State when images have been successfully loaded.
class ImageLoadedState extends ImageState {
  /// The list of images currently displayed.
  final List<ImageModel> images;
  
  /// Whether this is showing all images (false) or only liked images (true).
  final bool isShowingLiked;
  
  /// Set of image IDs that are currently in the process of being liked/unliked.
  final Set<String> loadingImageIds;
  
  const ImageLoadedState({
    required this.images,
    this.isShowingLiked = false,
    this.loadingImageIds = const {},
  });
  
  @override
  List<Object?> get props => [images, isShowingLiked, loadingImageIds];
  
  /// Creates a copy of this state with the given fields replaced.
  ImageLoadedState copyWith({
    List<ImageModel>? images,
    bool? isShowingLiked,
    Set<String>? loadingImageIds,
  }) {
    return ImageLoadedState(
      images: images ?? this.images,
      isShowingLiked: isShowingLiked ?? this.isShowingLiked,
      loadingImageIds: loadingImageIds ?? this.loadingImageIds,
    );
  }
  
  /// Checks if a specific image is currently in loading state.
  bool isImageLoading(String imageId) {
    return loadingImageIds.contains(imageId);
  }
  
  /// Adds an image ID to the loading set.
  ImageLoadedState setImageLoading(String imageId) {
    final updatedLoadingIds = Set<String>.from(loadingImageIds)..add(imageId);
    return copyWith(loadingImageIds: updatedLoadingIds);
  }
  
  /// Removes an image ID from the loading set.
  ImageLoadedState setImageNotLoading(String imageId) {
    final updatedLoadingIds = Set<String>.from(loadingImageIds)..remove(imageId);
    return copyWith(loadingImageIds: updatedLoadingIds);
  }
}

/// State when there's an error loading images.
class ImageErrorState extends ImageState {
  /// The error message.
  final String message;
  
  const ImageErrorState(this.message);
  
  @override
  List<Object?> get props => [message];
} 