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
      
      // --- UPDATE PROMPT AGAR SESUAI KRITERIA ANDA ---
      final prompt = '''
      Kamu adalah asisten lingkungan yang bijak.
      Saya memiliki sampah yang teridentifikasi sebagai: "$wasteType".

      Berikan respons dalam BAHASA INDONESIA. Ikuti format berikut agar aplikasi dapat membacanya:

      FUN FACT:
      [Jelaskan DAMPAK LINGKUNGAN dari sampah ini secara informatif. 
       Contoh: Berapa lama terurai? Apa bahayanya bagi tanah/laut jika dibuang sembarangan? 
       Maksimal 2-3 kalimat.]

      HOW TO RECYCLE:
      [Berikan panduan lengkap berupa poin-poin:
       1. Peringatan KESELAMATAN (jika benda ini tajam/beracun/berbahaya).
       2. Langkah membersihkan atau mempersiapkan sampah tersebut.
       3. Cara menyalurkannya ke bank sampah atau tempat daur ulang.
       4. Berikan 1-2 ide KREATIF (UPCYCLING) untuk menggunakan kembali barang ini di rumah.]

      Aturan:
      - Header "FUN FACT:" dan "HOW TO RECYCLE:" JANGAN DIUBAH (Wajib Bahasa Inggris).
      - Isi konten WAJIB Bahasa Indonesia yang mudah dipahami.
      - Gunakan format list angka (1., 2., dst) pada bagian langkah.
      - Jangan gunakan bold/italic/markdown.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      debugPrint("DEBUG GEMINI: Berhasil menerima respon!");
      return response.text ?? "Maaf, tidak dapat mengambil informasi saat ini.";

    } catch (e) {
      String errorMsg = e.toString();
      debugPrint("❌ Gemini Error: $errorMsg");

      if (errorMsg.contains("429") || errorMsg.toLowerCase().contains("quota")) {
        return "Kuota AI habis. Mohon tunggu sebentar.";
      } 
      
      return "Gagal terhubung ke AI. Periksa koneksi internet Anda.";
    }
  }
}