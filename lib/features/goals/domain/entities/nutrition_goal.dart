import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum Gender { male, female }

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive;

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:  return 'Sedentary';
      case ActivityLevel.light:      return 'Lightly Active';
      case ActivityLevel.moderate:   return 'Moderately Active';
      case ActivityLevel.active:     return 'Very Active';
      case ActivityLevel.veryActive: return 'Extra Active';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:  return 'Little to no exercise';
      case ActivityLevel.light:      return 'Light exercise 1–3 days/week';
      case ActivityLevel.moderate:   return 'Moderate exercise 3–5 days/week';
      case ActivityLevel.active:     return 'Hard exercise 6–7 days/week';
      case ActivityLevel.veryActive: return 'Very hard exercise / physical job';
    }
  }

  /// Harris-Benedict TDEE multiplier.
  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:  return 1.2;
      case ActivityLevel.light:      return 1.375;
      case ActivityLevel.moderate:   return 1.55;
      case ActivityLevel.active:     return 1.725;
      case ActivityLevel.veryActive: return 1.9;
    }
  }

  static ActivityLevel fromString(String s) =>
      ActivityLevel.values.firstWhere(
        (e) => e.name == s,
        orElse: () => ActivityLevel.moderate,
      );
}

enum WeightGoal {
  lose,
  maintain,
  gain;

  String get label {
    switch (this) {
      case WeightGoal.lose:     return 'Lose Weight';
      case WeightGoal.maintain: return 'Maintain Weight';
      case WeightGoal.gain:     return 'Gain Weight';
    }
  }

  String get description {
    switch (this) {
      case WeightGoal.lose:     return '−500 kcal/day deficit';
      case WeightGoal.maintain: return 'Match your TDEE exactly';
      case WeightGoal.gain:     return '+500 kcal/day surplus';
    }
  }

  /// Calorie offset applied to TDEE.
  double get calorieOffset {
    switch (this) {
      case WeightGoal.lose:     return -500;
      case WeightGoal.maintain: return 0;
      case WeightGoal.gain:     return 500;
    }
  }

  static WeightGoal fromString(String s) =>
      WeightGoal.values.firstWhere(
        (e) => e.name == s,
        orElse: () => WeightGoal.maintain,
      );
}

// ─── TDEE Calculator ─────────────────────────────────────────────────────────

/// Mifflin-St Jeor BMR → TDEE calculator.
class TdeeCalculator {
  const TdeeCalculator._();

  /// Calculates Basal Metabolic Rate using the Mifflin-St Jeor equation.
  ///
  /// [weightKg] – body weight in kg  
  /// [heightCm] – height in cm  
  /// [age]      – age in years  
  /// [gender]   – biological sex
  static double bmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
  }) {
    // Mifflin-St Jeor:
    //   Male:   10W + 6.25H − 5A + 5
    //   Female: 10W + 6.25H − 5A − 161
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return gender == Gender.male ? base + 5 : base - 161;
  }

  /// TDEE = BMR × activity multiplier.
  static double tdee({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
    required ActivityLevel activity,
  }) {
    return bmr(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    ) * activity.multiplier;
  }

  /// Daily calorie target after applying the [weightGoal] offset.
  static double dailyCalorieTarget({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
    required ActivityLevel activity,
    required WeightGoal weightGoal,
  }) {
    final base = tdee(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      activity: activity,
    );
    return (base + weightGoal.calorieOffset).clamp(1200, 5000);
  }

  /// Recommended macro split based on the calorie target.
  ///
  /// Default split: 30 % protein · 40 % carbs · 30 % fat.
  /// Protein goal is bumped to 2 g/kg for gain/lose goals.
  static ({double protein, double carbs, double fat}) macros({
    required double calories,
    required double weightKg,
    required WeightGoal weightGoal,
  }) {
    // Protein: 2 g/kg for active goals, 1.6 g/kg for maintain
    final proteinG = weightGoal == WeightGoal.maintain
        ? weightKg * 1.6
        : weightKg * 2.0;
    final proteinKcal = proteinG * 4;

    final remaining = (calories - proteinKcal).clamp(0.0, double.infinity);
    // Carbs 55 %, Fat 45 % of remaining
    final carbsG = (remaining * 0.55) / 4;
    final fatG   = (remaining * 0.45) / 9;

    return (protein: proteinG, carbs: carbsG, fat: fatG);
  }
}

