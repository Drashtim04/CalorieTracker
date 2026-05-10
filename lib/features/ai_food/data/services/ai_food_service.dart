import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/models/ai_meal_analysis.dart';

/// Service for interacting with the Google Gemini AI for food image analysis.
class AiFoodService {
  static const String _modelName = 'gemini-1.5-flash';

  GenerativeModel _getModel(String apiKey) {
    return GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        topK: 32,
        topP: 0.8,
        maxOutputTokens: 1024,
        responseMimeType: 'application/json',
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  /// Analyzes a food image using Gemini AI and returns structured nutritional data.
  Future<AiMealAnalysis> detectFoodFromImage(File imageFile) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      throw Exception('Gemini API key is missing. Please add it to your .env file.');
    }

    try {
      final model = _getModel(apiKey);
      final bytes = await imageFile.readAsBytes();
      final mimeType = _getMimeType(imageFile.path);

      final prompt = _buildPrompt();
      
      print('GEMINI: Sending request via official SDK (Model: $_modelName)...');
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, bytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text;

      if (text == null || text.isEmpty) {
        print('GEMINI ERROR: Empty response from AI');
        throw Exception('AI returned an empty response. Please try a different image.');
      }

      print('GEMINI RAW RESPONSE: $text');

      final cleanedContent = _cleanJsonResponse(text);
      final jsonResult = jsonDecode(cleanedContent);

      final analysis = AiMealAnalysis.fromJson(jsonResult);
      if (analysis.foods.isEmpty) {
        print('GEMINI: No foods detected in analysis result.');
        throw Exception('No food items identified. Please ensure the image is clear.');
      }
      return analysis;
    } on GenerativeAIException catch (e) {
      print('GEMINI SDK ERROR: $e');
      if (e.message.contains('429')) {
        throw Exception('Daily scan limit reached. Please try again later.');
      }
      throw Exception('Gemini AI Error: ${e.message}');
    } catch (e, st) {
      print('GEMINI EXCEPTION: $e');
      print('GEMINI STACKTRACE: $st');
      rethrow;
    }
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png': return 'image/png';
      case 'webp': return 'image/webp';
      case 'heic': return 'image/heic';
      case 'heif': return 'image/heif';
      default: return 'image/jpeg';
    }
  }

  String _buildPrompt() {
    return '''
You are an expert nutrition AI. Analyze the given meal image carefully.
Return STRICT JSON representing the nutritional analysis of the food items visible.

JSON structure:
{
  "foods": [
    {
      "name": "item name",
      "portion": "portion description",
      "calories": number,
      "protein": number,
      "carbs": number,
      "fats": number,
      "confidence": number
    }
  ],
  "nutrition": {
    "calories": number,
    "protein": number,
    "carbs": number,
    "fats": number
  },
  "insights": "short nutritional summary"
}

Guidelines:
- Identify all visible items.
- Estimate realistic serving sizes.
- Prioritize Indian and international cuisine accuracy.
- If no food is detected, return an empty "foods" list.
''';
  }

  String _cleanJsonResponse(String content) {
    var cleaned = content.trim();
    
    // Attempt to extract JSON if it's wrapped in markdown code blocks
    final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(cleaned);
    if (jsonMatch != null) {
      cleaned = jsonMatch.group(1) ?? cleaned;
    } else {
      // If no code blocks, try to find the first '{' and last '}'
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        cleaned = cleaned.substring(start, end + 1);
      }
    }
    
    return cleaned.trim();
  }
}
