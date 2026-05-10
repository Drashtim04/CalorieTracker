import 'package:flutter/material.dart';

import '../../domain/entities/nutrition_goal.dart';

/// Step 3 — Shows TDEE breakdown and editable macro targets.
class GoalReviewCard extends StatelessWidget {
  const GoalReviewCard({
    super.key,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.weightGoal,
    required this.computedCalories,
    required this.manualOverride,
    required this.calCtrl,
    required this.protCtrl,
    required this.carbCtrl,
    required this.fatCtrl,
    required this.waterCtrl,
    required this.onToggleOverride,
  });

  final double?        weightKg;
  final double?        heightCm;
  final int?           age;
  final Gender?        gender;
  final ActivityLevel? activityLevel;
  final WeightGoal?    weightGoal;
  final double?        computedCalories;
  final bool           manualOverride;
  final TextEditingController calCtrl;
  final TextEditingController protCtrl;
  final TextEditingController carbCtrl;
  final TextEditingController fatCtrl;
  final TextEditingController waterCtrl;
  final void Function(bool) onToggleOverride;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasBio = weightKg != null && heightCm != null &&
        age != null && gender != null && activityLevel != null &&
        weightGoal != null;

    final bmr = hasBio
        ? TdeeCalculator.bmr(
            weightKg: weightKg!,
            heightCm: heightCm!,
            age: age!,
            gender: gender!,
          )
        : null;

    final tdee = hasBio
        ? TdeeCalculator.tdee(
            weightKg: weightKg!,
            heightCm: heightCm!,
            age: age!,
            gender: gender!,
            activity: activityLevel!,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── TDEE breakdown card ─────────────────────────────────────────────
        if (hasBio) ...[
          _TdeeCard(
            bmr: bmr!,
            tdee: tdee!,
            target: computedCalories,
            activityLevel: activityLevel!,
            weightGoal: weightGoal!,
          ),
          const SizedBox(height: 20),
        ],

        // ── Profile summary ──────────────────────────────────────────────────
        if (hasBio) ...[
          _ProfileSummary(
            weightKg: weightKg!,
            heightCm: heightCm!,
            age: age!,
            gender: gender!,
            activityLevel: activityLevel!,
            weightGoal: weightGoal!,
          ),
          const SizedBox(height: 20),
        ],

        // ── Manual override toggle ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.tune_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customise targets',
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Override the calculated values manually',
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Switch(
                value: manualOverride,
                onChanged: onToggleOverride,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Macro fields ─────────────────────────────────────────────────────
        _MacroFields(
          calCtrl: calCtrl,
          protCtrl: protCtrl,
          carbCtrl: carbCtrl,
          fatCtrl: fatCtrl,
          waterCtrl: waterCtrl,
          enabled: manualOverride,
        ),
      ],
    );
  }
}

// ─── TDEE breakdown card ──────────────────────────────────────────────────────

class _TdeeCard extends StatelessWidget {
  const _TdeeCard({
    required this.bmr,
    required this.tdee,
    required this.target,
    required this.activityLevel,
    required this.weightGoal,
  });

  final double        bmr;
  final double        tdee;
  final double?       target;
  final ActivityLevel activityLevel;
  final WeightGoal    weightGoal;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withOpacity(0.6),
            cs.secondaryContainer.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Calorie Calculation',
                style:
                    tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // BMR row
          _CalcRow(
            label: 'Basal Metabolic Rate (BMR)',
            value: bmr.toStringAsFixed(0),
            suffix: 'kcal',
            color: cs.onSurfaceVariant,
            formula: 'Mifflin-St Jeor',
          ),
          const SizedBox(height: 6),

          // Activity multiplier
          _CalcRow(
            label: '× Activity (${activityLevel.label})',
            value: activityLevel.multiplier.toString(),
            suffix: '',
            color: const Color(0xFFF7B731),
          ),
          Divider(height: 20, color: cs.outlineVariant.withOpacity(0.3)),

          // TDEE
          _CalcRow(
            label: 'TDEE (maintenance)',
            value: tdee.toStringAsFixed(0),
            suffix: 'kcal',
            color: cs.secondary,
            bold: true,
          ),
          const SizedBox(height: 6),

