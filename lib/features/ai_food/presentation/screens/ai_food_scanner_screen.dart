import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/meal_type.dart';
import '../providers/ai_food_provider.dart';
import 'ai_food_result_screen.dart';

class AiFoodScannerScreen extends ConsumerWidget {
  const AiFoodScannerScreen({super.key, this.targetMealType});

  final MealType? targetMealType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiFoodProvider);
    final cs = Theme.of(context).colorScheme;

    // We use a listener to navigate automatically when detection is successful
    ref.listen(aiFoodProvider, (previous, next) {
      final wasAnalyzing = previous?.isLoading ?? false;
      final isDone = next.hasValue && !next.isLoading && !next.hasError;
      final hasNewAnalysis = next.value?.analysis != null && previous?.value?.analysis == null;

      if (isDone && hasNewAnalysis) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AiFoodResultScreen(targetMealType: targetMealType)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset',
            onPressed: () => ref.read(aiFoodProvider.notifier).reset(),
          ),
        ],
      ),
      body: aiState.when(
        data: (state) => _buildBody(context, ref, cs),
        loading: () => _buildLoading(cs),
        error: (error, _) => _buildError(context, ref, error, cs),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 80, color: cs.primary),
            const SizedBox(height: 24),
            Text(
              'What are you eating?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Snap a photo or upload from your gallery, and our AI will automatically detect the foods and estimate the macros.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Take a Photo'),
              onPressed: () => ref.read(aiFoodProvider.notifier).pickAndDetectImage(ImageSource.camera),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Upload from Gallery'),
              onPressed: () => ref.read(aiFoodProvider.notifier).pickAndDetectImage(ImageSource.gallery),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Analyzing your food...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: cs.error),
            const SizedBox(height: 24),
            Text(
              'Detection Failed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              onPressed: () => ref.read(aiFoodProvider.notifier).reset(),
            ),
          ],
        ),
      ),
    );
  }
}
