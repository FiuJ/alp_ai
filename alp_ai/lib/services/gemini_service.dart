import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<String> getRecyclingSteps(String category) async {
    final prompt = "Provide a step-by-step recycling guide for $category waste. "
        "Include safety tips and creative reuse ideas. Format it clearly.";
    
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? "No recommendations available.";
  }
}