import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/food_model.dart';
import '../../../../data/models/meal_type.dart';
import '../../../../data/providers/data_providers.dart';
import 'package:uuid/uuid.dart';
import '../../../food_search/presentation/providers/food_search_providers.dart';
import '../../domain/models/ai_meal_analysis.dart';
import '../providers/ai_food_provider.dart';
import '../../../../data/models/meal_log_model.dart';

class AiFoodResultScreen extends ConsumerWidget {
  const AiFoodResultScreen({super.key, this.targetMealType});

  final MealType? targetMealType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiFoodProvider);
    final cs = Theme.of(context).colorScheme;

    if (!state.hasValue || state.value?.analysis == null) {
      return const Scaffold(body: Center(child: Text('No results.')));
    }

    final aiState = state.value!;
    final analysis = aiState.analysis!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detected Meal'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(aiFoodProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (aiState.selectedImage != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: FileImage(aiState.selectedImage!),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                if (analysis.insights.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: cs.primary, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              analysis.insights,
                              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Macros',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${analysis.nutrition.totalCalories.toStringAsFixed(0)} kcal',
                        style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MacroSummary(label: 'Protein', value: analysis.nutrition.totalProtein, color: Colors.green[700]!),
                      _MacroSummary(label: 'Carbs', value: analysis.nutrition.totalCarbs, color: Colors.orange[700]!),
                      _MacroSummary(label: 'Fats', value: analysis.nutrition.totalFats, color: Colors.red[700]!),
                    ],
                  ),
                ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Detected Items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final food = analysis.foods[index];
                  return _AiFoodTile(
                    food: food,
                    onRemove: () => ref.read(aiFoodProvider.notifier).removeFoodItem(index),
                    onEdit: () => _showEditDialog(context, ref, index, food),
                  );
                },
                childCount: analysis.foods.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Confirm & Save Meal'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            onPressed: () {
              final newFoods = <FoodModel>[];
              for (final aiFood in analysis.foods) {
                // Parse double value from portion or default to 100
                final match = RegExp(r'\d+').firstMatch(aiFood.portion);
                final qty = match != null ? double.tryParse(match.group(0)!) ?? 100.0 : 100.0;

                newFoods.add(FoodModel(
                  id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${aiFood.name.replaceAll(' ', '_')}',
                  name: aiFood.name,
                  calories: aiFood.calories,
                  protein: aiFood.protein,
                  carbs: aiFood.carbs,
                  fats: aiFood.fats,
                  quantity: qty,
                ));
              }

              if (targetMealType != null) {
                final log = MealLogModel(
                  id: const Uuid().v4(),
                  dateTime: DateTime.now(),
                  mealType: targetMealType!,
                  foods: newFoods,
                );
                ref.read(mealLogNotifierProvider.notifier).add(log);
              } else {
                for (final domainFood in newFoods) {
                  ref.read(mealCartProvider.notifier).addFood(domainFood, domainFood.quantity);
                }
              }
              
              ref.read(aiFoodProvider.notifier).reset();
              Navigator.pop(context); // Pop result screen
              Navigator.pop(context); // Pop scanner
            },
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, int index, FoodItem food) {
    final nameCtrl = TextEditingController(text: food.name);
    final portionCtrl = TextEditingController(text: food.portion);
    final calCtrl = TextEditingController(text: food.calories.toString());
    final pCtrl = TextEditingController(text: food.protein.toString());
    final cCtrl = TextEditingController(text: food.carbs.toString());
    final fCtrl = TextEditingController(text: food.fats.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Food'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(controller: portionCtrl, decoration: const InputDecoration(labelText: 'Portion')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: calCtrl, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: pCtrl, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: cCtrl, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: fCtrl, decoration: const InputDecoration(labelText: 'Fats (g)'), keyboardType: TextInputType.number)),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final updated = FoodItem(
                name: nameCtrl.text,
                portion: portionCtrl.text,
                calories: double.tryParse(calCtrl.text) ?? food.calories,
                protein: double.tryParse(pCtrl.text) ?? food.protein,
                carbs: double.tryParse(cCtrl.text) ?? food.carbs,
                fats: double.tryParse(fCtrl.text) ?? food.fats,
              );
              ref.read(aiFoodProvider.notifier).updateFoodItem(index, updated);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _MacroSummary extends StatelessWidget {
  const _MacroSummary({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${value.toStringAsFixed(1)}g', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _AiFoodTile extends StatelessWidget {
  const _AiFoodTile({required this.food, required this.onRemove, required this.onEdit});

  final FoodItem food;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  '${food.calories.toStringAsFixed(0)} kcal',
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              food.portion,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('P: ${food.protein}g', style: TextStyle(color: Colors.green[700], fontSize: 12)),
                      Text('C: ${food.carbs}g', style: TextStyle(color: Colors.orange[700], fontSize: 12)),
                      Text('F: ${food.fats}g', style: TextStyle(color: Colors.red[700], fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: onEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: onRemove,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
