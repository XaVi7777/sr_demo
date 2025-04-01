import 'package:equatable/equatable.dart';
import 'package:sr_demo/models/image_model.dart';

/// Base class for all single result events in the image BLoC.
abstract class ImageSingleResult extends Equatable {
  const ImageSingleResult();
  
  @override
  List<Object?> get props => [];
}

/// SingleResult for when an image is liked.
class ImageLikedResult extends ImageSingleResult {
  /// The image that was liked.
  final ImageModel image;
  
  const ImageLikedResult(this.image);
  
  @override
  List<Object?> get props => [image];
}

/// SingleResult for when an image is unliked.
class ImageUnlikedResult extends ImageSingleResult {
  /// The image that was unliked.
  final ImageModel image;
  
  const ImageUnlikedResult(this.image);
  
  @override
  List<Object?> get props => [image];
}

/// SingleResult for error notifications.
class ErrorNotificationResult extends ImageSingleResult {
  /// The error message.
  final String message;
  
  const ErrorNotificationResult(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// SingleResult for like operation failure.
class LikeOperationFailureResult extends ImageSingleResult {
  /// The image that failed to be liked/unliked.
  final ImageModel image;
  
  /// The error message.
  final String message;
  
  const LikeOperationFailureResult({
    required this.image,
    required this.message,
  });
  
  @override
  List<Object?> get props => [image, message];
} 