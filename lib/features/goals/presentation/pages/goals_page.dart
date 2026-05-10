import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/nutrition_goal.dart';
import '../providers/goals_providers.dart';
import '../widgets/activity_level_picker.dart';
import '../widgets/biometric_form.dart';
import '../widgets/goal_review_card.dart';
import '../widgets/weight_goal_picker.dart';

/// Three-step goal-setting wizard.
///
/// Step 1 — Biometrics (weight, height, age, gender)
/// Step 2 — Activity level + weight goal
/// Step 3 — Review calculated targets + optional manual override
class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _progressCtrl;
  int _step = 0;
  static const int _totalSteps = 3;

  // ── Wizard state ────────────────────────────────────────────────────────────

  double? _weightKg;
  double? _heightCm;
  int? _age;
  Gender? _gender;
  ActivityLevel? _activityLevel;
  WeightGoal? _weightGoal;

  // Computed values (set in step 3)
  double? _computedCalories;
  double? _computedProtein;
  double? _computedCarbs;
  double? _computedFat;

  // Manual override controllers (step 3)
  late TextEditingController _calCtrl;
  late TextEditingController _protCtrl;
  late TextEditingController _carbCtrl;
  late TextEditingController _fatCtrl;
  late TextEditingController _waterCtrl;

  bool _isSaving = false;
  bool _manualOverride = false;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1 / _totalSteps,
    );

    // Pre-fill from existing goal
    final existing = ref.read(currentGoalProvider);
    _weightKg      = existing.weightKg;
    _heightCm      = existing.heightCm;
    _age           = existing.age;
    _gender        = existing.gender ?? Gender.male;
    _activityLevel = existing.activityLevel ?? ActivityLevel.moderate;
    _weightGoal    = existing.weightGoal ?? WeightGoal.maintain;

    _calCtrl   = TextEditingController(text: existing.calorieGoal.toStringAsFixed(0));
    _protCtrl  = TextEditingController(text: existing.proteinGoal.toStringAsFixed(0));
    _carbCtrl  = TextEditingController(text: existing.carbsGoal.toStringAsFixed(0));
    _fatCtrl   = TextEditingController(text: existing.fatGoal.toStringAsFixed(0));
    _waterCtrl = TextEditingController(text: existing.waterGoal.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _progressCtrl.dispose();
    _calCtrl.dispose();
    _protCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _next() {
    if (_step == 0 && !_validateBiometrics()) return;
    if (_step == 1 && !_validateActivity()) return;

    if (_step == 1) _computeTargets(); // before showing review

    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      _progressCtrl.animateTo((_step + 1) / _totalSteps);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      _progressCtrl.animateTo((_step + 1) / _totalSteps);
    } else {
      context.pop();
    }
  }

  // ── Validation ──────────────────────────────────────────────────────────────

  bool _validateBiometrics() {
    if (_weightKg == null || _weightKg! < 20 || _weightKg! > 300) {
      _showError('Enter a valid weight (20–300 kg)');
      return false;
    }
    if (_heightCm == null || _heightCm! < 100 || _heightCm! > 250) {
      _showError('Enter a valid height (100–250 cm)');
      return false;
    }
    if (_age == null || _age! < 10 || _age! > 100) {
      _showError('Enter a valid age (10–100)');
      return false;
    }
    if (_gender == null) {
      _showError('Please select a gender');
      return false;
    }
    return true;
  }

  bool _validateActivity() {
    if (_activityLevel == null) {
      _showError('Please select your activity level');
      return false;
    }
    if (_weightGoal == null) {
      _showError('Please select your weight goal');
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ── TDEE computation ────────────────────────────────────────────────────────

  void _computeTargets() {
    final cal = TdeeCalculator.dailyCalorieTarget(
      weightKg:   _weightKg!,
      heightCm:   _heightCm!,
      age:        _age!,
      gender:     _gender!,
      activity:   _activityLevel!,
      weightGoal: _weightGoal!,
    );
    final (:protein, :carbs, :fat) = TdeeCalculator.macros(
      calories:   cal,
      weightKg:   _weightKg!,
      weightGoal: _weightGoal!,
    );

    setState(() {
      _computedCalories = cal;
      _computedProtein  = protein;
      _computedCarbs    = carbs;
      _computedFat      = fat;
      _calCtrl.text  = cal.toStringAsFixed(0);
      _protCtrl.text = protein.toStringAsFixed(0);
      _carbCtrl.text = carbs.toStringAsFixed(0);
      _fatCtrl.text  = fat.toStringAsFixed(0);
    });
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final cal  = double.tryParse(_calCtrl.text)  ?? _computedCalories ?? 2000;
    final prot = double.tryParse(_protCtrl.text) ?? _computedProtein  ?? 150;
    final carb = double.tryParse(_carbCtrl.text) ?? _computedCarbs    ?? 250;
    final fat  = double.tryParse(_fatCtrl.text)  ?? _computedFat      ?? 65;
    final water = double.tryParse(_waterCtrl.text) ?? 2500;

    setState(() => _isSaving = true);
    try {
      final current = ref.read(currentGoalProvider);
      final updated = current.copyWith(
        calorieGoal:   cal,
        proteinGoal:   prot,
        carbsGoal:     carb,
        fatGoal:       fat,
        waterGoal:     water,
        weightKg:      _weightKg,
        heightCm:      _heightCm,
        age:           _age,
        gender:        _gender,
        activityLevel: _activityLevel,
        weightGoal:    _weightGoal,
        updatedAt:     DateTime.now(),
      );
      await ref.read(goalsProvider.notifier).saveGoal(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text('Goals saved — ${cal.toStringAsFixed(0)} kcal/day'),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF82),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final stepTitles = ['Your Profile', 'Activity & Goal', 'Review Targets'];
    final stepIcons  = [
      Icons.person_outline_rounded,
      Icons.directions_run_rounded,
      Icons.check_circle_outline_rounded,
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(_step == 0
              ? Icons.close_rounded
              : Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stepTitles[_step],
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              'Step ${_step + 1} of $_totalSteps',
              style:
                  tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          if (_step < 2)
            TextButton(
              onPressed: _next,
              child: Text(
                'Next',
                style: tt.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Step progress bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              children: List.generate(_totalSteps, (i) {
                final done = i < _step;
                final current = i == _step;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: done || current
                          ? cs.primary
                          : cs.surfaceContainerHighest,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 4),

          // ── Step icon strip ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: List.generate(_totalSteps, (i) {
                final done    = i < _step;
                final current = i == _step;
                return Expanded(
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? cs.primary
                              : current
                                  ? cs.primaryContainer
                                  : cs.surfaceContainerHighest,
                        ),
                        child: Icon(
                          done ? Icons.check_rounded : stepIcons[i],
                          size: 16,
                          color: done
                              ? cs.onPrimary
                              : current
                                  ? cs.primary
                                  : cs.onSurfaceVariant,
                        ),
                      ),
                      if (i < _totalSteps - 1)
                        Expanded(
                          child: Container(
                            height: 1,
                            color: i < _step
                                ? cs.primary
                                : cs.outlineVariant.withOpacity(0.4),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // ── Page content ─────────────────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Biometrics
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: BiometricForm(
                    weightKg: _weightKg,
                    heightCm: _heightCm,
                    age: _age,
                    gender: _gender,
                    onWeightChanged: (v) => setState(() => _weightKg = v),
                    onHeightChanged: (v) => setState(() => _heightCm = v),
                    onAgeChanged: (v) => setState(() => _age = v),
                    onGenderChanged: (v) => setState(() => _gender = v),
                  ),
                ),

                // Step 2: Activity + goal
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActivityLevelPicker(
                        selected: _activityLevel,
                        onChanged: (v) =>
                            setState(() => _activityLevel = v),
                      ),
                      const SizedBox(height: 24),
                      WeightGoalPicker(
                        selected: _weightGoal,
                        onChanged: (v) => setState(() => _weightGoal = v),
                      ),
                    ],
                  ),
                ),

                // Step 3: Review
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: GoalReviewCard(
                    weightKg:       _weightKg,
                    heightCm:       _heightCm,
                    age:            _age,
                    gender:         _gender,
                    activityLevel:  _activityLevel,
                    weightGoal:     _weightGoal,
                    computedCalories: _computedCalories,
                    manualOverride: _manualOverride,
                    calCtrl:        _calCtrl,
                    protCtrl:       _protCtrl,
                    carbCtrl:       _carbCtrl,
                    fatCtrl:        _fatCtrl,
                    waterCtrl:      _waterCtrl,
                    onToggleOverride: (v) =>
                        setState(() => _manualOverride = v),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom action bar ─────────────────────────────────────────────
          _BottomBar(
            step: _step,
            totalSteps: _totalSteps,
            isSaving: _isSaving,
            onNext: _next,
            onSave: _save,
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.totalSteps,
    required this.isSaving,
    required this.onNext,
    required this.onSave,
  });

  final int step;
  final int totalSteps;
  final bool isSaving;
  final VoidCallback onNext;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isLast = step == totalSteps - 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton(
          onPressed: isSaving ? null : (isLast ? onSave : onNext),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5,
                      color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'Save My Goals' : 'Continue',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
