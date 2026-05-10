import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/food_log.dart';
import '../providers/food_log_providers.dart';

class FoodLogTile extends ConsumerWidget {
  const FoodLogTile({super.key, required this.log});

  final FoodLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline_rounded, color: cs.onErrorContainer),
      ),
      onDismissed: (_) {
        ref.read(foodLogNotifierProvider.notifier).deleteLog(log.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${log.foodName} removed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                log.foodName.isNotEmpty
                    ? log.foodName[0].toUpperCase()
                    : '?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimaryContainer,
                    ),
              ),
            ),
          ),
          title: Text(
            log.foodName,
            style: const TextStyle(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${log.servingSize.toStringAsFixed(0)} ${log.servingUnit} • '
            'P: ${log.protein.toStringAsFixed(1)}g  '
            'C: ${log.carbohydrates.toStringAsFixed(1)}g  '
            'F: ${log.fat.toStringAsFixed(1)}g',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Text(
            '${log.calories.toStringAsFixed(0)}\nkcal',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
          ),
        ),
      ),
    );
  }
}
