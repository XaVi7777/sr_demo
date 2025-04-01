import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sr_demo/blocs/image_bloc.dart';
import 'package:sr_demo/blocs/image_events.dart';
import 'package:sr_demo/blocs/image_single_results.dart';
import 'package:sr_demo/blocs/image_states.dart';
import 'package:sr_demo/data/image_repository.dart';
import 'package:sr_demo/models/image_model.dart';

// Generate mocks
@GenerateMocks([ImageRepository])
import 'image_loading_state_test.mocks.dart';

void main() {
  late MockImageRepository mockRepository;
  late ImageBloc imageBloc;
  
  const testImage = ImageModel(
    id: '1', 
    author: 'Test Author',
    width: 100,
    height: 100,
    url: 'https://test.com/test',
    downloadUrl: 'https://test.com/test',
    isLiked: false,
  );
  
  final likedImage = testImage.copyWithLiked(true);
  
  setUp(() {
    mockRepository = MockImageRepository();
    imageBloc = ImageBloc(repository: mockRepository);
    
    // Setup initial state with loaded images
    when(mockRepository.fetchImages(
      page: anyNamed('page'),
      limit: anyNamed('limit'),
      refresh: anyNamed('refresh'),
    )).thenAnswer((_) async => [testImage]);
  });
  
  tearDown(() {
    imageBloc.close();
  });
  
  group('Image Like Loading State', () {
    test('sets loading state during like operation', () async {
      // Load initial images
      imageBloc.add(const LoadImagesEvent());
      
      // Wait for initial state to be loaded
      await expectLater(
        imageBloc.stream,
        emitsThrough(isA<ImageLoadedState>()),
      );
      
      // Setup the like operation with a delay
      when(mockRepository.toggleLikeStatusAsync(testImage))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return likedImage;
          });
      
      // Verify states emitted during the like operation
      expectLater(
        imageBloc.stream,
        emitsInOrder([
          // First state: image is marked as loading
          isA<ImageLoadedState>().having(
            (state) => state.loadingImageIds.contains(testImage.id), 
            'image is loading', 
            true,
          ),
          // Second state: loading is removed, image is updated
          isA<ImageLoadedState>()
            .having(
              (state) => state.loadingImageIds.contains(testImage.id), 
              'image is no longer loading', 
              false,
            )
            .having(
              (state) => state.images.first.isLiked, 
              'image is liked', 
              true,
            ),
        ]),
      );
      
      // Trigger the like operation
      imageBloc.add(const ToggleLikeEvent(testImage));
    });
    
    test('removes loading state when operation fails', () async {
      // Load initial images
      imageBloc.add(const LoadImagesEvent());
      
      // Wait for initial state to be loaded
      await expectLater(
        imageBloc.stream,
        emitsThrough(isA<ImageLoadedState>()),
      );
      
      // Setup the like operation to fail
      when(mockRepository.toggleLikeStatusAsync(testImage))
          .thenThrow(LikeOperationException('Failed to like image'));
      
      // Verify states emitted during the failed like operation
      expectLater(
        imageBloc.stream,
        emitsInOrder([
          // First state: image is marked as loading
          isA<ImageLoadedState>().having(
            (state) => state.loadingImageIds.contains(testImage.id), 
            'image is loading', 
            true,
          ),
          // Second state: loading is removed, image remains unchanged
          isA<ImageLoadedState>()
            .having(
              (state) => state.loadingImageIds.contains(testImage.id), 
              'image is no longer loading', 
              false,
            )
            .having(
              (state) => state.images.first.isLiked, 
              'image is still not liked', 
              false,
            ),
        ]),
      );
      
      // Verify that a failure result is emitted
      expectLater(
        imageBloc.singleResults,
        emits(isA<LikeOperationFailureResult>()),
      );
      
      // Trigger the like operation
      imageBloc.add(const ToggleLikeEvent(testImage));
    });
    
    test('prevents duplicate like operations for the same image', () async {
      // Load initial images
      imageBloc.add(const LoadImagesEvent());
      
      // Wait for initial state to be loaded
      await expectLater(
        imageBloc.stream,
        emitsThrough(isA<ImageLoadedState>()),
      );
      
      // Setup the like operation with a longer delay
      when(mockRepository.toggleLikeStatusAsync(testImage))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 500));
            return likedImage;
          });
      
      // Verify only one loading state change is emitted
      expectLater(
        imageBloc.stream,
        emitsInOrder([
          // First state: image is marked as loading
          isA<ImageLoadedState>().having(
            (state) => state.loadingImageIds.contains(testImage.id), 
            'image is loading', 
            true,
          ),
          // Final state: loading is removed, image is updated
          isA<ImageLoadedState>()
            .having(
              (state) => state.loadingImageIds.contains(testImage.id), 
              'image is no longer loading', 
              false,
            )
            .having(
              (state) => state.images.first.isLiked, 
              'image is liked', 
              true,
            ),
        ]),
      );
      
      // Trigger the first like operation
      imageBloc.add(const ToggleLikeEvent(testImage));
      
      // Immediately trigger a second like operation on the same image
      // This should be ignored because the first operation is still in progress
      await Future.delayed(const Duration(milliseconds: 50));
      imageBloc.add(const ToggleLikeEvent(testImage));
      
      // Verify that repository was called only once
      await Future.delayed(const Duration(milliseconds: 600));
      verify(mockRepository.toggleLikeStatusAsync(testImage)).called(1);
    });
  });
} 