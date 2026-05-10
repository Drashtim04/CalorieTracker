import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/dummy/dummy_foods.dart';
import '../../../../data/models/food_model.dart';

final foodDetectionServiceProvider = Provider<FoodDetectionService>((ref) {
  return FoodDetectionService();
});

class FoodDetectionService {
  final ImagePicker _picker = ImagePicker();
  final _random = Random();

  /// Prompts user to pick an image from the given [source] and mocks AI food detection.
  Future<FoodModel?> detectFood(ImageSource source) async {
    // 1. Capture/pick image
    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    
    if (xFile == null) return null; // User cancelled

    // 2. Simulate AI processing latency
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. Mock detection logic
    // We pick a random food from the dummy database to simulate detection
    final randomIndex = _random.nextInt(DummyFoods.all.length);
    return DummyFoods.all[randomIndex];
  }
}
