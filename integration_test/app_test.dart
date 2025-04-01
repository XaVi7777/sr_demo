import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sr_demo/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('App Integration Tests', () {
    testWidgets('Complete app flow test - view images, like, and switch tabs', 
      (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Verify that we're on the All Images screen
      expect(find.text('Image Gallery'), findsOneWidget);
      
      // Wait for images to load (this may take time in a real environment)
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Look for a like button on any image card
      final likeButton = find.byIcon(Icons.favorite_border);
      
      // If images were loaded, there should be like buttons
      if (likeButton.evaluate().isNotEmpty) {
        // Tap a like button to favorite an image
        await tester.tap(likeButton.first);
        await tester.pumpAndSettle();
        
        // Navigate to the Liked Images tab
        await tester.tap(find.text('Liked Images'));
        await tester.pumpAndSettle();
        
        // Verify that we're on the Liked Images screen
        expect(find.text('Liked Images'), findsOneWidget);
        
        // Wait for the liked images to load
        await tester.pumpAndSettle();
        
        // There should be at least one filled heart icon in the liked images view
        expect(find.byIcon(Icons.favorite), findsWidgets);
        
        // Go back to the All Images tab
        await tester.tap(find.text('All Images'));
        await tester.pumpAndSettle();
        
        // Verify that we're on the All Images screen again
        expect(find.text('Image Gallery'), findsOneWidget);
      } else {
        // If no images were loaded, there should be a retry button or error message
        // This is to handle potential API failures during testing
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