import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sr_demo/models/image_model.dart';
import 'package:sr_demo/widgets/image_card.dart';

// Manual mock class for the callback
class MockLikeCallback {
  bool wasCalled = false;
  ImageModel? lastImage;
  
  void call(ImageModel image) {
    wasCalled = true;
    lastImage = image;
  }
}

void main() {
  late ImageModel testImage;
  late MockLikeCallback mockCallback;
  
  setUp(() {
    testImage = const ImageModel(
      id: '123',
      author: 'Test Author',
      width: 400,
      height: 300,
      url: 'https://test.com/image.jpg',
      downloadUrl: 'https://test.com/image.jpg',
      isLiked: false,
    );
    
    mockCallback = MockLikeCallback();
  });
  
  group('ImageCard Loading State', () {
    testWidgets('shows like button in normal state when not loading', 
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 200,
              child: ImageCard(
                image: testImage,
                onLikeTapped: mockCallback.call,
                isLikeLoading: false,
              ),
            ),
          ),
        ),
      );
      
      // Verify the like button is visible
      final iconFinder = find.byIcon(Icons.favorite_border);
      expect(iconFinder, findsOneWidget);
      
      // Verify the loading indicator is not shown
      final progressIndicatorFinder = find.byType(CircularProgressIndicator);
      expect(progressIndicatorFinder, findsNWidgets(1)); // Only the image placeholder
    });
    
    testWidgets('shows loading indicator when like is in progress', 
        (WidgetTester tester) async {
      // Build the widget with loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 200,
              child: ImageCard(
                image: testImage,
                onLikeTapped: mockCallback.call,
                isLikeLoading: true,
              ),
            ),
          ),
        ),
      );
      
      // Verify the like button is not visible
      final iconFinder = find.byIcon(Icons.favorite_border);
      expect(iconFinder, findsNothing);
      
      // Verify the loading indicator is shown
      final progressIndicatorFinder = find.byType(CircularProgressIndicator);
      expect(progressIndicatorFinder, findsNWidgets(2)); // Image placeholder + like button
    });
    
    testWidgets('disables like button when loading', 
        (WidgetTester tester) async {
      // Build the widget with loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 200,
              child: ImageCard(
                image: testImage,
                onLikeTapped: mockCallback.call,
                isLikeLoading: true,
              ),
            ),
          ),
        ),
      );
      
      // Find the like button
      final buttonFinder = find.byType(InkWell);
      expect(buttonFinder, findsOneWidget);
      
      // Tap the like button (should be disabled)
      await tester.tap(buttonFinder);
      await tester.pump();
      
      // Verify the callback was not called
      expect(mockCallback.wasCalled, false);
    });
    
    testWidgets('enables like button when not loading', 
        (WidgetTester tester) async {
      // Build the widget with normal state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 200,
              child: ImageCard(
                image: testImage,
                onLikeTapped: mockCallback.call,
                isLikeLoading: false,
              ),
            ),
          ),
        ),
      );
      
      // Find the like button
      final buttonFinder = find.byType(InkWell);
      expect(buttonFinder, findsOneWidget);
      
      // Tap the like button (should be enabled)
      await tester.tap(buttonFinder);
      await tester.pump();
      
      // Verify the callback was called
      expect(mockCallback.wasCalled, true);
      expect(mockCallback.lastImage, equals(testImage));
    });
  });
} 