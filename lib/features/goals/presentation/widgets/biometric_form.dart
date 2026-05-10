import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/nutrition_goal.dart';

/// Step 1 — weight, height, age, gender inputs.
class BiometricForm extends StatefulWidget {
  const BiometricForm({
    super.key,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.onWeightChanged,
    required this.onHeightChanged,
    required this.onAgeChanged,
    required this.onGenderChanged,
  });

  final double? weightKg;
  final double? heightCm;
  final int?    age;
  final Gender? gender;
  final void Function(double?) onWeightChanged;
  final void Function(double?) onHeightChanged;
  final void Function(int?)    onAgeChanged;
  final void Function(Gender)  onGenderChanged;

  @override
  State<BiometricForm> createState() => _BiometricFormState();
}

class _BiometricFormState extends State<BiometricForm> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _ageCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
        text: widget.weightKg?.toStringAsFixed(1) ?? '');
    _heightCtrl = TextEditingController(
        text: widget.heightCm?.toStringAsFixed(0) ?? '');
    _ageCtrl = TextEditingController(
        text: widget.age?.toString() ?? '');
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _StepHeader(
          icon: Icons.person_outline_rounded,
          title: 'Tell us about yourself',
          subtitle: 'We use this to calculate your personalised calorie target.',
        ),
        const SizedBox(height: 24),

        // Gender selector
        Text('Biological Sex', style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: Gender.values.map((g) {
            final selected = widget.gender == g;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: g == Gender.male ? 8 : 0),
                child: InkWell(
                  onTap: () => widget.onGenderChanged(g),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? cs.primaryContainer
                          : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? cs.primary
                            : cs.outlineVariant.withOpacity(0.4),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          g == Gender.male
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          size: 32,
                          color: selected ? cs.primary : cs.onSurfaceVariant,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          g == Gender.male ? 'Male' : 'Female',
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected ? cs.primary : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Weight + height row
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: _weightCtrl,
                label: 'Weight',
                suffix: 'kg',
                icon: Icons.monitor_weight_outlined,
                color: cs.primary,
                decimal: true,
                onChanged: (v) =>
                    widget.onWeightChanged(double.tryParse(v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumberField(
                controller: _heightCtrl,
                label: 'Height',
                suffix: 'cm',
                icon: Icons.straighten_rounded,
                color: const Color(0xFF6C5CE7),
                decimal: false,
                onChanged: (v) =>
                    widget.onHeightChanged(double.tryParse(v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Age
        _NumberField(
          controller: _ageCtrl,
          label: 'Age',
          suffix: 'years',
          icon: Icons.cake_outlined,
          color: const Color(0xFFE17055),
          decimal: false,
          onChanged: (v) => widget.onAgeChanged(int.tryParse(v)),
        ),
        const SizedBox(height: 24),

        // BMI preview (live)
        if (widget.weightKg != null && widget.heightCm != null)
          _BmiChip(weightKg: widget.weightKg!, heightCm: widget.heightCm!),
      ],
    );
  }
}

// ─── Number input field ────────────────────────────────────────────────────────

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.color,
    required this.decimal,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String   label;
  final String   suffix;
  final IconData icon;
  final Color    color;
  final bool     decimal;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]')),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: color),
        filled: true,
        fillColor: cs.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ─── BMI chip ────────────────────────────────────────────────────────────────

class _BmiChip extends StatelessWidget {
  const _BmiChip({required this.weightKg, required this.heightCm});

  final double weightKg;
  final double heightCm;

  @override
  Widget build(BuildContext context) {
    final hm = heightCm / 100;
    final bmi = weightKg / (hm * hm);

    Color color;
    String category;
    if (bmi < 18.5) {
      color = const Color(0xFF74B9FF);
      category = 'Underweight';
    } else if (bmi < 25) {
      color = const Color(0xFF4CAF82);
      category = 'Healthy Weight';
    } else if (bmi < 30) {
      color = const Color(0xFFF7B731);
      category = 'Overweight';
    } else {
      color = const Color(0xFFE17055);
      category = 'Obese';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BMI: ${bmi.toStringAsFixed(1)} · $category',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                'Based on your height and weight',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step header ─────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String   title;
  final String   subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: cs.primary, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: tt.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900)),
              Text(subtitle,
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
