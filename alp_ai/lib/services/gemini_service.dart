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
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', 
      apiKey: _apiKey!,
    );

    if (_apiKey!.isNotEmpty) {
      checkAvailableModels();
    } else {
      debugPrint("DEBUG GEMINI: API Key Kosong!");
    }
  }

  // Cek Daftar Model
  Future<void> checkAvailableModels() async {
    debugPrint("\n--- SEDANG MENGECEK DAFTAR MODEL KE GOOGLE... ---");
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey');
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
              String name = model['name'].toString().replaceFirst('models/', '');
              debugPrint("• $name");
            }
          }
        }
        debugPrint("\n⚠️ CATATAN KUOTA: API Google tidak menyediakan cara untuk mengecek 'sisa kuota' lewat kode.");
        debugPrint("Info kuota hanya muncul di error log saat batas terlampaui (429 Resource Exhausted).");
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

      debugPrint("DEBUG GEMINI: Berhasil menerima respon!");
      return response.text ?? "Could not fetch info at this time.";

    } catch (e) {
      // --- PENANGANAN ERROR KUOTA ---
      String errorMsg = e.toString();
      debugPrint("❌ Gemini Error: $errorMsg");

      if (errorMsg.contains("429") || errorMsg.toLowerCase().contains("quota")) {
        debugPrint("⚠️ KUOTA HABIS (Rate Limit Exceeded). Coba ganti model di kode ke 'gemini-1.5-flash'.");
        return "Kuota AI habis (Limit Free Tier). Tunggu 1 menit atau ganti API Key.";
      } 
      else if (errorMsg.contains("400") || errorMsg.toLowerCase().contains("key")) {
        return "API Key Salah/Tidak Valid. Cek .env Anda.";
      }
      else if (errorMsg.contains("SocketException")) {
        return "Tidak ada koneksi internet.";
      }

      return "Gagal terhubung ke AI. Coba lagi nanti.";
    }
  }
}