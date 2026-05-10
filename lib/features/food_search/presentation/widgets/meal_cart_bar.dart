import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/food_search_providers.dart';

/// Sticky bottom bar showing the cart summary and Save Meal button.
class MealCartBar extends ConsumerWidget {
  const MealCartBar({super.key, required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(mealCartProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (cart.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // ── Cart summary ───────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${cart.count} item${cart.count == 1 ? '' : 's'} '
                      '· ${cart.mealType.label}',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${cart.totalCalories.toStringAsFixed(0)} kcal  '
                      'P ${cart.totalProtein.toStringAsFixed(0)}g  '
                      'C ${cart.totalCarbs.toStringAsFixed(0)}g  '
                      'F ${cart.totalFats.toStringAsFixed(0)}g',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ── Discard ────────────────────────────────────────────────────
              IconButton.outlined(
                icon: const Icon(Icons.delete_outline_rounded),
                color: cs.error,
                onPressed: () {
                  ref.read(mealCartProvider.notifier).clearCart();
                },
                tooltip: 'Clear cart',
              ),
              const SizedBox(width: 8),

              // ── Save meal ──────────────────────────────────────────────────
              FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save Meal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
