import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sr_demo/blocs/image_bloc.dart';
import 'package:sr_demo/blocs/image_events.dart';
import 'package:sr_demo/blocs/image_states.dart';
import 'package:sr_demo/data/image_repository.dart';
import 'package:sr_demo/data/image_service.dart';
import 'package:sr_demo/models/image_model.dart';

// Generate mocks
@GenerateMocks([ImageRepository])
import 'image_bloc_test.mocks.dart';

void main() {
  late MockImageRepository mockRepository;
  late List<ImageModel> testImages;
  late ImageBloc imageBloc;

  setUp(() {
    mockRepository = MockImageRepository();
    
    // Create test data
    testImages = [
      const ImageModel(
        id: '1',
        author: 'Test Author 1',
        url: 'https://test.com/1',
        downloadUrl: 'https://test.com/download/1',
        width: 100,
        height: 100,
      ),
      const ImageModel(
        id: '2',
        author: 'Test Author 2',
        url: 'https://test.com/2',
        downloadUrl: 'https://test.com/download/2',
        width: 200,
        height: 200,
      ),
    ];

    imageBloc = ImageBloc(repository: mockRepository);
  });

  tearDown(() {
    imageBloc.close();
  });

  group('ImageBloc', () {
    test('initial state should be ImageLoadingState', () {
      // Arrange
      expect(imageBloc.state, isA<ImageLoadingState>());
    });

    group('LoadImagesEvent', () {
      test('emits loading then loaded states', () async {
        when(mockRepository.fetchImages(page: 1, limit: 10, refresh: false))
            .thenAnswer((_) async => [testImages[0]]);
        
        expectLater(
          imageBloc.stream,
          emitsInOrder([
            isA<ImageLoadingState>(),
            isA<ImageLoadedState>().having(
              (state) => state.images, 
              'images', 
              [testImages[0]],
            ),
          ]),
        );
        
        imageBloc.add(const LoadImagesEvent());
      });

      blocTest<ImageBloc, ImageState>(
        'emits [ImageLoadingState, ImageLoadedState] when LoadImagesEvent is added',
        build: () {
          when(mockRepository.fetchImages(
            page: anyNamed('page'),
            limit: anyNamed('limit'),
            refresh: anyNamed('refresh'),
          )).thenAnswer((_) async => testImages);
          
          return ImageBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadImagesEvent()),
        expect: () => [
          isA<ImageLoadingState>(),
          isA<ImageLoadedState>().having((state) => state.images, 'images', testImages),
        ],
        verify: (_) {
          verify(mockRepository.fetchImages(
            page: 1,
            limit: 20,
            refresh: false,
          )).called(1);
        },
      );

      blocTest<ImageBloc, ImageState>(
        'emits [ImageLoadingState, ImageErrorState] when repository throws an exception',
        build: () {
          when(mockRepository.fetchImages(
            page: anyNamed('page'),
            limit: anyNamed('limit'),
            refresh: anyNamed('refresh'),
          )).thenThrow(ImageFetchException('Test error'));
          
          return ImageBloc(repository: mockRepository);
        },
        act: (bloc) => bloc.add(const LoadImagesEvent()),
        expect: () => [
          isA<ImageLoadingState>(),
          isA<ImageErrorState>().having((state) => state.message, 'message', 'Test error'),
        ],
        verify: (_) {
          verify(mockRepository.fetchImages(
            page: 1,
            limit: 20,
            refresh: false,
          )).called(1);
        },
      );
    });

    blocTest<ImageBloc, ImageState>(
      'emits correct state when ToggleLikeEvent is added',
      build: () {
        when(mockRepository.toggleLikeStatus(any)).thenReturn(
          testImages[0].copyWithLiked(true),
        );
        
        return ImageBloc(repository: mockRepository);
      },
      seed: () => ImageLoadedState(images: testImages),
      act: (bloc) => bloc.add(ToggleLikeEvent(testImages[0])),
      expect: () => [
        isA<ImageLoadedState>().having(
          (state) => state.images[0].isLiked, 
          'first image liked', 
          true,
        ),
      ],
      verify: (_) {
        verify(mockRepository.toggleLikeStatus(testImages[0])).called(1);
      },
    );

    blocTest<ImageBloc, ImageState>(
      'emits state with only liked images when ViewLikedImagesEvent is added',
      build: () {
        final likedImage = testImages[0].copyWithLiked(true);
        when(mockRepository.getLikedImages()).thenReturn([likedImage]);
        
        return ImageBloc(repository: mockRepository);
      },
      seed: () => ImageLoadedState(images: testImages),
      act: (bloc) => bloc.add(ViewLikedImagesEvent()),
      expect: () => [
        isA<ImageLoadingState>(),
        isA<ImageLoadedState>()
            .having((state) => state.isShowingLiked, 'isShowingLiked', true)
            .having((state) => state.images.length, 'images length', 1)
            .having((state) => state.images[0].isLiked, 'first image liked', true),
      ],
      verify: (_) {
        verify(mockRepository.getLikedImages()).called(1);
      },
    );
  });
} 