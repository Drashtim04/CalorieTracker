class AiFoodItem {
  AiFoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.quantity,
  });

  String name;
  double calories;
  double protein;
  double carbs;
  double fats;
  double quantity;

  factory AiFoodItem.fromJson(Map<String, dynamic> json) {
    return AiFoodItem(
      name: json['name'] as String? ?? 'Unknown Food',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'quantity': quantity,
    };
  }
}
