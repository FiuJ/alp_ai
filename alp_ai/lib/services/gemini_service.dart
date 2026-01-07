import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    // 1. We keep using dotenv since your project is already set up for it
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', 
      apiKey: apiKey,
    );
  }

  // 2. We use the name 'getRecyclingSteps' because HomeViewModel calls this specific name
  Future<String> getRecyclingSteps(String wasteType) async {
    try {
      // 3. We use your new STRICT prompt logic here
      final prompt = '''
      You are a helpful eco-friendly recycling assistant.
      I have a piece of waste identified as: "$wasteType".

      Please provide a response following STRICTLY this format:

      FUN FACT:
      [Write 1 short, interesting sentence about this waste]

      HOW TO RECYCLE:
      1. [First step]
      2. [Second step]
      3. [Third step]

      Rules:
      - Do not use markdown formatting (no bolding, no italics, no #).
      - Keep the steps short and imperative.
      - Do not add any intro or outro text.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? "Could not fetch info at this time.";
    } catch (e) {
      print("Gemini Error: $e");
      return "Unable to connect to AI service. Please check your internet connection.";
    }
  }
}