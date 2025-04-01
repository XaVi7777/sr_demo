import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sr_demo/models/image_model.dart';
import 'package:sr_demo/widgets/image_card.dart';

/// Widget that displays a grid of images.
class ImageGrid extends StatelessWidget {
  /// The list of images to display.
  final List<ImageModel> images;
  
  /// Set of image IDs that are currently being processed
  final Set<String> loadingImageIds;
  
  /// Callback for when the like button is tapped on an image.
  final Function(ImageModel) onLikeTapped;
  
  /// Creates a new ImageGrid.
  const ImageGrid({
    required this.images,
    required this.onLikeTapped,
    this.loadingImageIds = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const Center(
        child: Text(
          'No images found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        
        // Calculate aspect ratio based on image dimensions
        final aspectRatio = image.width / image.height;
        
        return SizedBox(
          height: 250 * (aspectRatio > 1 ? 0.7 : 1.2),
          child: ImageCard(
            image: image, 
            onLikeTapped: onLikeTapped,
            isLikeLoading: loadingImageIds.contains(image.id),
          ),
        );
      },
    );
  }
} 