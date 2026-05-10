import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../../core/router/app_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(currentGoalProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.primaryContainer.withOpacity(0.6),
                    cs.surface,
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.person_rounded,
                        size: 48, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'My Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    'Manage your settings and goals',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),

            // Goals Summary Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Daily Goals',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => context.push(AppRoutes.goals),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _GoalRow(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Calories',
                          value:
                              '${goal.calorieGoal.toStringAsFixed(0)} kcal',
                          color: cs.primary),
                      _GoalRow(
                          icon: Icons.fitness_center_rounded,
                          label: 'Protein',
                          value: '${goal.proteinGoal.toStringAsFixed(0)} g',
                          color: const Color(0xFF4CAF82)),
                      _GoalRow(
                          icon: Icons.grain_rounded,
                          label: 'Carbs',
                          value: '${goal.carbsGoal.toStringAsFixed(0)} g',
                          color: const Color(0xFFF7B731)),
                      _GoalRow(
                          icon: Icons.opacity_rounded,
                          label: 'Fat',
                          value: '${goal.fatGoal.toStringAsFixed(0)} g',
                          color: const Color(0xFFE17055)),
                      _GoalRow(
                          icon: Icons.water_drop_rounded,
                          label: 'Water',
                          value: '${goal.waterGoal.toStringAsFixed(0)} ml',
                          color: const Color(0xFF74B9FF)),
                    ],
                  ),
                ),
              ),
            ),

            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.track_changes_rounded,
                      title: 'Nutrition Goals',
                      subtitle: 'Set your daily calorie & macro targets',
                      onTap: () => context.push(AppRoutes.goals),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'Meal Reminders',
                      subtitle: 'Configure daily logging reminders',
                      onTap: () => context.push(AppRoutes.mealReminders),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Food Database',
                      subtitle: 'Browse and manage saved foods',
                      onTap: () => context.push(AppRoutes.foodSearch),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      subtitle: 'Calorie Tracker v1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Calorie Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 40),
      children: const [
        Text(
            'A clean and beautiful calorie tracking app built with Flutter, '
            'Riverpod, and Hive.'),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: cs.onPrimaryContainer),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