          // Goal offset
          _CalcRow(
            label: '${weightGoal.label} offset',
            value: weightGoal.calorieOffset >= 0
                ? '+${weightGoal.calorieOffset.toStringAsFixed(0)}'
                : weightGoal.calorieOffset.toStringAsFixed(0),
            suffix: 'kcal',
            color: weightGoal == WeightGoal.lose
                ? const Color(0xFF4CAF82)
                : weightGoal == WeightGoal.gain
                    ? const Color(0xFFE17055)
                    : cs.onSurfaceVariant,
          ),
          Divider(height: 20, color: cs.outlineVariant.withOpacity(0.3)),

          // Target
          _CalcRow(
            label: '🎯 Daily Target',
            value: target?.toStringAsFixed(0) ?? '—',
            suffix: 'kcal/day',
            color: cs.primary,
            bold: true,
            large: true,
          ),
        ],
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  const _CalcRow({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
    this.formula,
    this.bold = false,
    this.large = false,
  });

  final String  label;
  final String  value;
  final String  suffix;
  final Color   color;
  final String? formula;
  final bool    bold;
  final bool    large;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: (large ? tt.bodyMedium : tt.bodySmall)?.copyWith(
                  color: cs.onSurface,
                  fontWeight: bold ? FontWeight.w700 : null,
                ),
              ),
              if (formula != null)
                Text(formula!,
                    style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant, fontSize: 10)),
            ],
          ),
        ),
        Text(
          '$value ',
          style: (large ? tt.titleMedium : tt.bodyMedium)?.copyWith(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          suffix,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ─── Profile summary ──────────────────────────────────────────────────────────

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.weightGoal,
  });

  final double        weightKg;
  final double        heightCm;
  final int           age;
  final Gender        gender;
  final ActivityLevel activityLevel;
  final WeightGoal    weightGoal;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hm = heightCm / 100;
    final bmi = weightKg / (hm * hm);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Chip(
              Icons.monitor_weight_outlined,
              '${weightKg.toStringAsFixed(1)} kg',
              cs.primary),
          _Chip(
              Icons.straighten_rounded,
              '${heightCm.toStringAsFixed(0)} cm',
              const Color(0xFF6C5CE7)),
          _Chip(
              Icons.cake_outlined,
              '$age yrs',
              const Color(0xFFE17055)),
          _Chip(
              gender == Gender.male
                  ? Icons.male_rounded
                  : Icons.female_rounded,
              gender == Gender.male ? 'Male' : 'Female',
              const Color(0xFF74B9FF)),
          _Chip(
              Icons.directions_run_rounded,
              activityLevel.label,
              const Color(0xFFF7B731)),
          _Chip(
              Icons.flag_rounded,
              weightGoal.label,
              const Color(0xFF4CAF82)),
          _Chip(
              Icons.calculate_outlined,
              'BMI ${bmi.toStringAsFixed(1)}',
              cs.secondary),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label, this.color);

  final IconData icon;
  final String   label;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Macro fields ─────────────────────────────────────────────────────────────

class _MacroFields extends StatelessWidget {
  const _MacroFields({
    required this.calCtrl,
    required this.protCtrl,
    required this.carbCtrl,
    required this.fatCtrl,
    required this.waterCtrl,
    required this.enabled,
  });

  final TextEditingController calCtrl;
  final TextEditingController protCtrl;
  final TextEditingController carbCtrl;
  final TextEditingController fatCtrl;
  final TextEditingController waterCtrl;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget field(
      TextEditingController ctrl,
      String label,
      String suffix,
      IconData icon,
      Color color,
    ) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          enabled: enabled,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffix,
            prefixIcon: Icon(icon,
                color: enabled ? color : cs.onSurfaceVariant),
            filled: true,
            fillColor: enabled
                ? cs.surfaceContainerLow
                : cs.surfaceContainerHighest.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              enabled ? Icons.edit_rounded : Icons.lock_outline_rounded,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              enabled
                  ? 'Edit your targets below'
                  : 'Calculated targets (read-only)',
              style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        field(calCtrl,  'Daily Calories',   'kcal', Icons.local_fire_department_rounded, cs.primary),
        field(protCtrl, 'Protein Goal',     'g',    Icons.fitness_center_rounded,        const Color(0xFF4CAF82)),
        field(carbCtrl, 'Carbohydrates',    'g',    Icons.grain_rounded,                 const Color(0xFFF7B731)),
        field(fatCtrl,  'Fat Goal',         'g',    Icons.water_drop_rounded,            const Color(0xFFE17055)),
        field(waterCtrl,'Water Intake',     'ml',   Icons.local_drink_rounded,           const Color(0xFF74B9FF)),
      ],
    );
  }
}
