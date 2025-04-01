import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sr_demo/models/image_model.dart';

/// Widget that displays an image as a card with a like button.
class ImageCard extends StatefulWidget {
  /// The image to display.
  final ImageModel image;
  
  /// Whether the like operation is currently in progress
  final bool isLikeLoading;
  
  /// Callback for when the like button is tapped.
  final Function(ImageModel) onLikeTapped;
  
  /// Creates a new ImageCard.
  const ImageCard({
    super.key,
    required this.image,
    required this.onLikeTapped,
    this.isLikeLoading = false,
  });

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _sizeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_animationController);
    
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.5),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.0),
        weight: 90,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(ImageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the liked status changed, animate the heart button
    if (oldWidget.image.isLiked != widget.image.isLiked) {
      _animateHeartButton();
    }
  }
  
  void _animateHeartButton() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                Hero(
                  tag: 'image_${widget.image.id}',
                  child: CachedNetworkImage(
                    imageUrl: widget.image.downloadUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                
                // Like button overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildLikeButton(),
                ),
              ],
            ),
          ),
          
          // Author info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By ${widget.image.author}',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.image.id}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Builds the like button with appropriate styling based on the liked state.
  Widget _buildLikeButton() {
    return Material(
      color: Colors.white.withOpacity(0.7),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.isLikeLoading 
            ? null // Disable the button while loading
            : () => widget.onLikeTapped(widget.image),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _sizeAnimation.value,
                  child: child,
                ),
              );
            },
            child: widget.isLikeLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                : Icon(
                    widget.image.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.image.isLiked ? Colors.red : Colors.grey,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
} 