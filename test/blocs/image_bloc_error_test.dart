import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sr_demo/blocs/image_bloc.dart';
import 'package:sr_demo/blocs/image_events.dart';
import 'package:sr_demo/blocs/image_single_results.dart';
import 'package:sr_demo/blocs/image_states.dart';
import 'package:sr_demo/data/image_repository.dart';
import 'package:sr_demo/data/image_service.dart';
import 'package:sr_demo/models/image_model.dart';

// Generate mocks
@GenerateMocks([ImageRepository])
import 'image_bloc_error_test.mocks.dart';

void main() {
  late MockImageRepository mockRepository;
  late ImageModel testImage;

  setUp(() {
    mockRepository = MockImageRepository();
    
    // Create test data
    testImage = const ImageModel(
      id: '1',
      author: 'Test Author',
      url: 'https://test.com/1',
      downloadUrl: 'https://test.com/download/1',
      width: 100,
      height: 100,
    );
  });

  group('ImageBloc Error Handling', () {
    blocTest<ImageBloc, ImageState>(
      'emits error state when fetchImages throws ImageFetchException',
      build: () {
        when(mockRepository.fetchImages(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          refresh: anyNamed('refresh'),
        )).thenThrow(ImageFetchException('Test fetch error'));
        
        return ImageBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadImagesEvent()),
      expect: () => [
        isA<ImageLoadingState>(),
        isA<ImageErrorState>().having(
          (state) => state.message, 
          'error message', 
          'Test fetch error'
        ),
      ],
      verify: (_) {
        verify(mockRepository.fetchImages(
          page: 1,
          limit: 20,
          refresh: false,
        )).called(1);
      },
    );

    test('emits LikeOperationFailureResult when toggleLikeStatusAsync throws', () async {
      // Arrange
      when(mockRepository.toggleLikeStatusAsync(any))
          .thenThrow(LikeOperationException('Test like operation error'));
      
      when(mockRepository.fetchImages(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          refresh: anyNamed('refresh'),
      )).thenAnswer((_) async => [testImage]);
      
      final bloc = ImageBloc(repository: mockRepository);
      
      // Load initial state
      bloc.add(const LoadImagesEvent());
      
      // Wait for the state to be loaded
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Set up listener for single results
      LikeOperationFailureResult? capturedResult;
      bloc.singleResults.listen((result) {
        if (result is LikeOperationFailureResult) {
          capturedResult = result;
        }
      });
      
      // Act - toggle like
      bloc.add(ToggleLikeEvent(testImage));
      
      // Wait for the operation to complete
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Assert
      expect(capturedResult, isNotNull);
      expect(capturedResult?.image, equals(testImage));
      expect(capturedResult?.message, equals('Test like operation error'));
      
      // Verify state didn't change due to error (we only show notification)
      expect(bloc.state, isA<ImageLoadedState>());
      
      // Cleanup
      await bloc.close();
    });
  });
} 