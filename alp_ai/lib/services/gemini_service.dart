import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  late final GenerativeModel _model;
  String? _apiKey;

  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

    // --- REKOMENDASI PERBAIKAN ---
    // Ganti 'gemini-2.0-flash' dengan 'gemini-1.5-flash' atau 'gemini-flash-latest'.
    // Model 2.0/2.5 seringkali memiliki limit rate yang sangat kecil (misal 2-5 RPM) untuk free tier.
    // Model 1.5 Flash biasanya memberikan hingga 15 RPM (Requests Per Minute).
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey!);

    if (_apiKey!.isNotEmpty) {
      checkAvailableModels();
    } else {
      debugPrint("DEBUG GEMINI: API Key Kosong!");
    }
  }

  // Cek Daftar Model
  Future<void> checkAvailableModels() async {
    debugPrint("\n--- SEDANG MENGECEK DAFTAR MODEL KE GOOGLE... ---");
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey',
    );
    final httpClient = HttpClient();

    try {
      final request = await httpClient.getUrl(url);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody);

        debugPrint("✅ KONEKSI SUKSES! Berikut model yang tersedia:");
        if (json['models'] != null) {
          for (var model in json['models']) {
            List<dynamic> methods = model['supportedGenerationMethods'] ?? [];
            if (methods.contains('generateContent')) {
              String name = model['name'].toString().replaceFirst(
                'models/',
                '',
              );
              debugPrint("• $name");
            }
          }
        }
        debugPrint(
          "\n⚠️ CATATAN KUOTA: API Google tidak menyediakan cara untuk mengecek 'sisa kuota' lewat kode.",
        );
        debugPrint(
          "Info kuota hanya muncul di error log saat batas terlampaui (429 Resource Exhausted).",
        );
      } else {
        debugPrint("❌ GAGAL CEK MODEL. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ ERROR KONEKSI: $e");
    } finally {
      httpClient.close();
      debugPrint("--- SELESAI PENGECEKAN ---\n");
    }
  }

  Future<String> getRecyclingSteps(String wasteType) async {
    try {
      debugPrint("DEBUG GEMINI: Mengirim request untuk '$wasteType'...");

      // --- UPDATE PROMPT TO ENGLISH ---
      final prompt =
          '''
      You are a wise environmental assistant.
      I have a piece of waste identified as: "$wasteType".

      Provide the response in ENGLISH. Follow this strict format so the app can read it:

      FUN FACT:
      [Explain the ENVIRONMENTAL IMPACT of this waste informatively. 
       Example: How long does it take to decompose? What are the dangers to soil/ocean if littered? 
       Maximum 2-3 sentences.]

      HOW TO RECYCLE:
      [Provide a complete guide using a numbered list:
       1. SAFETY WARNING (if the item is sharp/toxic/dangerous).
       2. Steps to clean or prepare the waste.
       3. How to dispose of it properly or send it to a recycling center.
       4. Provide 1-2 CREATIVE IDEAS (UPCYCLING) to reuse this item at home.]

      Rules:
      - The headers "FUN FACT:" and "HOW TO RECYCLE:" MUST NOT BE CHANGED.
      - The content MUST be in English and easy to understand.
      - Use numbered list format (1., 2., etc.) for the steps.
      - Do not use bold/italic/markdown formatting.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      debugPrint("DEBUG GEMINI: Berhasil menerima respon!");
      return response.text ??
          "Sorry, could not fetch information at this time.";
    } catch (e) {
      String errorMsg = e.toString();
      debugPrint("❌ Gemini Error: $errorMsg");

      if (errorMsg.contains("429") ||
          errorMsg.toLowerCase().contains("quota")) {
        return "AI Quota Exceeded (Free Tier Limit). Please wait a moment.";
      } else if (errorMsg.contains("400") ||
          errorMsg.toLowerCase().contains("key")) {
        return "Invalid API Key. Please check your .env file.";
      } else if (errorMsg.contains("SocketException")) {
        return "No internet connection.";
      }

      return "Failed to connect to AI. Please try again later.";
    }
  }
}
