import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'YOUR_API_KEY',
  );

  Future<String> analyzeFoodImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();

    final prompt = TextPart('''
Analyze this food image and return:
- food items
- calories
- protein
- carbs
- fats

Return JSON only.
''');

    final imagePart = DataPart(
      'image/jpeg',
      imageBytes,
    );

    final response = await model.generateContent([
      Content.multi([
        prompt,
        imagePart,
      ])
    ]);

    return response.text ?? '';
  }
}