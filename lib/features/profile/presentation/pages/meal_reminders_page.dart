import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service.dart';

final mealRemindersProvider = StateNotifierProvider<MealRemindersNotifier, MealRemindersState>((ref) {
  return MealRemindersNotifier(ref);
});

class MealRemindersState {
  final bool breakfastEnabled;
  final TimeOfDay breakfastTime;
  final bool lunchEnabled;
  final TimeOfDay lunchTime;
  final bool dinnerEnabled;
  final TimeOfDay dinnerTime;

  MealRemindersState({
    this.breakfastEnabled = true,
    this.breakfastTime = const TimeOfDay(hour: 8, minute: 30),
    this.lunchEnabled = true,
    this.lunchTime = const TimeOfDay(hour: 13, minute: 0),
    this.dinnerEnabled = true,
    this.dinnerTime = const TimeOfDay(hour: 19, minute: 30),
  });

  MealRemindersState copyWith({
    bool? breakfastEnabled,
    TimeOfDay? breakfastTime,
    bool? lunchEnabled,
    TimeOfDay? lunchTime,
    bool? dinnerEnabled,
    TimeOfDay? dinnerTime,
  }) {
    return MealRemindersState(
      breakfastEnabled: breakfastEnabled ?? this.breakfastEnabled,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchEnabled: lunchEnabled ?? this.lunchEnabled,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerEnabled: dinnerEnabled ?? this.dinnerEnabled,
      dinnerTime: dinnerTime ?? this.dinnerTime,
    );
  }
}

class MealRemindersNotifier extends StateNotifier<MealRemindersState> {
  MealRemindersNotifier(this._ref) : super(MealRemindersState()) {
    _load();
  }

  final Ref _ref;
  Box get _box => Hive.box(AppConstants.settingsBox);

  void _load() {
    final bEnabled = _box.get('breakfastEnabled', defaultValue: true);
    final bTimeH = _box.get('breakfastTimeH', defaultValue: 8);
    final bTimeM = _box.get('breakfastTimeM', defaultValue: 30);
    
    final lEnabled = _box.get('lunchEnabled', defaultValue: true);
    final lTimeH = _box.get('lunchTimeH', defaultValue: 13);
    final lTimeM = _box.get('lunchTimeM', defaultValue: 0);

    final dEnabled = _box.get('dinnerEnabled', defaultValue: true);
    final dTimeH = _box.get('dinnerTimeH', defaultValue: 19);
    final dTimeM = _box.get('dinnerTimeM', defaultValue: 30);

    state = MealRemindersState(
      breakfastEnabled: bEnabled,
      breakfastTime: TimeOfDay(hour: bTimeH, minute: bTimeM),
      lunchEnabled: lEnabled,
      lunchTime: TimeOfDay(hour: lTimeH, minute: lTimeM),
      dinnerEnabled: dEnabled,
      dinnerTime: TimeOfDay(hour: dTimeH, minute: dTimeM),
    );
    
    _rescheduleAll();
  }

  Future<void> _rescheduleAll() async {
    final service = _ref.read(notificationServiceProvider);
    await service.init();
    
    if (state.breakfastEnabled) {
      await service.scheduleDailyReminder(
        id: 1, 
        title: 'Breakfast Time!', 
        body: 'Log your breakfast to stay on track today.', 
        hour: state.breakfastTime.hour, 
        minute: state.breakfastTime.minute,
      );
    } else {
      await service.cancelReminder(1);
    }

    if (state.lunchEnabled) {
      await service.scheduleDailyReminder(
        id: 2, 
        title: 'Lunch Time!', 
        body: 'Time to refuel. Log your lunch now.', 
        hour: state.lunchTime.hour, 
        minute: state.lunchTime.minute,
      );
    } else {
      await service.cancelReminder(2);
    }

    if (state.dinnerEnabled) {
      await service.scheduleDailyReminder(
        id: 3, 
        title: 'Dinner Time!', 
        body: 'Don\'t forget to log your dinner.', 
        hour: state.dinnerTime.hour, 
        minute: state.dinnerTime.minute,
      );
    } else {
      await service.cancelReminder(3);
    }
  }

  void toggleBreakfast(bool enabled) {
    _box.put('breakfastEnabled', enabled);
    state = state.copyWith(breakfastEnabled: enabled);
    _rescheduleAll();
  }

  void setBreakfastTime(TimeOfDay time) {
    _box.put('breakfastTimeH', time.hour);
    _box.put('breakfastTimeM', time.minute);
    state = state.copyWith(breakfastTime: time);
    _rescheduleAll();
  }

  void toggleLunch(bool enabled) {
    _box.put('lunchEnabled', enabled);
    state = state.copyWith(lunchEnabled: enabled);
    _rescheduleAll();
  }

  void setLunchTime(TimeOfDay time) {
    _box.put('lunchTimeH', time.hour);
    _box.put('lunchTimeM', time.minute);
    state = state.copyWith(lunchTime: time);
    _rescheduleAll();
  }

  void toggleDinner(bool enabled) {
    _box.put('dinnerEnabled', enabled);
    state = state.copyWith(dinnerEnabled: enabled);
    _rescheduleAll();
  }

  void setDinnerTime(TimeOfDay time) {
    _box.put('dinnerTimeH', time.hour);
    _box.put('dinnerTimeM', time.minute);
    state = state.copyWith(dinnerTime: time);
    _rescheduleAll();
  }
}

class MealRemindersPage extends ConsumerWidget {
  const MealRemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealRemindersProvider);
    final notifier = ref.read(mealRemindersProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Reminders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Stay consistent by setting daily reminders to log your meals.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          _ReminderCard(
            title: 'Breakfast',
            icon: Icons.free_breakfast_rounded,
            color: const Color(0xFFF7B731),
            enabled: state.breakfastEnabled,
            time: state.breakfastTime,
            onToggle: notifier.toggleBreakfast,
            onTimeSet: notifier.setBreakfastTime,
          ),
          const SizedBox(height: 12),
          _ReminderCard(
            title: 'Lunch',
            icon: Icons.lunch_dining_rounded,
            color: const Color(0xFF4CAF82),
            enabled: state.lunchEnabled,
            time: state.lunchTime,
            onToggle: notifier.toggleLunch,
            onTimeSet: notifier.setLunchTime,
          ),
          const SizedBox(height: 12),
          _ReminderCard(
            title: 'Dinner',
            icon: Icons.dinner_dining_rounded,
            color: const Color(0xFF6C5CE7),
            enabled: state.dinnerEnabled,
            time: state.dinnerTime,
            onToggle: notifier.toggleDinner,
            onTimeSet: notifier.setDinnerTime,
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTimeSet,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool enabled;
  final TimeOfDay time;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onTimeSet;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: enabled ? cs.surfaceContainerHigh : cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: enabled ? color.withOpacity(0.5) : cs.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: enabled ? color.withOpacity(0.15) : cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: enabled ? color : cs.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: enabled ? cs.onSurface : cs.onSurfaceVariant,
                        ),
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeColor: color,
                ),
              ],
            ),
            if (enabled) ...[
              const Divider(height: 24),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null) onTimeSet(picked);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 20, color: cs.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text('Reminder Time', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text(
                        time.format(context),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