// ─── Entity ──────────────────────────────────────────────────────────────────

class NutritionGoal extends Equatable {
  const NutritionGoal({
    required this.id,
    this.calorieGoal   = AppConstants.defaultCalorieGoal,
    this.proteinGoal   = AppConstants.defaultProteinGoal,
    this.carbsGoal     = AppConstants.defaultCarbsGoal,
    this.fatGoal       = AppConstants.defaultFatGoal,
    this.waterGoal     = AppConstants.defaultWaterGoal,
    this.updatedAt,
    // Biometric fields
    this.weightKg,
    this.heightCm,
    this.age,
    this.gender,
    this.activityLevel,
    this.weightGoal,
  });

  final String  id;
  final double  calorieGoal;
  final double  proteinGoal;
  final double  carbsGoal;
  final double  fatGoal;
  final double  waterGoal;
  final DateTime? updatedAt;

  // Biometric fields
  final double?        weightKg;
  final double?        heightCm;
  final int?           age;
  final Gender?        gender;
  final ActivityLevel? activityLevel;
  final WeightGoal?    weightGoal;

  // ── Derived ────────────────────────────────────────────────────────────────

  bool get hasBiometrics =>
      weightKg != null && heightCm != null && age != null &&
      gender != null && activityLevel != null && weightGoal != null;

  /// Computed TDEE when biometrics are available.
  double? get computedTdee {
    if (!hasBiometrics) return null;
    return TdeeCalculator.tdee(
      weightKg: weightKg!,
      heightCm: heightCm!,
      age: age!,
      gender: gender!,
      activity: activityLevel!,
    );
  }

  /// BMI (kg / m²).
  double? get bmi {
    if (weightKg == null || heightCm == null) return null;
    final hm = heightCm! / 100;
    return weightKg! / (hm * hm);
  }

  String get bmiCategory {
    final b = bmi;
    if (b == null)    return '—';
    if (b < 18.5)     return 'Underweight';
    if (b < 25.0)     return 'Healthy';
    if (b < 30.0)     return 'Overweight';
    return 'Obese';
  }

  // ── Default ────────────────────────────────────────────────────────────────

  static const NutritionGoal defaultGoal = NutritionGoal(id: 'default');

  // ── copyWith ───────────────────────────────────────────────────────────────

  NutritionGoal copyWith({
    String?        id,
    double?        calorieGoal,
    double?        proteinGoal,
    double?        carbsGoal,
    double?        fatGoal,
    double?        waterGoal,
    DateTime?      updatedAt,
    double?        weightKg,
    double?        heightCm,
    int?           age,
    Gender?        gender,
    ActivityLevel? activityLevel,
    WeightGoal?    weightGoal,
  }) {
    return NutritionGoal(
      id:            id            ?? this.id,
      calorieGoal:   calorieGoal   ?? this.calorieGoal,
      proteinGoal:   proteinGoal   ?? this.proteinGoal,
      carbsGoal:     carbsGoal     ?? this.carbsGoal,
      fatGoal:       fatGoal       ?? this.fatGoal,
      waterGoal:     waterGoal     ?? this.waterGoal,
      updatedAt:     updatedAt     ?? this.updatedAt,
      weightKg:      weightKg      ?? this.weightKg,
      heightCm:      heightCm      ?? this.heightCm,
      age:           age           ?? this.age,
      gender:        gender        ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      weightGoal:    weightGoal    ?? this.weightGoal,
    );
  }

  @override
  List<Object?> get props => [
        id, calorieGoal, proteinGoal, carbsGoal, fatGoal,
        waterGoal, updatedAt, weightKg, heightCm, age,
        gender, activityLevel, weightGoal,
      ];
}
