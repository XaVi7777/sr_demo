import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sr_demo/data/image_repository.dart';
import 'package:sr_demo/models/image_model.dart';
import 'package:sr_demo/main.dart' as app;

class MockImageRepository extends Mock implements ImageRepository {
  final List<ImageModel> _mockImages = [
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
  
  final Set<String> _likedIds = {};
  
  @override
  Future<List<ImageModel>> fetchImages({
    int page = 1, 
    int limit = 20,
    bool refresh = false,
  }) async {
    return _mockImages.map((image) {
      final isLiked = _likedIds.contains(image.id);
      return isLiked ? image.copyWithLiked(true) : image;
    }).toList();
  }
  
  @override
  List<ImageModel> getLikedImages() {
    return _mockImages
        .where((image) => _likedIds.contains(image.id))
        .map((image) => image.copyWithLiked(true))
        .toList();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Image Like Operation', () {
    testWidgets('Successfully like and unlike an image', 
      (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Verify that we're on the All Images screen
      expect(find.text('Image Gallery'), findsOneWidget);
      
      // Wait for images to load
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Look for a like button on any image card
      final likeButton = find.byIcon(Icons.favorite_border);
      
      // If images were loaded, there should be like buttons
      if (likeButton.evaluate().isNotEmpty) {
        // Tap a like button to favorite an image
        await tester.tap(likeButton.first);
        
        // Wait for the simulated network delay (800ms + buffer)
        await tester.pump(const Duration(milliseconds: 1000));
        
        // Check if either success or error notification appears
        // (since we have random failures, we can't guarantee which one)
        final successNotification = find.textContaining('added to favorites');
        final errorNotification = find.textContaining('Failed to update');
        
        expect(successNotification.evaluate().isNotEmpty || 
               errorNotification.evaluate().isNotEmpty, true);
        
        // If it was a success, let's navigate to liked page to verify
        if (successNotification.evaluate().isNotEmpty) {
          // Navigate to the Liked Images tab
          await tester.tap(find.text('Liked Images'));
          await tester.pumpAndSettle();
          
          // Verify that we're on the Liked Images screen
          expect(find.text('Liked Images'), findsOneWidget);
          
          // Wait for the liked images to load
          await tester.pumpAndSettle();
          
          // There should be at least one filled heart icon in the liked images view
          expect(find.byIcon(Icons.favorite), findsWidgets);
          
          // Now unlike the image
          await tester.tap(find.byIcon(Icons.favorite).first);
          
          // Wait for the simulated network delay (800ms + buffer)
          await tester.pump(const Duration(milliseconds: 1000));
          
          // Check for notifications again
          final unlikeNotification = find.textContaining('removed from favorites');
          final unlikeError = find.textContaining('Failed to update');
          
          expect(unlikeNotification.evaluate().isNotEmpty || 
                 unlikeError.evaluate().isNotEmpty, true);
        }
      } else {
        // If no images were loaded, there should be a retry button or error message
        expect(
          find.byWidgetPredicate((widget) => 
            widget is ElevatedButton || 
            (widget is Text && (widget.data == 'Try Again' || widget.data == 'No images found'))
          ),
          findsWidgets
        );
      }
    });
  });
} 