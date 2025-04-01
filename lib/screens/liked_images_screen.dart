import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sr_demo/blocs/image_bloc.dart';
import 'package:sr_demo/blocs/image_events.dart';
import 'package:sr_demo/blocs/image_states.dart';
import 'package:sr_demo/widgets/image_grid.dart';

/// Screen that displays the collection of liked images.
class LikedImagesScreen extends StatefulWidget {
  /// Creates a new LikedImagesScreen.
  const LikedImagesScreen({super.key});

  @override
  State<LikedImagesScreen> createState() => _LikedImagesScreenState();
}

class _LikedImagesScreenState extends State<LikedImagesScreen> {
  @override
  void initState() {
    super.initState();
    // Load liked images when the screen is created
    context.read<ImageBloc>().add(ViewLikedImagesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Images'),
      ),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImageLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ImageLoadedState && state.isShowingLiked) {
            if (state.images.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: Colors.grey,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No liked images yet',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your liked images will appear here',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Switch to the All Images tab
                        context.read<ImageBloc>().add(ViewAllImagesEvent());
                        // Navigate to the first tab (All Images)
                        // Note: This is handled by the HomeScreen
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Browse Images'),
                    ),
                  ],
                ),
              );
            }
            
            return ImageGrid(
              images: state.images,
              loadingImageIds: state.loadingImageIds,
              onLikeTapped: (image) {
                context.read<ImageBloc>().add(ToggleLikeEvent(image));
              },
            );
          } else if (state is ImageErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ImageBloc>().add(ViewLikedImagesEvent());
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          // Default state or wrong state
          return const SizedBox.shrink();
        },
      ),
    );
  }
} 