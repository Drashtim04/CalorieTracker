class FoodItem {
  FoodItem({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.confidence,
  });

  String name;
  String portion;
  double calories;
  double protein;
  double carbs;
  double fats;
  double? confidence;

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String? ?? 'Unknown',
      portion: json['portion'] as String? ?? '1 portion',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'portion': portion,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'confidence': confidence,
    };
  }
}

class NutritionInfo {
  NutritionInfo({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });

  double totalCalories;
  double totalProtein;
  double totalCarbs;
  double totalFats;

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      totalCalories: (json['calories'] as num?)?.toDouble() ?? (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['protein'] as num?)?.toDouble() ?? (json['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['carbs'] as num?)?.toDouble() ?? (json['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFats: (json['fats'] as num?)?.toDouble() ?? (json['totalFats'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AiMealAnalysis {
  AiMealAnalysis({
    required this.foods,
    required this.nutrition,
    required this.insights,
  });

  List<FoodItem> foods;
  NutritionInfo nutrition;
  String insights;

  factory AiMealAnalysis.fromJson(Map<String, dynamic> json) {
    final foodsList = json['foods'] as List<dynamic>? ?? [];
    
    String parsedInsights = '';
    if (json['insights'] is List) {
      parsedInsights = (json['insights'] as List).join(' ');
    } else {
      parsedInsights = json['insights'] as String? ?? '';
    }

    return AiMealAnalysis(
      foods: foodsList.map((e) => FoodItem.fromJson(e)).toList(),
      nutrition: NutritionInfo.fromJson(json['nutrition'] ?? {}),
      insights: parsedInsights,
    );
  }
}
