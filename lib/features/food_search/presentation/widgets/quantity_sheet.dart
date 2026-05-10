import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/food_model.dart';
import '../providers/food_search_providers.dart';

/// Bottom sheet shown when the user taps a food item.
/// Allows adjusting the quantity before adding to the cart.
class QuantitySheet extends ConsumerStatefulWidget {
  const QuantitySheet({super.key, required this.food});

  final FoodModel food;

  /// Shows the sheet and returns the quantity chosen, or null if dismissed.
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    FoodModel food,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuantitySheet(food: food),
    );
  }

  @override
  ConsumerState<QuantitySheet> createState() => _QuantitySheetState();
}

class _QuantitySheetState extends ConsumerState<QuantitySheet> {
  late double _qty;
  late TextEditingController _ctrl;

  static const double _minQty = 1;
  static const double _maxQty = 1000;

  @override
  void initState() {
    super.initState();
    _qty = widget.food.quantity; // default to the food's own serving size
    _ctrl = TextEditingController(text: _qty.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  FoodModel get _preview => widget.food.scaledTo(_qty);

  void _setQty(double v) {
    final clamped = v.clamp(_minQty, _maxQty);
    setState(() {
      _qty = clamped;
      _ctrl.text = clamped.toStringAsFixed(0);
    });
  }

  void _addToCart() {
    ref.read(mealCartProvider.notifier).addFood(widget.food, _qty);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.food.name} (${_qty.toStringAsFixed(0)} g) added to meal!',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isInCart = ref.watch(isInCartProvider(widget.food.id));

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Food name & category
          Text(widget.food.name,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          Text(
            '${widget.food.quantity.toStringAsFixed(0)} g base serving',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          // ── Quantity slider + input ─────────────────────────────────────────
          Row(
            children: [
              Text('Quantity', style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    suffixText: 'g',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null && parsed > 0) {
                      setState(() => _qty = parsed.clamp(_minQty, _maxQty));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _qty.clamp(_minQty, _maxQty),
              min: _minQty,
              max: _maxQty,
              divisions: 99,
              onChanged: _setQty,
            ),
          ),

          // ── Quick-pick buttons ──────────────────────────────────────────────
          Wrap(
            spacing: 8,
            children: [50.0, 100.0, 150.0, 200.0, 250.0, 300.0]
                .map((q) => ActionChip(
                      label: Text('${q.toInt()} g'),
                      onPressed: () => _setQty(q),
                      backgroundColor:
                          (_qty == q) ? cs.primaryContainer : null,
                      labelStyle: TextStyle(
                        fontWeight: (_qty == q)
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: (_qty == q) ? cs.onPrimaryContainer : null,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // ── Nutrition preview ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrition for ${_qty.toStringAsFixed(0)} g',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _MacroRow(
                  label: 'Calories',
                  value: '${_preview.calories.toStringAsFixed(1)} kcal',
                  color: cs.primary,
                  bold: true,
                ),
                const Divider(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MacroRow(
                        label: 'Protein',
                        value: '${_preview.protein.toStringAsFixed(1)} g',
                        color: const Color(0xFF4CAF82),
                      ),
                    ),
                    Expanded(
                      child: _MacroRow(
                        label: 'Carbs',
                        value: '${_preview.carbs.toStringAsFixed(1)} g',
                        color: const Color(0xFFF7B731),
                      ),
                    ),
                    Expanded(
                      child: _MacroRow(
                        label: 'Fats',
                        value: '${_preview.fats.toStringAsFixed(1)} g',
                        color: const Color(0xFFE17055),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Action button ──────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: _addToCart,
            icon: Icon(isInCart
                ? Icons.update_rounded
                : Icons.add_shopping_cart_rounded),
            label: Text(isInCart ? 'Update in Meal' : 'Add to Meal'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: color),
        ),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
