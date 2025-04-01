import 'package:equatable/equatable.dart';
import 'package:sr_demo/models/image_model.dart';

/// Base class for all image-related events.
abstract class ImageEvent extends Equatable {
  const ImageEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event to request loading images from the API.
class LoadImagesEvent extends ImageEvent {
  /// Page number to load (1-based).
  final int page;
  
  /// Number of items per page.
  final int limit;
  
  /// Whether to force a refresh of the data.
  final bool refresh;
  
  const LoadImagesEvent({
    this.page = 1, 
    this.limit = 20,
    this.refresh = false,
  });
  
  @override
  List<Object?> get props => [page, limit, refresh];
}

/// Event to toggle the liked status of an image.
class ToggleLikeEvent extends ImageEvent {
  /// The image to toggle the liked status for.
  final ImageModel image;
  
  const ToggleLikeEvent(this.image);
  
  @override
  List<Object?> get props => [image];
}

/// Event to view the liked images.
class ViewLikedImagesEvent extends ImageEvent {}

/// Event to go back to all images.
class ViewAllImagesEvent extends ImageEvent {} 