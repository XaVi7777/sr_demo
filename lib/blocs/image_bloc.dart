import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sr_demo/blocs/image_events.dart';
import 'package:sr_demo/blocs/image_single_results.dart';
import 'package:sr_demo/blocs/image_states.dart';
import 'package:sr_demo/data/image_repository.dart';
import 'package:sr_demo/data/image_service.dart';
import 'package:sr_demo/models/image_model.dart';
import 'package:sr_demo/sr_bloc/sr_bloc.dart';

/// BLoC that manages the image state and handle image-related events.
class ImageBloc extends SrBloc<ImageEvent, ImageState, ImageSingleResult> {
  final ImageRepository _repository;
  
  /// Creates a new ImageBloc with the given repository.
  /// 
  /// If no repository is provided, a new one will be created.
  ImageBloc({ImageRepository? repository}) 
      : _repository = repository ?? ImageRepository(),
        super(ImageLoadingState()) {
    on<LoadImagesEvent>(_onLoadImages);
    on<ToggleLikeEvent>(_onToggleLike);
    on<ViewLikedImagesEvent>(_onViewLikedImages);
    on<ViewAllImagesEvent>(_onViewAllImages);
  }
  
  /// Handles the LoadImagesEvent by fetching images from the repository.
  Future<void> _onLoadImages(
    LoadImagesEvent event, 
    Emitter<ImageState> emit,
  ) async {
    emit(ImageLoadingState());
    
    try {
      final images = await _repository.fetchImages(
        page: event.page,
        limit: event.limit,
        refresh: event.refresh,
      );
      
      emit(ImageLoadedState(images: images));
    } on ImageFetchException catch (e) {
      emit(ImageErrorState(e.message));
      addSr(ErrorNotificationResult(e.message));
    } catch (e) {
      final message = 'An unexpected error occurred: ${e.toString()}';
      emit(ImageErrorState(message));
      addSr(ErrorNotificationResult(message));
    }
  }
  
  /// Handles the ToggleLikeEvent by toggling the liked status of an image.
  Future<void> _onToggleLike(
    ToggleLikeEvent event, 
    Emitter<ImageState> emit,
  ) async {
    if (state is ImageLoadedState) {
      final currentState = state as ImageLoadedState;
      final image = event.image;
      
      // Check if this image is already being processed
      if (currentState.isImageLoading(image.id)) {
        return; // Prevent duplicate operations
      }
      
      // Set the image as loading
      emit(currentState.setImageLoading(image.id));
      
      try {
        // Use the async version that simulates network delay and can fail
        final updatedImage = await _repository.toggleLikeStatusAsync(image);
        
        // Get the current state again as it might have changed during the async operation
        final updatedState = state as ImageLoadedState;
        
        // If the image is now liked, emit a liked result
        if (updatedImage.isLiked) {
          addSr(ImageLikedResult(updatedImage));
        } else {
          addSr(ImageUnlikedResult(updatedImage));
        }
        
        // If we're in the liked view and the image was unliked, we need to remove it
        if (updatedState.isShowingLiked && !updatedImage.isLiked) {
          final updatedImages = List<ImageModel>.from(updatedState.images)
            ..removeWhere((image) => image.id == updatedImage.id);
          
          emit(updatedState
            .copyWith(images: updatedImages)
            .setImageNotLoading(image.id));
        } else {
          // Otherwise just update the image in the list
          final updatedImages = List<ImageModel>.from(updatedState.images);
          final index = updatedImages.indexWhere((img) => img.id == updatedImage.id);
          
          if (index >= 0) {
            updatedImages[index] = updatedImage;
            emit(updatedState
              .copyWith(images: updatedImages)
              .setImageNotLoading(image.id));
          } else {
            // Just remove from loading state if image isn't in the list anymore
            emit(updatedState.setImageNotLoading(image.id));
          }
        }
      } on LikeOperationException catch (e) {
        // For like operation failures, emit a special single result
        // and remove loading state without changing the image
        final currentState = state as ImageLoadedState;
        emit(currentState.setImageNotLoading(image.id));
        
        addSr(LikeOperationFailureResult(
          image: image,
          message: e.message,
        ));
      } catch (e) {
        // Generic error handling
        final currentState = state as ImageLoadedState;
        emit(currentState.setImageNotLoading(image.id));
        
        final message = 'Failed to update like status: ${e.toString()}';
        addSr(ErrorNotificationResult(message));
      }
    }
  }
  
  /// Handles the ViewLikedImagesEvent by switching to show only liked images.
  Future<void> _onViewLikedImages(
    ViewLikedImagesEvent event, 
    Emitter<ImageState> emit,
  ) async {
    if (state is ImageLoadedState) {
      emit(ImageLoadingState());
      
      try {
        final likedImages = _repository.getLikedImages();
        emit(ImageLoadedState(
          images: likedImages,
          isShowingLiked: true,
        ));
      } catch (e) {
        final message = 'Failed to load liked images: ${e.toString()}';
        emit(ImageErrorState(message));
        addSr(ErrorNotificationResult(message));
      }
    }
  }
  
  /// Handles the ViewAllImagesEvent by switching back to showing all images.
  Future<void> _onViewAllImages(
    ViewAllImagesEvent event, 
    Emitter<ImageState> emit,
  ) async {
    if (state is ImageLoadedState) {
      emit(ImageLoadingState());
      
      try {
        final images = await _repository.fetchImages();
        emit(ImageLoadedState(images: images));
      } catch (e) {
        final message = 'Failed to load all images: ${e.toString()}';
        emit(ImageErrorState(message));
        addSr(ErrorNotificationResult(message));
      }
    }
  }
  
  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
} 