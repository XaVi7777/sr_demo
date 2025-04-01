import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sr_demo/blocs/image_bloc.dart';
import 'package:sr_demo/blocs/image_events.dart';
import 'package:sr_demo/blocs/image_single_results.dart';
import 'package:sr_demo/screens/all_images_screen.dart';
import 'package:sr_demo/screens/liked_images_screen.dart';
import 'package:sr_demo/sr_bloc/sr_bloc_builder.dart';
import 'package:sr_demo/utils/notification_util.dart';

/// The main screen of the app with bottom navigation between all images and liked images.
class HomeScreen extends StatefulWidget {
  /// Creates a new HomeScreen.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // List of screens to show based on the selected tab
  final List<Widget> _screens = [
    const AllImagesScreen(),
    const LikedImagesScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return SrBlocBuilder<ImageBloc, dynamic, ImageSingleResult>(
      onSR: _handleSingleResult,
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                label: 'All Images',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Liked Images',
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Handles tab changes in the bottom navigation bar.
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Update the BLoC with the appropriate event based on the selected tab
    if (index == 0) {
      context.read<ImageBloc>().add(ViewAllImagesEvent());
    } else {
      context.read<ImageBloc>().add(ViewLikedImagesEvent());
    }
  }
  
  /// Handles single results from the BLoC (for showing notifications).
  void _handleSingleResult(BuildContext context, ImageSingleResult singleResult) {
    if (singleResult is ImageLikedResult) {
      NotificationUtil.showSuccess(
        'Image by ${singleResult.image.author} added to favorites',
      );
    } else if (singleResult is ImageUnlikedResult) {
      NotificationUtil.showInfo(
        'Image by ${singleResult.image.author} removed from favorites',
      );
    } else if (singleResult is LikeOperationFailureResult) {
      NotificationUtil.showError(
        'Failed to update image by ${singleResult.image.author}: ${singleResult.message}',
      );
    } else if (singleResult is ErrorNotificationResult) {
      NotificationUtil.showError(singleResult.message);
    }
  }
} 