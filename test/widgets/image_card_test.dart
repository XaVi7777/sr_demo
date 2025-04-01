import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sr_demo/models/image_model.dart';
import 'package:sr_demo/widgets/image_card.dart';

void main() {
  const testImage = ImageModel(
    id: '1',
    author: 'Test Author',
    url: 'https://test.com/1',
    downloadUrl: 'https://test.com/download/1',
    width: 100,
    height: 100,
  );

  final likedImage = testImage.copyWithLiked(true);
  
  testWidgets('ImageCard displays image details correctly', (WidgetTester tester) async {
    bool likeTapped = false;
    
    // Build the ImageCard widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageCard(
            image: testImage,
            onLikeTapped: (_) {
              likeTapped = true;
            },
          ),
        ),
      ),
    );
    
    // Verify that image author is displayed
    expect(find.text('By Test Author'), findsOneWidget);
    
    // Verify that image ID is displayed
    expect(find.text('ID: 1'), findsOneWidget);
    
    // Verify that the like button is in the unfilled state
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
    
    // Tap the like button
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();
    
    // Verify the like callback was called
    expect(likeTapped, true);
  });
  
  testWidgets('ImageCard displays liked state correctly', (WidgetTester tester) async {
    // Build the ImageCard widget with a liked image
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImageCard(
            image: likedImage,
            onLikeTapped: (_) {},
          ),
        ),
      ),
    );
    
    // Verify that the like button is in the filled state for a liked image
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });
} 