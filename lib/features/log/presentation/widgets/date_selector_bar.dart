import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/food_log_providers.dart';

class DateSelectorBar extends ConsumerWidget {
  const DateSelectorBar({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dates = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day - (6 - i)),
    );

    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: dates.length,
        itemBuilder: (context, i) {
          final date = dates[i];
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, now);
          final cs = Theme.of(context).colorScheme;

          return GestureDetector(
            onTap: () => ref
                .read(foodLogNotifierProvider.notifier)
                .refreshForDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? cs.primary
                      : cs.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Today' : DateFormat('EEE').format(date),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? cs.onPrimary
                              : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    DateFormat('d').format(date),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected ? cs.onPrimary : cs.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
