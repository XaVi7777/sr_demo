# Image Gallery App

A Flutter application that displays images from a public API and allows users to like and collect their favorite images.

## Features

- View images from the Picsum Photos public API
- Like/unlike images with visual feedback
- View collection of liked images in a separate tab
- Error handling with user-friendly notifications
- Material Design UI with beautiful image cards

## Architecture

The app follows a modern Flutter architecture:

- **BLoC Pattern**: State management using flutter_bloc with SingleResult BLoC for notifications
- **Repository Pattern**: Clean separation of data sources and business logic
- **Clean Architecture**: Clear separation of concerns with models, data sources, business logic, and UI

## Project Structure

- `lib/models/`: Data models
- `lib/data/`: Data sources and repositories
- `lib/blocs/`: BLoC classes for state management
- `lib/screens/`: UI screens
- `lib/widgets/`: Reusable UI components
- `lib/utils/`: Utility classes
- `lib/config/`: Configuration constants
- `lib/sr_bloc/`: SingleResult BLoC implementation for notifications

## Getting Started

### Prerequisites

- Flutter SDK (^3.5.4)
- Dart SDK (^3.0.0)

### Installation

1. Clone the repository
```
git clone https://github.com/yourusername/image_gallery.git
```

2. Navigate to the project directory
```
cd image_gallery
```

3. Install dependencies
```
flutter pub get
```

4. Run the app
```
flutter run
```

## Testing

The app includes comprehensive test coverage:

### Unit Tests
```
flutter test
```

### Widget Tests
```
flutter test test/widgets/
```

### Integration Tests
```
flutter test integration_test/
```

## Dependencies

- flutter_bloc: ^8.1.4 - State management
- equatable: ^2.0.5 - Value equality
- http: ^1.2.0 - API requests
- cached_network_image: ^3.3.1 - Image caching
- flutter_staggered_grid_view: ^0.7.0 - Grid layout
- fluttertoast: ^8.2.4 - Toast notifications

## License

This project is licensed under the MIT License - see the LICENSE file for details.
