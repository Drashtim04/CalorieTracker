import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/ai_food_service.dart';
import '../../domain/models/ai_meal_analysis.dart';
import '../../../../core/utils/image_utils.dart';

final aiFoodServiceProvider = Provider((ref) => AiFoodService());

class AiFoodState {
AiFoodState({
this.selectedImage,
this.analysis,
});

final File? selectedImage;
final AiMealAnalysis? analysis;

AiFoodState copyWith({
File? selectedImage,
AiMealAnalysis? analysis,
}) {
return AiFoodState(
selectedImage: selectedImage ?? this.selectedImage,
analysis: analysis ?? this.analysis,
);
}
}

class AiFoodNotifier extends AutoDisposeAsyncNotifier<AiFoodState> {
  // Guard to prevent concurrent analysis requests.
  bool _isProcessing = false;
  // Track the last analyzed path to prevent redundant scans of the same file.
  String? _lastAnalyzedPath;
  // Simple timestamp for debouncing UI interactions.
  DateTime? _lastInteractionTime;

  @override
  FutureOr<AiFoodState> build() {
    // Ensure we reset guards when the provider is re-initialized.
    _isProcessing = false;
    _lastAnalyzedPath = null;
    return AiFoodState();
  }

  Future<void> pickAndDetectImage(ImageSource source) async {
    // 1. Interaction Debounce: Prevent rapid taps from firing multiple pickers.
    final now = DateTime.now();
    if (_lastInteractionTime != null && 
        now.difference(_lastInteractionTime!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastInteractionTime = now;

    // 2. Processing Lock: If already analyzing, ignore new requests.
    if (_isProcessing || state.isLoading) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    // 3. Duplicate Path Guard: Don't re-analyze if it's the exact same file path.
    if (pickedFile.path == _lastAnalyzedPath) return;

    _isProcessing = true;
    _lastAnalyzedPath = pickedFile.path;
    
    // Preserve previous data if available while loading a new one, 
    // or start fresh depending on UX preference.
    state = const AsyncValue.loading();

    try {
      final originalFile = File(pickedFile.path);
      final optimizedFile = await ImageUtils.optimizeForAi(originalFile);

      // Check if we were disposed during the async gap (optimization/compression).
      if (!ref.exists(aiFoodProvider)) return;

      final service = ref.read(aiFoodServiceProvider);

      // 🔥 GEMINI API CALL
      final analysis = await service.detectFoodFromImage(optimizedFile);

      // Final check before updating state.
      if (!ref.exists(aiFoodProvider)) return;

      state = AsyncValue.data(
        AiFoodState(
          selectedImage: optimizedFile,
          analysis: analysis,
        ),
      );
    } catch (e, st) {
      print('PROVIDER ERROR: $e');
      print('PROVIDER STACKTRACE: $st');
      // 4. Graceful Error Handling: Show user-friendly messages for quota issues.
      _lastAnalyzedPath = null;
      
      String errorMessage = 'AI Analysis failed. Please try again.';
      if (e.toString().contains('429')) {
        errorMessage = 'Daily scan limit reached. Please try again later.';
      } else if (e.toString().contains('limit')) {
        errorMessage = 'Server is temporarily busy. Please wait a moment.';
      }

      state = AsyncValue.error('AI Analysis failed: ${e.toString()}', st);
    } finally {
      _isProcessing = false;
    }
  }

  void updateFoodItem(int index, FoodItem updatedFood) {
    final current = state.value;
    if (current?.analysis == null) return;

    final currentAnalysis = current!.analysis!;
    final currentFoods = List<FoodItem>.from(currentAnalysis.foods);

    currentFoods[index] = updatedFood;

    final newNutrition = NutritionInfo(
      totalCalories: currentFoods.fold(0.0, (sum, f) => sum + f.calories),
      totalProtein: currentFoods.fold(0.0, (sum, f) => sum + f.protein),
      totalCarbs: currentFoods.fold(0.0, (sum, f) => sum + f.carbs),
      totalFats: currentFoods.fold(0.0, (sum, f) => sum + f.fats),
    );

    final updatedAnalysis = AiMealAnalysis(
      foods: currentFoods,
      nutrition: newNutrition,
      insights: currentAnalysis.insights,
    );

    state = AsyncValue.data(
      current.copyWith(
        analysis: updatedAnalysis,
      ),
    );
  }

  void removeFoodItem(int index) {
    final current = state.value;
    if (current?.analysis == null) return;

    final currentAnalysis = current!.analysis!;
    final currentFoods = List<FoodItem>.from(currentAnalysis.foods);

    currentFoods.removeAt(index);

    final newNutrition = NutritionInfo(
      totalCalories: currentFoods.fold(0.0, (sum, f) => sum + f.calories),
      totalProtein: currentFoods.fold(0.0, (sum, f) => sum + f.protein),
      totalCarbs: currentFoods.fold(0.0, (sum, f) => sum + f.carbs),
      totalFats: currentFoods.fold(0.0, (sum, f) => sum + f.fats),
    );

    final updatedAnalysis = AiMealAnalysis(
      foods: currentFoods,
      nutrition: newNutrition,
      insights: currentAnalysis.insights,
    );

    state = AsyncValue.data(
      current.copyWith(
        analysis: updatedAnalysis,
      ),
    );
  }

  void reset() {
    _isProcessing = false;
    _lastAnalyzedPath = null;
    state = AsyncValue.data(AiFoodState());
  }
}

final aiFoodProvider =
AutoDisposeAsyncNotifierProvider<
AiFoodNotifier,
AiFoodState>(() {

return AiFoodNotifier();

});
