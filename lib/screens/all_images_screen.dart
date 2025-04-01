import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sr_demo/blocs/image_bloc.dart';
import 'package:sr_demo/blocs/image_events.dart';
import 'package:sr_demo/blocs/image_states.dart';
import 'package:sr_demo/widgets/image_grid.dart';

/// Screen that displays all images from the API.
class AllImagesScreen extends StatefulWidget {
  /// Creates a new AllImagesScreen.
  const AllImagesScreen({super.key});

  @override
  State<AllImagesScreen> createState() => _AllImagesScreenState();
}

class _AllImagesScreenState extends State<AllImagesScreen> {
  final _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Load images on screen creation
    context.read<ImageBloc>().add(const LoadImagesEvent());
    
    // Set up scroll listener for potential pagination
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ImageBloc>().add(
                const LoadImagesEvent(refresh: true),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImageLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ImageLoadedState) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ImageBloc>().add(
                  const LoadImagesEvent(refresh: true),
                );
              },
              child: ImageGrid(
                images: state.images,
                loadingImageIds: state.loadingImageIds,
                onLikeTapped: (image) {
                  context.read<ImageBloc>().add(ToggleLikeEvent(image));
                },
              ),
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
                      context.read<ImageBloc>().add(const LoadImagesEvent());
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          // Default state (shouldn't reach here)
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  /// Handles scroll events for potential pagination implementation.
  void _onScroll() {
    if (_isBottom) {
      // Load next page when scrolled to bottom
    }
  }
  
  /// Checks if the scroll position is at the bottom.
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
} 