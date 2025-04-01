import 'package:equatable/equatable.dart';

/// Model class representing an image from the API.
/// 
/// Contains information about the image including ID, author, URL, dimensions,
/// and a liked status flag.
class ImageModel extends Equatable {
  /// Unique identifier for the image
  final String id;
  
  /// Author of the image
  final String author;
  
  /// URL where the image can be accessed
  final String url;
  
  /// URL for the original, full-size image
  final String downloadUrl;
  
  /// Width of the image in pixels
  final int width;
  
  /// Height of the image in pixels
  final int height;
  
  /// Flag indicating if the image has been liked by the user
  final bool isLiked;

  const ImageModel({
    required this.id,
    required this.author,
    required this.url,
    required this.downloadUrl,
    required this.width,
    required this.height,
    this.isLiked = false,
  });

  /// Creates a new ImageModel with the liked status toggled.
  ImageModel copyWithLiked(bool isLiked) {
    return ImageModel(
      id: id,
      author: author,
      url: url,
      downloadUrl: downloadUrl,
      width: width,
      height: height,
      isLiked: isLiked,
    );
  }

  /// Factory constructor to create an ImageModel from a JSON map.
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      author: json['author'],
      url: json['url'],
      downloadUrl: json['download_url'],
      width: json['width'],
      height: json['height'],
    );
  }

  /// Converts this ImageModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'url': url,
      'download_url': downloadUrl,
      'width': width,
      'height': height,
      'isLiked': isLiked,
    };
  }

  @override
  List<Object?> get props => [id, author, url, downloadUrl, width, height, isLiked];
} 