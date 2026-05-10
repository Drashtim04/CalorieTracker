import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/food_log.dart';
import '../providers/food_log_providers.dart';
import '../../../food/presentation/pages/food_search_page.dart';
import '../../../food/domain/entities/food_item.dart';
import '../../../../core/constants/app_constants.dart';

class AddFoodLogPage extends ConsumerStatefulWidget {
  const AddFoodLogPage({super.key, required this.mealType});

  final String mealType;

  @override
  ConsumerState<AddFoodLogPage> createState() => _AddFoodLogPageState();
}

class _AddFoodLogPageState extends ConsumerState<AddFoodLogPage> {
  late String _selectedMealType;
  FoodItem? _selectedFood;
  final _servingController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
  }

  @override
  void dispose() {
    _servingController.dispose();
    super.dispose();
  }

  double get _servingSize =>
      double.tryParse(_servingController.text) ??
      (_selectedFood?.servingSize ?? 100);

  FoodItem? get _scaledFood =>
      _selectedFood?.scaledTo(_servingSize);

  Future<void> _pickFood() async {
    final food = await Navigator.of(context).push<FoodItem>(
      MaterialPageRoute(builder: (_) => const FoodSearchPage(selectionMode: true)),
    );
    if (food != null) {
      setState(() {
        _selectedFood = food;
        _servingController.text = food.servingSize.toStringAsFixed(0);
      });
    }
  }

  Future<void> _saveLog() async {
    final food = _scaledFood;
    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a food item')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final log = FoodLog(
        id: const Uuid().v4(),
        foodItemId: food.id,
        foodName: food.name,
        mealType: _selectedMealType,
        servingSize: _servingSize,
        servingUnit: food.servingUnit,
        calories: food.calories,
        protein: food.protein,
        carbohydrates: food.carbohydrates,
        fat: food.fat,
        fiber: food.fiber,
        sugar: food.sugar,
        sodium: food.sodium,
        loggedAt: DateTime.now(),
      );
      await ref.read(foodLogNotifierProvider.notifier).addLog(log);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${food.name} logged to $_selectedMealType!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scaled = _scaledFood;

    return Scaffold(
      appBar: AppBar(title: const Text('Log Food')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Type Selector
            Text('Meal Type',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppConstants.mealTypes.map((type) {
                final selected = type == _selectedMealType;
                return ChoiceChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedMealType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Food Selector
            Text('Food Item',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickFood,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFood != null
                        ? cs.primary
                        : cs.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: cs.surfaceContainerHighest.withOpacity(0.4),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedFood != null
                          ? Icons.check_circle_rounded
                          : Icons.search_rounded,
                      color: _selectedFood != null
                          ? cs.primary
                          : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFood?.name ?? 'Search and select a food...',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _selectedFood != null
                                      ? cs.onSurface
                                      : cs.onSurfaceVariant,
                                ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Serving Size
            if (_selectedFood != null) ...[
              Text('Serving Size (${_selectedFood!.servingUnit})',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _servingController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText:
                      'e.g. ${_selectedFood!.servingSize.toStringAsFixed(0)}',
                  suffixText: _selectedFood!.servingUnit,
                ),
              ),
              const SizedBox(height: 20),

              // Nutrition Preview
              if (scaled != null) ...[
                Text('Nutrition Preview',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      _NutritionRow('Calories',
                          '${scaled.calories.toStringAsFixed(1)} kcal',
                          bold: true),
                      const Divider(height: 16),
                      _NutritionRow('Protein',
                          '${scaled.protein.toStringAsFixed(1)} g'),
                      _NutritionRow('Carbohydrates',
                          '${scaled.carbohydrates.toStringAsFixed(1)} g'),
                      _NutritionRow(
                          'Fat', '${scaled.fat.toStringAsFixed(1)} g'),
                      _NutritionRow(
                          'Fiber', '${scaled.fiber.toStringAsFixed(1)} g'),
                      _NutritionRow(
                          'Sugar', '${scaled.sugar.toStringAsFixed(1)} g'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // Save Button
              FilledButton(
                onPressed: _isSaving ? null : _saveLog,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save to Log'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: bold ? FontWeight.w700 : null,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: bold
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
          ),
        ],
      ),
    );
  }
}
